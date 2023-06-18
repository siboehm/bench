#include <cmath>
#include <random>

#include "benchmark/benchmark.h"

float_t abcd(float a, float b, float c, float d) { return (a * b) + (c * d); }

static void BM_ABCD(benchmark::State &state) {
  for (auto _ : state) {
    float_t x = static_cast<float_t>(state.range(0));
    benchmark::DoNotOptimize(abcd(x, x, x, x));
  }
}

BENCHMARK(BM_ABCD)->Range(1, 1);
BENCHMARK_MAIN();
