
#include "fast_exp.h"
#include <cassert>
#include <iostream>
#include <vdtMath.h>

void test_exp() {
  for (float x = -87.0; x < 88.43; x += 0.01) {
    float se = std::exp(x);
    float fe = fastExp(x);
    assert(std::abs((se - fe) / se) < 1.1e-5);
  }
}

void test_vdt_exp() {
  float maxDiff = 0.0;
  for (float x = -87.0; x < 88.00; x += 0.01) {
    float se = std::exp(x);
    float fe = vdt::fast_expf(x);
    maxDiff = std::max(maxDiff, std::abs((se - fe) / se));
    assert(std::abs((se - fe) / se) < 1.1e-5);
  }
}

int main() {
  test_exp();
  test_vdt_exp();
  return 0;
}