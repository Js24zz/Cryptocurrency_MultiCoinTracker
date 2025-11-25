#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$BASE_DIR/Data"
LOG_DIR="$BASE_DIR/Logs"
TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
SNAPSHOT_TIME_SQL="$(date -u +"%Y-%m-%d %H:%M:%S")"
RAW_FILE="$DATA_DIR/crypto_${TIMESTAMP}.json"
LOG_FILE="$LOG_DIR/collect_crypto.log"

IDS="bitcoin,ethereum,solana,binancecoin,ripple,cardano,dogecoin,tron,chainlink,litecoin"
URL="https://api.coingecko.com/api/v3/simple/price?ids=${IDS}&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&precision=full"

DB_NAME="cryptocurrency_multicoin_tracker"

mkdir -p "$DATA_DIR" "$LOG_DIR"

log() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") $1" | tee -a "$LOG_FILE"
}

mysql_exec() {
    mysql -N -B -e "$1"
}

log "Starting collection"
if curl -sS "$URL" -o "$RAW_FILE"; then
    if [ -s "$RAW_FILE" ]; then
        log "Saved $RAW_FILE"
    else
        log "Error: Empty response"
        rm -f "$RAW_FILE"
        exit 1
    fi
else
    log "Error: curl failed"
    rm -f "$RAW_FILE" || true
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    log "Error: jq is not installed"
    exit 1
fi

SNAPSHOT_ID="$(mysql_exec "USE $DB_NAME; INSERT INTO snapshots (snapshot_time, source) VALUES ('$SNAPSHOT_TIME_SQL', '$URL'); SELECT LAST_INSERT_ID();" | tail -n 1)"

if [ -z "$SNAPSHOT_ID" ]; then
    log "Error: Failed to obtain snapshot id"
    exit 1
fi

PARSED_LINES="$(jq -r 'to_entries[] | [.key, .value.usd, .value.usd_market_cap, .value.usd_24h_vol, .value.usd_24h_change] | @tsv' "$RAW_FILE")"

if [ -z "$PARSED_LINES" ]; then
    log "Error: Parsed data is empty"
    exit 1
fi

while IFS=$'\t' read -r COIN_ID PRICE MARKET_CAP VOLUME CHANGE; do
    if [ -z "$COIN_ID" ]; then
        continue
    fi
    mysql_exec "USE $DB_NAME; INSERT INTO coin_prices (snapshot_id, coin_id, price_usd, market_cap_usd, volume_24h_usd, change_24h_pct) VALUES ($SNAPSHOT_ID, (SELECT id FROM coins WHERE coingecko_id='$COIN_ID'), $PRICE, $MARKET_CAP, $VOLUME, $CHANGE);"
done <<< "$PARSED_LINES"

log "Inserted data for snapshot $SNAPSHOT_ID"
echo "Collected cryptocurrency data at $TIMESTAMP"
echo "Raw JSON saved to $(basename "$RAW_FILE")"
