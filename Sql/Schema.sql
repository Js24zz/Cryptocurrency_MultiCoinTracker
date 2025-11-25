CREATE DATABASE IF NOT EXISTS cryptocurrency_multicoin_tracker
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cryptocurrency_multicoin_tracker;

CREATE TABLE coins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coingecko_id VARCHAR(50) NOT NULL UNIQUE,
    symbol VARCHAR(10) NOT NULL,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE snapshots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    snapshot_time DATETIME NOT NULL,
    source VARCHAR(255) NOT NULL
);

CREATE TABLE coin_prices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    snapshot_id BIGINT NOT NULL,
    coin_id INT NOT NULL,
    price_usd DECIMAL(18,8) NOT NULL,
    market_cap_usd DECIMAL(20,2),
    volume_24h_usd DECIMAL(20,2),
    change_24h_pct DECIMAL(7,2),
    FOREIGN KEY (snapshot_id) REFERENCES snapshots(id),
    FOREIGN KEY (coin_id) REFERENCES coins(id)
);

CREATE UNIQUE INDEX idx_coin_snapshot ON coin_prices (snapshot_id, coin_id);

INSERT INTO coins (coingecko_id, symbol, name) VALUES
('bitcoin', 'BTC', 'Bitcoin'),
('ethereum', 'ETH', 'Ethereum'),
('solana', 'SOL', 'Solana'),
('binancecoin', 'BNB', 'Binance Coin'),
('ripple', 'XRP', 'XRP'),
('cardano', 'ADA', 'Cardano'),
('dogecoin', 'DOGE', 'Dogecoin'),
('toncoin', 'TON', 'Toncoin'),
('chainlink', 'LINK', 'Chainlink'),
('litecoin', 'LTC', 'Litecoin');
