#!/usr/bin/env bash
# One-command bootstrap for a fresh clone, on any machine.
# Installs nothing without asking; discovers what is already here.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PAPERTEX_ROOT/.env"
ENV_EXAMPLE="$PAPERTEX_ROOT/.env.example"
ASSUME_YES=false

# shellcheck source=lib/discover.sh
source "$PAPERTEX_ROOT/scripts/lib/discover.sh"

usage() {
	cat <<EOF
Usage: $0 [-y]

Bootstraps PaperTeX on this machine:
  1. checks or installs uv
  2. installs Python 3.13 and syncs backend dependencies
  3. creates .env from .env.example if absent
  4. discovers the local toolchain and records what it finds
  5. prints the compile providers available here

Safe to re-run. Never overwrites an existing .env value.

Options:
	-y, --yes    Do not prompt; install uv automatically if missing
	-h, --help   Show this message
EOF
}

while [[ ${#} -gt 0 ]]; do
	case "$1" in
		-y|--yes) ASSUME_YES=true; shift ;;
		-h|--help) usage; exit 0 ;;
		*) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
	esac
done

step() { printf '\n==> %s\n' "$1"; }

confirm() {
	$ASSUME_YES && return 0
	read -r -p "$1 [y/N] " reply
	[[ "$reply" =~ ^[Yy]$ ]]
}

set_env_value() {
	# set_env_value KEY VALUE -- only fills an empty or absent key
	local key="$1" value="$2" current
	current="$(grep -E "^${key}=" "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2- || true)"
	if [[ -n "$current" ]]; then
		echo "    $key already set, leaving it alone"
		return 0
	fi
	if grep -qE "^${key}=" "$ENV_FILE"; then
		# Portable in-place edit: no sed -i, which differs on macOS.
		local tmp
		tmp="$(mktemp)"
		awk -v k="$key" -v v="$value" \
			'BEGIN{FS=OFS="="} $1==k {print k "=" v; next} {print}' \
			"$ENV_FILE" > "$tmp"
		mv "$tmp" "$ENV_FILE"
	else
		printf '%s=%s\n' "$key" "$value" >> "$ENV_FILE"
	fi
	echo "    $key=$value"
}

step "Platform"
echo "    $(detect_platform)"

step "uv"
if command -v uv >/dev/null 2>&1; then
	echo "    found: $(uv --version)"
else
	echo "    uv is not installed."
	if confirm "    Install uv from https://astral.sh/uv ?"; then
		curl -LsSf https://astral.sh/uv/install.sh | sh
		export PATH="$HOME/.local/bin:$PATH"
	else
		echo "    Skipped. Install uv and re-run this script." >&2
		exit 1
	fi
fi

step "Python and backend dependencies"
uv python install 3.13
uv sync --project "$PAPERTEX_ROOT/backend"

step "Environment file"
if [[ -f "$ENV_FILE" ]]; then
	echo "    $ENV_FILE already exists, keeping it"
else
	cp "$ENV_EXAMPLE" "$ENV_FILE"
	echo "    created $ENV_FILE from .env.example"
fi

set -a; source "$ENV_FILE"; set +a

step "Installation token"
if [[ -z "${PAPERTEX_TOKEN:-}" ]]; then
	token="$(uv run --project "$PAPERTEX_ROOT/backend" python -c \
		'import secrets; print(secrets.token_urlsafe(32))')"
	set_env_value PAPERTEX_TOKEN "$token"
else
	echo "    PAPERTEX_TOKEN already set, leaving it alone"
fi

step "Compile providers"
echo "    browser (wasm)   available -- no install needed, this is the default"

if discover_docker; then
	echo "    bridge (docker)  available at $DISCOVERED_DOCKER"
	echo "                     run: docker compose -f docker/texlive_container.yaml up -d"
else
	echo "    bridge (docker)  docker not available (optional)"
fi

if discover_tex; then
	echo "    native ($DISCOVERED_TEX_KIND)   $DISCOVERED_TEX_BIN"
	set_env_value TEX_BIN_PATH "$DISCOVERED_TEX_BIN"
else
	echo "    native           no local TeX found (optional)"
fi

step "Done"
cat <<EOF
PaperTeX is ready to compile with the browser provider on this machine.

Next:
    ./scripts/backend/preflight_toolchain.sh    review what is available
    ./scripts/backend/runserver.sh              start the local backend
    ./scripts/frontend/dev.sh                   start the frontend on :5174
EOF
