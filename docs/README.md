NCCL Latencies: https://github.com/NVIDIA/nccl-tests/issues/68

See https://gist.github.com/eshelman/343a1c46cb3fba142c1afdcdeec17646

Also: https://github.com/te42kyfo/cuda-benches

https://github.com/stas00/toolbox/blob/master/pytorch/all_reduce_bench.py

- FLOPS / parameter
- common GPU utilization
- Look at Lennart's posts again -> How does he estimate the costs?
- AI and compute -> How did they count the flops?
- kernel launch latency
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

| Device                      | Fabric            | Latency | Bandwidth per direction | 1MB  | 1GB  | Example GPUs |
|-----------------------------|-------------------|---------|-------------------------|------|------|--------------|
| GPU to CPU                  | 16x PCIe 4.0      | 10 μs   | 20 GB/s                 | 75μs | 50ms | A100, A6000  |
| GPU to GPU (same node)      | 4x NVLink 3.0     | 10 μs   | 50 GB/s                 | 25μs | 20ms | A6000        |
| GPU to GPU (same node)      | 12x NVLink 3.0    | 10 μs   | 300 GB/s                | 25μs | 5ms  | A100         |
| GPU to GPU (different node) | Infiniband        | ?       | ?                       | ?    | ?    |              |
| GPU to GPU (different node) | TCP over Ethernet | ?       | ?                       | ?    | ?    |              |

## Costs:

| Device   | Properties                                    | Cost/h (Spot instance)          | Cost (purchase) |
|----------|-----------------------------------------------|---------------------------------|-----------------|
| A100     | 80GB GMEM, 300 TFLOPs bfloat16                | 5$ [^awsP4]                     | 10.000$         |
| RTX 3090 | 24GB GMEM, 150 TFLOPs bfloat16 [^rtx3090perf] | not allowed [^consumerGpuCloud] | 1000$           |

## LLMs

| Metric                                  | Value                    |
|-----------------------------------------|--------------------------|
| Latency (ChatGPT-esque system)          | 500 to 1000 WPM          |
| OpenAI API cost per 1K tokens (~1 page) | 0,01 $ [^openaiPrincing] |
| Tokens per word                         | 1                        |


[^awsP4]: https://aws.amazon.com/ec2/instance-types/p4/
[^rtx3090perf]: https://en.wikipedia.org/wiki/GeForce_30_series
[^consumerGpuCloud]: https://www.nvidia.com/en-us/drivers/geforce-license/
    > No Datacenter Deployment. The SOFTWARE is not licensed for datacenter deployment, except that blockchain processing in a datacenter is permitted.
[^openaiPricing]: https://openai.com/pricing
