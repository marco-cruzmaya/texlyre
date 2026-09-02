#!/usr/bin/env bash
# Restore the local SQLite database from a backup file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
	cat <<EOF
Usage: $0 [-h]

Restore the local SQLite database from a backup file.

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
#   takes a backup path, stops the server, replaces $PAPERTEX_DB_PATH
#   refuses to run without an explicit backup argument
echo "$(basename "$0"): not implemented yet" >&2
exit 1
