-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 30, 2024 at 11:05 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vibe_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `apartments`
--

CREATE TABLE `apartments` (
  `SQLID` int(11) NOT NULL,
  `ProveraVlasnika` int(11) NOT NULL DEFAULT 0,
  `Vlasnik` varchar(24) NOT NULL DEFAULT 'Niko',
  `UlazX` float NOT NULL DEFAULT 0,
  `UlazY` float NOT NULL DEFAULT 0,
  `UlazZ` float NOT NULL DEFAULT 0,
  `IzlazX` float NOT NULL DEFAULT 0,
  `IzlazY` float NOT NULL DEFAULT 0,
  `IzlazZ` float NOT NULL DEFAULT 0,
  `Level` int(11) NOT NULL DEFAULT 0,
  `Cena` int(11) NOT NULL DEFAULT 0,
  `Novac` int(11) NOT NULL DEFAULT 0,
  `Interijer` int(11) NOT NULL DEFAULT 0,
  `Zatvoreno` int(11) NOT NULL DEFAULT 1,
  `VW` int(11) NOT NULL DEFAULT 0,
  `Oruzije` int(11) NOT NULL DEFAULT -1,
  `Municija` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `apartments`
--

INSERT INTO `apartments` (`SQLID`, `ProveraVlasnika`, `Vlasnik`, `UlazX`, `UlazY`, `UlazZ`, `IzlazX`, `IzlazY`, `IzlazZ`, `Level`, `Cena`, `Novac`, `Interijer`, `Zatvoreno`, `VW`, `Oruzije`, `Municija`) VALUES
(1, 1, 'Sosa', 1505.92, -1060.68, 25.0625, 2282.99, -1139.94, 1050.9, 999, 1, 0, 11, 1, 1, -1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `atms`
--

CREATE TABLE `atms` (
  `SQLID` int(11) NOT NULL,
  `Postavljen_Bankomat` int(11) NOT NULL DEFAULT 0,
  `Poz_X` float NOT NULL DEFAULT 0,
  `Poz_Y` float NOT NULL DEFAULT 0,
  `Poz_Z` float NOT NULL DEFAULT 0,
  `Poz_Angle` float NOT NULL DEFAULT 0,
  `Interijer` int(11) NOT NULL DEFAULT 0,
  `VW` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `atms`
--

INSERT INTO `atms` (`SQLID`, `Postavljen_Bankomat`, `Poz_X`, `Poz_Y`, `Poz_Z`, `Poz_Angle`, `Interijer`, `VW`) VALUES
(1, 1, 830.292, -1336.86, 13.2669, -179.807, 0, 0),
(2, 1, 1456.54, -1022.14, 23.4681, 1.40889, 0, 0),
(3, 1, 1467.47, -1022.15, 23.4281, 1.5109, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `houses`
--

CREATE TABLE `houses` (
  `SQLID` int(11) NOT NULL,
  `ProveraVlasnika` int(11) NOT NULL DEFAULT 0,
  `Vlasnik` varchar(24) NOT NULL DEFAULT 'Niko',
  `Vrsta` int(11) NOT NULL DEFAULT 0,
  `UlazX` float NOT NULL DEFAULT 0,
  `UlazY` float NOT NULL DEFAULT 0,
  `UlazZ` float NOT NULL DEFAULT 0,
  `IzlazX` float NOT NULL DEFAULT 0,
  `IzlazY` float NOT NULL DEFAULT 0,
  `IzlazZ` float NOT NULL DEFAULT 0,
  `Level` int(11) NOT NULL DEFAULT 0,
  `Cena` int(11) NOT NULL DEFAULT 0,
  `Novac` int(11) NOT NULL DEFAULT 0,
  `Interior` int(11) NOT NULL DEFAULT 0,
  `Zatvoreno` int(11) NOT NULL DEFAULT 1,
  `VW` int(11) NOT NULL DEFAULT 0,
  `Oruzije` int(11) NOT NULL DEFAULT -1,
  `Municija` int(11) NOT NULL DEFAULT -1,
  `Rent` int(11) NOT NULL DEFAULT 0,
  `CenaRenta` int(11) NOT NULL DEFAULT 50,
  `Zvono` int(11) NOT NULL DEFAULT 0,
  `Heal` int(11) NOT NULL DEFAULT 0,
  `Mats` int(11) NOT NULL DEFAULT 0,
  `Droga` int(11) NOT NULL DEFAULT 0,
  `Odjeca` int(11) NOT NULL DEFAULT 0,
  `VrstaIntKuce` int(11) NOT NULL DEFAULT 0,
  `Hrana` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `houses`
--

INSERT INTO `houses` (`SQLID`, `ProveraVlasnika`, `Vlasnik`, `Vrsta`, `UlazX`, `UlazY`, `UlazZ`, `IzlazX`, `IzlazY`, `IzlazZ`, `Level`, `Cena`, `Novac`, `Interior`, `Zatvoreno`, `VW`, `Oruzije`, `Municija`, `Rent`, `CenaRenta`, `Zvono`, `Heal`, `Mats`, `Droga`, `Odjeca`, `VrstaIntKuce`, `Hrana`) VALUES
(1, 1, 'Sosa', 4, 1331.91, -632.963, 109.135, 140.26, 1367.42, 1083.86, 999, 1, 0, 5, 1, 1, -1, -1, 0, 50, 0, 0, 0, 0, 0, 4, 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `SQLID` int(11) NOT NULL,
  `Ime` varchar(24) NOT NULL DEFAULT 'Ime_Prezime',
  `Password` varchar(128) NOT NULL DEFAULT 'Prazno',
  `Email` varchar(50) NOT NULL DEFAULT 'Prazno',
  `Skin` int(11) NOT NULL DEFAULT 0,
  `Admin` int(11) NOT NULL DEFAULT 0,
  `Level` int(11) NOT NULL DEFAULT 0,
  `Respekti` int(11) NOT NULL DEFAULT 0,
  `SatiIgre` int(11) NOT NULL DEFAULT 0,
  `Novac` int(11) NOT NULL DEFAULT 0,
  `Pol` int(11) NOT NULL DEFAULT 0,
  `Drzava` int(11) NOT NULL DEFAULT 0,
  `Godine` int(11) NOT NULL DEFAULT 0,
  `NovacBanka` int(11) NOT NULL DEFAULT 0,
  `Zlato` int(11) NOT NULL DEFAULT 0,
  `Banovan` int(11) NOT NULL DEFAULT 0,
  `BRazlog` varchar(40) NOT NULL DEFAULT 'Prazno',
  `Kartica` int(11) NOT NULL DEFAULT 0,
  `KarticaPin` int(11) NOT NULL DEFAULT 0,
  `Warn` int(11) NOT NULL DEFAULT 0,
  `ADozvola` int(11) NOT NULL DEFAULT 0,
  `KamionDozvola` int(11) NOT NULL DEFAULT 0,
  `MotorDozvola` int(11) NOT NULL DEFAULT 0,
  `AvionDozvola` int(11) NOT NULL DEFAULT 0,
  `BrodDozvola` int(11) NOT NULL DEFAULT 0,
  `Kuca` int(11) NOT NULL DEFAULT -1,
  `RentKuca` int(11) NOT NULL DEFAULT -1,
  `Spawn` int(11) NOT NULL DEFAULT 1,
  `Droga` int(11) NOT NULL DEFAULT 0,
  `Mats` int(11) NOT NULL DEFAULT 0,
  `Hrana` int(11) NOT NULL DEFAULT 0,
  `Stan` int(11) NOT NULL DEFAULT -1,
  `IznosKredita` int(11) NOT NULL DEFAULT 0,
  `IznosRate` int(11) NOT NULL DEFAULT 0,
  `PreostalozaOtplatu` int(11) NOT NULL DEFAULT 0,
  `Vip` int(11) NOT NULL DEFAULT 0,
  `Mutiran` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`SQLID`, `Ime`, `Password`, `Email`, `Skin`, `Admin`, `Level`, `Respekti`, `SatiIgre`, `Novac`, `Pol`, `Drzava`, `Godine`, `NovacBanka`, `Zlato`, `Banovan`, `BRazlog`, `Kartica`, `KarticaPin`, `Warn`, `ADozvola`, `KamionDozvola`, `MotorDozvola`, `AvionDozvola`, `BrodDozvola`, `Kuca`, `RentKuca`, `Spawn`, `Droga`, `Mats`, `Hrana`, `Stan`, `IznosKredita`, `IznosRate`, `PreostalozaOtplatu`, `Vip`, `Mutiran`) VALUES
(1, 'Sosa', 'A7B50BD1273110CE4D58D77AFB8E95EDADA8FEEF2788C661B795CE31DAD5D420', '@mail.com', 124, 6, 8, 1, 71, 74050, 1, 1, 22, 52412, 32, 0, 'Prazno', 1, 8070, 0, 1, 1, 1, 1, 1, 1, -1, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `apartments`
--
ALTER TABLE `apartments`
  ADD PRIMARY KEY (`SQLID`);

--
-- Indexes for table `atms`
--
ALTER TABLE `atms`
  ADD PRIMARY KEY (`SQLID`);

--
-- Indexes for table `houses`
--
ALTER TABLE `houses`
  ADD PRIMARY KEY (`SQLID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`SQLID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `apartments`
--
ALTER TABLE `apartments`
  MODIFY `SQLID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `atms`
--
ALTER TABLE `atms`
  MODIFY `SQLID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `houses`
--
ALTER TABLE `houses`
  MODIFY `SQLID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `SQLID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
