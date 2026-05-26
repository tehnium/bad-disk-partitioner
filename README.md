# Bad Disk Partitioner

This project is inspired by an older tool developed by Dmitri Primochenko called Repartition Bad Drive, which ran on Windows but had specific hardware requirements, such as requiring the HDD to be in IDE mode. My application aims to achieve the same results on Linux (Debian-based distributions).

## Key Features and Workflow:
Automated Setup: It automatically installs all necessary dependencies.

Safety Check: The app checks if the HDD has existing partitions; if it does, the application will close to prevent accidental data loss.

Partition Management: Just like the original RBD, this tool destroys all existing partitions on the selected drive. I strongly recommend that you back up your data and manually delete all partitions before running this program.

Drive Selection: It lists all active HDDs so you can choose which one to scan.

Scanning Logic: When a bad sector is detected, the app creates an unformatted partition that ends 500 MB before the bad sector and starts a new one 500 MB after it. To avoid excessive fragmentation, a new partition will not be created if the bad sectors are less than 10 GB apart.


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

## ▶️ Usage
    ⚠️ Must be run as root — the tool needs low-level disk access.

The GUI will guide you through:

    Mode selection (SCAN ONLY or AGGRESSIVE)
    Disk selection (only disks without partitions are allowed)
    Real-time scan with progress
    Automatic partitioning (AGGRESSIVE mode only)

## 🛠️ Build from source
git clone https://github.com/your-username/bad-disk-partitioner.git
cd bad-disk-partitioner
./build-deb.sh
sudo dpkg -i bad-disk-partitioner_1.0_all.deb

## ⚠️ Warnings

    AGGRESSIVE MODE DESTROYS ALL DATA on the selected disk.
    Always backup important data before scanning.
    Do not interrupt the scan — it may leave the disk in an inconsistent state.
    This tool does not detect "slow" sectors — only sectors that fail read/write tests.

## 📁 Output

    Bad blocks list: saved in a temporary file (shown at end of scan)
    Partitions: created but not formatted — you can choose your filesystem later

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a PR.

## 📜 License

This project is licensed under GNU General Public License v3.0 — see LICENSE
 for details.

## 🙏 Acknowledgments

    Uses badblocks (from e2fsprogs) for low-level scanning
    Inspired by disk diagnostic tools for data recovery professionals
Thanks to QWEN.AI
## 🙏 Mulțumiri

Acest proiect a fost dezvoltat cu sprijinul [Qwen AI](https://qwen.ai), un asistent inteligent care a oferit orientare tehnică, depanare și implementare în etapele critice de dezvoltare. Fără ajutorul său, acest tool nu ar fi ajuns la forma sa finală, funcțională și robustă.

De asemenea, mulțumiri comunității open-source pentru tool-urile esențiale:  
- `badblocks` (e2fsprogs)  
- `smartmontools`  
- `parted`  
- și distribuțiile live precum **Strelec** și **SystemRescue**.
### 2. Another way...download and use script
sudo bash badpart_safe.sh /dev/sdX
read progress with another terminal (ex. ssh):
cd "$(ls -1dt /tmp/badpart-sda-* | head -1)"
tail -f badpart.log
