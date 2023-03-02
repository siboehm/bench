#!/usr/bin/env bash

DEVICE_NAME=$( nvidia-smi --query-gpu=gpu_name --format=csv,noheader | head -n 1)
README=$( realpath README.md )

echo "# NVLINK

See also: https://github.com/NVIDIA/nccl-tests

${DEVICE_NAME} 16x PCIe 4.0:
![](nvlink.png)

Device: ${DEVICE_NAME}

To figure out connectivity:
\`\`\`
nvidia-smi topo -m
\`\`\`

\`\`\`bash
> lspci -vvv -s 06:00.0 | grep -i 'LnkCap\|LnkSta'
LnkCap:	Port #0, Speed 16GT/s, Width x16, ASPM not supported
LnkSta:	Speed 16GT/s (ok), Width x16 (ok)
LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete+, EqualizationPhase1+
\`\`\`

16GT/s tells you that you are using PCIe 4.0 (check [Wikipedia](https://en.wikipedia.org/wiki/PCI_Express) for more info

Results will depend on (among other things):
- PCIe version
- Number of lanes used
- CPU governor settings (set to performance)

Results after PCIe warmup:

\`\`\`txt" > ${README} 

./build/bench_nvlink >> ${README}

echo "\`\`\`" >> ${README} 
