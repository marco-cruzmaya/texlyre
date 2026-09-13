#!/usr/bin/env bash
# Delete and recreate the local SQLite database.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
	cat <<EOF
Usage: $0 [-h]

Delete and recreate the local SQLite database.

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
#   backs up first, deletes $PAPERTEX_DB_PATH, then runs backend/migrate.sh
#   destroys local installation state: sessions, annotations, provenance
echo "$(basename "$0"): not implemented yet" >&2
exit 1
