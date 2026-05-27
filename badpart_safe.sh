#!/usr/bin/env bash
set -Eeuo pipefail

DEVICE="${1:-}"
OFFSET_MIB=500
MERGE_GAP_GIB=20
START_RESERVE_MIB=1
END_RESERVE_MIB=1
BADBLOCKS_BLOCKSIZE=4096
LABEL_TYPE=gpt
FS_TYPE=ntfs

if [[ -z "$DEVICE" ]]; then
  echo "Usage: sudo $0 /dev/sdX"
  exit 1
fi

if [[ ! -b "$DEVICE" ]]; then
  echo "Error: $DEVICE is not a block device"
  exit 1
fi

for cmd in badblocks blockdev lsblk awk sed sort parted tee stdbuf date partprobe; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing command: $cmd"; exit 1; }
done

if command -v mkfs.ntfs >/dev/null 2>&1; then
  NTFS_MKFS="mkfs.ntfs"
elif command -v mkntfs >/dev/null 2>&1; then
  NTFS_MKFS="mkntfs"
else
  echo "Missing NTFS formatter: mkfs.ntfs or mkntfs"
  exit 1
fi

WORKDIR="/tmp/badpart-$(basename "$DEVICE")-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$WORKDIR"
LOGFILE="$WORKDIR/badpart.log"
BAD_TXT="$WORKDIR/badblocks.txt"
RANGES_RAW="$WORKDIR/excluded_ranges_raw_mib.txt"
RANGES_TXT="$WORKDIR/excluded_ranges_mib.txt"
GOOD_TXT="$WORKDIR/good_ranges_mib.txt"
PARTED_CMDS="$WORKDIR/parted_commands.txt"

exec > >(tee -a "$LOGFILE") 2>&1

cleanup() {
  echo
  echo "Log file: $LOGFILE"
  echo "Work dir : $WORKDIR"
}
trap cleanup EXIT

log() {
  printf '[%s] %s\n' "$(date '+%F %T')" "$*"
}

DISK_SIZE_BYTES=$(blockdev --getsize64 "$DEVICE")
DISK_SIZE_MIB=$(( DISK_SIZE_BYTES / 1024 / 1024 ))
MERGE_GAP_MIB=$(( MERGE_GAP_GIB * 1024 ))
SCAN_SIZE_GIB=$(( DISK_SIZE_BYTES / 1024 / 1024 / 1024 ))

show_header() {
  log "Target disk: $DEVICE"
  lsblk -o NAME,SIZE,MODEL,TYPE "$DEVICE"
  log "Disk size: ${DISK_SIZE_MIB} MiB (~${SCAN_SIZE_GIB} GiB)"
  log "Scan block size: ${BADBLOCKS_BLOCKSIZE} bytes"
  log "Offset around bad areas: ${OFFSET_MIB} MiB"
  log "Merge excluded areas closer than: ${MERGE_GAP_GIB} GiB"
  log "Live log: tail -f $LOGFILE"
  log "badblocks.txt ramane gol pana cand sunt gasite efectiv bad blocks."
}

smart_quicklook() {
  log "SMART quick look"
  if command -v smartctl >/dev/null 2>&1; then
    smartctl -H "$DEVICE" || true
    smartctl -A "$DEVICE" | egrep 'Reallocated_Sector_Ct|Current_Pending_Sector|Offline_Uncorrectable|UDMA_CRC_Error_Count' || true
  else
    log "smartctl not found; skipping SMART check"
  fi
}

scan_disk() {
  log "Starting badblocks read-only scan"
  log "Progress is shown directly by badblocks percentage"
  stdbuf -oL -eL badblocks -b "$BADBLOCKS_BLOCKSIZE" -sv -o "$BAD_TXT" "$DEVICE"
}

build_excluded_ranges() {
  log "Processing bad blocks into excluded ranges"
  awk -v bs="$BADBLOCKS_BLOCKSIZE" \
      -v off_mib="$OFFSET_MIB" \
      -v disk_mib="$DISK_SIZE_MIB" '
function mib_floor(bytes) { return int(bytes / 1048576) }
function mib_ceil(bytes)  { return int((bytes + 1048576 - 1) / 1048576) }
NR==1 {
  start_b=$1*bs
  prev_b=start_b
  next
}
{
  cur_b=$1*bs
  if (cur_b == prev_b + bs) {
    prev_b=cur_b
  } else {
    s=mib_floor(start_b) - off_mib
    e=mib_ceil(prev_b + bs) + off_mib
    if (s < 1) s=1
    if (e > disk_mib-1) e=disk_mib-1
    print s, e
    start_b=cur_b
    prev_b=cur_b
  }
}
END {
  s=mib_floor(start_b) - off_mib
  e=mib_ceil(prev_b + bs) + off_mib
  if (s < 1) s=1
  if (e > disk_mib-1) e=disk_mib-1
  print s, e
}
' "$BAD_TXT" | sort -n -k1,1 -k2,2 > "$RANGES_RAW"

  awk -v gap_mib="$MERGE_GAP_MIB" '
NR==1 { s=$1; e=$2; next }
{
  if ($1 <= e + gap_mib) {
    if ($2 > e) e=$2
  } else {
    print s, e
    s=$1; e=$2
  }
}
END {
  if (NR>0) print s, e
}
' "$RANGES_RAW" > "$RANGES_TXT"

  log "Excluded ranges (MiB):"
  cat "$RANGES_TXT"
}

build_good_ranges() {
  log "Building good ranges"
  awk -v start_res="$START_RESERVE_MIB" -v end_res="$END_RESERVE_MIB" -v disk_mib="$DISK_SIZE_MIB" '
BEGIN { cur=start_res }
{
  bs=$1; be=$2
  if (cur < bs) {
    gs=cur
    ge=bs-1
    if (ge > gs) print gs, ge
  }
  if (be + 1 > cur) cur=be+1
}
END {
  last=disk_mib-end_res
  if (cur < last) print cur, last
}
' "$RANGES_TXT" > "$GOOD_TXT"

  if [[ ! -s "$GOOD_TXT" ]]; then
    log "No good ranges left large enough for partitions"
    exit 1
  fi

  log "Good ranges (MiB):"
  nl -ba "$GOOD_TXT"
}

build_single_full_partition_plan() {
  cat > "$GOOD_TXT" <<EOF2
${START_RESERVE_MIB} $((DISK_SIZE_MIB - END_RESERVE_MIB))
EOF2
}

build_parted_plan() {
  log "Building parted plan"
  {
    echo "unit MiB"
    echo "mklabel $L
