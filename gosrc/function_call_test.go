package bench

import "testing"

//go:noinline
func sumNoInline(a, b, c, d int) int {
	return a + b + c + d
}

func sumInline(a, b, c, d int) int {
	return a + b + c + d
}

var Result int

func BenchmarkFunctionCallNoInline(b *testing.B) {
	tmp := 0
	for i := 0; i < b.N; i++ {
		tmp += sumNoInline(24, i, 1024, 70)
	}
	Result = tmp
}

func BenchmarkFunctionCallInline(b *testing.B) {
	tmp := 0
	for i := 0; i < b.N; i++ {
		tmp += sumInline(24, i, 1024, 70)
	}
	Result = tmp
}
