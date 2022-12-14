package main

import (
	"sync/atomic"
	"testing"
)

//go:noinline
func addToNoAtomic(a *int64, b int64) {
	*a += b
}

//go:noinline
func addToAtomic(a *int64, b int64) {
	atomic.AddInt64(a, b)
}

var Res int64

func BenchmarkNoAtomic(b *testing.B) {
	for i := 0; i < b.N; i++ {
		addToNoAtomic(&Res, 1)
	}
}

func BenchmarkAtomic(b *testing.B) {
	for i := 0; i < b.N; i++ {
		addToAtomic(&Res, 1)
	}
}
