#!/usr/bin/env bash

NVLINK_SETUP=$( nvidia-smi nvlink -s )
NVLINK_TOPO=$( nvidia-smi topo -m )
DEVICE_NAME=$( nvidia-smi --query-gpu=gpu_name --format=csv,noheader | head -n 1)
README=$( realpath README.md )
RESULTS=$( ./build/bench_nvlink )

echo "# NVLINK

See also: https://github.com/NVIDIA/nccl-tests

## Results 
after NVLINK warmup

Device: ${DEVICE_NAME}

\`\`\`txt
${RESULTS}
\`\`\`

\`\`\`txt
${NVLINK_SETUP}
\`\`\`

![](nvlink.png)

To figure out connectivity:
\`\`\`
> nvidia-smi topo -m
${NVLINK_TOPO}
\`\`\`

\`\`\`bash
> nvidia-smi nvlink -s
${NVLINK_SETUP}
\`\`\`

Currently, maximum possible inter-node connectivity is a dense web of 8 GPUs, connected via 12 Links.
>8 GPUs are supported via NVSwitch.

" > ${README} 
