-- MySQL dump 10.13  Distrib 8.0.44, for Linux (x86_64)
--
-- Host: localhost    Database: cryptocurrency_multicoin_tracker
-- ------------------------------------------------------
-- Server version	8.0.44-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `coin_prices`
--

DROP TABLE IF EXISTS `coin_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coin_prices` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `snapshot_id` bigint NOT NULL,
  `coin_id` int NOT NULL,
  `price_usd` decimal(18,8) NOT NULL,
  `market_cap_usd` decimal(20,2) DEFAULT NULL,
  `volume_24h_usd` decimal(20,2) DEFAULT NULL,
  `change_24h_pct` decimal(7,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_coin_snapshot` (`snapshot_id`,`coin_id`),
  KEY `coin_id` (`coin_id`),
  CONSTRAINT `coin_prices_ibfk_1` FOREIGN KEY (`snapshot_id`) REFERENCES `snapshots` (`id`),
  CONSTRAINT `coin_prices_ibfk_2` FOREIGN KEY (`coin_id`) REFERENCES `coins` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coin_prices`
--

LOCK TABLES `coin_prices` WRITE;
/*!40000 ALTER TABLE `coin_prices` DISABLE KEYS */;
INSERT INTO `coin_prices` VALUES (1,1,4,862.23040262,118724379422.17,1873623861.38,0.96),(2,1,1,88237.04347946,1760310537736.14,72430279555.31,1.59),(3,1,6,0.42559555,15592818686.85,912998473.35,2.47),(4,1,9,12.99245596,9055563193.61,678427866.05,3.48),(5,1,7,0.15156460,23016162254.79,1596403845.30,3.18),(6,1,2,2930.91678654,353761887875.90,29251554234.33,1.93),(7,1,10,85.07972886,6516154577.73,583999153.73,1.27),(8,1,5,2.24298773,135227821144.16,6372509091.55,7.80),(9,1,3,138.32744646,77341183299.94,5866413084.76,4.48),(10,2,4,860.11889699,118478019760.08,1787516680.32,0.86),(11,2,1,88002.88450167,1755610880104.95,72198966624.23,0.60),(12,2,6,0.42376911,15530173273.91,897076331.42,1.15),(13,2,9,12.96639312,9039121063.32,667781432.07,1.47),(14,2,7,0.15108467,22964790982.73,1567923016.68,2.15),(15,2,2,2922.90926352,352844598319.11,28858976807.11,1.61),(16,2,10,84.79957852,6496473623.62,566283087.51,0.15),(17,2,5,2.24438018,135254672183.40,6313374822.05,7.00),(18,2,3,138.15651832,77221646256.78,5812286803.95,3.42),(19,3,4,861.25305246,118579844997.14,1776705577.54,0.99),(20,3,1,88151.87901297,1757251137996.60,72303911814.09,0.77),(21,3,6,0.42386480,15516053454.07,896813872.71,1.17),(22,3,9,12.97203799,9038015434.38,667065506.29,1.51),(23,3,7,0.15116776,22946085557.37,1567240225.60,2.21),(24,3,2,2929.26996801,353244931913.38,28882944837.15,1.83),(25,3,10,84.86082909,6492595059.73,566914364.72,0.22),(26,3,5,2.24757310,135296995160.79,6322948665.38,7.15),(27,3,3,138.30690707,77329200781.75,5822218558.09,3.53),(28,4,4,861.25305246,118579844997.14,1776705577.54,0.99),(29,4,1,88151.87901297,1757251137996.60,72303911814.09,0.77),(30,4,6,0.42386480,15516053454.07,896813872.71,1.17),(31,4,9,12.97203799,9038015434.38,667065506.29,1.51),(32,4,7,0.15116776,22946085557.37,1567240225.60,2.21),(33,4,2,2929.26996801,353244931913.38,28882944837.15,1.83),(34,4,10,84.86082909,6492595059.73,566914364.72,0.22),(35,4,5,2.24757310,135296995160.79,6322948665.38,7.15),(36,4,3,138.30690707,77329200781.75,5822218558.09,3.53),(37,5,4,861.25305246,118579844997.14,1776705577.54,0.99),(38,5,1,88151.87901297,1757251137996.60,72303911814.09,0.77),(39,5,6,0.42386480,15516053454.07,896813872.71,1.17),(40,5,9,12.97203799,9038015434.38,667065506.29,1.51),(41,5,7,0.15116776,22946085557.37,1567240225.60,2.21),(42,5,2,2929.26996801,353244931913.38,28882944837.15,1.83),(43,5,10,84.86082909,6492595059.73,566914364.72,0.22),(44,5,5,2.24757310,135296995160.79,6322948665.38,7.15),(45,5,3,138.30690707,77329200781.75,5822218558.09,3.53);
/*!40000 ALTER TABLE `coin_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coins`
--

DROP TABLE IF EXISTS `coins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `coingecko_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `symbol` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `coingecko_id` (`coingecko_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coins`
--

LOCK TABLES `coins` WRITE;
/*!40000 ALTER TABLE `coins` DISABLE KEYS */;
INSERT INTO `coins` VALUES (1,'bitcoin','BTC','Bitcoin'),(2,'ethereum','ETH','Ethereum'),(3,'solana','SOL','Solana'),(4,'binancecoin','BNB','Binance Coin'),(5,'ripple','XRP','XRP'),(6,'cardano','ADA','Cardano'),(7,'dogecoin','DOGE','Dogecoin'),(8,'toncoin','TON','Toncoin'),(9,'chainlink','LINK','Chainlink'),(10,'litecoin','LTC','Litecoin');
/*!40000 ALTER TABLE `coins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `snapshots`
--

DROP TABLE IF EXISTS `snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snapshots` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `snapshot_time` datetime NOT NULL,
  `source` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `snapshots`
--

LOCK TABLES `snapshots` WRITE;
/*!40000 ALTER TABLE `snapshots` DISABLE KEYS */;
INSERT INTO `snapshots` VALUES (1,'2025-11-25 05:10:05','https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,binancecoin,ripple,cardano,dogecoin,toncoin,chainlink,litecoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&precision=full'),(2,'2025-11-25 05:32:42','https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,binancecoin,ripple,cardano,dogecoin,toncoin,chainlink,litecoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&precision=full'),(3,'2025-11-25 05:35:29','https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,binancecoin,ripple,cardano,dogecoin,toncoin,chainlink,litecoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&precision=full'),(4,'2025-11-25 05:35:31','https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,binancecoin,ripple,cardano,dogecoin,toncoin,chainlink,litecoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&precision=full'),(5,'2025-11-25 05:35:34','https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,binancecoin,ripple,cardano,dogecoin,toncoin,chainlink,litecoin&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&precision=full');
/*!40000 ALTER TABLE `snapshots` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-25 14:12:00
