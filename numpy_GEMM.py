import os

N_THREADS=1
os.environ['OPENBLAS_NUM_THREADS'] = str(N_THREADS)
os.environ['MKL_NUM_THREADS'] = str(N_THREADS)
os.environ['OMP_NUM_THREADS'] = str(N_THREADS)

import numpy as np
from time import time_ns

DIM=4096

# Zeros is slower than np.empty(), but I'm worried about running
# into NaN-handlers / subnormals
x = np.zeros((DIM, DIM), dtype=np.float32)
y = np.zeros((DIM, DIM), dtype=np.float32)
start = time_ns()
z = np.dot(x, y)

duration_ms = (time_ns() - start) / (10 ** 6)

# M * N * (dot product over K vectors, one FMA at each position)
flops_total = DIM * DIM * 2 * DIM

print(f"Duration: {duration_ms}ms, GFLOPS total: {flops_total/(10**9)}, GFLOPS/s: {flops_total/(10**9)/(duration_ms/1000)}")
