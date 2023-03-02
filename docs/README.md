NCCL Latencies: https://github.com/NVIDIA/nccl-tests/issues/68

See https://gist.github.com/eshelman/343a1c46cb3fba142c1afdcdeec17646

Also: https://github.com/te42kyfo/cuda-benches

https://github.com/stas00/toolbox/blob/master/pytorch/all_reduce_bench.py

- FLOPS / parameter
- common GPU utilization
- Look at Lennart's posts again -> How does he estimate the costs?
- AI and compute -> How did they count the flops?
- kernel launch latency
- PCIe bandwidth & NVLink bandwidth
- Can matmul kernels just be approximated with max FLOPs counts?
- Memory demand for training:
    - parameters 
    - activations
    - Optimizers state:
        - Adam: 2 * parameters
        - SGD: 0

# GPU latency numbers that a very small number of people might profit from being able to look up quickly

## Latencies

| What               | Latency |
|--------------------|---------|
| CPU function call  | 3ns     |
| CUDA kernel launch | 3μs     |


## Bandwidths:

### Memory

| Device               | Latency | Throughput (per direction) | 1MB | 1GB | Example GPUs | Source |
|----------------------|---------|----------------------------|-----|-----|--------------|--------|
| GPU GMEM to Register |         | 700 GB/s                   |     |     | A6000        |        |
| GPU GMEM to Register |         | 2 TB/s                     |     |     | A100 SXM     |        |

### Interconnect

| Device                 | Fabric         | Latency | Throughput (per direction) | 1MB  | 1GB  | Example GPUs |
|------------------------|----------------|---------|----------------------------|------|------|--------------|
| GPU to CPU             | 16x PCIe 4.0   | 10 μs   | 20 GB/s                    | 75μs | 50ms | A100, A6000  |
| GPU to GPU (same node) | 4x NVLink 3.0  | 10 μs   | 50 GB/s                    | 25μs | 20ms | A6000        |
| GPU to GPU (same node) | 12x NVLink 3.0 | 10 μs   | 300 GB/s                   | 25μs | 5ms  | A100         |

## Costs:

| Device   | Properties                                                                                     | Cost/h (Spot instance) | Cost (purchase) |
|----------|------------------------------------------------------------------------------------------------|------------------------|-----------------|
| A100     | 80GB GMEM, 300 TFLOPs bfloat16                                                                 | 3$                     | 10.000$         |
| RTX 3090 | 24GB GMEM, 150 TFLOPs bfloat16 [^rtx3090perf](https://en.wikipedia.org/wiki/GeForce_30_series) | not allowed in cloud   | 1000$           |

## LLMs:
| Metric                         | Value          |
|--------------------------------|----------------|
| Latency (ChatGPT-esque system) | 500 - 1000 WPM |
