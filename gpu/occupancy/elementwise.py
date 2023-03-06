# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:percent
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.14.4
#   kernelspec:
#     display_name: bench
#     language: python
#     name: python3
# ---

# %%
import torch
import time
import plotly.graph_objs as go
import plotly.io as pio
import tqdm

device = torch.device("cuda")  # Use GPU
sizes = [x * 5000 for x in range(1, 500)]  # Vectors of increasing sizes to test
num_iterations = 10  # Number of times to repeat each test

# %%
avg_times = []
bandwidths = []

for _ in range(10 * num_iterations):
    x = torch.randn(sizes[-1]).to(device)
    torch.relu(x)
torch.cuda.synchronize()

for size in tqdm.notebook.tqdm(sizes):
    x = torch.randn(size).to(
        device
    )  # Generate random tensor of size 'size' and move to GPU
    total_time = 0.0

    # warmup
    for i in range(num_iterations):
        torch.relu(x)
    torch.cuda.synchronize()

    for i in range(num_iterations):
        start_time = time.time_ns()  # Start timer
        torch.relu(x)
        torch.cuda.synchronize()
        end_time = time.time_ns()  # End timer
        total_time += end_time - start_time

    avg_time = total_time / num_iterations
    avg_times.append(avg_time / 1000)

    bandwidth = size * 4 / avg_time
    bandwidths.append(bandwidth)

# %%
# Save results in a CSV file
with open("relu_performance.csv", mode="w") as file:
    file.write("Size,Avg Time (ms),Bandwidth GB/s\n")
    for i in range(len(sizes)):
        file.write(f"{sizes[i]},{avg_times[i]},{bandwidths[i]}\n")

# %%
fig = go.Figure()
fig.add_trace(go.Scatter(x=sizes, y=avg_times, mode="lines", name="Avg Time (ms)"))
fig.add_trace(
    go.Scatter(x=sizes, y=bandwidths, mode="lines", name="Bandwidth GB/s", yaxis="y2")
)

fig.update_layout(
    title="ReLU performance on GPU",
    xaxis_title="Number of fp32 entries",
    yaxis_title="Avg Time (ms)",
    yaxis2=dict(title="Bandwidth GB/s", showgrid=True, overlaying="y", side="right"),
    legend=dict(x=0.05, y=0.95),
)

pio.write_image(fig, file="relu_performance.png", format="png")
fig.show()
