#include <chrono>
#include <cuda_runtime.h>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <thread>
#include <vector>

#define CUDA_CHECK(call)                                                       \
  {                                                                            \
    const cudaError_t error = call;                                            \
    if (error != cudaSuccess) {                                                \
      std::cout << "Error: " << __FILE__ << ":" << __LINE__ << ", ";           \
      std::cout << "code: " << error                                           \
                << ", reason: " << cudaGetErrorString(error);                  \
      std::cout << std::endl;                                                  \
      exit(1);                                                                 \
    }                                                                          \
  }

std::string bytes_to_human_readable(size_t size) {
  static const char *sizes[] = {"B", "KB", "MB", "GB", "TB"};
  int order = 0;
  double size_d = (double)size;
  while (size_d >= 1000 && order < 4) {
    size_d /= 1000;
    ++order;
  }

  std::stringstream ss;
  ss.precision(1);
  ss << std::fixed << size_d << sizes[order];

  return ss.str();
}

void runPcieDefault(int size, std::vector<std::chrono::nanoseconds> &time_data,
                    cudaStream_t stream_in, cudaStream_t stream_out,
                    bool verbose = true) {
  int sizeBytes = size * sizeof(float);

  float *in_host, *out_host;
  in_host = (float *)malloc(sizeBytes);
  out_host = (float *)malloc(sizeBytes);
  float *in_dev, *out_dev;
  CUDA_CHECK(cudaMalloc((void **)&in_dev, sizeBytes));
  CUDA_CHECK(cudaMalloc((void **)&out_dev, sizeBytes));

  auto ts = std::chrono::system_clock::now();

  CUDA_CHECK(cudaMemcpyAsync((void **)in_host, out_dev, sizeBytes,
                             cudaMemcpyDeviceToHost, stream_in));
  CUDA_CHECK(cudaMemcpyAsync((void **)in_dev, out_host, sizeBytes,
                             cudaMemcpyHostToDevice, stream_out));
  CUDA_CHECK(cudaStreamSynchronize(stream_in));
  CUDA_CHECK(cudaStreamSynchronize(stream_out));

  time_data.push_back(std::chrono::system_clock::now() - ts);
  if (verbose) {
    std::cout << "Size: " << bytes_to_human_readable(sizeBytes)
              << " Time: " << time_data.back().count() / 1000 << "μs"
              << " BW (Dev to Host): "
              << ((double)sizeBytes * 1024) / time_data.back().count()
              << " MB/s" << std::endl;
  }

  free(out_host);
  cudaFree(out_dev);
}

void runPciePinned(int size, std::vector<std::chrono::nanoseconds> &time_data,
                   cudaStream_t stream_in, cudaStream_t stream_out) {
  long sizeBytes = size * sizeof(float);

  float *in_host, *out_host;
  CUDA_CHECK(
      cudaHostAlloc((void **)&out_host, sizeBytes, cudaHostAllocDefault));
  CUDA_CHECK(cudaHostAlloc((void **)&in_host, sizeBytes, cudaHostAllocDefault));
  float *in_dev, *out_dev;
  CUDA_CHECK(cudaMalloc((void **)&in_dev, sizeBytes));
  CUDA_CHECK(cudaMalloc((void **)&out_dev, sizeBytes));

  auto ts = std::chrono::system_clock::now();

  CUDA_CHECK(cudaMemcpyAsync((void **)in_host, out_dev, sizeBytes,
                             cudaMemcpyDeviceToHost, stream_in));
  CUDA_CHECK(cudaMemcpyAsync((void **)in_dev, out_host, sizeBytes,
                             cudaMemcpyHostToDevice, stream_out));
  CUDA_CHECK(cudaStreamSynchronize(stream_in));
  CUDA_CHECK(cudaStreamSynchronize(stream_out));

  time_data.push_back(std::chrono::system_clock::now() - ts);
  std::cout << "Size: " << bytes_to_human_readable(sizeBytes)
            << " Time: " << time_data.back().count() / 1000 << "μs"
            << " BW (each direction): "
            << ((double)sizeBytes * 1000) / time_data.back().count() << " MB/s"
            << std::endl;

  cudaFreeHost(out_host);
  cudaFree(out_dev);
}

void runPciePinnedWriteCombined(
    int size, std::vector<std::chrono::nanoseconds> &time_data,
    cudaStream_t stream_in, cudaStream_t stream_out) {
  long sizeBytes = size * sizeof(float);

  float *in_host, *out_host;
  CUDA_CHECK(
      cudaHostAlloc((void **)&out_host, sizeBytes, cudaHostAllocWriteCombined));
  CUDA_CHECK(
      cudaHostAlloc((void **)&in_host, sizeBytes, cudaHostAllocWriteCombined));
  float *in_dev, *out_dev;
  CUDA_CHECK(cudaMalloc((void **)&in_dev, sizeBytes));
  CUDA_CHECK(cudaMalloc((void **)&out_dev, sizeBytes));

  auto ts = std::chrono::system_clock::now();

  CUDA_CHECK(cudaMemcpyAsync((void **)in_host, out_dev, sizeBytes,
                             cudaMemcpyDeviceToHost, stream_in));
  CUDA_CHECK(cudaMemcpyAsync((void **)in_dev, out_host, sizeBytes,
                             cudaMemcpyHostToDevice, stream_out));
  CUDA_CHECK(cudaStreamSynchronize(stream_in));
  CUDA_CHECK(cudaStreamSynchronize(stream_out));

  time_data.push_back(std::chrono::system_clock::now() - ts);
  std::cout << "Size: " << bytes_to_human_readable(sizeBytes)
            << " Time: " << time_data.back().count() / 1000 << "μs"
            << " BW (Dev to Host): "
            << ((double)sizeBytes * 1024) / time_data.back().count() << " MB/s"
            << std::endl;

  cudaFreeHost(out_host);
  cudaFree(out_dev);
}

void storeTimingsToFile(const std::vector<std::chrono::nanoseconds> &time_data,
                        const std::vector<size_t> sizes,
                        const std::string filename) {
  std::ofstream file;
  file.open(filename);
  file << "Size,Time\n";
  for (int i = 0; i < time_data.size(); i++) {
    file << sizes[i] << "," << time_data[i].count() << "\n";
  }
  file.close();
}

const size_t WARMUP = 2 << 14;

int main() {
  int deviceId;
  cudaGetDevice(&deviceId);
  cudaDeviceProp props{};
  cudaGetDeviceProperties(&props, deviceId);
  std::cout << "Device: " << props.name << "\n";
  if (props.asyncEngineCount < 2) {
    std::cout << "No duplex Pcie" << std::endl;
    return 0;
  }

  std::vector<std::chrono::nanoseconds> warmup_data;
  std::vector<std::chrono::nanoseconds> time_data;

  std::vector<size_t> SIZES = {
      8,        16,       32,       64,        128,      256,     512,
      1024,     2048,     4096,     8192,      16384,    32768,   65536,
      131072,   262144,   524288,   1048576,   2097152,  4194304, 8388608,
      16777216, 33554432, 67108864, 134217728, 268435456};

  cudaStream_t stream_in, stream_out;
  cudaStreamCreate(&stream_in);
  cudaStreamCreate(&stream_out);

  std::cout << "------- Running PCIe Normal ------"
            << "\n\n";
  // warmup
  runPcieDefault(WARMUP, warmup_data, stream_in, stream_out, false);
  for (auto size : SIZES) {
    runPcieDefault(size, time_data, stream_in, stream_out);
  }
  storeTimingsToFile(time_data, SIZES, "../pcie_normal.csv");
  time_data.clear();

  // sleep
  std::this_thread::sleep_for(std::chrono::seconds(5));

  std::cout << "\n----- Running PCIe Pinned ------"
            << "\n\n";
  // warmup
  runPcieDefault(WARMUP, warmup_data, stream_in, stream_out, false);
  for (auto size : SIZES) {
    runPciePinned(size, time_data, stream_in, stream_out);
  }
  storeTimingsToFile(time_data, SIZES, "../pcie_pinned.csv");
  time_data.clear();

  std::this_thread::sleep_for(std::chrono::seconds(5));

  std::cout << "\n----- Running PCIe Pinned Write Combined ------"
            << "\n\n";
  // warmup
  runPcieDefault(WARMUP, warmup_data, stream_in, stream_out, false);
  for (auto size : SIZES) {
    runPciePinnedWriteCombined(size, time_data, stream_in, stream_out);
  }
  storeTimingsToFile(time_data, SIZES, "../pcie_pinned_write_combined.csv");
  time_data.clear();

  cudaStreamDestroy(stream_in);
  cudaStreamDestroy(stream_out);
}