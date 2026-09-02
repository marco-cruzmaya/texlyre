#!/usr/bin/env bash
# Checks that every tool PaperTeX needs is reachable from this WSL shell.
# Reports honestly and exits non-zero if anything required is missing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$PAPERTEX_ROOT/.env"

usage() {
	cat <<EOF
Usage: $0 [-e env-file]

Verifies uv, Python 3.13, Node, Git and the MiKTeX executables reachable
through WSL interop.

Defaults to: $ENV_FILE

Options:
	-e, --env    Path to the .env file to read MIKTEX_BIN_PATH from
	-h, --help   Show this message
EOF
}

while [[ ${#} -gt 0 ]]; do
	case "$1" in
		-e|--env)
			shift
			ENV_FILE="$1"
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1" >&2
			usage >&2
			exit 2
			;;
	esac
done

FAILURES=0

report() {
	# report <status> <label> <detail>
	printf '%-8s %-24s %s\n' "$1" "$2" "${3:-}"
}

check_command() {
	# check_command <binary> <label> <required|optional>
	local bin="$1" label="$2" mode="$3" path
	if path="$(command -v "$bin" 2>/dev/null)"; then
		report "OK" "$label" "$path"
	elif [[ "$mode" == "optional" ]]; then
		report "SKIP" "$label" "not installed (optional)"
	else
		report "MISSING" "$label" "install it before continuing"
		FAILURES=$((FAILURES + 1))
	fi
}

echo "PaperTeX toolchain preflight"
echo "root: $PAPERTEX_ROOT"
echo

echo "-- core tools --"
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
	report "SKIP" "python 3.13" "uv is required to check this"
fi

echo
echo "-- latex --"
if [[ -f "$ENV_FILE" ]]; then
	# shellcheck disable=SC1090
	set -a; source "$ENV_FILE"; set +a
	report "OK" "env file" "$ENV_FILE"
else
	report "MISSING" "env file" "copy .env.example to .env"
	FAILURES=$((FAILURES + 1))
fi

if [[ -n "${MIKTEX_BIN_PATH:-}" ]]; then
	MIKTEX_OK=1
	for exe in pdflatex.exe xelatex.exe lualatex.exe latexmk.exe biber.exe bibtex.exe mpm.exe; do
		if [[ ! -x "$MIKTEX_BIN_PATH/$exe" ]]; then
			report "MISSING" "miktex $exe" "not executable at MIKTEX_BIN_PATH"
			MIKTEX_OK=0
			FAILURES=$((FAILURES + 1))
		fi
	done
	if [[ $MIKTEX_OK -eq 1 ]]; then
		version="$("$MIKTEX_BIN_PATH/pdflatex.exe" --version 2>/dev/null | head -1 || true)"
		report "OK" "miktex" "${version:-reachable} "
	fi
else
	report "MISSING" "MIKTEX_BIN_PATH" "set it in $ENV_FILE"
	FAILURES=$((FAILURES + 1))
fi

if [[ -n "${TEXLIVE_BIN_PATH:-}" ]]; then
	check_command "$TEXLIVE_BIN_PATH/latexmk" "texlive latexmk" optional
else
	report "SKIP" "texlive" "future provider, not configured"
fi

echo
echo "-- lsp --"
check_command texlab "texlab" optional

echo
if [[ $FAILURES -gt 0 ]]; then
	echo "preflight failed: $FAILURES required item(s) missing" >&2
	exit 1
fi
echo "preflight passed"
