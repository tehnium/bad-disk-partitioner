# Bad Disk Partitioner

This project is inspired by an older tool developed by Dmitri Primochenko called Repartition Bad Drive, which ran on Windows but had specific hardware requirements, such as requiring the HDD to be in IDE mode. My application aims to achieve the same results on Linux (Debian-based distributions).

## Key Features and Workflow:
Automated Setup: It automatically installs all necessary dependencies.

Safety Check: The app checks if the HDD has existing partitions; if it does, the application will close to prevent accidental data loss.

Partition Management: Just like the original RBD, this tool destroys all existing partitions on the selected drive. I strongly recommend that you back up your data and manually delete all partitions before running this program.

Drive Selection: It lists all active HDDs so you can choose which one to scan.

Scanning Logic: When a bad sector is detected, the app creates an unformatted partition that ends 100 MB before the bad sector and starts a new one 100 MB after it. To avoid excessive fragmentation, a new partition will not be created if the bad sectors are less than 10 GB apart.


## Disclaimer:
I ASSUME NO RESPONSIBILITY FOR ANY DATA LOSS. Please take all necessary precautions to ensure no mistakes are made during the process.


# Bad Disk Partitioner

![Python](https://img.shields.io/badge/Python-3.8%2B-blue?logo=python)
![License](https://img.shields.io/badge/License-GPLv3-green)
![Platform](https://img.shields.io/badge/Platform-Linux-orange)

Professional GUI tool for scanning hard drives with bad sectors and creating safe partitions **only in healthy regions**.

> 🔍 **Detects bad blocks**  
> 🛡️ **Excludes them with 500 MB buffer**  
> ✂️ **Creates partitions only if ≥10 GB of healthy space**  
> 🖥️ **User-friendly Tkinter interface**  
> ⚡ **Two modes: READ-ONLY (safe) and AGGRESSIVE (destructive)**

---

## ✨ Features

- **READ-ONLY Mode**: Non-destructive scan — detects bad blocks without writing.
- **AGGRESSIVE Mode**: Destructive 4-pass write/read/verify test that forces reallocation.
- **Smart Partitioning** (AGGRESSIVE only):
  - Skips all bad blocks
  - Leaves **500 MB safety margin** before and after each bad block
  - Merges overlapping bad regions
  - Creates GPT partitions **only in zones ≥10 GB**
- **Real-time Progress**:
  - Current time, elapsed time, estimated remaining time
  - Speed (MB/s), percentage, status
- **Automatic disk validation**: Refuses to run if disk has existing partitions.

---

## 📦 Installation

### Option 1: Install from `.deb` package (recommended)

```bash
# Download the latest .deb from Releases
wget https://github.com/tehnium/bad-disk-partitioner/releases/latest/download/bad-disk-partitioner_1.0_all.deb

# Install
sudo dpkg -i bad-disk-partitioner_1.0_all.deb

# If dependencies are missing:
sudo apt install -f
