package main

import "testing"

var result int64

func BenchmarkCoGoCall(b *testing.B) {
	for i := 0; i < b.N; i++ {
		result += callDoNothing(int64(i))
	}
}
