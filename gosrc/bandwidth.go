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

func benchmarkBandwidthMultiThread(b *testing.B, numGoroutines, chunkSize int, array []int64) {
	resultsInterim := make([]int64, numGoroutines)
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

// ~250KB
const cacheableChunkSize = 1 << 15

// ~17MB
const nonCacheableChunkSize = 1 << 21

func main() {
	sizes := []int{cacheableChunkSize, nonCacheableChunkSize}

	for _, size := range sizes {
		res := testing.Benchmark(func(b *testing.B) {
			BenchmarkBandwidthSingleThread(b, size)
		})
		fmt.Printf("Array: %.2fMB, single-thread Impl, BW: %.2fGB/s\n",
			float64(size)*8/1e6, float64(size)*8/float64(res.NsPerOp()))
	}

	threads := []int{1, 2, 4, 8, 10, 16, 32, 64}

	// init array
	array := make([]int64, threads[len(threads)-1]*nonCacheableChunkSize)
	for i := range array {
		array[i] = int64(i) + ResultInt64
	}

	for _, size := range sizes {
		for _, numThreads := range threads {
			res := testing.Benchmark(func(b *testing.B) {
				benchmarkBandwidthMultiThread(b, numThreads, size, array[0:size*numThreads])
			})
			sizeBytes := float64(size) * float64(numThreads) * 8
			fmt.Printf("Array: %7.2fMB, Threads: %2.d, BW: %6.2fGB/s, runs: %d\n", sizeBytes/1e6, numThreads, sizeBytes/float64(res.NsPerOp()), res.N)
		}
	}
}
