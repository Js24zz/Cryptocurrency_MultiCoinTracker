#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$BASE_DIR/Data"
DOC_DIR="$BASE_DIR/Documents"

mkdir -p "$DOC_DIR"

if ! command -v jq >/dev/null 2>&1; then
  echo "$(date '+%Y-%m-%d %H:%M:%S')  Error: jq is not installed." >&2
  exit 1
fi

LATEST_JSON=$(ls -t "$DATA_DIR"/crypto_*.json 2>/dev/null | head -n 1 || true)

if [ -z "$LATEST_JSON" ] || [ ! -f "$LATEST_JSON" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S')  No crypto_*.json found in $DATA_DIR" >&2
  exit 0
fi

OUT_FILE="$DOC_DIR/CryptoPricesTable.txt"

{
  echo "==================================================================="
  echo "Crypto Prices Snapshot: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Source JSON: $(basename "$LATEST_JSON")"
  echo

  printf "%-12s %-8s %-15s %15s %15s %15s %15s %15s %15s\n" \
    "ID" "Symbol" "Name" "Price_USD" "Market_Cap" "Volume_24h" \
    "High_24h" "Low_24h" "Change_24h%"

  printf "%-12s %-8s %-15s %15s %15s %15s %15s %15s %15s\n" \
    "------------" "--------" "---------------" "---------------" "---------------" "---------------" \
    "---------------" "---------------" "---------------"

  jq -r '.[] | [
      .id,
      .symbol,
      .name,
      (.current_price // 0 | tostring),
      (.market_cap // 0 | tostring),
      (.total_volume // 0 | tostring),
      (.high_24h // 0 | tostring),
      (.low_24h // 0 | tostring),
      (.price_change_percentage_24h // 0 | tostring)
    ] | @tsv' "$LATEST_JSON" |
  while IFS=$'\t' read -r ID SYM NAME PRICE MC VOL HIGH LOW CHG; do
    printf "%-12s %-8s %-15s %15s %15s %15s %15s %15s %15s\n" \
      "$ID" "$SYM" "$NAME" "$PRICE" "$MC" "$VOL" "$HIGH" "$LOW" "$CHG"
  done

  echo
  echo
} >> "$OUT_FILE"
