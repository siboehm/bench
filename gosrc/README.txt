goos: linux
goarch: amd64
pkg: benchmarks/gosrc
cpu: AMD EPYC 7513 32-Core Processor                
BenchmarkFunctionCallNoInline-128      	703844668	         1.647 ns/op
BenchmarkFunctionCallInline-128        	1000000000	         0.5512 ns/op
BenchmarkStructAccessAligned-128       	       1	1168922273 ns/op
BenchmarkStructAccessUnaligned-128     	       1	2201264693 ns/op
PASS
ok  	benchmarks/gosrc	5.349s
