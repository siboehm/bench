#include <benchmark/benchmark.h>

float __attribute__((noinline)) someFunctionNoInline(float a) { return -a; }

/*
Considerations:
- Cannot use int accumulator, bc the compiler will vectorize (associativity is
given)
- Accumulate happens in reg, writes to memory at the end
*/

float a = 10;
float result;

static void BM_someFunction(benchmark::State &state) {
  for (auto _ : state) {
    result += -a;
  }
}

static void BM_someFunctionNoInline(benchmark::State &state) {
  for (auto _ : state) {
    result += someFunctionNoInline(a);
  }
}

BENCHMARK(BM_someFunction);
BENCHMARK(BM_someFunctionNoInline);

BENCHMARK_MAIN();