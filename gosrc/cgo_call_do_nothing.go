package main

/*
#include <stdint.h>

int64_t doNothing(int64_t i) {
	return i + i;
}
*/
import "C"

func callDoNothing(i int64) int64 {
	val, _ := C.doNothing(C.longlong(i))
	return int64(val)
}
