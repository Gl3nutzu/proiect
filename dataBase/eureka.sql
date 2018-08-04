-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 01, 2017 at 09:25 PM
-- Server version: 10.1.21-MariaDB
-- PHP Version: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `eureka`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts_blocked`
--

CREATE TABLE `accounts_blocked` (
  `id` int(11) NOT NULL,
  `playerID` int(13) NOT NULL,
  `time` varchar(10) NOT NULL,
  `securityCode` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

CREATE TABLE `cars` (
  `id` int(11) NOT NULL,
  `Model` int(3) NOT NULL DEFAULT '400',
  `Group` int(3) NOT NULL DEFAULT '0',
  `CarPlate` varchar(10) NOT NULL,
  `pX` float NOT NULL DEFAULT '0',
  `pY` float NOT NULL DEFAULT '0',
  `pZ` float NOT NULL DEFAULT '0',
  `pA` float DEFAULT '0',
  `Color1` int(3) NOT NULL,
  `Color2` int(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cars`
--

INSERT INTO `cars` (`id`, `Model`, `Group`, `CarPlate`, `pX`, `pY`, `pZ`, `pA`, `Color1`, `Color2`) VALUES
(1, 411, 1, 'Null', 1571.86, -1317.24, 16.207, 181.127, 0, 79),
(2, 528, 1, 'Null', 1501.86, -1395.63, 14.074, 0.596, 0, 0),
(3, 411, 1, 'Null', 1579.68, -1357.99, 16.211, 269.609, 0, 0),
(4, 510, 0, 'Null', 726.122, -1412.44, 13.133, 1.787, -1, -1),
(5, 510, 0, 'Null', 721.323, -1412.39, 13.126, 0.935, -1, -1),
(6, 510, 0, 'Null', 723.715, -1412.46, 13.131, 1.502, -1, -1),
(7, 510, 0, 'Null', 719.029, -1412.52, 13.129, 359.771, -1, -1),
(8, 560, 0, 'Null', 1354.17, 363.753, 19.636, 65.671, -1, -1),
(9, 560, 0, 'Null', 1350.71, 356.492, 19.606, 65.545, -1, -1),
(10, 447, 0, 'Null', 1307.11, 344.882, 25.709, 21.317, -1, -1),
(11, 533, 0, 'Null', 1296.47, -1864.8, 13.256, 0.552, -1, -1),
(12, 409, 0, 'Null', 1483.4, -1737.72, 13.26, 269.786, -1, -1),
(13, 400, 0, 'Null', 1011.05, -1308.16, 13.475, 180.278, -1, -1),
(14, 442, 0, 'Null', 957.485, -1089.51, 24.072, 0.293, -1, -1),
(15, 418, 0, 'Null', 852.877, -1527.96, 13.137, 266.269, -1, -1),
(16, 419, 0, 'Null', 878.904, -1668.64, 13.344, 359.867, -1, -1),
(17, 419, 0, 'Null', 892.564, -1658.62, 13.344, 179.826, -1, -1),
(18, 510, 0, 'Null', 1863.77, -1395.06, 13.091, 270.979, -1, -1),
(19, 510, 0, 'Null', 1863.75, -1397.62, 13.088, 269.528, -1, -1),
(20, 510, 0, 'Null', 1863.78, -1399.92, 13.086, 272.615, -1, -1),
(21, 510, 0, 'Null', 1863.82, -1402.32, 13.085, 267.33, -1, -1),
(22, 481, 0, 'Null', 1884.4, -1364.63, 18.655, 89.228, -1, -1),
(23, 481, 0, 'Null', 1885.17, -1361.34, 18.656, 86.019, -1, -1),
(24, 481, 0, 'Null', 1869.81, -1363.03, 18.608, 268.097, -1, -1),
(25, 509, 0, 'Null', 1926.43, -1414.98, 13.072, 6.003, -1, -1),
(26, 509, 0, 'Null', 1923.64, -1415.4, 13.083, 8.804, -1, -1),
(27, 509, 0, 'Null', 1921.2, -1415.61, 13.083, 6.04, -1, -1),
(28, 509, 0, 'Null', 1919.18, -1415.75, 13.083, 8.866, -1, -1),
(29, 509, 0, 'Null', 1916.74, -1415.83, 13.083, 6.359, -1, -1),
(30, 482, 0, 'Null', 2092.8, -1558.91, 13.242, 180.793, -1, -1),
(31, 483, 0, 'Null', 2675.77, -1644.59, 11.058, 180.422, -1, -1),
(32, 560, 0, 'Null', 1276.75, -2010.97, 58.644, 89.423, 0, 0),
(33, 482, 0, 'Null', 1245.75, -2011.4, 59.952, 270.49, 0, 0),
(34, 475, 0, 'Null', 1245.92, -2019.2, 59.633, 270.808, 0, 0),
(35, 461, 0, 'Null', 1278.35, -2043.54, 58.592, 103.461, 0, 0),
(36, 560, 0, 'Null', 1276.76, -2017.01, 58.651, 89.946, -1, -1),
(37, 405, 3, 'Null', 1153.5, -2039.2, 68.808, 270.566, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE `groups` (
  `id` int(11) NOT NULL,
  `Name` varchar(50) NOT NULL,
  `Motd` varchar(128) NOT NULL,
  `eX` float NOT NULL,
  `eY` float NOT NULL,
  `eZ` float NOT NULL,
  `iX` float NOT NULL,
  `iY` float NOT NULL,
  `iZ` float NOT NULL,
  `rankName1` varchar(20) NOT NULL,
  `rankName2` varchar(20) NOT NULL,
  `rankName3` varchar(20) NOT NULL,
  `rankName4` varchar(20) NOT NULL,
  `rankName5` varchar(20) NOT NULL,
  `rankName6` varchar(20) NOT NULL,
  `rankName7` varchar(20) NOT NULL,
  `Type` int(2) NOT NULL,
  `Interior` int(2) NOT NULL,
  `Door` int(3) NOT NULL,
  `leadSkin` int(3) DEFAULT '3'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`id`, `Name`, `Motd`, `eX`, `eY`, `eZ`, `iX`, `iY`, `iZ`, `rankName1`, `rankName2`, `rankName3`, `rankName4`, `rankName5`, `rankName6`, `rankName7`, `Type`, `Interior`, `Door`, `leadSkin`) VALUES
(1, 'Federal Boreau of Investigation', 'FBI - power', 1570.3, -1334.29, 16.484, 246.376, 109.246, 1003.22, '', '', '', '', '', '', 'FBI Director', 1, 10, 0, 286),
(2, 'Hitman Agency', 'Hitman Agency - power', 1301.84, 385.67, 19.562, 2324.14, -1148.58, 1050.71, '', '', '', '', '', '', 'Director', 2, 12, 0, 294),
(3, 'Corleone Family', 'Corleone Family - power', 1123.72, -2036.92, 69.886, -2637.09, 1402.88, 906.461, '', '', '', '', '#5 Consigliere', '#6 Street boss', 'The Godfather', 3, 3, 0, 113);

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `ID` int(11) NOT NULL,
  `username` varchar(200) NOT NULL,
  `password` varchar(200) NOT NULL,
  `Email` varchar(150) DEFAULT NULL,
  `SerialCode` varchar(100) NOT NULL DEFAULT '(null)',
  `Level` int(11) NOT NULL DEFAULT '1',
  `AdminLevel` int(11) NOT NULL DEFAULT '0',
  `Cash` int(10) NOT NULL DEFAULT '150000',
  `Bank` int(10) NOT NULL DEFAULT '50000',
  `firstOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Sex` int(1) NOT NULL DEFAULT '0',
  `Age` int(1) NOT NULL DEFAULT '0',
  `Warns` int(11) NOT NULL,
  `Member` int(2) NOT NULL DEFAULT '0',
  `Rank` int(3) NOT NULL DEFAULT '0',
  `Skin` int(3) NOT NULL DEFAULT '184'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts_blocked`
--
ALTER TABLE `accounts_blocked`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cars`
--
ALTER TABLE `cars`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`ID`);
ALTER TABLE `players` ADD FULLTEXT KEY `password` (`password`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts_blocked`
--
ALTER TABLE `accounts_blocked`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;
--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
