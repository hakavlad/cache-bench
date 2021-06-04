
# cache-bench

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
usage: cache-bench [-h] [-p PATH] [-r READ] [-w WRITE] [-l LOG]

optional arguments:
  -h, --help            show this help message and exit
  -p PATH, --path PATH  path to the directory to write or read files
  -r READ, --read READ  how many mebibytes will be read from the files in the directory
  -w WRITE, --write WRITE
                        the number of mebibyte files to be written to the directory
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
$ cache-bench -w 5
mkdir testdir1
written testdir1/0.8413038645799809; total size: 1M
written testdir1/0.5403515973223167; total size: 2M
written testdir1/0.48694162517240913; total size: 3M
written testdir1/0.336817161455191; total size: 4M
written testdir1/0.18382311079398506; total size: 5M
OK
```

```
$ cache-bench -r 10
found 5 regular files in testdir1, total size: 5.0M
setting self oom_score_adj=1000
reading files from the directory testdir1
read 1.0M (10.0%) in 0.0s (avg 24.6M/s); file 0.336817161455191
read 2.0M (20.0%) in 0.0s (avg 48.4M/s); file 0.336817161455191
read 3.0M (30.0%) in 0.1s (avg 42.9M/s); file 0.8413038645799809
read 4.0M (40.0%) in 0.1s (avg 41.2M/s); file 0.48694162517240913
read 5.0M (50.0%) in 0.1s (avg 42.0M/s); file 0.18382311079398506
read 6.0M (60.0%) in 0.1s (avg 40.1M/s); file 0.5403515973223167
read 7.0M (70.0%) in 0.2s (avg 46.3M/s); file 0.18382311079398506
read 8.0M (80.0%) in 0.2s (avg 52.7M/s); file 0.336817161455191
read 9.0M (90.0%) in 0.2s (avg 59.0M/s); file 0.18382311079398506
read 10.0M (100.0%) in 0.2s (avg 65.2M/s); file 0.8413038645799809
--
read 10.0M in 0.2s (avg 65.2M/s); src: 5 files, 5.0M
OK
User defined signal 1
```

Log file example:
```
2021-05-30 21:47:56,084: mkdir testdir1
2021-05-30 21:47:56,211: written testdir1/0.9860985015646311; total size: 1M
2021-05-30 21:47:56,289: written testdir1/0.0691916965192153; total size: 2M
2021-05-30 21:47:56,377: written testdir1/0.27868153831296383; total size: 3M
2021-05-30 21:47:56,455: written testdir1/0.7341114648416274; total size: 4M
2021-05-30 21:47:56,533: written testdir1/0.5363495159203434; total size: 5M
2021-05-30 21:47:56,533: OK
2021-05-30 21:48:23,193: found 5 regular files in testdir1, total size: 5.0M
2021-05-30 21:48:23,199: setting self oom_score_adj=1000
2021-05-30 21:48:23,199: reading files from the directory testdir1
2021-05-30 21:48:23,229: read 1.0M (20.0%) in 0.0s (avg 32.9M/s); file 0.7341114648416274
2021-05-30 21:48:23,296: read 2.0M (40.0%) in 0.1s (avg 20.8M/s); file 0.0691916965192153
2021-05-30 21:48:23,298: read 3.0M (60.0%) in 0.1s (avg 30.3M/s); file 0.0691916965192153
2021-05-30 21:48:23,299: read 4.0M (80.0%) in 0.1s (avg 40.1M/s); file 0.7341114648416274
2021-05-30 21:48:23,352: read 5.0M (100.0%) in 0.2s (avg 32.6M/s); file 0.27868153831296383
2021-05-30 21:48:23,353: --
2021-05-30 21:48:23,353: read 5.0M in 0.2s (avg 32.6M/s); src: 5 files, 5.0M
2021-05-30 21:48:23,354: OK
```

## Requirements

- Python 3.3+

## Install
```sh
$ git clone https://github.com/hakavlad/cache-bench.git
$ cd cache-bench
$ sudo make install
```
`cache-bench` and `drop-caches` scripts will be installed in `/usr/local/bin`.

## Uninstall
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
