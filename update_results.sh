#!/usr/bin/env bash

set -euo pipefail

resultfile=$(realpath results.txt)
printf 'Results file: %s\n\n' "$resultfile"

pushd gosrc
printf 'GOSRC BENCHMARK RESULTS\n\n' > "$resultfile"
go test -bench=. | tee -a "$resultfile"
popd
