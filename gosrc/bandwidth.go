package main

import (
	"fmt"
	"sync"
	"testing"
)

var ResultInt64 int64

func benchmarkBandwidthMultiThread(b *testing.B, numGoroutines, chunkSize, repeats int, array []int64) {
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
				for rep := 0; rep < repeats; rep++ {
					for j := start; j < end; j += 1 {
						tmp += array[j]
					}
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
	threads := []int{1, 2, 4, 8, 10, 16, 32, 64}
	repeats := 1000

	// init array
	array := make([]int64, threads[len(threads)-1]*nonCacheableChunkSize)
	for i := range array {
		array[i] = int64(i) + ResultInt64
	}

	for _, size := range sizes {
		fmt.Printf("Chunk size: %6.1fMB\n", float64(size)*8/1e6)
		for _, numThreads := range threads {
			res := testing.Benchmark(func(b *testing.B) {
				benchmarkBandwidthMultiThread(b, numThreads, size, repeats, array[0:size*numThreads])
			})
			sizeBytes := float64(size) * float64(numThreads) * 8
			fmt.Printf("Arraysize: %7.2fMB, numThreads: %2.d, bandwidth: %6.2fGB/s, runs: %d\n", sizeBytes/1e6, numThreads, sizeBytes*float64(repeats)/float64(res.NsPerOp()), res.N)
		}
		fmt.Println()
	}
}
