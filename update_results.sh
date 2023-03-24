#!/usr/bin/env bash

set -euo pipefail

resultfile=$(realpath results.txt)
printf 'Results file: %s\n\n' "$resultfile"
printf 'BENCH RESULTS\n\n' > "$resultfile"

if command -v lscpu; then
	lscpu >> $resultfile
fi

pushd gosrc
printf '\n\nGOSRC BENCHMARK RESULTS\n\n' >> "$resultfile"
go test -bench=. | tee -a "$resultfile"

printf '\n\nBANDWIDTH BENCHMARK RESULTS\n\n' >> "$resultfile"
go run bandwidth.go | tee -a "$resultfile"
popd

printf '\n\nC BENCHMARK RESULTS\n\n' >> "$resultfile"
pushd csrc
mkdir -p build
pushd build && cmake .. && make
./bench_exp | tee -a "$resultfile"
mpirun -np 2 --bind-to core ./mpi_benchmark | tee -a "$resultfile"
mpirun -np 4 --bind-to core ./mpi_benchmark | tee -a "$resultfile"
mpirun -np 8 --bind-to core ./mpi_benchmark | tee -a "$resultfile"
popd && popd
