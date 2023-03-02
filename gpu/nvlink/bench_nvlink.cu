#include <cuda_runtime.h>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <thread>
#include <vector>

#define CHECK(call)                                                            \
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

template <typename T> void printArray(T arr[], int size) {
  for (int i = 0; i < size; i++) {
    std::cout << arr[i] << " ";
  }
  std::cout << std::endl;
}

void storeTimingsToFile(const std::vector<std::chrono::nanoseconds> &timeData,
                        const std::vector<size_t> sizes,
                        const std::string filename) {
  std::ofstream file;
  file.open(filename);
  file << "Size,Time\n";
  for (int i = 0; i < timeData.size(); i++) {
    file << sizes[i] << "," << timeData[i].count() << "\n";
  }
  file.close();
}

const size_t WARMUP_STEPS = 2;
const size_t WARMUP_SIZE = 32 * 1024 * 1024; // 134 MB

const std::vector<size_t> SIZES = {
    8,        16,       32,       64,        128,      256,     512,
    1024,     2048,     4096,     8192,      16384,    32768,   65536,
    131072,   262144,   524288,   1048576,   2097152,  4194304, 8388608,
    16777216, 33554432, 67108864, 134217728, 268435456};

void checkTransfer(float *d0_data0, float *d0_data1, float *d1_data0,
                   float *d1_data1, cudaStream_t d0_stream,
                   cudaStream_t d1_stream) {

  // ensure pointers are on the correct device
  cudaPointerAttributes d0_data0_attr;
  cudaPointerAttributes d0_data1_attr;
  cudaPointerAttributes d1_data0_attr;
  cudaPointerAttributes d1_data1_attr;

  CHECK(cudaPointerGetAttributes(&d0_data0_attr, d0_data0));
  CHECK(cudaPointerGetAttributes(&d0_data1_attr, d0_data1));
  CHECK(cudaPointerGetAttributes(&d1_data0_attr, d1_data0));
  CHECK(cudaPointerGetAttributes(&d1_data1_attr, d1_data1));

  if (d0_data0_attr.device != 0 || d0_data1_attr.device != 0 ||
      d1_data0_attr.device != 1 || d1_data1_attr.device != 1) {
    throw std::runtime_error("Incorrect device for pointer");
  }

  std::vector<float> hsrc_d0(WARMUP_SIZE);
  std::vector<float> hsrc_d1(WARMUP_SIZE);
  std::vector<float> hdst_d0(WARMUP_SIZE);
  std::vector<float> hdst_d1(WARMUP_SIZE);

  for (int i = 0; i < hsrc_d0.size(); i++) {
    hsrc_d0[i] = (float)WARMUP_SIZE - i;
    hsrc_d1[i] = i + 1.0f;
  }

  CHECK(cudaMemcpy(d0_data0, hsrc_d0.data(), WARMUP_SIZE * sizeof(float),
                   cudaMemcpyDefault));
  CHECK(cudaMemcpy(d1_data0, hsrc_d1.data(), WARMUP_SIZE * sizeof(float),
                   cudaMemcpyDefault));

  CHECK(cudaMemcpyPeerAsync(d1_data1, 1, d0_data0, 0,
                            WARMUP_SIZE * sizeof(float), d0_stream));
  CHECK(cudaMemcpyPeerAsync(d0_data1, 0, d1_data0, 1,
                            WARMUP_SIZE * sizeof(float), d1_stream));
  CHECK(cudaStreamSynchronize(d0_stream));
  CHECK(cudaStreamSynchronize(d1_stream));

  CHECK(cudaSetDevice(0));
  CHECK(cudaMemcpy(hdst_d0.data(), d0_data1, WARMUP_SIZE * sizeof(float),
                   cudaMemcpyDeviceToHost));

  CHECK(cudaSetDevice(1));
  CHECK(cudaMemcpy(hdst_d1.data(), d1_data1, WARMUP_SIZE * sizeof(float),
                   cudaMemcpyDeviceToHost));

  for (int i = 0; i < WARMUP_SIZE; i++) {
    if (hdst_d1[i] != hsrc_d0[i]) {
      std::ostringstream ss;
      ss << "Divergence! hdst_d1[" << i << "]=" << hdst_d1[i] << " hsrc_d0["
         << i << "]=" << hsrc_d0[i] << std::endl;
      throw std::runtime_error(ss.str());
    }
    if (hdst_d0[i] != hsrc_d1[i]) {
      std::ostringstream ss;
      ss << "Divergence! hdst_d0[" << i << "]=" << hdst_d0[i] << " hsrc_d1["
         << i << "]=" << hsrc_d1[i] << std::endl;
      throw std::runtime_error(ss.str());
    }
  }
  std::cout << "Transfer check passed" << std::endl;
}

int main() {
  int deviceCount;
  cudaGetDeviceCount(&deviceCount);
  if (deviceCount < 2) {
    std::cout << "This benchmark requires at least two devices" << std::endl;
    return 1;
  }

  CHECK(cudaSetDevice(0));
  cudaStream_t d0_stream;
  cudaStreamCreate(&d0_stream);
  float *d0_data0, *d0_data1;
  CHECK(cudaMalloc(&d0_data0, SIZES.back() * sizeof(float)));
  CHECK(cudaMalloc(&d0_data1, SIZES.back() * sizeof(float)));
  CHECK(cudaDeviceEnablePeerAccess(1, 0)); // needs to be called on both devices

  CHECK(cudaSetDevice(1));
  cudaStream_t d1_stream;
  cudaStreamCreate(&d1_stream);
  float *d1_data0, *d1_data1;
  CHECK(cudaMalloc(&d1_data0, SIZES.back() * sizeof(float)));
  CHECK(cudaMalloc(&d1_data1, SIZES.back() * sizeof(float)));
  CHECK(cudaDeviceEnablePeerAccess(0, 0));

  checkTransfer(d0_data0, d0_data1, d1_data0, d1_data1, d0_stream, d1_stream);

  std::vector<std::chrono::nanoseconds> timeData;

  for (int i = 0; i < WARMUP_STEPS; i++) {
    CHECK(cudaMemcpyPeerAsync(d1_data1, 1, d0_data0, 0,
                              WARMUP_SIZE * sizeof(float), d0_stream));
    CHECK(cudaMemcpyPeerAsync(d0_data0, 0, d1_data1, 1,
                              WARMUP_SIZE * sizeof(float), d1_stream));
  }
  CHECK(cudaStreamSynchronize(d0_stream));
  CHECK(cudaStreamSynchronize(d1_stream));

  for (auto size : SIZES) {
    size_t sizeBytes = size * sizeof(float);
    auto ts = std::chrono::system_clock::now();
    CHECK(cudaMemcpyPeerAsync(d1_data1, 1, d0_data0, 0, sizeBytes, d0_stream));
    CHECK(cudaMemcpyPeerAsync(d0_data1, 0, d1_data0, 1, sizeBytes, d1_stream));
    CHECK(cudaStreamSynchronize(d0_stream));
    CHECK(cudaStreamSynchronize(d1_stream));
    timeData.push_back(std::chrono::system_clock::now() - ts);

    std::cout << "Size: " << bytes_to_human_readable(sizeBytes)
              << " Time: " << timeData.back().count() / 1000 << "μs"
              << " BW (duplex): "
              << ((double)sizeBytes * 1024) / timeData.back().count()
              << " MB/s\n";
  }

  storeTimingsToFile(timeData, SIZES, "build/cudaMemcpyPeerAsync.csv");

  CHECK(cudaGetLastError());

  cudaFree(d0_data0);
  cudaFree(d0_data1);
  cudaFree(d1_data0);
  cudaFree(d1_data1);
  cudaStreamDestroy(d0_stream);
  cudaStreamDestroy(d1_stream);

  return 0;
}