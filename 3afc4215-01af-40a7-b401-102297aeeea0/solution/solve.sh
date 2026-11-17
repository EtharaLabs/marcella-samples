#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp "$here/method.md" /app/method.md
mkdir -p /app/output
python3 "$here/oracle.py" --data /data --out /app/output/reflector_positions.csv
