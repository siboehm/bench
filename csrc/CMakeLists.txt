cmake_minimum_required(VERSION 3.19)
project(cpp_bench)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

if (APPLE)
  # if on mac, use mcpu instead of march
  set(CMAKE_CXX_FLAGS_RELEASE "-O3 -mcpu=native -mtune=native")
else()
    set(CMAKE_CXX_FLAGS_RELEASE "-O3 -march=native -mtune=native")
endif()

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(benchmark REQUIRED)

add_executable(bench_exp benchmark_exp.cpp)
target_link_libraries(bench_exp benchmark::benchmark)
add_executable(bench_fma benchmark_fma.cpp)
target_link_libraries(bench_fma benchmark::benchmark)
add_executable(bench_unhelpful_fma benchmark_unhelpful_fma.cpp)
target_link_libraries(bench_unhelpful_fma benchmark::benchmark)
add_executable(benchmark_func_calls benchmark_func_calls.cpp)
target_link_libraries(benchmark_func_calls benchmark::benchmark)

add_executable(test_exp fast_exp_test.cpp)

# Add MPI components
find_package(MPI REQUIRED)
include_directories(${MPI_INCLUDE_PATH})

# Create MPI benchmark executable
add_executable(mpi_benchmark mpi_benchmark.cpp)
target_link_libraries(mpi_benchmark ${MPI_LIBRARIES})

if(MPI_COMPILE_FLAGS)
  set_target_properties(mpi_benchmark PROPERTIES
    COMPILE_FLAGS "${MPI_COMPILE_FLAGS}")
endif()

if(MPI_LINK_FLAGS)
  set_target_properties(mpi_benchmark PROPERTIES
    LINK_FLAGS "${MPI_LINK_FLAGS}")
endif()


