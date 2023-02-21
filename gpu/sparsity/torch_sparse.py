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
from pathlib import Path
from torch.profiler import profile, record_function, ProfilerActivity
import time
import math

import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns

# matplotlib.style.use("fivethirtyeight")
# matplotlib.style.use("seaborn-v0_8-talk")
matplotlib.rcParams["font.family"] = "monospace"
matplotlib.rcParams["figure.dpi"] = 200
plt.rcParams["savefig.facecolor"] = "white"

torch.random.manual_seed(0)

print(torch.__version__)


# +
DEVICE = "cuda"
PROFILER_OUTDIR = Path("profiler_output")
PATCH_SIZE = 16

densify = lambda x: x.to_dense() if x.is_sparse else x
cooify = lambda x: x.to_sparse_coo()
cscify = lambda x: x.to_sparse_csc()
csrify = lambda x: x.to_sparse_csr()
bsrify = lambda x: x.to_sparse_bsr((16, 16))

MATRIX_TYPES = [
    ("dense", densify),
    ("coo", cooify),
    # ("csc", cscify),
    ("csr", csrify),
    ("bsr", bsrify),
]


# +
SIZES = [512, 1024, 2048, 4096, 8192, 16384]
PERCENTAGES_NONZERO = [0.0001, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3]


def run_benchmark(profiling=False):
    results = []
    for size in SIZES:
        b = torch.rand((size, 1), device=DEVICE, dtype=torch.float32)
        for percentage_nonzero in PERCENTAGES_NONZERO:
            # Define the number of patches to set to a non-zero value
            num_patches = math.ceil(size**2 * percentage_nonzero / PATCH_SIZE**2)
            # Create a tensor of zeros with the specified shape
            A_dense = torch.zeros((size, size), device=DEVICE, dtype=torch.float32)
            # Set a random set of patches to random values
            for i in range(num_patches):
                # Generate random row and column indices for the top-left corner of the patch
                row_idx = torch.randint(size - PATCH_SIZE + 1, (1,))
                col_idx = torch.randint(size - PATCH_SIZE + 1, (1,))
                # Generate a random patch with values between min_value and max_value
                patch = torch.rand((PATCH_SIZE, PATCH_SIZE))
                # Set the patch in the dense matrix
                A_dense[
                    row_idx : row_idx + PATCH_SIZE, col_idx : col_idx + PATCH_SIZE
                ] = patch

            archieved_percentage = A_dense.count_nonzero() / (size * size)
            print(
                f"Running {size}x{size} with {percentage_nonzero * 100}% non-zero (achieved {archieved_percentage * 100}%)"
            )

            for name, matrix_fun in MATRIX_TYPES:
                matrix = matrix_fun(A_dense)
                start_time = time.time()
                with profile(
                    activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
                    with_stack=profiling,
                    record_shapes=profiling,
                ) as prof:
                    _ = torch.matmul(matrix, b)
                torch.cuda.synchronize()
                end_time = time.time()
                print(f"  {name} took {end_time - start_time} seconds")
                result = {
                    "size": size,
                    "percentage_nonzero": percentage_nonzero,
                    "name": name,
                    "cuda_micros": prof.key_averages()
                    .total_average()
                    .self_cuda_time_total,
                    "cpu_micros": prof.key_averages()
                    .total_average()
                    .self_cpu_time_total,
                    "measured_time": end_time - start_time,
                }
                results.append(result)
                if profiling:
                    prof.export_chrome_trace(
                        str(
                            PROFILER_OUTDIR
                            / f"torch_sparse_{size}_{percentage_nonzero}_{name}.json"
                        )
                    )
                    prof.export_stacks(
                        str(
                            PROFILER_OUTDIR
                            / f"torch_sparse_stacks_{size}_{percentage_nonzero}_{name}.txt"
                        ),
                        "self_cuda_time_total",
                    )
    return results


results = run_benchmark(profiling=False)
df = pd.DataFrame(results)
df.to_csv(PROFILER_OUTDIR / "torch_sparse_results.csv", index=False)
# -


SIZES = [8192]
PERCENTAGES_NONZERO = [0.05]
_ = run_benchmark(profiling=True)

df = pd.read_csv(PROFILER_OUTDIR / "torch_sparse_results.csv")
df["percentage_nonzero"] = df["percentage_nonzero"] * 100
df["cuda_millis"] = df["cuda_micros"] / 1000
df["cpu_millis"] = df["cpu_micros"] / 1000
df

# +
# Create the lineplots with log y-scale and dots
g = sns.FacetGrid(
    df,
    col="percentage_nonzero",
    height=4,
    aspect=1.2,
    col_wrap=2,
    sharey=True,
    sharex=False,
)
g.map(sns.lineplot, "size", "cuda_millis", "name")
g.map(sns.scatterplot, "size", "cuda_millis", "name", color="black", alpha=0.7, s=20)
g.set(yscale="log")

# Set the titles and labels
g.set_titles(col_template="{col_name}% Nonzero", fontweight="bold")
g.set_axis_labels("Size", "CUDA ms")

# Add legend
g.add_legend()

# add grid
g.despine(left=True, bottom=True)
g.map(plt.grid, which="both", axis="both", ls="--", color="grey", alpha=0.5)

# Show the plot
plt.show()
# save the plot
g.savefig(f"torch_sparse_plot_cuda.png")

# largest size only
sub_df = df[df["size"] == df["size"].max()]
g = sns.FacetGrid(sub_df, col="size", height=4, aspect=1.2, sharey=True, sharex=False)
g.map(sns.lineplot, "percentage_nonzero", "cuda_millis", "name")
g.map(
    sns.scatterplot,
    "percentage_nonzero",
    "cuda_millis",
    "name",
    color="black",
    alpha=0.7,
    s=20,
)
g.set(yscale="log")

# Set the titles and labels
g.set_titles(col_template="Size: {col_name}x{col_name}", fontweight="bold")
g.set_axis_labels("% nonzero", "CUDA ms")

# Add legend
g.add_legend()

# add grid
g.despine(left=True, bottom=True)
g.map(plt.grid, which="both", axis="both", ls="--", color="grey", alpha=0.5)

# Show the plot
plt.show()
g.savefig("torch_sparse_plot_largest.png")
# -


