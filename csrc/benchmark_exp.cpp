#include "fast_exp.h"
#include <cmath>
#include <random>

#include "benchmark/benchmark.h"

float_t expfp32(float_t x) { return std::exp(x); }

// Benchmark the performance of std::exp applied to float32 values.
static void BM_Expf(benchmark::State &state) {
  // Benchmark the function.
  for (auto _ : state) {
    benchmark::DoNotOptimize(expfp32(state.range(0)));
  }
}

// Benchmark an approximation of std::exp applied to float32 values.
static void BM_ExpfApprox(benchmark::State &state) {
  // Benchmark the function.
  for (auto _ : state) {
    benchmark::DoNotOptimize(fastExp(state.range(0)));
  }
}

BENCHMARK(BM_ExpfApprox)->Range(-20, 20);
BENCHMARK(BM_Expf)->Range(-20, 20);
BENCHMARK_MAIN();
