#!/usr/bin/env bash
# Apply Django migrations to the local SQLite database.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
	cat <<EOF
Usage: $0 [-h]

Apply Django migrations to the local SQLite database.

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
#   uv run --project "$PAPERTEX_ROOT/backend" manage.py migrate
#   enables WAL mode on first run
echo "$(basename "$0"): not implemented yet" >&2
exit 1
