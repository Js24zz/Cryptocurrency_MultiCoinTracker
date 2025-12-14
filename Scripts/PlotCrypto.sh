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
  mysql -N -B -e "$1"
}

if ! command -v gnuplot >/dev/null 2>&1; then
  log "Error: gnuplot is not installed."
  exit 1
fi

# -------------------------------
# PRICE PLOT
# -------------------------------
plot_price() {
  COIN="$1"
  SYMBOL="$2"
  TITLE="$3"
  OUTPUT="$PLOTS_DIR/${SYMBOL}_price.png"
  TMP_DATA="$(mktemp)"

  mysql_query "
    USE $DB_NAME;
    SET @rn := 0;
    SELECT
      DATE_FORMAT(DATE_ADD(s.snapshot_time, INTERVAL (@rn:=@rn+1) SECOND), '%Y-%m-%d %H:%i:%s') AS ts_unique,
      p.price_usd
    FROM snapshots s
    JOIN coin_prices p ON s.id = p.snapshot_id
    JOIN coins c       ON c.id = p.coin_id
    WHERE c.coingecko_id = '$COIN'
    ORDER BY s.snapshot_time, s.id;
  " > "$TMP_DATA" || true

  if [ ! -s "$TMP_DATA" ]; then
    log "No data for $COIN (price). Skipping."
    rm -f "$TMP_DATA"
    return
  fi

  gnuplot <<GP
set terminal pngcairo size 1600,900 enhanced font 'Arial,12'
set output '$OUTPUT'
set datafile separator '\t'

set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x '%d-%m\n%H:%M:%S'
set xtics rotate by -45 font ',10' offset 0,-1
set grid xtics ytics lw 2

set xlabel 'Date & Time'
set ylabel 'Price (USD)'
set title '$TITLE Price Over Time'
set key left top

plot '$TMP_DATA' using 1:2 with linespoints lw 3 pt 7 ps 1.8 title '$SYMBOL', \
     '$TMP_DATA' using 1:2:(strftime('%H:%M:%S', timecolumn(1))) with labels offset 0,1 font ',8' notitle
GP

  rm -f "$TMP_DATA"
  log "Saved price plot → $OUTPUT"
}

# -------------------------------
# 24H CHANGE PLOT
# -------------------------------
plot_change() {
  COIN="$1"
  SYMBOL="$2"
  TITLE="$3"
  OUTPUT="$PLOTS_DIR/${SYMBOL}_change24.png"
  TMP_DATA="$(mktemp)"

  mysql_query "
    USE $DB_NAME;
    SET @rn := 0;
    SELECT
      DATE_FORMAT(DATE_ADD(s.snapshot_time, INTERVAL (@rn:=@rn+1) SECOND), '%Y-%m-%d %H:%i:%s') AS ts_unique,
      p.change_24h_pct
    FROM snapshots s
    JOIN coin_prices p ON s.id = p.snapshot_id
    JOIN coins c       ON c.id = p.coin_id
    WHERE c.coingecko_id = '$COIN'
      AND p.change_24h_pct IS NOT NULL
    ORDER BY s.snapshot_time, s.id;
  " > "$TMP_DATA" || true

  if [ ! -s "$TMP_DATA" ]; then
    log "No data for $COIN (24h change). Skipping."
    rm -f "$TMP_DATA"
    return
  fi

  gnuplot <<GP
set terminal pngcairo size 1600,900 enhanced font 'Arial,12'
set output '$OUTPUT'
set datafile separator '\t'

set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x '%d-%m\n%H:%M:%S'
set xtics rotate by -45 font ',10' offset 0,-1
set grid xtics ytics lw 2

set xlabel 'Date & Time'
set ylabel '24h Change (%)'
set title '$TITLE 24h Change Over Time'
set key left top

plot '$TMP_DATA' using 1:2 with linespoints lw 3 pt 7 ps 1.8 title '$SYMBOL 24h %', \
     '$TMP_DATA' using 1:2:(strftime('%H:%M:%S', timecolumn(1))) with labels offset 0,1 font ',8' notitle
GP

  rm -f "$TMP_DATA"
  log "Saved 24h change plot → $OUTPUT"
}

# -------------------------------
# MARKET CAP PLOT (USD)
# -------------------------------
plot_marketcap() {
  COIN="$1"
  SYMBOL="$2"
  TITLE="$3"
  OUTPUT="$PLOTS_DIR/${SYMBOL}_marketcap.png"
  TMP_DATA="$(mktemp)"

  mysql_query "
    USE $DB_NAME;
    SET @rn := 0;
    SELECT
      DATE_FORMAT(DATE_ADD(s.snapshot_time, INTERVAL (@rn:=@rn+1) SECOND), '%Y-%m-%d %H:%i:%s') AS ts_unique,
      p.market_cap_usd
    FROM snapshots s
    JOIN coin_prices p ON s.id = p.snapshot_id
    JOIN coins c       ON c.id = p.coin_id
    WHERE c.coingecko_id = '$COIN'
      AND p.market_cap_usd IS NOT NULL
    ORDER BY s.snapshot_time, s.id;
  " > "$TMP_DATA" || true

  if [ ! -s "$TMP_DATA" ]; then
    log "No data for $COIN (market cap). Skipping."
    rm -f "$TMP_DATA"
    return
  fi

  gnuplot <<GP
set terminal pngcairo size 1600,900 enhanced font 'Arial,12'
set output '$OUTPUT'
set datafile separator '\t'

set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x '%d-%m\n%H:%M:%S'
set xtics rotate by -45 font ',10' offset 0,-1
set grid xtics ytics lw 2

set xlabel 'Date & Time'
set ylabel 'Market Cap (USD)'
set title '$TITLE Market Cap Over Time'
set key left top
set format y '%.2s%c'

plot '$TMP_DATA' using 1:2 with linespoints lw 3 pt 7 ps 1.8 title '$SYMBOL MCap'
GP

  rm -f "$TMP_DATA"
  log "Saved market cap plot → $OUTPUT"
}

# -------------------------------
# VOLUME (24H) PLOT (USD)
# -------------------------------
plot_volume() {
  COIN="$1"
  SYMBOL="$2"
  TITLE="$3"
  OUTPUT="$PLOTS_DIR/${SYMBOL}_volume24h.png"
  TMP_DATA="$(mktemp)"

  mysql_query "
    USE $DB_NAME;
    SET @rn := 0;
    SELECT
      DATE_FORMAT(DATE_ADD(s.snapshot_time, INTERVAL (@rn:=@rn+1) SECOND), '%Y-%m-%d %H:%i:%s') AS ts_unique,
      p.volume_24h_usd
    FROM snapshots s
    JOIN coin_prices p ON s.id = p.snapshot_id
    JOIN coins c       ON c.id = p.coin_id
    WHERE c.coingecko_id = '$COIN'
      AND p.volume_24h_usd IS NOT NULL
    ORDER BY s.snapshot_time, s.id;
  " > "$TMP_DATA" || true

  if [ ! -s "$TMP_DATA" ]; then
    log "No data for $COIN (24h volume). Skipping."
    rm -f "$TMP_DATA"
    return
  fi

  gnuplot <<GP
set terminal pngcairo size 1600,900 enhanced font 'Arial,12'
set output '$OUTPUT'
set datafile separator '\t'

set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x '%d-%m\n%H:%M:%S'
set xtics rotate by -45 font ',10' offset 0,-1
set grid xtics ytics lw 2

set xlabel 'Date & Time'
set ylabel '24h Volume (USD)'
set title '$TITLE 24h Volume Over Time'
set key left top
set format y '%.2s%c'

plot '$TMP_DATA' using 1:2 with linespoints lw 3 pt 7 ps 1.8 title '$SYMBOL Vol 24h'
GP

  rm -f "$TMP_DATA"
  log "Saved 24h volume plot → $OUTPUT"
}

MODE="${1:-all}"

case "$MODE" in
  price)
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
    ;;
  change)
    log "Generating 24h change plots (BTC, ETH)..."
    plot_change "bitcoin"  "BTC" "Bitcoin"
    plot_change "ethereum" "ETH" "Ethereum"
    ;;
  marketcap)
    log "Generating market cap plots (BTC, ETH)..."
    plot_marketcap "bitcoin"  "BTC" "Bitcoin"
    plot_marketcap "ethereum" "ETH" "Ethereum"
    ;;
  volume)
    log "Generating 24h volume plots (BTC, ETH)..."
    plot_volume "bitcoin"  "BTC" "Bitcoin"
    plot_volume "ethereum" "ETH" "Ethereum"
    ;;
  all)
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

    log "Generating market cap plots (BTC, ETH)..."
    plot_marketcap "bitcoin"  "BTC" "Bitcoin"
    plot_marketcap "ethereum" "ETH" "Ethereum"

    log "Generating 24h volume plots (BTC, ETH)..."
    plot_volume "bitcoin"  "BTC" "Bitcoin"
    plot_volume "ethereum" "ETH" "Ethereum"
    ;;
  *)
    echo "Usage: $0 {price|change|marketcap|volume|all}"
    exit 2
    ;;
esac

log "Finished generating plots."
