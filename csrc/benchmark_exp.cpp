#include <cmath>
#include <random>

#include "benchmark/benchmark.h"

// Benchmark the performance of std::expf applied to float32 values.
static void BM_Expf(benchmark::State &state) {
  // Benchmark the function.
  for (auto _ : state) {
    benchmark::DoNotOptimize(std::expf(state.range(0)));
  }
}
BENCHMARK(BM_Expf)->Range(-20, 20);
BENCHMARK_MAIN();
