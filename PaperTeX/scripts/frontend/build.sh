#!/usr/bin/env bash
# Type-check and build the PaperTeX frontend.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
	cat <<EOF
Usage: $0 [-h]

Type-check and build the PaperTeX frontend.

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
#   npm --prefix "$PAPERTEX_ROOT/frontend" run type-check
#   npm --prefix "$PAPERTEX_ROOT/frontend" run build
echo "$(basename "$0"): not implemented yet" >&2
exit 1
