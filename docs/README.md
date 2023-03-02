# Hello

NCCL Latencies: https://github.com/NVIDIA/nccl-tests/issues/68

See https://gist.github.com/eshelman/343a1c46cb3fba142c1afdcdeec17646

Also: https://github.com/te42kyfo/cuda-benches

https://github.com/stas00/toolbox/blob/master/pytorch/all_reduce_bench.py

- NVLink speeds
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

## Bandwidths:

| Fabric | Latency | Throughput | 1MB | 1GB |
| ------------ | ------- | ---------- | --- | --- |
| 16x PCIe 4.0 | 10 μs   | 20GB/s  (full duplex)   | 75μs| 50ms|

## Costs:

## LLMs:
| Metric | Value |
| ------------ | ------- |
| Latency (ChatGPT-esque system) | 500 - 1000 WPM |
