CREATE DATABASE IF NOT EXISTS cryptocurrency_multicoin_tracker
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cryptocurrency_multicoin_tracker;

-- -------------------------------------------------------------------
-- Master list of coins
-- -------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS coins (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    coingecko_id VARCHAR(50) NOT NULL UNIQUE,
    symbol       VARCHAR(10) NOT NULL,
    name         VARCHAR(50) NOT NULL
);

-- -------------------------------------------------------------------
-- One row per data collection run
-- -------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS snapshots (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    snapshot_time DATETIME    NOT NULL,
    source        VARCHAR(255) NOT NULL
);

-- -------------------------------------------------------------------
-- One row per (snapshot, coin)
-- -------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS coin_prices (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    snapshot_id      BIGINT NOT NULL,
    coin_id          INT    NOT NULL,
    price_usd        DECIMAL(18,8) NOT NULL,
    market_cap_usd   BIGINT        NULL,
    volume_24h_usd   BIGINT        NULL,
    low_24h_usd      DECIMAL(18,8) NULL,
    high_24h_usd     DECIMAL(18,8) NULL,
    change_24h_pct   DECIMAL(10,4) NULL,
    CONSTRAINT fk_coin_prices_snapshot
      FOREIGN KEY (snapshot_id) REFERENCES snapshots(id)
      ON DELETE CASCADE,
    CONSTRAINT fk_coin_prices_coin
      FOREIGN KEY (coin_id) REFERENCES coins(id)
      ON DELETE RESTRICT
);

CREATE INDEX idx_coin_prices_snapshot ON coin_prices (snapshot_id);
CREATE INDEX idx_coin_prices_coin     ON coin_prices (coin_id);
CREATE UNIQUE INDEX idx_coin_snapshot ON coin_prices (snapshot_id, coin_id);

-- -------------------------------------------------------------------
-- Seed the coins table with the 10 tracked coins
-- -------------------------------------------------------------------
INSERT INTO coins (coingecko_id, symbol, name) VALUES
('bitcoin',     'BTC',  'Bitcoin'),
('ethereum',    'ETH',  'Ethereum'),
('solana',      'SOL',  'Solana'),
('binancecoin', 'BNB',  'Binance Coin'),
('ripple',      'XRP',  'XRP'),
('cardano',     'ADA',  'Cardano'),
('dogecoin',    'DOGE', 'Dogecoin'),
('tron',        'TRX',  'Tron'),
('chainlink',   'LINK', 'Chainlink'),
('litecoin',    'LTC',  'Litecoin')
ON DUPLICATE KEY UPDATE
  symbol = VALUES(symbol),
  name   = VALUES(name);
