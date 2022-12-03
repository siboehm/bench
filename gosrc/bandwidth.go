package main

import (
	"fmt"
	"sync"
	"testing"
)

var ResultInt64 int64

const size = 1 << 26

func BenchmarkBandwidthSingleThread(b *testing.B) {
	array := make([]int64, size)

	for i := range array {
		array[i] = int64(i) + ResultInt64
	}

	b.ResetTimer()

	tmp := int64(0)
	for i := 0; i < b.N; i++ {
		for j := 0; j < len(array); j += 1 {
			tmp += array[j]
		}
	}
}

func benchmarkBandwidthMultiThread(b *testing.B, thread int) {
	numGoroutines := thread

	array := make([]int64, size)

	for i := range array {
		array[i] = int64(i) + ResultInt64
	}
	resultsInterim := make([]int64, numGoroutines)
	chunkSize := len(array) / numGoroutines

	b.ResetTimer()

	for j := 0; j < b.N; j++ {
		var wg sync.WaitGroup
		wg.Add(numGoroutines)
		for i := 0; i < numGoroutines; i++ {
			go func(i int) {
				start := i * chunkSize
				end := start + chunkSize

				if end > len(array) {
					end = len(array)
				}

				tmp := int64(0)
				for j := start; j < end; j += 1 {
					tmp += array[j]
				}
				resultsInterim[i] = tmp
				wg.Done()
			}(i)
		}
		wg.Wait()

		for _, v := range resultsInterim {
			ResultInt64 += v
		}
	}
}

func BenchmarkBandwidth1Thread(b *testing.B) {
	benchmarkBandwidthMultiThread(b, 1)
}

func BenchmarkBandwidth2Thread(b *testing.B) {
	benchmarkBandwidthMultiThread(b, 2)
}

func BenchmarkBandwidth4Thread(b *testing.B) {
	benchmarkBandwidthMultiThread(b, 4)
}

func BenchmarkBandwidth8Thread(b *testing.B) {
	benchmarkBandwidthMultiThread(b, 8)
}

func BenchmarkBandwidth10Thread(b *testing.B) {
	benchmarkBandwidthMultiThread(b, 10)
}

func main() {
	// calculate final bandwidth
	sizeInBytes := int64(size) * 8
	fmt.Printf("Size of array: %.2fGB\n", float64(sizeInBytes)/1e9)
	println("Bandwidth in GB/s:")
	res := testing.Benchmark(BenchmarkBandwidth1Thread)
	oneThreadBandwidth := sizeInBytes / res.NsPerOp()
	println("1 thread:", oneThreadBandwidth)
	res = testing.Benchmark(BenchmarkBandwidth2Thread)
	twoThreadBandwidth := sizeInBytes / res.NsPerOp()
	println("2 threads:", twoThreadBandwidth)
	res = testing.Benchmark(BenchmarkBandwidth4Thread)
	fourThreadBandwidth := sizeInBytes / res.NsPerOp()
	println("4 threads:", fourThreadBandwidth)
	res = testing.Benchmark(BenchmarkBandwidth8Thread)
	eightThreadBandwidth := sizeInBytes / res.NsPerOp()
	println("8 threads:", eightThreadBandwidth)
	res = testing.Benchmark(BenchmarkBandwidth10Thread)
	tenThreadBandwidth := sizeInBytes / res.NsPerOp()
	println("10 threads:", tenThreadBandwidth)
}
