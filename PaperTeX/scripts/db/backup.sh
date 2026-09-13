#!/usr/bin/env bash
# Back up the local SQLite database into db/backups/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
	cat <<EOF
Usage: $0 [-h]

Back up the local SQLite database into db/backups/.

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
#   sqlite3 "$PAPERTEX_DB_PATH" ".backup db/backups/papertex_$(date +%Y%m%d_%H%M%S).sqlite3"
#   backups hold real research data and are gitignored
echo "$(basename "$0"): not implemented yet" >&2
exit 1
