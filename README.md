
# cache-bench

[![Total alerts](https://img.shields.io/lgtm/alerts/g/hakavlad/cache-bench.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/cache-bench/alerts/)

Explore the impact of virtual memory settings on caching efficiency on Linux systems under memory pressure.

`cache-bench` is a Python script that can: 
- create the specified number of mebibyte files in the specified directory;
- read the specified volume of files from the directory in random order and add the resulting volume to the list in memory;
- show time and average reading speed;
- log results in the specified file.

The script can be used, for example, to assess the impact of virtual memory settings (`vm.swappiness`, `vm.watermark_scale_factor`, Multigenerational LRU Framework etc) on the efficiency of file caching, especially under memory pressure. The script allows you to evaluate the performance of I/O operations under memory pressure.

## Usage

Options:

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

Create a directory with the specified number of mebibyte files. 
```
cache-bench -w 300
```
In this case, 300 mebibyte files will be created in the `testdir1` directory (this is the default name; you can specify a different directory with the `-p` option). 

Drop caches and write dirty cache:
```sh
$ drop-caches
#!/bin/sh -v
sudo sync
[sudo] password for user: 
echo 3 | sudo tee /proc/sys/vm/drop_caches
3
```

Next, run the test. Be careful when choosing a reading volume: the system can reach OOM or freeze. One useful option is to read as much as needed to move a significant amount of memory to the swap space. Read the files from the directory in random order.
```
cache-bench -r 20000
```
In this case, 20000 MiB files will be read in random order from the default directory. 

Optionally, you can specify the path to the log file. 

## Output examples

```
$ cache-bench -w 200
starting cache-bench
  file: testfile.bench
  file size: 200 MiB
writing the file...
fsync...
OK
```

```
$ cache-bench --read 8000 --chunk 32 --mmap 1 --preread 1 --bloat 1
starting cache-bench
  file: testfile.bench
  file size: 200.0 MiB
  log file is not set
  output interval: 2s
  mmap: 1, preread: 1, bloat: 1, chunk: 32 KiB
prereading (caching) the file...
  preread 200.0 MiB (100.0%) in 1.7s
reading 8000.0 MiB from the file...
  read 3053.4M in 2.0s (1526.7M/s); total 3053.4M in 2.0s, avg 1526.7M/s
  read 3077.7M in 2.0s (1538.9M/s); total 6131.2M in 4.0s, avg 1532.8M/s
  read 1868.8M in 1.2s (1504.4M/s); total 8000.0M in 5.2s, avg 1526.1M/s
total read 8000.0 MiB in 5.2s (avg 1526.0 MiB/s)
```

Log file example:
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

These tools may be used to monitor memory and PSI metrics during stress tests:
- [mem2log](https://github.com/hakavlad/mem2log) may be used to log memory metrics from `/proc/meminfo`;
- [psi2log](https://github.com/hakavlad/nohang/blob/master/docs/psi2log.manpage.md) from [nohang](https://github.com/hakavlad/nohang) package may be used to log [PSI](https://facebookmicrosites.github.io/psi/docs/overview) metrics during tests.

Documentation for `/proc/sys/vm/`:
- https://www.kernel.org/doc/html/latest/admin-guide/sysctl/vm.html

Multigenerational LRU Framework at LKML:
- https://lore.kernel.org/lkml/20210313075747.3781593-1-yuzhao@google.com/
- https://lore.kernel.org/lkml/20210413065633.2782273-1-yuzhao@google.com/
- https://lore.kernel.org/lkml/20210520065355.2736558-1-yuzhao@google.com/

Daemons that can affect file reading performance:
- [prelockd](https://github.com/hakavlad/prelockd): Lock executables and shared libraries in memory to improve system responsiveness under low-memory conditions;
- [memavaild](https://github.com/hakavlad/memavaild): Keep amount of available memory by evicting memory of selected cgroups into swap space.
