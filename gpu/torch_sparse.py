# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.4
#   kernelspec:
#     display_name: bench
#     language: python
#     name: python3
# ---

# +
import torch
import pandas as pd
from torch.profiler import profile, record_function, ProfilerActivity

torch.random.manual_seed(0)

print(torch.__version__)


# +
SIZES = [128, 256, 512, 1024, 2048, 4096, 8192, 16384]
PERCENTAGES_NONZERO = [0.01, 0.05, 0.1, 0.2, 0.5]
DEVICE = "cuda"

densify = lambda x: x.to_dense() if x.is_sparse else x
cooify = lambda x: x.to_sparse_coo()
cscify = lambda x: x.to_sparse_csc()
csrify = lambda x: x.to_sparse_csr()

MATRIX_TYPES = [
    ("dense", densify),
    ("coo", cooify),
    ("csc", cscify),
    ("csr", csrify),
]


# +
results = []
for size in SIZES:
    b = torch.rand((size, 1), device=DEVICE)
    for percentage_nonzero in PERCENTAGES_NONZERO:
        A_dense = torch.rand((size, size), device=DEVICE)
        mask = torch.rand((size, size), device=DEVICE) > percentage_nonzero
        A_dense = A_dense.masked_fill_(mask, 0)
        archieved_percentage = 1 - (mask.sum() / (size * size))
        print(
            f"Running {size}x{size} with {percentage_nonzero}% non-zero (achieved {archieved_percentage}%)"
        )

        for name, matrix_fun in MATRIX_TYPES:
            matrix = matrix_fun(A_dense)
            with profile(activities=[ProfilerActivity.CUDA], with_stack=True) as prof:
                _ = torch.matmul(matrix, b)
            prof.export_chrome_trace(f"torch_sparse_trace_{name}.json")
            prof.export_stacks(f"profiler_stacks_{name}.txt", "self_cuda_time_total")

            result = {
                "size": size,
                "percentage_nonzero": percentage_nonzero,
                "name": name,
                "cuda_str": prof.key_averages()
                .total_average()
                .self_cuda_time_total_str,
                "cuda_micros": prof.key_averages().total_average().self_cuda_time_total,
                "cpu_str": prof.key_averages().total_average().self_cpu_time_total_str,
                "cpu_micros": prof.key_averages().total_average().self_cuda_time_total,
            }
            results.append(result)

df = pd.DataFrame(results)
# -

df


