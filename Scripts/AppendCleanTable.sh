#!/bin/bash

# Base folders
BASE_DIR="/mnt/c/Users/yeonj/OneDrive/Cryptocurrency_MultiCoinTracker"
DATA_DIR="$BASE_DIR/Data"
DOC_DIR="$BASE_DIR/Documents"

mkdir -p "$DOC_DIR"

# Latest JSON produced by CollectCrypto
LATEST_JSON=$(ls -t "$DATA_DIR"/crypto_*.json 2>/dev/null | head -n 1)

# If somehow no JSON yet, stop quietly
if [ -z "$LATEST_JSON" ] || [ ! -f "$LATEST_JSON" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S')  No crypto_*.json found in $DATA_DIR" >&2
  exit 1
fi

# ONE combined clean file
OUT_FILE="$DOC_DIR/crypto_clean_log.txt"

# When this script runs (local time)
RUN_TIME=$(date '+%Y-%m-%d %H:%M:%S')

{
  echo "===================================================================="
  echo "Snapshot from JSON : $(basename "$LATEST_JSON")"
  echo "Logged at (local)  : $RUN_TIME"
  echo "--------------------------------------------------------------------"
  printf '%-10s %-8s %-12s %12s %15s %15s %12s %12s %10s %s\n' \
    "id" "symbol" "name" "price" "mkt_cap" "volume" "high_24h" "low_24h" "chg24h%" "last_updated"

  jq -r '.[] | [
      .id,
      .symbol,
      .name,
      (.current_price | tostring),
      (.market_cap | tostring),
      (.total_volume | tostring),
      (.high_24h | tostring),
      (.low_24h | tostring),
      (.price_change_percentage_24h | tostring),
      .last_updated
    ] | @tsv' "$LATEST_JSON" |
  awk '
    BEGIN { fmt="%-10s %-8s %-12s %12s %15s %15s %12s %12s %10s %s\n" }
    { printf fmt, $1,$2,$3,$4,$5,$6,$7,$8,$9,$10 }
  '

  echo
  echo
} >> "$OUT_FILE"
