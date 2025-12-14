#!/bin/bash
set -euo pipefail

# Base folders
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$BASE_DIR/Data"
LOG_DIR="$BASE_DIR/Logs"
TIMESTAMP="$(date +"%Y%m%dT%H%M%S")"
SNAPSHOT_TIME_SQL="$(date +"%Y-%m-%d %H:%M:%S")"
RAW_FILE="$DATA_DIR/crypto_${TIMESTAMP}.json"
LOG_FILE="$LOG_DIR/collect_crypto.log"

IDS="bitcoin,ethereum,solana,binancecoin,ripple,cardano,dogecoin,tron,chainlink,litecoin"
URL="https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${IDS}&price_change_percentage=24h"
DB_NAME="cryptocurrency_multicoin_tracker"

mkdir -p "$DATA_DIR" "$LOG_DIR"

log() {
  echo "$(date +"%Y-%m-%dT%H:%M:%S") $1" | tee -a "$LOG_FILE"
}

mysql_exec() {
  mysql -N -B -e "$1"
}

if ! command -v jq >/dev/null 2>&1; then
  log "Error: jq is not installed."
  exit 1
fi

# --------------------------------------------------------------------
# Download from CoinGecko with retry, saving PRETTY JSON
# --------------------------------------------------------------------
MAX_RETRIES=3
RETRY_DELAY=5
SUCCESS=0

for attempt in 1 2 3; do
  log "Downloading data from CoinGecko (attempt $attempt)..."
  if curl -sS "$URL" | jq '.' > "$RAW_FILE"; then
    if [ -s "$RAW_FILE" ]; then
      SUCCESS=1
      break
    fi
  fi
  sleep "$RETRY_DELAY"
done

if [ "$SUCCESS" -eq 0 ]; then
  log "Failed to download JSON after $MAX_RETRIES attempts."
  rm -f "$RAW_FILE" 2>/dev/null || true
  exit 1
fi

log "Saved pretty JSON to $RAW_FILE"

# --------------------------------------------------------------------
# Parse JSON to tab-separated lines for DB insertion
# --------------------------------------------------------------------
PARSED_LINES="$(jq -r '.[] | [
  .id,
  (.current_price // 0),
  (.market_cap // 0),
  (.total_volume // 0),
  (.low_24h // 0),
  (.high_24h // 0),
  (.price_change_percentage_24h // 0)
] | @tsv' "$RAW_FILE")"

if [ -z "$PARSED_LINES" ]; then
  log "Error: parsed data is empty."
  exit 1
fi

# --------------------------------------------------------------------
# Insert snapshot and get snapshot_id
# --------------------------------------------------------------------
SNAPSHOT_ID="$(mysql_exec "
  USE $DB_NAME;
  INSERT INTO snapshots (snapshot_time, source)
  VALUES ('$SNAPSHOT_TIME_SQL', '$URL');
  SELECT LAST_INSERT_ID();
" | tail -n 1 | tr -d '[:space:]')"

if [ -z "$SNAPSHOT_ID" ] || ! [[ "$SNAPSHOT_ID" =~ ^[0-9]+$ ]]; then
  log "Error: invalid snapshot id '$SNAPSHOT_ID'"
  exit 1
fi

log "Using snapshot_id=$SNAPSHOT_ID"

# --------------------------------------------------------------------
# Insert coin prices (one row per coin)
# --------------------------------------------------------------------
while IFS=$'\t' read -r COIN PRICE MKT VOL LOW HIGH CHANGE; do
  if [ -z "$COIN" ] || [ -z "$PRICE" ]; then
    continue
  fi

  mysql_exec "
    USE $DB_NAME;
    INSERT INTO coin_prices (
      snapshot_id,
      coin_id,
      price_usd,
      market_cap_usd,
      volume_24h_usd,
      low_24h_usd,
      high_24h_usd,
      change_24h_pct
    )
    VALUES (
      $SNAPSHOT_ID,
      (SELECT id FROM coins WHERE coingecko_id='$COIN'),
      $PRICE,
      $MKT,
      $VOL,
      $LOW,
      $HIGH,
      $CHANGE
    );
  "
done <<< "$PARSED_LINES"

log "Inserted data for snapshot $SNAPSHOT_ID"
echo "Done: collected cryptocurrency data at $TIMESTAMP"
