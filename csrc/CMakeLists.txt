cmake_minimum_required(VERSION 3.19)
project(cpp_bench)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# set(CMAKE_CXX_FLAGS_RELEASE "-O3 -ffast-math -march=native -mtune=native -funsafe-math-optimizations")
# if on mac, use mcpu instead of march
if (APPLE)
  set(CMAKE_CXX_FLAGS_RELEASE "-O3 -ffast-math -mcpu=native -mtune=native -funsafe-math-optimizations")
else()
    set(CMAKE_CXX_FLAGS_RELEASE "-O3 -ffast-math -march=native -mtune=native -funsafe-math-optimizations")
endif()

set(CMAKE_CXX_STANDARD 17)

add_executable(bench_exp benchmark_exp.cpp)

find_package(benchmark REQUIRED)

target_link_libraries(bench_exp benchmark::benchmark)