#include "benchmark/benchmark.h"

float __attribute__((noinline)) doAbcd(float a, float b, float c, float d) {
  return (a * b) + (c * d);
}

float a = 1.0f;
float b = 1.0f;
float c = 1.0f;
float d = 1.0f;

static void BM_ABCD(benchmark::State &state) {
  for (auto _ : state) {
    benchmark::DoNotOptimize(doAbcd(a, b, c, d));
  }
}

BENCHMARK(BM_ABCD);
BENCHMARK_MAIN();
