#!/usr/bin/env bash

set -euox pipefail

NUM_CORES=$(lscpu | grep '^CPU(s):' | awk '{print $2}')
NUM_CORES=$((NUM_CORES / 2))

mpirun --version
echo ""

# power of two
for ((i=2; 2**i<=NUM_CORES; i++)); do
    CORES=$((2**i))
    echo "Running with $CORES cores"
    mpirun -np $CORES --bind-to core ./build/mpi_benchmark
    echo ""
done