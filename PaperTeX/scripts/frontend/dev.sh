#!/usr/bin/env bash
# Start the PaperTeX Vite dev server on port 5174.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
	cat <<EOF
Usage: $0 [-h]

Start the PaperTeX Vite dev server on port 5174.

Options:
	-h, --help   Show this message
EOF
}

while [[ ${#} -gt 0 ]]; do
	case "$1" in
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

# TODO: not implemented yet. Planned behavior:
#   npm --prefix "$PAPERTEX_ROOT/frontend" run dev -- --port 5174
#   5173 belongs to the upstream TeXlyre dev server; both may run at once
echo "$(basename "$0"): not implemented yet" >&2
exit 1
