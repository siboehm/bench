.PHONY: all

TARGET: fma fma.asm

CXX = clang++
CXXFLAGS = -std=c++20 -O3 -flto -march=native
INCDIR = /home/simon/mambaforge/envs/bench/include
LIBDIR = /home/simon/mambaforge/envs/bench/lib

.all: $(TARGET)

fma: benchmark_fma.cpp
	$(CXX) $(CXXFLAGS) -I$(INCDIR) -L$(LIBDIR) -o $@ $^ -lbenchmark

fma.asm: fma
	objdump -S $^ | c++filt > $@