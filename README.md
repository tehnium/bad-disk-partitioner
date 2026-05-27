# badpart_safe.sh

`badpart_safe.sh` is a destructive Linux shell script that scans an entire disk with `badblocks`, isolates defective areas with a safety margin, creates partitions only in the remaining good regions, and formats them as NTFS using quick format mode (`mkfs.ntfs -Q`). The script is intended for temporary or low-trust reuse of problematic HDDs, not for reliable long-term storage.

## What it does

The script performs these steps automatically:

1. Reads the target disk size and basic SMART data when `smartctl` is available.
2. Runs a full read-only scan with `badblocks -sv`, showing native progress percentage in the terminal.
3. Writes only discovered bad block numbers to a text file via `badblocks -o`.
4. Groups adjacent bad blocks into bad regions and adds a 500 MiB safety offset around each region.
5. Merges excluded regions that are closer than 20 GiB.
6. Builds a GPT partition layout only from the remaining good regions using `parted`.
7. Creates the partitions and formats them with NTFS quick format using `mkfs.ntfs -Q`.

## Important warning

This script **destroys all existing data** on the target disk.

Use it only if the entire disk may be repartitioned and reformatted. The user is fully responsible for selecting the correct disk device, for example `/dev/sda` or `/dev/sdb`. Running the script against the wrong disk will erase that disk's partition table and filesystems.

No warranty is provided. No responsibility is accepted for data loss, filesystem corruption, hardware failure, target disk misidentification, or any other consequence of running this script.

## Intended use

This script is suitable for:

- Temporary transfer disks.
- Low-value scratch storage.
- Testing disks with known media defects.
- Isolating bad areas on large HDDs for short-term reuse.

This script is **not** suitable for:

- Backups.
- Long-term storage.
- Important personal or business data.
- Production systems.
- RAID / NAS use.

Disks that already show pending sectors, uncorrectable sectors, or repeated SMART read failures should still be considered unreliable even if this script completes successfully.

## Requirements

The script expects the following tools to be available on the Linux system:

- `bash`
- `badblocks`
- `blockdev`
- `lsblk`
- `awk`
- `sed`
- `sort`
- `parted`
- `tee`
- `stdbuf`
- `date`
- `partprobe`
- `mkfs.ntfs` or `mkntfs`

Optional but recommended:

- `smartctl` from `smartmontools` for a quick SMART summary before scanning.
- `udevadm` to help detect newly created partition nodes after repartitioning.

## Usage

Run locally:

```bash
sudo bash badpart_safe.sh /dev/sdX
```

Example:

```bash
sudo bash badpart_safe.sh /dev/sdb
```

The script will automatically:

- Scan the entire disk.
- Compute bad regions.
- Create a GPT layout from safe regions only.
- Format resulting partitions as NTFS with quick format.

## Output files

Each run creates a work directory in `/tmp/`, for example:

```text
/tmp/badpart-sdb-20260527-070000-12345/
```

Typical files inside that directory:

- `badpart.log`
- `badblocks.txt`
- `excluded_ranges_mib.txt`
- `good_ranges_mib.txt`
- `parted_commands.txt`

To watch the live log:

```bash
tail -f /tmp/badpart-*/badpart.log
```

Or for the newest run:

```bash
tail -f "$(ls -1dt /tmp/badpart-* | head -1)/badpart.log"
```

## How the safety logic works

- Every discovered bad region receives an additional 500 MiB exclusion margin on both sides.
- If two excluded regions are less than 20 GiB apart, they are merged into one larger excluded region.
- Partitions are created only from the good gaps left between excluded regions.
- If no bad blocks are found, the script creates one full-disk NTFS partition.

This behavior is intentionally conservative so unstable areas are not used too closely.

## Run from GitHub

Review the script before running it. Piping remote shell code directly into `bash` is convenient but risky.

Recommended two-step method:

```bash
curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/badpart_safe.sh -o badpart_safe.sh
chmod +x badpart_safe.sh
sudo ./badpart_safe.sh /dev/sdX
```

Direct one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/badpart_safe.sh | sudo bash -s -- /dev/sdX
```

Replace `USER` and `REPO` with the actual GitHub account and repository name.

## Notes

- The scan can take many hours on multi-terabyte HDDs.
- `badblocks.txt` may remain empty until actual bad blocks are found.
- NTFS quick format (`-Q`) is used to avoid another long full initialization pass.
- Avoid USB disconnects, cable movement, or power loss during scanning and formatting.

## Disclaimer

Use at your own risk. The operator must understand that the whole selected disk will be scanned, repartitioned, and reformatted.
