# badpart_safe.sh

A Linux shell script for temporary reuse of failing HDDs by scanning the whole disk, excluding bad regions with a safety margin, creating partitions only in good areas, and formatting them as NTFS using quick format mode. This project is meant for damaged or unreliable disks that are no longer trusted for normal storage use. [web:269][web:270][web:90]

## Features

- Full-disk read-only scan with `badblocks -sv`, with native percentage progress shown in the terminal. [web:91][web:92]
- Saves detected bad blocks to a file using `badblocks -o`. [web:91][web:263]
- Adds a 500 MiB safety offset around detected bad regions.
- Merges excluded regions if they are closer than 20 GiB.
- Creates a GPT partition layout only in the remaining safe areas using `parted`. [web:216][web:217]
- Formats resulting partitions as NTFS using quick format mode `mkfs.ntfs -Q`. [web:249][web:253]

## Warning

This script is **destructive**. It repartitions and reformats the **entire target disk**. [web:216][web:217]

By using this script, the operator acknowledges that:

- all existing data on the selected disk will be lost;
- selecting the wrong disk device will destroy data on that disk;
- failing disks remain unreliable even after repartitioning;
- this tool is intended only for temporary, low-trust, non-critical use.

No warranty is provided. No responsibility is accepted for data loss, filesystem corruption, hardware failure, misuse, or any other consequence of running this script.

## Suitable use cases

- Temporary file transfer disks.
- Scratch storage.
- Short-term reuse of damaged HDDs.
- Testing bad-region isolation on disks with media errors.

## Not suitable for

- Backups.
- Long-term storage.
- Important personal or business data.
- Production systems.
- RAID / NAS / server use.

Disks with pending sectors, uncorrectable sectors, or repeated SMART read failures should still be treated as unsafe. [web:90][web:99]

## Requirements

Required tools:

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

- `smartctl` from `smartmontools` for a quick SMART summary. [web:99]
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

## Run directly from GitHub

Safer method:

```bash
curl -fsSL https://raw.githubusercontent.com/tehnium/bad-disk-partitioner/main/badpart_safe.sh -o badpart_safe.sh
chmod +x badpart_safe.sh
sudo ./badpart_safe.sh /dev/sdX
```

Direct one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/tehnium/bad-disk-partitioner/main/badpart_safe.sh | sudo bash -s -- /dev/sdX
```

## How it works

1. Reads disk information and optional SMART summary. [web:90][web:99]
2. Scans the entire disk in read-only mode with `badblocks`. [web:91][web:92]
3. Builds excluded regions from detected bad blocks.
4. Adds 500 MiB offset before and after each bad region.
5. Merges excluded regions closer than 20 GiB.
6. Builds safe partition ranges from the remaining disk space.
7. Creates a GPT partition table with `parted`. [web:216][web:217]
8. Formats the resulting partitions with NTFS quick format using `mkfs.ntfs -Q`. [web:249][web:253]

If no bad blocks are found, the script creates one full-disk NTFS partition.

## Output

Each run creates a work directory in `/tmp/`, for example:

```text
/tmp/badpart-sdb-20260527-070000-12345/
```

Typical files:

- `badpart.log`
- `badblocks.txt`
- `excluded_ranges_mib.txt`
- `good_ranges_mib.txt`
- `parted_commands.txt`

Follow the latest log with:

```bash
tail -f "$(ls -1dt /tmp/badpart-* | head -1)/badpart.log"
```

## Notes

- Large disks may take many hours to scan. [web:90][web:91]
- `badblocks.txt` may remain empty until actual bad blocks are found. [web:91][web:263]
- NTFS quick format is used to avoid another long full initialization pass. [web:249][web:253]
- Avoid USB disconnects, cable movement, or power loss during scanning and formatting.

## Disclaimer

Use at your own risk. The operator must understand that the whole selected disk will be scanned, repartitioned, and reformatted.
