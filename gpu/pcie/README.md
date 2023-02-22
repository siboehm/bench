# PCIe

A100 40GB SMX, 16x PCIe 4.0:
![](pcie.png)

Device: NVIDIA A100-SXM4-40GB
```
------- Running PCIe Normal ------

Size: 32.0B Time: 46μs BW (Dev to Host): 0.69926 MB/s
Size: 64.0B Time: 23μs BW (Dev to Host): 2.8346 MB/s
Size: 128.0B Time: 21μs BW (Dev to Host): 6.1739 MB/s
Size: 256.0B Time: 20μs BW (Dev to Host): 12.6025 MB/s
Size: 512.0B Time: 20μs BW (Dev to Host): 25.4868 MB/s
Size: 1.0KB Time: 20μs BW (Dev to Host): 50.6314 MB/s
Size: 2.0KB Time: 20μs BW (Dev to Host): 100.776 MB/s
Size: 4.1KB Time: 21μs BW (Dev to Host): 194.361 MB/s
Size: 8.2KB Time: 23μs BW (Dev to Host): 361.111 MB/s
Size: 16.4KB Time: 29μs BW (Dev to Host): 566.587 MB/s
Size: 32.8KB Time: 40μs BW (Dev to Host): 828.3 MB/s
Size: 65.5KB Time: 63μs BW (Dev to Host): 1057.32 MB/s
Size: 131.1KB Time: 100μs BW (Dev to Host): 1336.95 MB/s
Size: 262.1KB Time: 173μs BW (Dev to Host): 1545.11 MB/s
Size: 524.3KB Time: 319μs BW (Dev to Host): 1682.8 MB/s
Size: 1.0MB Time: 643μs BW (Dev to Host): 1667.64 MB/s
Size: 2.1MB Time: 1105μs BW (Dev to Host): 1942.66 MB/s
Size: 4.2MB Time: 2251μs BW (Dev to Host): 1907.67 MB/s
Size: 8.4MB Time: 4298μs BW (Dev to Host): 1998.47 MB/s
Size: 16.8MB Time: 8279μs BW (Dev to Host): 2074.96 MB/s
Size: 33.6MB Time: 16663μs BW (Dev to Host): 2061.95 MB/s
Size: 67.1MB Time: 33566μs BW (Dev to Host): 2047.26 MB/s
Size: 134.2MB Time: 66215μs BW (Dev to Host): 2075.64 MB/s
Size: 268.4MB Time: 129815μs BW (Dev to Host): 2117.45 MB/s
Size: 536.9MB Time: 256325μs BW (Dev to Host): 2144.76 MB/s
Size: 1.1GB Time: 520195μs BW (Dev to Host): 2113.65 MB/s

----- Running PCIe Pinned ------

Size: 32.0B Time: 33μs BW (each direction): 0.946718 MB/s
Size: 64.0B Time: 13μs BW (each direction): 4.65827 MB/s
Size: 128.0B Time: 12μs BW (each direction): 10.1579 MB/s
Size: 256.0B Time: 12μs BW (each direction): 21.1221 MB/s
Size: 512.0B Time: 12μs BW (each direction): 40.96 MB/s
Size: 1.0KB Time: 12μs BW (each direction): 82.7809 MB/s
Size: 2.0KB Time: 12μs BW (each direction): 167.047 MB/s
Size: 4.1KB Time: 12μs BW (each direction): 328.495 MB/s
Size: 8.2KB Time: 13μs BW (each direction): 618.311 MB/s
Size: 16.4KB Time: 15μs BW (each direction): 1088.64 MB/s
Size: 32.8KB Time: 17μs BW (each direction): 1916.15 MB/s
Size: 65.5KB Time: 16μs BW (each direction): 3866.43 MB/s
Size: 131.1KB Time: 20μs BW (each direction): 6533.35 MB/s
Size: 262.1KB Time: 26μs BW (each direction): 9810.78 MB/s
Size: 524.3KB Time: 45μs BW (each direction): 11576 MB/s
Size: 1.0MB Time: 73μs BW (each direction): 14314.6 MB/s
Size: 2.1MB Time: 128μs BW (each direction): 16353.1 MB/s
Size: 4.2MB Time: 238μs BW (each direction): 17555 MB/s
Size: 8.4MB Time: 457μs BW (each direction): 18333.9 MB/s
Size: 16.8MB Time: 893μs BW (each direction): 18768.7 MB/s
Size: 33.6MB Time: 1776μs BW (each direction): 18887.1 MB/s
Size: 67.1MB Time: 3519μs BW (each direction): 19068.9 MB/s
Size: 134.2MB Time: 7020μs BW (each direction): 19119 MB/s
Size: 268.4MB Time: 14013μs BW (each direction): 19154.9 MB/s
Size: 536.9MB Time: 27995μs BW (each direction): 19177.2 MB/s
Size: 1.1GB Time: 55958μs BW (each direction): 19188.2 MB/s

----- Running PCIe Pinned Write Combined ------

Size: 32.0B Time: 34μs BW (Dev to Host): 0.939692 MB/s
Size: 64.0B Time: 16μs BW (Dev to Host): 4.07081 MB/s
Size: 128.0B Time: 13μs BW (Dev to Host): 9.38239 MB/s
Size: 256.0B Time: 16μs BW (Dev to Host): 16.262 MB/s
Size: 512.0B Time: 17μs BW (Dev to Host): 30.3777 MB/s
Size: 1.0KB Time: 25μs BW (Dev to Host): 41.9095 MB/s
Size: 2.0KB Time: 31μs BW (Dev to Host): 66.2586 MB/s
Size: 4.1KB Time: 59μs BW (Dev to Host): 70.7159 MB/s
Size: 8.2KB Time: 89μs BW (Dev to Host): 93.6093 MB/s
Size: 16.4KB Time: 193μs BW (Dev to Host): 86.9223 MB/s
Size: 32.8KB Time: 19μs BW (Dev to Host): 1743 MB/s
Size: 65.5KB Time: 19μs BW (Dev to Host): 3513.55 MB/s
Size: 131.1KB Time: 24μs BW (Dev to Host): 5420.31 MB/s
Size: 262.1KB Time: 36μs BW (Dev to Host): 7306.16 MB/s
Size: 524.3KB Time: 46μs BW (Dev to Host): 11454.2 MB/s
Size: 1.0MB Time: 73μs BW (Dev to Host): 14541.3 MB/s
Size: 2.1MB Time: 128μs BW (Dev to Host): 16706.5 MB/s
Size: 4.2MB Time: 237μs BW (Dev to Host): 18054.1 MB/s
Size: 8.4MB Time: 457μs BW (Dev to Host): 18783.8 MB/s
Size: 16.8MB Time: 894μs BW (Dev to Host): 19213.1 MB/s
Size: 33.6MB Time: 1770μs BW (Dev to Host): 19408.1 MB/s
Size: 67.1MB Time: 3529μs BW (Dev to Host): 19472.2 MB/s
Size: 134.2MB Time: 7023μs BW (Dev to Host): 19569.2 MB/s
Size: 268.4MB Time: 14014μs BW (Dev to Host): 19614 MB/s
Size: 536.9MB Time: 27994μs BW (Dev to Host): 19638 MB/s
Size: 1.1GB Time: 55957μs BW (Dev to Host): 19648.9 MB/s
```
