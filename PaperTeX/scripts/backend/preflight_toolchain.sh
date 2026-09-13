#!/usr/bin/env bash
# Reports what PaperTeX can use on this machine. Only git, node and uv are
# required: LaTeX is optional because the browser WASM provider always works.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PAPERTEX_ROOT/.env"

# shellcheck source=../lib/discover.sh
source "$PAPERTEX_ROOT/scripts/lib/discover.sh"

usage() {
	cat <<EOF
Usage: $0 [-e env-file]

Reports the available toolchain: required tools, and which of the three
compile providers (browser, bridge, native) this machine can offer.

Defaults to: $ENV_FILE

Options:
	-e, --env    Path to the .env file to read overrides from
	-h, --help   Show this message
EOF
}

while [[ ${#} -gt 0 ]]; do
	case "$1" in
		-e|--env) shift; ENV_FILE="$1"; shift ;;
		-h|--help) usage; exit 0 ;;
		*) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
	esac
done

FAILURES=0

report() { printf '%-8s %-22s %s\n' "$1" "$2" "${3:-}"; }

check_command() {
	local bin="$1" label="$2" mode="$3" path
	if path="$(command -v "$bin" 2>/dev/null)"; then
		report "OK" "$label" "$path"
	elif [[ "$mode" == "optional" ]]; then
		report "SKIP" "$label" "not installed (optional)"
	else
		report "MISSING" "$label" "required"
		FAILURES=$((FAILURES + 1))
	fi
}

if [[ -f "$ENV_FILE" ]]; then
	set -a; source "$ENV_FILE"; set +a
fi

echo "PaperTeX toolchain"
echo "root:     $PAPERTEX_ROOT"
echo "platform: $(detect_platform)"
echo

echo "-- required --"
check_command git "git" required
check_command node "node" required
check_command npm "npm" required
check_command uv "uv" required

echo
echo "-- python --"
if command -v uv >/dev/null 2>&1; then
	if uv python find 3.13 >/dev/null 2>&1; then
		report "OK" "python 3.13" "$(uv python find 3.13)"
	else
		report "MISSING" "python 3.13" "run: uv python install 3.13"
		FAILURES=$((FAILURES + 1))
	fi
else
	report "SKIP" "python 3.13" "needs uv"
fi

echo
echo "-- compile providers --"
report "OK" "browser (wasm)" "always available, no install needed"

if discover_docker; then
	report "OK" "bridge (docker)" "$DISCOVERED_DOCKER"
else
	report "SKIP" "bridge (docker)" "docker unavailable; optional"
fi

if [[ -n "${TYPESETTER_BRIDGE_URL:-}" ]]; then
	report "INFO" "bridge (url)" "$TYPESETTER_BRIDGE_URL"
fi

if discover_tex; then
	report "OK" "native ($DISCOVERED_TEX_KIND)" "$DISCOVERED_TEX_BIN"
	version="$(tex_version_string "$DISCOVERED_TEX_BIN" "$DISCOVERED_TEX_KIND" || true)"
	[[ -n "$version" ]] && report "" "" "$version"
else
	report "SKIP" "native (local tex)" "no local TeX found; optional"
fi

echo
echo "-- lsp --"
if [[ -n "${TEXLAB_BRIDGE_URL:-}" ]]; then
	report "INFO" "texlab (bridge)" "$TEXLAB_BRIDGE_URL"
fi
check_command texlab "texlab (native)" optional

echo
if [[ $FAILURES -gt 0 ]]; then
	echo "preflight failed: $FAILURES required item(s) missing" >&2
	exit 1
fi
echo "preflight passed"
