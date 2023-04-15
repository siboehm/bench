import torch
import torch.mps
from time import time_ns

DIM = 2048

# Use CUDA if available, else use Metal if available, otherwise use CPU
device = 'cuda' if torch.cuda.is_available() else 'mps' if torch.backends.mps.is_available() else 'cpu'
print(f"PyTorch version: {torch.__version__}")
print(f"Using device: {device}")


def sync():
    if device == 'cuda':
        torch.cuda.synchronize()
    elif device == 'mps':
        torch.mps.synchronize()

# Zeros is slower than torch.empty(), but I'm worried about running
# into NaN-handlers / subnormals
x = torch.zeros((DIM, DIM), dtype=torch.float32, device=device)
y = torch.zeros((DIM, DIM), dtype=torch.float32, device=device)

for _ in range(10):
    z = torch.matmul(x, y)
sync()

start = time_ns()
for _ in range(10):
    z = torch.matmul(x, y)
sync()
duration_ms = (time_ns() - start) / (10 ** 6) / 10

# M * N * (dot product over K vectors, one FMA at each position)
flops_total = DIM * DIM * 2 * DIM

print(f"Duration: {duration_ms}ms, GFLOP total: {flops_total/(10**9)}, GFLOP/s: {flops_total/(10**9)/(duration_ms/1000)}")
