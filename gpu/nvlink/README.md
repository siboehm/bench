# NVLINK

See also: https://github.com/NVIDIA/nccl-tests

## Results 
after NVLINK warmup

Device: NVIDIA RTX A6000

```txt
Transfer check passed
Size: 32.0B Time: 9μs BW (duplex): 3.32333 MB/s
Size: 64.0B Time: 8μs BW (duplex): 7.92455 MB/s
Size: 128.0B Time: 7μs BW (duplex): 16.7184 MB/s
Size: 256.0B Time: 7μs BW (duplex): 34.4473 MB/s
Size: 512.0B Time: 7μs BW (duplex): 67.2164 MB/s
Size: 1.0KB Time: 7μs BW (duplex): 135.65 MB/s
Size: 2.0KB Time: 7μs BW (duplex): 274.138 MB/s
Size: 4.1KB Time: 7μs BW (duplex): 534.988 MB/s
Size: 8.2KB Time: 7μs BW (duplex): 1049.89 MB/s
Size: 16.4KB Time: 8μs BW (duplex): 2094.53 MB/s
Size: 32.8KB Time: 8μs BW (duplex): 4157.92 MB/s
Size: 65.5KB Time: 8μs BW (duplex): 7999.63 MB/s
Size: 131.1KB Time: 9μs BW (duplex): 13780.1 MB/s
Size: 262.1KB Time: 12μs BW (duplex): 22039 MB/s
Size: 524.3KB Time: 17μs BW (duplex): 31104.9 MB/s
Size: 1.0MB Time: 28μs BW (duplex): 38022 MB/s
Size: 2.1MB Time: 48μs BW (duplex): 44069 MB/s
Size: 4.2MB Time: 89μs BW (duplex): 47764.8 MB/s
Size: 8.4MB Time: 172μs BW (duplex): 49866.4 MB/s
Size: 16.8MB Time: 336μs BW (duplex): 51094.4 MB/s
Size: 33.6MB Time: 665μs BW (duplex): 51645.8 MB/s
Size: 67.1MB Time: 1322μs BW (duplex): 51966.1 MB/s
Size: 134.2MB Time: 2636μs BW (duplex): 52120.2 MB/s
Size: 268.4MB Time: 5260μs BW (duplex): 52250.5 MB/s
Size: 536.9MB Time: 10523μs BW (duplex): 52240.3 MB/s
Size: 1.1GB Time: 21044μs BW (duplex): 52246.3 MB/s
```

```txt
GPU 0: NVIDIA RTX A6000 (UUID: GPU-5baec991-de63-c196-1766-04c38407e133)
	 Link 0: 14.062 GB/s
	 Link 1: 14.062 GB/s
	 Link 2: 14.062 GB/s
	 Link 3: 14.062 GB/s
GPU 1: NVIDIA RTX A6000 (UUID: GPU-39fc2446-cb50-2067-2867-d95efd470a2c)
	 Link 0: 14.062 GB/s
	 Link 1: 14.062 GB/s
	 Link 2: 14.062 GB/s
	 Link 3: 14.062 GB/s
GPU 2: NVIDIA RTX A6000 (UUID: GPU-02c05ee3-bdb5-aac7-f9e8-a4c8f3f725b3)
NVML: Unable to retrieve NVLink information as all links are inActive
```

![](nvlink.png)

To figure out connectivity:
```
> nvidia-smi topo -m
	[4mGPU0	GPU1	GPU2	CPU Affinity	NUMA Affinity[0m
GPU0	 X 	NV4	NODE	0-31,64-95	0
GPU1	NV4	 X 	NODE	0-31,64-95	0
GPU2	NODE	NODE	 X 	0-31,64-95	0

Legend:

  X    = Self
  SYS  = Connection traversing PCIe as well as the SMP interconnect between NUMA nodes (e.g., QPI/UPI)
  NODE = Connection traversing PCIe as well as the interconnect between PCIe Host Bridges within a NUMA node
  PHB  = Connection traversing PCIe as well as a PCIe Host Bridge (typically the CPU)
  PXB  = Connection traversing multiple PCIe bridges (without traversing the PCIe Host Bridge)
  PIX  = Connection traversing at most a single PCIe bridge
  NV#  = Connection traversing a bonded set of # NVLinks
```

```bash
> nvidia-smi nvlink -s
GPU 0: NVIDIA RTX A6000 (UUID: GPU-5baec991-de63-c196-1766-04c38407e133)
	 Link 0: 14.062 GB/s
	 Link 1: 14.062 GB/s
	 Link 2: 14.062 GB/s
	 Link 3: 14.062 GB/s
GPU 1: NVIDIA RTX A6000 (UUID: GPU-39fc2446-cb50-2067-2867-d95efd470a2c)
	 Link 0: 14.062 GB/s
	 Link 1: 14.062 GB/s
	 Link 2: 14.062 GB/s
	 Link 3: 14.062 GB/s
GPU 2: NVIDIA RTX A6000 (UUID: GPU-02c05ee3-bdb5-aac7-f9e8-a4c8f3f725b3)
NVML: Unable to retrieve NVLink information as all links are inActive
```

Currently, maximum possible inter-node connectivity is a dense web of 8 GPUs, connected via 12 Links.
More than 8 GPUs are supported by using NVSwitch.


