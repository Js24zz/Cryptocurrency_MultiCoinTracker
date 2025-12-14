CREATE DATABASE IF NOT EXISTS cryptocurrency_multicoin_tracker
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cryptocurrency_multicoin_tracker;

CREATE TABLE IF NOT EXISTS coins (
  id INT NOT NULL AUTO_INCREMENT,
  coingecko_id VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  symbol VARCHAR(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  name VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY coingecko_id (coingecko_id)
);

CREATE TABLE IF NOT EXISTS snapshots (
  id BIGINT NOT NULL AUTO_INCREMENT,
  snapshot_time DATETIME NOT NULL,
  source VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS coin_prices (
  id BIGINT NOT NULL AUTO_INCREMENT,
  snapshot_id BIGINT NOT NULL,
  coin_id INT NOT NULL,
  price_usd DECIMAL(18,8) NOT NULL,
  market_cap_usd DECIMAL(20,2) DEFAULT NULL,
  volume_24h_usd DECIMAL(20,2) DEFAULT NULL,
  low_24h_usd DECIMAL(18,8) DEFAULT NULL,
  high_24h_usd DECIMAL(18,8) DEFAULT NULL,
  change_24h_pct DECIMAL(7,2) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY idx_coin_snapshot (snapshot_id, coin_id),
  KEY coin_id (coin_id),
  CONSTRAINT coin_prices_fk_snapshot FOREIGN KEY (snapshot_id) REFERENCES snapshots (id),
  CONSTRAINT coin_prices_fk_coin FOREIGN KEY (coin_id) REFERENCES coins (id)
);

INSERT INTO coins (coingecko_id, symbol, name) VALUES
('bitcoin','BTC','Bitcoin'),
('ethereum','ETH','Ethereum'),
('solana','SOL','Solana'),
('binancecoin','BNB','Binance Coin'),
('ripple','XRP','XRP'),
('cardano','ADA','Cardano'),
('dogecoin','DOGE','Dogecoin'),
('tron','TRX','Tron'),
('chainlink','LINK','Chainlink'),
('litecoin','LTC','Litecoin')
ON DUPLICATE KEY UPDATE symbol=VALUES(symbol), name=VALUES(name);
