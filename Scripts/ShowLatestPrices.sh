#!/bin/bash
set -euo pipefail

DB_NAME="cryptocurrency_multicoin_tracker"

mysql -t -e "USE $DB_NAME; \
SELECT DATE_FORMAT(s.snapshot_time, '%Y-%m-%d %H:%i:%s') AS Snapshot_Time, \
       c.symbol AS Coin, \
       p.price_usd AS Current_USD, \
       p.low_24h_usd AS Low_24h_USD, \
       p.high_24h_usd AS High_24h_USD, \
       p.change_24h_pct AS Change_24h_Pct \
FROM coin_prices p \
JOIN snapshots s ON s.id = p.snapshot_id \
JOIN coins c ON c.id = p.coin_id \
WHERE s.id = (SELECT MAX(id) FROM snapshots) \
ORDER BY c.symbol;"
