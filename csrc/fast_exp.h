#include <cmath>

// based on https://github.com/goki/mat32/blob/master/fastexp.go
float fastExp(float x) {
  // should probably add proper handling of infinities and NaNs, I bet
  // with branch prediction there's basically no penalty to it
  if (x <= -88.76731) {
    return 0.0;
  }
  int32_t i = int32_t(12102203 * x) + 127 * (1 << 23);
  int32_t m = i >> 7 & 0xFFFF; // copy mantissa
  i += ((((((((((3537 * m) >> 16) + 13668) * m) >> 18) + 15817) * m) >> 14) -
         80470) *
        m) >>
       11;
  return *reinterpret_cast<float *>(&i);
}