#include <iostream>
#include <mpi.h>
#include <vector>

int main(int argc, char *argv[]) {
  int rank, num_procs;
  int num_iterations = 1000;
  double start_time, end_time, elapsed_time;

  // Initialize MPI environment
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

  if (rank == 0) {
    std::cout << "Data Size (Bytes), Average AllReduce Latency (microseconds)"
              << std::endl;
  }

  for (int data_size = 1024; data_size <= (1024 * 1024 * 1024);
       data_size *= 2) {
    std::vector<double> send_buffer(data_size / sizeof(double), 0.0);
    std::vector<double> recv_buffer(data_size / sizeof(double), 0.0);

    // Warm-up
    for (int i = 0; i < 10; ++i) {
      MPI_Allreduce(send_buffer.data(), recv_buffer.data(), send_buffer.size(),
                    MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
    }

    // Measure AllReduce latency
    MPI_Barrier(MPI_COMM_WORLD);
    start_time = MPI_Wtime();

    for (int i = 0; i < num_iterations; ++i) {
      MPI_Allreduce(send_buffer.data(), recv_buffer.data(), send_buffer.size(),
                    MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
    }

    end_time = MPI_Wtime();
    elapsed_time = (end_time - start_time) / num_iterations;

    // Output the latency in microseconds
    if (rank == 0) {
      std::cout << data_size << ", " << elapsed_time * 1e6 << std::endl;
    }
  }

  MPI_Finalize();

  return 0;
}
