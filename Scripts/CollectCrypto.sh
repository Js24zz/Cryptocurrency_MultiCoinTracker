#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$BASE_DIR/Data"
LOG_DIR="$BASE_DIR/Logs"
TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
RAW_FILE="$DATA_DIR/crypto_${TIMESTAMP}.json"
LOG_FILE="$LOG_DIR/collect_crypto.log"

IDS="bitcoin,ethereum,solana,binancecoin,ripple,cardano,dogecoin,toncoin,chainlink,litecoin"
URL="https://api.coingecko.com/api/v3/simple/price?ids=${IDS}&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&precision=full"

mkdir -p "$DATA_DIR" "$LOG_DIR"

{
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") Starting collection"
    if curl -sS "$URL" -o "$RAW_FILE"; then
        if [ -s "$RAW_FILE" ]; then
            echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") Saved $RAW_FILE"
        else
            echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") Error: Empty response" >&2
            rm -f "$RAW_FILE"
        fi
    else
        echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") Error: curl failed" >&2
        rm -f "$RAW_FILE" || true
    fi
} | tee -a "$LOG_FILE"

echo "Collected cryptocurrency data at $TIMESTAMP"
echo "Raw JSON saved to $(basename "$RAW_FILE")"
