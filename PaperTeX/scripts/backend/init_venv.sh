#!/usr/bin/env bash
# Create the backend virtualenv and install dependencies with uv.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAPERTEX_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
	cat <<EOF
Usage: $0 [-h]

Create the backend virtualenv and install dependencies with uv.

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
#   uv sync --project "$PAPERTEX_ROOT/backend"
#   uses backend/.python-version (3.13) and backend/pyproject.toml
#   commits the resulting backend/uv.lock
echo "$(basename "$0"): not implemented yet" >&2
exit 1
