
#include "fast_exp.h"
#include <cassert>
#include <iostream>

void test_exp() {
  for (float x = -87.0; x < 88.43; x += 0.01) {
    float se = std::exp(x);
    float fe = fastExp(x);
    assert(std::abs((se - fe) / se) < 1.1e-5);
  }
}

int main() {
  test_exp();
  return 0;
}