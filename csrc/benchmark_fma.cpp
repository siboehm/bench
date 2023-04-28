#include <cmath>
#include <random>

#include "benchmark/benchmark.h"

// TODO: make sure this actually works
float_t no_fma(float_t x) {
  float_t y = x * x;
  return 1 + y;
}

float_t with_fma(float_t x) { return std::fma(x, x, 1); }

static void BM_NoFMA(benchmark::State &state) {
  for (auto _ : state) {
    float_t x = static_cast<float_t>(state.range(0));
    benchmark::DoNotOptimize(no_fma(x));
  }
}

static void BM_WithFMA(benchmark::State &state) {
  for (auto _ : state) {
    float_t x = static_cast<float_t>(state.range(0));
    benchmark::DoNotOptimize(with_fma(x));
  }
}

BENCHMARK(BM_NoFMA)->Range(-20, 20);
BENCHMARK(BM_WithFMA)->Range(-20, 20);
BENCHMARK_MAIN();
