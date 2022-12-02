## How to use

To look at pprof profiles and disasm:
```bash
cd gosrc
# generate gosrc.test binary
go test -c .
# run all tests that match `.` regex, store profile
./gosrc.test -test.bench=. -test.cpuprofile=profile.prof
# pprof web interface, also pass binary to get disasm access
go tool pprof -http :9898 gosrc.test profile.prof
```

## Benchmarks

### `gosrc/struct_access_test`

Iterating through a slice of structs sequentially, but accessing each of the structs 4*16 fields either sequentially or non-sequentially.

Trying to test: how much gain is there from grouping elements that are accessed together (`gc` doesn't do struct any struct reordering by itself).

`gc` could change the order of the sums to better fit the in-memory struct layout (int math is assoc), but looking at the disasm it doesn't seem to do that (see [issue](https://github.com/golang/go/issues/49331)).

### `gosrc/function_call_test`

Trying to test: Cost of function call.

Go has infinite function stacks and resizing the stack comes with a big [penalty](https://dave.cheney.net/2013/06/02/why-is-a-goroutines-stack-infinite), but this test is not looking at that.