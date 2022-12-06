package main

import (
	"fmt"
	"sync"
	"testing"
)

var ResultInt64 int64

func BenchmarkBandwidthSingleThread(b *testing.B, size int) {
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

func benchmarkBandwidthMultiThread(b *testing.B, thread, size int) {
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

// array ends up being ~4MB
const cacheableSize = 1 << 19

// array ends up being ~1GB
const nonCacheableSize = 1 << 27

func main() {
	sizes := []int{cacheableSize, nonCacheableSize}

	for _, size := range sizes {
		res := testing.Benchmark(func(b *testing.B) {
			BenchmarkBandwidthSingleThread(b, size)
		})
		fmt.Printf("Array: %.2fMB, single-thread Impl, BW: %.2fGB/s\n",
			float64(size)*8/1e6, float64(size)/float64(res.NsPerOp()))
	}

	threads := []int{1, 2, 4, 8, 10, 16, 32, 64}

	for _, size := range sizes {
		for _, numThreads := range threads {
			res := testing.Benchmark(func(b *testing.B) {
				benchmarkBandwidthMultiThread(b, numThreads, size)
			})
			fmt.Printf("Array: %.2fMB, Threads: %d, BW: %.2fGB/s\n", float64(size)*8/1e6, numThreads, float64(size)/float64(res.NsPerOp()))
		}
	}
}
