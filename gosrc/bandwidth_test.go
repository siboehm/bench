package bench

import (
	"sync"
	"testing"
)

func BenchmarkBandwidthSingleThread(b *testing.B) {
	size := 1 << 24

	array := make([]int64, size)

	for i := range array {
		array[i] = int64(i) + ResultInt64
	}

	b.ResetTimer()

	tmp := int64(0)
	for i := 0; i < b.N; i++ {
		for j := 0; j < len(array); j++ {
			tmp += array[j]
		}
	}
}

func benchmarkBandwidthMultiThread(b *testing.B, thread int) {
	size := 1 << 27
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
				for j := start; j < end; j++ {
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

func BenchmarkBandwidth16Thread(b *testing.B) {
	benchmarkBandwidthMultiThread(b, 16)
}
