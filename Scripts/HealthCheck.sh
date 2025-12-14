#!/bin/bash
set -euo pipefail

DB="cryptocurrency_multicoin_tracker"
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLOTS_DIR="$BASE_DIR/Plots"
DOCS_DIR="$BASE_DIR/Documents"
CLEAN_TABLE="$DOCS_DIR/CryptoPricesTable.txt"

echo "=============================================="
echo "CRYPTO PIPELINE HEALTH CHECK   $(date)"
echo "Project: $BASE_DIR"
echo "=============================================="

echo
echo "[1] Latest snapshot + number of coin rows (expect 10)"
sudo mysql -e "USE ${DB};
SELECT
  s.id AS latest_snapshot_id,
  s.snapshot_time,
  COUNT(cp.id) AS rows_in_coin_prices
FROM snapshots s
LEFT JOIN coin_prices cp ON cp.snapshot_id = s.id
WHERE s.id = (SELECT MAX(id) FROM snapshots)
GROUP BY s.id, s.snapshot_time;"

echo
echo "[2] Total records in DB"
sudo mysql -e "USE ${DB};
SELECT
  (SELECT COUNT(*) FROM snapshots)   AS total_snapshots,
  (SELECT COUNT(*) FROM coin_prices) AS total_coin_prices;"

echo
echo "[3] Latest snapshot table (10 coins)"
bash "$BASE_DIR/Scripts/ShowLatestPrices.sh"

echo
echo "[4] Plot outputs"
if ls "$PLOTS_DIR"/*.png >/dev/null 2>&1; then
  echo "Total PNG plots: $(ls -1 "$PLOTS_DIR"/*.png | wc -l)"
  echo "Latest 8 plots:"
  ls -lt "$PLOTS_DIR"/*.png | head -n 8
else
  echo "No plots found in $PLOTS_DIR"
fi

echo
echo "[5] Clean table file (last 20 lines)"
if [ -f "$CLEAN_TABLE" ]; then
  tail -n 20 "$CLEAN_TABLE"
else
  echo "Not found: $CLEAN_TABLE"
fi

echo
echo "✅ Health check complete."
