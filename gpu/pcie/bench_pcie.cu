#include <chrono>
#include <cuda_runtime.h>
#include <iostream>
#include <vector>

int main() {

  std::vector<std::chrono::duration<double>> time_data;

  auto ts = std::chrono::system_clock::now();

  cudaStream_t stream_in, stream_out;
  cudaStreamCreate(&stream_in);
  cudaStreamCreate(&stream_out);

  int size = 1000 * 1000 * 1000;
  int *in_host = (int *)malloc(1000 * size);
  int *out_host = (int *)malloc(1000 * size);
  int *in_dev, *out_dev;
  cudaMalloc((void **)&in_dev, 1000 * size);
  cudaMalloc((void **)&out_dev, 1000 * size);

  cudaMemcpyAsync((void **)in_dev, in_host, 1000 * size, cudaMemcpyHostToDevice,
                  stream_in);
  cudaMemcpyAsync((void **)out_host, out_dev, 1000 * size,
                  cudaMemcpyDeviceToHost, stream_out);

  cudaStreamSynchronize(stream_in);
  cudaStreamSynchronize(stream_out);

  time_data.push_back(std::chrono::system_clock::now() - ts);
  std::cout << "Time taken: " << time_data.back().count() << "s " << std::endl;
}