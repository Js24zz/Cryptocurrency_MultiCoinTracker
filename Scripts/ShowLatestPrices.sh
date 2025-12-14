#!/bin/bash
set -euo pipefail

DB_NAME="cryptocurrency_multicoin_tracker"

mysql -t -e "

USE $DB_NAME;
SELECT
  s.snapshot_time AS Snapshot_Time,
  c.symbol        AS Coin,
  p.price_usd     AS Price_USD,
  p.low_24h_usd   AS Low_24h_USD,
  p.high_24h_usd  AS High_24h_USD,
  p.change_24h_pct AS Change_24h_Pct
FROM snapshots s
JOIN coin_prices p ON s.id = p.snapshot_id
JOIN coins c       ON c.id = p.coin_id
WHERE s.snapshot_time = (SELECT MAX(snapshot_time) FROM snapshots)
ORDER BY Coin;
"

