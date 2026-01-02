# Bad Disk Partitioner

This project is inspired by an older tool developed by Dmitri Primochenko called Repartition Bad Drive, which ran on Windows but had specific hardware requirements, such as the HDD needing to be in IDE mode. My application aims to achieve the same results on Linux (Debian-based distributions).

## Key Features and Workflow:
Automated Setup: It automatically installs all necessary dependencies.

Safety Check: The app checks if the HDD has existing partitions; if it does, the application will close to prevent accidental data loss.

Partition Management: Just like the original RBD, this tool destroys all existing partitions on the selected drive. I strongly recommend that you back up your data and manually delete all partitions before running this program.

Drive Selection: It lists all active HDDs so you can choose which one to scan.

Scanning Logic: When a bad sector is detected, the app creates an unformatted partition that ends 100 MB before the bad sector and starts a new one 100 MB after it. To avoid excessive fragmentation, a new partition will not be created if the bad sectors are less than 5 GB apart.

Reporting: Upon completion, the program generates a PDF report of the execution process.

## Disclaimer:
I ASSUME NO RESPONSIBILITY FOR ANY DATA LOSS. Please take all necessary precautions to ensure no mistakes are made during the process.



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
