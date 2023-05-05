#include <benchmark/benchmark.h>

// The function to be benchmarked
float __attribute__((noinline)) someFunctionNoInline(float a) { return 1 / a; }

float a = 10;
float b = 20;
float result;

// Benchmark definition
static void BM_someFunction(benchmark::State &state) {
  for (auto _ : state) {
    float x = static_cast<float>(state.range(0));
    result += -x;
  }
}

// Benchmark definition
static void BM_someFunctionNoInline(benchmark::State &state) {
  for (auto _ : state) {
    float x = static_cast<float>(state.range(0));
    result += someFunctionNoInline(x);
  }
}

// Register the benchmark
BENCHMARK(BM_someFunction)->Range(8, 8 << 10);
BENCHMARK(BM_someFunctionNoInline)->Range(8, 8 << 10);

// Main function
BENCHMARK_MAIN();