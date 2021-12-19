
# cache-bench

[![Total alerts](https://img.shields.io/lgtm/alerts/g/hakavlad/cache-bench.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/cache-bench/alerts/)

Explore the impact of virtual memory settings on caching efficiency on Linux systems under memory pressure.

The script reads the specified file in chunks of the specified size in random order (with `--read` option) and logs the result with a specified interval.

Optionally read chunks are added to the list, thus increasing the memory consumption of the process for creating memory pressure and paging.

The script can be used, for example, to assess the impact of virtual memory settings (`vm.swappiness`, `vm.watermark_scale_factor`, Multigenerational LRU Framework etc) on the efficiency of file caching, especially under memory pressure. The script allows you to evaluate the performance of I/O operations under memory pressure.

## Options

```
$ cache-bench -h
usage: cache-bench [-h] [-f FILE] [-r READ] [-w WRITE] [-m MMAP] [-p PREREAD] [-b BLOAT] [-c CHUNK] [-i INTERVAL] [-l LOG]

optional arguments:
  -h, --help            show this help message and exit
  -f FILE, --file FILE  path to the file to be read or written
  -r READ, --read READ  how many mebibytes to read from the file
  -w WRITE, --write WRITE
                        size of the file being written
  -m MMAP, --mmap MMAP  mmap the file (0 | 1)
  -p PREREAD, --preread PREREAD
                        preread the file (0 | 1)
  -b BLOAT, --bloat BLOAT
                        bloat process memory (0 | 1)
  -c CHUNK, --chunk CHUNK
                        chunk size in KiB
  -i INTERVAL, --interval INTERVAL
                        output interval in seconds
  -l LOG, --log LOG     path to the log file
```

#### -f FILE, --file FILE
Path to the file to be read or written. Default value: `testfile.bench`.

#### -r READ, --read READ
How many mebibytes to read from the specified file.

#### -w WRITE, --write WRITE
The size of the file to create, in mebibytes. This is just an auxiliary option to create a file of the desired size.

#### -m MMAP, --mmap MMAP
mmap the file. Valid values: `0` and `1`. Default value: `0`. If set to `1`, the file will be memory-mapped and the reading will be done from the memory-mapped file object.

#### -p PREREAD, --preread PREREAD
Preread the file. Valid values: `0` and `1`. Default value: `0`. If set to `1`, the file will first be preread completely sequentially by mebibyte chunks.

#### -b BLOAT, --bloat BLOAT
Bloat process memory. Valid values: `0` and `1`. Default value: `0`. If set to `1`, the chunks will be added to the list and the memory consumed by the process will increase. This option can be used to create memory pressure during tests.

#### -c CHUNK, --chunk CHUNK
Chunk size in KiB. Default value: `64`. The file will be read by chunks of a given size in random order.

#### -i INTERVAL, --interval INTERVAL
Output (log) interval in seconds. Default value: `2`.

#### -l LOG, --log LOG
Path to the log file. The output will be written with timestamps.

## Usage

Select or create a file. You can use any existing file (with `--file` option), or create a test file of the desired size with the `--write` option:
```
$ cache-bench -w 300
starting cache-bench
  file: testfile.bench
  file size: 300 MiB
writing the file...
fsync...
OK
```

Optionally remove extraneous disk caches. You can use the `drop-caches` script:
```
$ drop-caches
#!/bin/sh -v
sudo sync
[sudo] password for user:
echo 3 | sudo tee /proc/sys/vm/drop_caches
3
```

Run the script with `-r` option. The default behavior is to read the data size specified by the `--read` option in 64k chunks in random order:
```
$ cache-bench -r 25000 -i 5
starting cache-bench
  file: testfile.bench
  file size: 300.0 MiB
  log file is not set
  output interval: 5.0s
  mmap: 0, preread: 0, bloat: 0, chunk: 64 KiB
reading 25000.0 MiB from the file...
  read 45.0M in 5.0s (9.0M/s); total 45.0M in 5.0s, avg 9.0M/s
  read 46.9M in 5.0s (9.4M/s); total 91.9M in 10.0s, avg 9.2M/s
  read 55.6M in 5.0s (11.1M/s); total 147.4M in 15.0s, avg 9.8M/s
  read 68.5M in 5.0s (13.7M/s); total 215.9M in 20.0s, avg 10.8M/s
  read 92.4M in 5.0s (18.5M/s); total 308.3M in 25.0s, avg 12.3M/s
  read 196.2M in 5.0s (39.2M/s); total 504.5M in 30.0s, avg 16.8M/s
  read 7619.3M in 5.0s (1523.9M/s); total 8123.8M in 35.0s, avg 231.9M/s
  read 16041.2M in 5.0s (3208.2M/s); total 24165.1M in 40.0s, avg 603.6M/s
  read 835.0M in 0.3s (3270.5M/s); total 25000.0M in 40.3s, avg 620.5M/s
total read 25000.0 MiB in 40.3s (avg 620.5 MiB/s)
```
In the output of the script you can observe the current reading speed, the amount of data read per time interval, the average values during the reading time.

With the `--bloat` option you can investigate the effectiveness of caching when memory is low and the effect of the VM settings on the result:
```
$ cache-bench -r 15000 -i 4 -b 1 -p 1
starting cache-bench
  file: testfile.bench
  file size: 300.0 MiB
  log file is not set
  output interval: 4.0s
  mmap: 0, preread: 1, bloat: 1, chunk: 64 KiB
prereading (caching) the file...
  preread 300.0 MiB (100.0%) in 2.6s
reading 15000.0 MiB from the file...
  read 7042.6M in 4.0s (1760.7M/s); total 7042.6M in 4.0s, avg 1760.7M/s
  read 3541.1M in 4.0s (884.7M/s); total 10583.7M in 8.0s, avg 1322.5M/s
  read 68.6M in 4.0s (17.1M/s); total 10652.4M in 12.0s, avg 886.8M/s
  read 46.1M in 4.0s (11.5M/s); total 10698.4M in 16.0s, avg 667.8M/s
  read 51.3M in 4.0s (12.8M/s); total 10749.7M in 20.0s, avg 536.7M/s
  read 55.8M in 4.0s (13.9M/s); total 10805.5M in 24.0s, avg 449.6M/s
  read 74.3M in 4.0s (18.6M/s); total 10879.9M in 28.0s, avg 388.0M/s
  read 99.9M in 4.0s (24.9M/s); total 10979.7M in 32.0s, avg 342.7M/s
  read 169.5M in 4.0s (42.3M/s); total 11149.2M in 36.0s, avg 309.3M/s
  read 420.6M in 4.0s (105.1M/s); total 11569.8M in 40.1s, avg 288.9M/s
  read 2277.9M in 4.0s (569.5M/s); total 13847.7M in 44.1s, avg 314.4M/s
  read 1152.3M in 1.1s (1042.2M/s); total 15000.0M in 45.2s, avg 332.2M/s
total read 15000.0 MiB in 45.2s (avg 332.2 MiB/s)
```

Optionally, you can specify the path to the log file. Log file example:
```
2021-12-18 19:44:14,306: starting cache-bench
2021-12-18 19:44:14,307:   file: testfile.bench
2021-12-18 19:44:14,307:   file size: 200.0 MiB
2021-12-18 19:44:14,307:   log file: /tmpfs/log
2021-12-18 19:44:14,307:   output interval: 2s
2021-12-18 19:44:14,308:   mmap: 1, preread: 1, bloat: 1, chunk: 32 KiB
2021-12-18 19:44:14,308: prereading (caching) the file...
2021-12-18 19:44:16,041:   preread 200.0 MiB (100.0%) in 1.7s
2021-12-18 19:44:16,046: reading 8000.0 MiB from the file...
2021-12-18 19:44:18,047:   read 3071.6M in 2.0s (1535.8M/s); total 3071.6M in 2.0s, avg 1535.8M/s
2021-12-18 19:44:20,047:   read 3111.0M in 2.0s (1555.5M/s); total 6182.6M in 4.0s, avg 1545.6M/s
2021-12-18 19:44:21,233:   read 1817.4M in 1.2s (1531.6M/s); total 8000.0M in 5.2s, avg 1542.4M/s
2021-12-18 19:44:21,233: total read 8000.0 MiB in 5.2s (avg 1542.4 MiB/s)
```

During the tests, you can check the state of the system (cache size, memory and io pressure, disk activity etc) using additional tools: `mem2log`, `psi2log`, `iostat`, `vmstat` etc.

## Requirements

- Python 3.3+

## Installation

Install
```sh
$ git clone https://github.com/hakavlad/cache-bench.git && cd cache-bench
$ sudo make install
```
`cache-bench` and `drop-caches` scripts will be installed in `/usr/local/bin`.

Uninstall
```sh
$ sudo make uninstall
```

## See also

Documentation for `/proc/sys/vm/`:
- https://www.kernel.org/doc/html/latest/admin-guide/sysctl/vm.html

Multigenerational LRU Framework at LKML:
- v1: https://lore.kernel.org/lkml/20210313075747.3781593-1-yuzhao@google.com/
- v2: https://lore.kernel.org/lkml/20210413065633.2782273-1-yuzhao@google.com/
- v3: https://lore.kernel.org/lkml/20210520065355.2736558-1-yuzhao@google.com/
- v4: https://lore.kernel.org/lkml/20210818063107.2696454-1-yuzhao@google.com/
- v5: https://lore.kernel.org/lkml/20211111041510.402534-1-yuzhao@google.com/

le9 patch can be used to protect the specified amount of cache:
- https://github.com/hakavlad/le9-patch

Daemons that can affect file reading performance:
- [prelockd](https://github.com/hakavlad/prelockd): Lock executables and shared libraries in memory to improve system responsiveness under low-memory conditions;
- [memavaild](https://github.com/hakavlad/memavaild): Keep amount of available memory by evicting memory of selected cgroups into swap space.

These tools may be used to monitor memory and PSI metrics during stress tests:
- [mem2log](https://github.com/hakavlad/mem2log) may be used to log memory metrics from `/proc/meminfo`;
- [psi2log](https://github.com/hakavlad/nohang/blob/master/docs/psi2log.manpage.md) from [nohang](https://github.com/hakavlad/nohang) package may be used to log [PSI](https://facebookmicrosites.github.io/psi/docs/overview) metrics during tests.

