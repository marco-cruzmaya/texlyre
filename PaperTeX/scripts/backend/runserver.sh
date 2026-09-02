#!/usr/bin/env bash
# Run the Django ASGI server bound to loopback.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
	cat <<EOF
Usage: $0 [-h]

Run the Django ASGI server bound to loopback.

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
#   uv run --project "$PAPERTEX_ROOT/backend" manage.py runserver \
#     "$PAPERTEX_HOST:$PAPERTEX_PORT"
#   reads PAPERTEX_HOST and PAPERTEX_PORT from PaperTeX/.env
echo "$(basename "$0"): not implemented yet" >&2
exit 1
