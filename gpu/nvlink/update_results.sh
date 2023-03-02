#!/usr/bin/env bash

NVLINK_SETUP=$( nvidia-smi nvlink -s )
NVLINK_TOPO=$( nvidia-smi topo -m )
DEVICE_NAME=$( nvidia-smi --query-gpu=gpu_name --format=csv,noheader | head -n 1)
README=$( realpath README.md )

echo "# NVLINK

See also: https://github.com/NVIDIA/nccl-tests

\`\`\`txt
${NVLINK_SETUP}
\`\`\`

![](nvlink.png)

Device: ${DEVICE_NAME}

To figure out connectivity:
\`\`\`
> nvidia-smi topo -m
${NVLINK_TOPO}
\`\`\`

\`\`\`bash
> nvidia-smi nvlink -s
${NVLINK_SETUP}
\`\`\`

Results after NVLINK warmup:

\`\`\`txt" > ${README} 

./build/bench_nvlink >> ${README}

echo "\`\`\`" >> ${README} 
