#include <random>

#include "benchmark/benchmark.h"

__attribute__((noinline)) float_t no_fma(float x) {
  // clang defaults to -ffp-contract=on (fuse inside the same statement)
  // hence separate the statements to avoid fma
  // -ffast-math enables -ffp-contract=fast (fuse across statements)
  float_t y = x * x;
  return 1.0f + y;
}

__attribute__((noinline)) float_t with_fma(float x) { return x * x + 1.0f; }

float val = 0.1;

static void BM_NoFMA(benchmark::State &state) {
  for (auto _ : state) {
    benchmark::DoNotOptimize(val = no_fma(val));
  }
}

static void BM_WithFMA(benchmark::State &state) {
  for (auto _ : state) {
    benchmark::DoNotOptimize(val = with_fma(val));
  }
}

BENCHMARK(BM_NoFMA);
BENCHMARK(BM_WithFMA);
BENCHMARK_MAIN();
