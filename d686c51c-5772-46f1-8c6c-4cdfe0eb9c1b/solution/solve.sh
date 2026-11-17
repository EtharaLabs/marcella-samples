#!/usr/bin/env bash
set -euo pipefail
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
here="$(cd "$(dirname "$0")" && pwd)"
mkdir -p /app/output
python3 "$here/oracle.py" /data /app/output/periods.csv
cp "$here/method.md" /app/method.md
