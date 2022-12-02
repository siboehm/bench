package bench

import "testing"

type Sequential struct {
	a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 int32
	b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15 int32
	c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15 int32
	d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15 int32
}

type NonSequential struct {
	b0, c0, a0, d0     int32
	b14, c14, a14, d14 int32
	b3, c3, a3, d3     int32
	b12, c12, a12, d12 int32
	b4, c4, a4, d4     int32
	c10, a10, b10, d10 int32
	c7, a7, b7, d7     int32
	c9, a9, b9, d9     int32
	c6, a6, b6, d6     int32
	c8, a8, b8, d8     int32
	c11, a11, b11, d11 int32
	b5, c5, a5, d5     int32
	b13, c13, a13, d13 int32
	b2, c2, a2, d2     int32
	b15, c15, a15, d15 int32
	b1, c1, a1, d1     int32
}

// 4 * 16 * 4B = 256B per struct. 4 structs are 1KB, and we create 4MB of them.
const sliceLen = 4 * 1024 * 4 * 1024

//go:noinline
func sumAsSequential(s Sequential) int32 {
	return s.a0 + s.a1 + s.a2 + s.a3 + s.a4 + s.a5 + s.a6 + s.a7 + s.a8 + s.a9 + s.a10 + s.a11 + s.a12 + s.a13 + s.a14 + s.a15
}

//go:noinline
func sumAsNonSequential(s NonSequential) int32 {
	return s.a0 + s.a1 + s.a2 + s.a3 + s.a4 + s.a5 + s.a6 + s.a7 + s.a8 + s.a9 + s.a10 + s.a11 + s.a12 + s.a13 + s.a14 + s.a15
}

//go:noinline
func sumBsSequential(s Sequential) int32 {
	return s.b0 + s.b1 + s.b2 + s.b3 + s.b4 + s.b5 + s.b6 + s.b7 + s.b8 + s.b9 + s.b10 + s.b11 + s.b12 + s.b13 + s.b14 + s.b15
}

//go:noinline
func sumBsNonSequential(s NonSequential) int32 {
	return s.b0 + s.b1 + s.b2 + s.b3 + s.b4 + s.b5 + s.b6 + s.b7 + s.b8 + s.b9 + s.b10 + s.b11 + s.b12 + s.b13 + s.b14 + s.b15
}

//go:noinline
func sumCsSequential(s Sequential) int32 {
	return s.c0 + s.c1 + s.c2 + s.c3 + s.c4 + s.c5 + s.c6 + s.c7 + s.c8 + s.c9 + s.c10 + s.c11 + s.c12 + s.c13 + s.c14 + s.c15
}

//go:noinline
func sumCsNonSequential(s NonSequential) int32 {
	return s.c0 + s.c1 + s.c2 + s.c3 + s.c4 + s.c5 + s.c6 + s.c7 + s.c8 + s.c9 + s.c10 + s.c11 + s.c12 + s.c13 + s.c14 + s.c15
}

//go:noinline
func sumDsSequential(s Sequential) int32 {
	return s.d0 + s.d1 + s.d2 + s.d3 + s.d4 + s.d5 + s.d6 + s.d7 + s.d8 + s.d9 + s.d10 + s.d11 + s.d12 + s.d13 + s.d14 + s.d15
}

//go:noinline
func sumDsNonSequential(s NonSequential) int32 {
	return s.d0 + s.d1 + s.d2 + s.d3 + s.d4 + s.d5 + s.d6 + s.d7 + s.d8 + s.d9 + s.d10 + s.d11 + s.d12 + s.d13 + s.d14 + s.d15
}

var ResultInt32 int32

func BenchmarkStructAccessSequential(b *testing.B) {
	alignedSlice := make([]Sequential, sliceLen)
	tmp := int32(0)
	for i := 0; i < b.N; i++ {
		for j := 0; j < sliceLen; j++ {
			tmp += sumAsSequential(alignedSlice[j])
			tmp += sumBsSequential(alignedSlice[j])
			tmp += sumCsSequential(alignedSlice[j])
			tmp += sumDsSequential(alignedSlice[j])
		}
	}
	ResultInt32 += tmp
}

func BenchmarkStructAccessNonSequential(b *testing.B) {
	unalignedSlice := make([]NonSequential, sliceLen)
	tmp := int32(0)
	for i := 0; i < b.N; i++ {
		for j := 0; j < sliceLen; j++ {
			tmp += sumAsNonSequential(unalignedSlice[j])
			tmp += sumBsNonSequential(unalignedSlice[j])
			tmp += sumCsNonSequential(unalignedSlice[j])
			tmp += sumDsNonSequential(unalignedSlice[j])
		}
	}
	ResultInt32 += tmp
}
