#!/usr/bin/env bash
set -euo pipefail
mkdir -p /app/output
python3 "$(dirname "$0")/oracle.py"
