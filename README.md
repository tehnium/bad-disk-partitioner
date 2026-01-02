# Bad Disk Partitioner

A complete ncurses utility for scanning HDDs for bad blocks, partitioning around them, generating a PDF report, and checking SMART status.

## Features
- Interactive ncurses interface with disk selection
- Real-time progress bar for `badblocks`
- Automatic log generation
- PDF report export
- SMART monitoring
- Support for disks > 2 TB with 1 MB alignment

## Installation

Build the `.deb` package:

```bash
chmod +x build-bad-disk-deb.sh
./build-bad-disk-deb.sh
sudo dpkg -i /tmp/bad-disk-partitioner_1.1.deb
or download and install:
bad-disk-partitioner.deb


## After install launch in terminal
sudo bad-disk-partitioner

Is first my project so... dont shuuuut me down :))))
