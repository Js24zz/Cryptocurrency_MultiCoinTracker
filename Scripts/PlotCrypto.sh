#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLOTS_DIR="$BASE_DIR/Plots"
LOG_DIR="$BASE_DIR/Logs"
LOG_FILE="$LOG_DIR/plot_crypto.log"
DB_NAME="cryptocurrency_multicoin_tracker"

mkdir -p "$PLOTS_DIR" "$LOG_DIR"

log() {
  echo "$(date +"%Y-%m-%dT%H:%M:%S") $1" | tee -a "$LOG_FILE"
}

mysql_query() {
  sudo mysql -N -B -e "$1"
}

if ! command -v gnuplot >/dev/null 2>&1; then
  log "Error: gnuplot is not installed."
  exit 1
fi

plot_price() {
  COIN="$1"
  SYMBOL="$2"
  TITLE="$3"
  OUTPUT="$PLOTS_DIR/${SYMBOL}_price.png"
  TMP_DATA="$(mktemp)"

  mysql_query "
    USE $DB_NAME;
    SELECT
      DATE_FORMAT(s.snapshot_time, '%Y-%m-%d %H:%i:%s') AS ts,
      p.price_usd
    FROM snapshots s
    JOIN coin_prices p ON s.id = p.snapshot_id
    JOIN coins c       ON c.id = p.coin_id
    WHERE c.coingecko_id = '$COIN'
    ORDER BY s.snapshot_time;
  " > "$TMP_DATA" || true

  if [ ! -s "$TMP_DATA" ]; then
    log "No data for $COIN (price). Skipping."
    rm -f "$TMP_DATA"
    return
  fi

  gnuplot <<EOF
set terminal pngcairo size 1600,900 enhanced font 'Arial,12'
set output '$OUTPUT'
set datafile separator '\t'

set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x '%d-%m\n%H:%M'
set xtics rotate by -45 font ',10' offset 0,-1
set grid xtics ytics lw 2 lc rgb '#dddddd'

set xlabel 'Date & Time'
set ylabel 'Price (USD)'
set title '$TITLE Price Over Time'
set key left top

plot '$TMP_DATA' using 1:2 with linespoints lw 3 pt 7 ps 1.8 lc rgb '#3366ff' title '$SYMBOL'
EOF

  rm -f "$TMP_DATA"
  log "Saved price plot → $OUTPUT"
}

plot_change() {
  COIN="$1"
  SYMBOL="$2"
  TITLE="$3"
  OUTPUT="$PLOTS_DIR/${SYMBOL}_change24.png"
  TMP_DATA="$(mktemp)"

  mysql_query "
    USE $DB_NAME;
    SELECT
      DATE_FORMAT(s.snapshot_time, '%Y-%m-%d %H:%i:%s') AS ts,
      p.change_24h_pct
    FROM snapshots s
    JOIN coin_prices p ON s.id = p.snapshot_id
    JOIN coins c       ON c.id = p.coin_id
    WHERE c.coingecko_id = '$COIN'
    ORDER BY s.snapshot_time;
  " > "$TMP_DATA" || true

  if [ ! -s "$TMP_DATA" ]; then
    log "No data for $COIN (24h change). Skipping."
    rm -f "$TMP_DATA"
    return
  fi

  gnuplot <<EOF
set terminal pngcairo size 1600,900 enhanced font 'Arial,12'
set output '$OUTPUT'
set datafile separator '\t'

set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x '%d-%m\n%H:%M'
set xtics rotate by -45 font ',10' offset 0,-1
set grid xtics ytics lw 2 lc rgb '#dddddd'

set xlabel 'Date & Time'
set ylabel '24h Change (%)'
set title '$TITLE 24h Change Over Time'
set key left top

plot '$TMP_DATA' using 1:2 with linespoints lw 3 pt 7 ps 1.8 lc rgb '#cc33ff' title '$SYMBOL 24h %'
EOF

  rm -f "$TMP_DATA"
  log "Saved 24h change plot → $OUTPUT"
}

log "Generating price plots for 10 cryptocurrencies..."

plot_price "bitcoin"     "BTC"  "Bitcoin"
plot_price "ethereum"    "ETH"  "Ethereum"
plot_price "solana"      "SOL"  "Solana"
plot_price "binancecoin" "BNB"  "Binance Coin"
plot_price "ripple"      "XRP"  "XRP"
plot_price "cardano"     "ADA"  "Cardano"
plot_price "dogecoin"    "DOGE" "Dogecoin"
plot_price "tron"        "TRX"  "Tron"
plot_price "chainlink"   "LINK" "Chainlink"
plot_price "litecoin"    "LTC"  "Litecoin"

log "Generating 24h change plots (BTC, ETH)..."

plot_change "bitcoin"  "BTC" "Bitcoin"
plot_change "ethereum" "ETH" "Ethereum"

log "Finished generating plots."
