#!/usr/bin/env bash

set -euo pipefail

resultfile=$(realpath results.txt)
printf 'Results file: %s\n\n' "$resultfile"

pushd gosrc
printf 'GOSRC BENCHMARK RESULTS\n\n' > "$resultfile"
go test -bench=. | tee -a "$resultfile"

printf 'BANDWIDTH BENCHMARK RESULTS\n\n' >> "$resultfile"
go run bandwidth.go | tee -a "$resultfile"
popd

printf 'C BENCHMARK RESULTS\n\n' >> "$resultfile"
pushd csrc
mkdir -p build
pushd build && cmake .. && make
./bench_exp | tee -a "$resultfile"
popd && popd