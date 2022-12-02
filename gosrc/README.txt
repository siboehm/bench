goos: linux
goarch: amd64
pkg: benchmarks/gosrc
cpu: AMD EPYC 7513 32-Core Processor                
BenchmarkFunctionCallNoInline-128          	688194266	         1.646 ns/op
BenchmarkFunctionCallInline-128            	1000000000	         0.5534 ns/op
BenchmarkStructAccessSequential-128        	       1	1183988365 ns/op
BenchmarkStructAccessNonSequential-128     	       1	2204128344 ns/op
PASS
ok  	benchmarks/gosrc	7.969s
