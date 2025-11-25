#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLOTS_DIR="$BASE_DIR/Plots"
LOG_DIR="$BASE_DIR/Logs"
LOG_FILE="$LOG_DIR/plot_crypto.log"
DB_NAME="cryptocurrency_multicoin_tracker"

mkdir -p "$PLOTS_DIR" "$LOG_DIR"

log() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") $1" | tee -a "$LOG_FILE"
}

mysql_query() {
    mysql -N -B -e "$1"
}

plot_price() {
    COIN_ID="$1"
    SYMBOL="$2"
    TITLE="$3"
    OUTPUT="$PLOTS_DIR/${SYMBOL}_price.png"
    TMP_DATA="$(mktemp)"

    mysql_query "USE $DB_NAME; SELECT DATE_FORMAT(s.snapshot_time,'%Y-%m-%d %H:%i:%s'), p.price_usd FROM snapshots s JOIN coin_prices p ON s.id = p.snapshot_id JOIN coins c ON c.id = p.coin_id WHERE c.coingecko_id='$COIN_ID' ORDER BY s.snapshot_time;" > "$TMP_DATA" || true

    if [ ! -s "$TMP_DATA" ]; then
        log \"No data for $COIN_ID price\"
        rm -f \"$TMP_DATA\"
        return
    fi

    gnuplot <<EOF
set terminal pngcairo size 1280,720
set output '$OUTPUT'
set datafile separator '\t'
set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x '%m-%d\n%H:%M'
set grid
set title '$TITLE Price (USD)'
set xlabel 'Time'
set ylabel 'Price (USD)'
plot '$TMP_DATA' using 1:2 with lines lw 2 title '$SYMBOL'
EOF

    rm -f "$TMP_DATA"
    log "Saved $OUTPUT"
}

log "Generating price plots for 10 cryptocurrencies"

plot_price "bitcoin" "BTC" "Bitcoin"
plot_price "ethereum" "ETH" "Ethereum"
plot_price "solana" "SOL" "Solana"
plot_price "binancecoin" "BNB" "Binance Coin"
plot_price "ripple" "XRP" "XRP"
plot_price "cardano" "ADA" "Cardano"
plot_price "dogecoin" "DOGE" "Dogecoin"
plot_price "tron" "TRX" "Tron"
plot_price "chainlink" "LINK" "Chainlink"
plot_price "litecoin" "LTC" "Litecoin"

log "Finished generating price plots"
