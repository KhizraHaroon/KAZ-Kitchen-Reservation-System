-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jul 08, 2025 at 09:52 AM
-- Server version: 10.11.10-MariaDB
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u232217965_kaz_kitchen_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(191) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cache`
--

INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES
('laravel_cache_asd@gmail.co|2400:adcc:106:8900:2dca:d2f0:75cf:2173', 'i:1;', 1751498046),
('laravel_cache_asd@gmail.co|2400:adcc:106:8900:2dca:d2f0:75cf:2173:timer', 'i:1751498046;', 1751498046),
('laravel_cache_hasd@gmail.com|2400:adcc:106:8900:2dca:d2f0:75cf:2173', 'i:2;', 1751499670),
('laravel_cache_hasd@gmail.com|2400:adcc:106:8900:2dca:d2f0:75cf:2173:timer', 'i:1751499670;', 1751499670),
('laravel_cache_jamal234@gmail.com|127.0.0.1', 'i:1;', 1751473413),
('laravel_cache_jamal234@gmail.com|127.0.0.1:timer', 'i:1751473413;', 1751473413),
('laravel_cache_kiarn234@gmail.com|127.0.0.1', 'i:1;', 1751473434),
('laravel_cache_kiarn234@gmail.com|127.0.0.1:timer', 'i:1751473434;', 1751473434);

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(191) NOT NULL,
  `owner` varchar(191) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cancellation`
--

CREATE TABLE `cancellation` (
  `Cancellation_ID` int(11) NOT NULL,
  `Reservation_ID` int(11) DEFAULT NULL,
  `Refund_Amount` decimal(10,2) DEFAULT NULL,
  `IsRefundable` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cancellation`
--

INSERT INTO `cancellation` (`Cancellation_ID`, `Reservation_ID`, `Refund_Amount`, `IsRefundable`) VALUES
(1, 3, NULL, 0),
(3, 1, NULL, 0),
(4, 8, 2500.00, 0),
(5, 9, 888.00, 0);

--
-- Triggers `cancellation`
--
DELIMITER $$
CREATE TRIGGER `prevent_late_cancellation` BEFORE INSERT ON `cancellation` FOR EACH ROW BEGIN
    DECLARE reserved_time DATETIME;
    
    SELECT ts.start_time
    INTO reserved_time
    FROM Reservation r
    JOIN Time_Slot ts ON r.Slot_ID = ts.Slot_ID
    WHERE r.Reservation_ID = NEW.Reservation_ID;

    IF NOW() > reserved_time THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot cancel a reservation after the reserved time.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `set_refund_on_cancellation` BEFORE INSERT ON `cancellation` FOR EACH ROW BEGIN
    DECLARE payment_exists INT;
    
    SELECT COUNT(*) INTO payment_exists
    FROM Payment
    WHERE Reservation_ID = NEW.Reservation_ID;
    
    IF payment_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot issue a refund: No payment found for this reservation.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_status_on_cancellation` AFTER INSERT ON `cancellation` FOR EACH ROW BEGIN
    UPDATE Reservation
    SET ReservationStatus = 'Cancelled'
    WHERE Reservation_ID = NEW.Reservation_ID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `confirmed_reservations`
--

CREATE ALGORITHM=UNDEFINED DEFINER=`u232217965_kazkitchen`@`127.0.0.1` SQL SECURITY DEFINER VIEW `confirmed_reservations`  AS SELECT `r`.`Reservation_ID` AS `Reservation_ID`, `c`.`Name` AS `Customer`, `t`.`Capacity` AS `Capacity`, `ts`.`Start_Time` AS `Start_Time`, `s`.`Name` AS `Service` FROM ((((`reservation` `r` join `customer` `c` on(`r`.`Customer_ID` = `c`.`Customer_ID`)) join `tableinfo` `t` on(`r`.`Table_ID` = `t`.`Table_ID`)) join `time_slot` `ts` on(`r`.`Slot_ID` = `ts`.`Slot_ID`)) left join `service` `s` on(`r`.`Service_ID` = `s`.`Service_ID`)) WHERE `r`.`ReservationStatus` = 'Confirmed' ;
-- Error reading data for table u232217965_kaz_kitchen_db.confirmed_reservations: #1064 - You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'FROM `u232217965_kaz_kitchen_db`.`confirmed_reservations`' at line 1

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `Customer_ID` int(11) NOT NULL,
  `Name` varchar(100) DEFAULT NULL,
  `Contact` varchar(20) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Password` varchar(100) DEFAULT NULL,
  `User_ID` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`Customer_ID`, `Name`, `Contact`, `Email`, `Password`, `User_ID`) VALUES
(1, 'w2', '03001234567', 'ali.khan@email.com', 'ali123', 10),
(2, 'Sara Malik', '03019876543', 'sara.malik@email.com', 'sara456', 10),
(3, 'Hamza Shah', '03111234567', 'hamza.shah@email.com', 'hamza789', 10),
(4, 'Zara Noor', '03211223344', 'zara.noor@email.com', 'zara321', 10),
(5, 'Ahmed Raza', '03312223334', 'ahmed.raza@email.com', 'ahmed654', 10),
(6, 'Customer Name', 'Contact Info', 'email@example.com', 'hashed_password', 6),
(7, 'zaru', NULL, NULL, NULL, 10),
(8, 'w2', NULL, NULL, NULL, 10),
(9, 'zaru', NULL, NULL, NULL, 10),
(10, 'mehru', NULL, NULL, NULL, 10),
(11, 'ben', NULL, NULL, NULL, 10),
(12, 'fern', NULL, NULL, NULL, 10),
(13, 'fern', NULL, NULL, NULL, 10),
(14, 'fern', NULL, NULL, NULL, 10),
(15, 'vemin', NULL, NULL, NULL, 10),
(16, 'benis', NULL, NULL, NULL, 10),
(17, 'ferm', NULL, NULL, NULL, 10),
(18, 'ferm', NULL, NULL, NULL, 10),
(19, 'ben', NULL, NULL, NULL, 10),
(20, 'rose', NULL, NULL, NULL, 10),
(21, 'jemi', NULL, NULL, NULL, 10),
(22, 'ben', NULL, NULL, NULL, 11),
(23, 'venis', NULL, NULL, NULL, 12),
(24, 'zoi', NULL, NULL, NULL, 13),
(25, 'naila', NULL, NULL, NULL, 14),
(26, 'zubaida', NULL, NULL, NULL, 14),
(27, 'neha', NULL, NULL, NULL, 14),
(28, 'hania', NULL, NULL, NULL, 14),
(29, 'kMRn', NULL, NULL, NULL, 14),
(30, 'xs', NULL, NULL, NULL, 14),
(31, 'khurram', NULL, NULL, NULL, 15),
(32, 'bakhtawar', NULL, NULL, NULL, 15),
(33, 'sana', NULL, NULL, NULL, 15),
(34, 'gulale', NULL, NULL, NULL, 15),
(35, 'kiran', NULL, NULL, NULL, 15),
(36, 'hania', NULL, NULL, NULL, 15),
(37, 'shafaq', NULL, NULL, NULL, 16),
(38, 'ayesha', NULL, NULL, NULL, 16),
(39, 'ayesha', NULL, NULL, NULL, 16),
(40, 'haris', NULL, NULL, NULL, 17),
(41, 'hadia', NULL, NULL, NULL, 17),
(42, 'hadia', NULL, NULL, NULL, 17),
(43, 'hadia', NULL, NULL, NULL, 17),
(44, 'hania', NULL, NULL, NULL, 18),
(45, 'jamal', NULL, NULL, NULL, 18),
(46, 'namal', NULL, NULL, NULL, 18),
(47, 'kiran', NULL, NULL, NULL, 18),
(48, 'zaru', NULL, NULL, NULL, 18),
(49, 'zaru', NULL, NULL, NULL, 18),
(50, 'dev', NULL, NULL, NULL, 18),
(51, 'fakhra', NULL, NULL, NULL, 18),
(52, 'HIBA', NULL, NULL, NULL, 19),
(53, 'laila', NULL, NULL, NULL, 19),
(54, 'amber', NULL, NULL, NULL, 20),
(55, 'paro', NULL, NULL, NULL, 20),
(56, 'xs', NULL, NULL, NULL, 20),
(57, 'namal', NULL, NULL, NULL, 20),
(58, 'hania', NULL, NULL, NULL, 20),
(59, 'aila', NULL, NULL, NULL, 20),
(60, 'aila', NULL, NULL, NULL, 20),
(61, 'gulale', NULL, NULL, NULL, 20),
(62, 'gulale', NULL, NULL, NULL, 20),
(63, 'hajira', NULL, NULL, NULL, 20),
(64, 'saira', NULL, NULL, NULL, 21),
(65, 'ali', NULL, NULL, NULL, 21),
(66, 'ali', NULL, NULL, NULL, 21),
(67, 'Bilawal', NULL, NULL, NULL, 21),
(68, 'summayea', NULL, NULL, NULL, 21),
(69, 'bilal', NULL, NULL, NULL, 21),
(70, 'kamran', NULL, NULL, NULL, 22),
(71, 'huda', NULL, NULL, NULL, 22),
(72, 'fnayab', NULL, NULL, NULL, 22),
(73, 'shabana', NULL, NULL, NULL, 23),
(74, 'aliyan', NULL, NULL, NULL, 23),
(75, 'jamal', NULL, NULL, NULL, 23),
(76, 'khizra', NULL, NULL, NULL, 23),
(77, 'khizra', NULL, NULL, NULL, 23),
(78, 'test', NULL, NULL, NULL, 25),
(79, 'Atif Khan', NULL, NULL, NULL, 26),
(80, 'Khan', NULL, NULL, NULL, 26),
(81, 'Khan khan', NULL, NULL, NULL, 26),
(82, 'Khizra', NULL, NULL, NULL, 27),
(83, 'Khizra', NULL, NULL, NULL, 27),
(84, 'KHizra', NULL, NULL, NULL, 27),
(85, 'Hajira', NULL, NULL, NULL, 28),
(86, 'Falak', NULL, NULL, NULL, 28),
(87, 'Areej', NULL, NULL, NULL, 29),
(88, 'Kamil', NULL, NULL, NULL, 28),
(89, 'Nabeel', NULL, NULL, NULL, 28),
(90, 'Nadia', NULL, NULL, NULL, 28),
(91, 'Jamal', NULL, NULL, NULL, 28),
(92, 'Khizra', NULL, NULL, NULL, 27),
(93, 'Atif', NULL, NULL, NULL, 27),
(94, 'saba', NULL, NULL, NULL, 31),
(95, 'aliyan', NULL, NULL, NULL, 31),
(96, 'Zumra', NULL, NULL, NULL, 32),
(97, 'Zumra', NULL, NULL, NULL, 32),
(98, 'khizra', NULL, NULL, NULL, 34),
(99, 'khizra khan', NULL, NULL, NULL, 34),
(100, 'hajra', NULL, NULL, NULL, 34),
(101, 'Haider', NULL, NULL, NULL, 37),
(102, 'Jamal', NULL, NULL, NULL, 37),
(103, 'Yusra', NULL, NULL, NULL, 38),
(104, 'Kamran', NULL, NULL, NULL, 38),
(105, 'Hajira', NULL, NULL, NULL, 38),
(106, 'Hajira', NULL, NULL, NULL, 38);

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(191) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(191) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(191) NOT NULL,
  `name` varchar(191) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(191) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_06_12_090708_create_payment_table', 1),
(5, '2025_06_14_081326_create_customer_table', 1),
(6, '2025_06_14_081359_create_reservations_table', 1),
(7, '2025_06_14_081708_create_service_table', 1),
(8, '2025_06_14_081927_create_tableinfo_table', 1),
(9, '2025_06_14_093120_create_reservations_table', 2),
(10, '2025_06_14_140317_add_user_id_to_reservations_table', 3),
(12, '2025_06_14_142601_add_user_id_to_reservation_table', 4),
(14, '2025_06_14_165733_add_status_to_reservation_table', 5);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(191) NOT NULL,
  `token` varchar(191) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `Payment_ID` int(11) NOT NULL,
  `Reservation_ID` int(11) DEFAULT NULL,
  `Amount` decimal(10,2) DEFAULT NULL,
  `PaymentDate` date DEFAULT NULL,
  `Method` varchar(50) DEFAULT NULL,
  `Payment_Date` datetime DEFAULT NULL,
  `PaymentStatus` enum('Paid','Refunded','Pending') DEFAULT 'Paid'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`Payment_ID`, `Reservation_ID`, `Amount`, `PaymentDate`, `Method`, `Payment_Date`, `PaymentStatus`) VALUES
(1, 1, 5000.00, NULL, NULL, NULL, 'Paid'),
(2, 2, 5000.00, NULL, NULL, NULL, 'Paid'),
(3, 4, 4500.00, NULL, NULL, NULL, 'Paid'),
(4, 5, 6000.00, NULL, NULL, NULL, 'Paid'),
(5, 1, 5000.00, NULL, 'EasyPaisa', NULL, 'Paid'),
(6, 2, 5000.00, NULL, 'CreditCard', NULL, 'Paid'),
(7, 4, 4500.00, NULL, 'CreditCard', NULL, 'Paid'),
(8, 5, 6000.00, NULL, 'EasyPaisa', NULL, 'Paid'),
(9, 8, 5000.00, NULL, 'CreditCard', NULL, 'Paid'),
(10, 9, 888.00, NULL, NULL, '2025-06-14 01:56:59', 'Paid');

-- --------------------------------------------------------

--
-- Table structure for table `reservation`
--

CREATE TABLE `reservation` (
  `Reservation_ID` int(11) NOT NULL,
  `Customer_ID` int(11) DEFAULT NULL,
  `Table_ID` int(11) DEFAULT NULL,
  `Slot_ID` int(11) DEFAULT NULL,
  `Service_ID` int(11) DEFAULT NULL,
  `ReservationDate` date DEFAULT NULL,
  `ReservationStatus` enum('confirmed','cancelled') DEFAULT NULL,
  `NumberOfGuests` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `Status` varchar(191) NOT NULL DEFAULT 'Confirmed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reservation`
--

INSERT INTO `reservation` (`Reservation_ID`, `Customer_ID`, `Table_ID`, `Slot_ID`, `Service_ID`, `ReservationDate`, `ReservationStatus`, `NumberOfGuests`, `created_at`, `updated_at`, `user_id`, `Status`) VALUES
(1, 1, 2, 1, 1, '2025-06-01', 'cancelled', 2, NULL, NULL, NULL, 'Confirmed'),
(2, 2, 3, 2, 2, '2025-06-02', 'confirmed', 4, NULL, NULL, NULL, 'Confirmed'),
(3, 3, 1, 3, NULL, '2025-06-03', 'cancelled', 2, NULL, NULL, NULL, 'Confirmed'),
(4, 4, 4, 4, 3, '2025-06-04', 'confirmed', 6, NULL, NULL, NULL, 'Confirmed'),
(5, 5, 5, 5, 5, '2025-06-05', 'confirmed', 8, NULL, NULL, NULL, 'Confirmed'),
(8, 3, 3, 1, NULL, '2025-06-24', 'cancelled', 4, NULL, NULL, NULL, 'Confirmed'),
(9, 2, 2, 2, NULL, NULL, 'cancelled', NULL, NULL, NULL, NULL, 'Confirmed'),
(10, NULL, 2, NULL, 2, '2025-06-09', 'confirmed', 1, '2025-06-14 22:10:28', '2025-06-14 22:10:28', 1, 'Confirmed'),
(11, NULL, 1, NULL, 1, '2025-06-18', 'confirmed', 1, '2025-06-14 22:44:46', '2025-06-14 22:44:46', 1, 'Confirmed'),
(12, NULL, 1, NULL, 3, '2025-06-26', 'confirmed', 1, '2025-06-14 22:49:43', '2025-06-14 22:49:43', 1, 'Confirmed'),
(13, NULL, 2, NULL, 1, '2025-07-05', 'confirmed', 1, '2025-06-14 22:53:27', '2025-06-14 22:53:27', 1, 'Confirmed'),
(14, NULL, 3, NULL, 4, '2025-06-25', 'confirmed', 1, '2025-06-14 23:07:20', '2025-06-14 23:07:20', 1, 'Confirmed'),
(15, NULL, 3, NULL, 4, '2025-06-25', 'confirmed', 1, '2025-06-14 23:07:31', '2025-06-14 23:07:31', 1, 'Confirmed'),
(16, NULL, 3, NULL, 3, '2025-06-16', 'confirmed', 1, '2025-06-14 23:10:05', '2025-06-14 23:10:05', 1, 'Confirmed'),
(17, 1, 4, NULL, 2, '2025-06-16', NULL, NULL, '2025-06-14 23:19:12', '2025-06-14 23:19:12', NULL, 'Confirmed'),
(18, 1, 2, NULL, 3, '2025-06-16', NULL, NULL, '2025-06-14 23:19:37', '2025-06-14 23:19:37', NULL, 'Confirmed'),
(19, 1, 1, NULL, 2, '2025-06-13', NULL, NULL, '2025-06-14 23:24:00', '2025-06-14 23:24:00', NULL, 'Confirmed'),
(20, 2, 2, NULL, 2, '2025-06-30', NULL, NULL, '2025-06-14 23:28:33', '2025-06-14 23:28:33', NULL, 'Confirmed'),
(21, 2, 3, NULL, 4, '2025-06-28', NULL, NULL, '2025-06-14 23:28:59', '2025-06-14 23:28:59', NULL, 'Confirmed'),
(22, 2, 3, NULL, 3, '2025-06-30', NULL, NULL, '2025-06-14 23:32:13', '2025-06-14 23:32:13', NULL, 'Confirmed'),
(23, 2, 2, NULL, 4, '2025-06-12', NULL, NULL, '2025-06-14 23:34:19', '2025-06-14 23:34:19', NULL, 'Confirmed'),
(24, 2, 3, NULL, 1, '2025-07-10', NULL, NULL, '2025-06-14 23:44:31', '2025-06-14 23:44:31', NULL, 'Confirmed'),
(25, 2, 3, NULL, 3, NULL, NULL, NULL, '2025-06-14 23:58:34', '2025-06-14 23:58:34', NULL, 'Confirmed'),
(26, 2, 4, NULL, 2, NULL, NULL, NULL, '2025-06-15 00:08:58', '2025-06-15 00:08:58', NULL, 'Confirmed'),
(27, 2, 3, NULL, 5, NULL, NULL, NULL, '2025-06-15 00:18:22', '2025-06-15 00:18:22', NULL, 'Confirmed'),
(28, NULL, 4, NULL, 1, '2025-06-26', 'confirmed', 1, '2025-06-16 15:18:16', '2025-06-16 15:18:16', 3, 'Confirmed'),
(29, NULL, 4, NULL, 1, '2025-06-26', 'confirmed', 1, NULL, NULL, 3, 'Confirmed'),
(30, NULL, 1, NULL, 3, '2025-06-26', 'confirmed', 1, NULL, NULL, 3, 'Confirmed'),
(31, NULL, 3, NULL, 4, '2025-06-28', NULL, NULL, NULL, NULL, 3, 'Confirmed'),
(32, NULL, 3, NULL, 4, '2025-06-28', NULL, NULL, '2025-06-16 16:40:09', '2025-06-16 16:40:09', 3, 'Confirmed'),
(33, NULL, 3, 4, 2, '2025-06-10', 'confirmed', NULL, '2025-06-16 19:13:53', '2025-06-16 19:13:53', 3, 'Confirmed'),
(34, NULL, 2, 4, 3, '2025-06-19', 'confirmed', NULL, '2025-06-16 19:38:53', '2025-06-16 19:38:53', 4, 'Confirmed'),
(35, NULL, 1, 3, 2, '2025-06-02', 'confirmed', NULL, '2025-06-16 19:49:41', '2025-06-16 19:49:41', 4, 'Confirmed'),
(36, 5, 2, 3, 2, '2025-06-19', 'confirmed', NULL, '2025-06-16 22:45:07', '2025-06-16 22:45:07', 5, 'Confirmed'),
(37, NULL, 1, 3, 2, '2025-06-21', NULL, NULL, '2025-06-17 00:05:38', '2025-06-17 00:05:38', 5, 'Confirmed'),
(40, 6, 2, 3, 3, '2025-06-12', 'confirmed', NULL, '2025-06-17 21:08:56', '2025-06-17 21:08:56', NULL, 'Confirmed'),
(41, 7, 3, 5, 3, '2025-06-18', 'confirmed', NULL, '2025-06-17 21:25:44', '2025-06-17 21:25:44', 6, 'Confirmed'),
(42, 8, 3, 5, 2, '2025-06-19', 'confirmed', NULL, '2025-06-17 21:29:02', '2025-06-17 21:29:02', 6, 'Confirmed'),
(43, 9, 1, 3, 2, '2025-06-16', 'confirmed', NULL, '2025-06-17 21:32:21', '2025-06-17 21:32:21', 6, 'Confirmed'),
(44, 6, 4, 3, 3, '2025-06-19', NULL, NULL, '2025-06-17 21:54:56', '2025-06-17 21:54:56', NULL, 'Confirmed'),
(45, 6, 4, 3, 3, '2025-06-19', NULL, NULL, '2025-06-17 22:04:19', '2025-06-17 22:04:19', NULL, 'Confirmed'),
(46, 6, 4, 3, 3, '2025-06-19', NULL, NULL, '2025-06-17 22:05:59', '2025-06-17 22:05:59', NULL, 'Confirmed'),
(47, 7, 3, 3, 1, '2025-06-27', NULL, NULL, '2025-06-17 22:27:14', '2025-06-17 22:27:14', NULL, 'Confirmed'),
(48, 7, 3, 3, 2, '2025-06-23', NULL, NULL, '2025-06-17 22:30:26', '2025-06-17 22:30:26', NULL, 'Confirmed'),
(49, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 22:43:24', '2025-06-17 22:43:24', NULL, 'Confirmed'),
(50, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 22:44:48', '2025-06-17 22:44:48', NULL, 'Confirmed'),
(51, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 22:46:59', '2025-06-17 22:46:59', NULL, 'Confirmed'),
(52, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 22:52:48', '2025-06-17 22:52:48', NULL, 'Confirmed'),
(53, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 22:53:08', '2025-06-17 22:53:08', NULL, 'Confirmed'),
(54, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 22:54:45', '2025-06-17 22:54:45', NULL, 'Confirmed'),
(55, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 22:58:30', '2025-06-17 22:58:30', NULL, 'Confirmed'),
(56, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 22:59:10', '2025-06-17 22:59:10', NULL, 'Confirmed'),
(57, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 22:59:31', '2025-06-17 22:59:31', NULL, 'Confirmed'),
(58, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 23:00:49', '2025-06-17 23:00:49', NULL, 'Confirmed'),
(59, 8, 3, 3, 4, '2025-06-18', NULL, NULL, '2025-06-17 23:05:43', '2025-06-17 23:05:43', NULL, 'Confirmed'),
(60, 9, 2, 3, 3, '2025-06-15', NULL, NULL, '2025-06-18 23:52:24', '2025-06-18 23:52:24', NULL, 'Confirmed'),
(61, 9, 2, 2, 1, '2025-06-26', NULL, NULL, '2025-06-19 00:03:16', '2025-06-19 00:03:16', NULL, 'Confirmed'),
(62, 9, 3, 5, 4, '2025-06-15', NULL, NULL, '2025-06-19 00:04:05', '2025-06-19 00:04:05', NULL, 'Confirmed'),
(63, 10, 4, 5, 5, '2025-06-28', NULL, NULL, '2025-06-19 00:09:41', '2025-06-19 00:09:41', NULL, 'Confirmed'),
(64, 11, 1, 3, 4, '2025-06-11', NULL, NULL, '2025-06-19 00:10:17', '2025-06-19 00:10:17', NULL, 'Confirmed'),
(65, 14, 5, 5, 2, '2025-06-30', NULL, NULL, '2025-06-19 00:22:59', '2025-06-19 00:22:59', NULL, 'Confirmed'),
(66, 15, 1, 3, 4, '2025-06-27', NULL, NULL, '2025-06-19 00:23:32', '2025-06-19 00:23:32', NULL, 'Confirmed'),
(67, 16, 4, 3, 1, '2025-06-16', NULL, NULL, '2025-06-19 00:24:23', '2025-06-19 00:24:23', NULL, 'Confirmed'),
(68, NULL, 3, 2, 3, '2025-06-28', NULL, NULL, '2025-06-19 00:34:31', '2025-06-19 00:34:31', NULL, 'Confirmed'),
(69, 19, 1, 5, 1, '2025-06-30', NULL, NULL, '2025-06-19 00:40:19', '2025-06-19 00:40:19', NULL, 'Confirmed'),
(70, 20, 4, 2, 4, '2025-06-01', NULL, NULL, '2025-06-19 00:40:54', '2025-06-19 00:40:54', NULL, 'Confirmed'),
(71, 21, 1, 1, 4, '2025-07-06', NULL, NULL, '2025-06-19 00:42:42', '2025-06-19 00:42:42', NULL, 'Confirmed'),
(72, 1, 1, 4, 3, '2025-07-10', NULL, NULL, '2025-06-19 00:51:16', '2025-06-19 00:51:16', NULL, 'Confirmed'),
(78, 22, 3, 4, 5, '2025-06-23', NULL, NULL, '2025-06-20 21:23:55', '2025-06-20 21:23:55', NULL, 'Confirmed'),
(81, 22, 1, 4, 2, '2025-06-16', NULL, NULL, '2025-06-20 23:19:32', '2025-06-20 23:19:32', NULL, 'Confirmed'),
(82, 22, 1, 4, 2, '2025-06-16', NULL, NULL, '2025-06-20 23:19:56', '2025-06-20 23:19:56', NULL, 'Confirmed'),
(83, 22, 1, 4, 2, '2025-06-16', NULL, NULL, '2025-06-20 23:20:51', '2025-06-20 23:20:51', NULL, 'Confirmed'),
(84, 22, 3, 2, 2, '2025-06-25', NULL, NULL, '2025-06-20 23:33:17', '2025-06-20 23:33:17', NULL, 'Confirmed'),
(85, 22, 3, 2, 2, '2025-06-24', NULL, NULL, '2025-06-20 23:37:52', '2025-06-20 23:37:52', NULL, 'Confirmed'),
(86, 22, 3, 3, 3, '2025-06-22', NULL, NULL, '2025-06-20 23:39:27', '2025-06-20 23:39:27', NULL, 'Confirmed'),
(87, 23, 3, 3, 2, '2025-06-17', NULL, NULL, '2025-06-20 23:49:57', '2025-06-20 23:49:57', NULL, 'Confirmed'),
(89, 23, 1, 1, 4, '2025-06-22', NULL, NULL, '2025-06-20 23:51:57', '2025-06-20 23:51:57', NULL, 'Confirmed'),
(90, 24, 3, 4, 1, '2025-06-22', NULL, NULL, '2025-06-21 00:07:15', '2025-06-21 00:07:15', NULL, 'Confirmed'),
(92, 25, 3, 3, 2, '2025-06-19', NULL, NULL, '2025-06-30 21:19:10', '2025-06-30 21:19:10', NULL, 'Confirmed'),
(93, 25, 1, 1, 4, '2025-06-05', NULL, NULL, '2025-06-30 21:19:29', '2025-06-30 21:19:29', NULL, 'Confirmed'),
(94, 26, 3, 3, 1, '2025-06-20', NULL, NULL, '2025-06-30 21:30:07', '2025-06-30 21:30:07', NULL, 'Confirmed'),
(95, 28, 3, 2, 4, '2025-06-16', NULL, NULL, '2025-06-30 21:30:47', '2025-06-30 21:30:47', NULL, 'Confirmed'),
(96, 30, 4, 3, 5, '2025-06-02', NULL, NULL, '2025-06-30 21:31:45', '2025-06-30 21:31:45', NULL, 'Confirmed'),
(97, 31, 1, 4, 3, '2025-06-06', NULL, NULL, '2025-06-30 21:36:47', '2025-06-30 21:36:47', NULL, 'Confirmed'),
(98, 32, 4, 2, 1, '2025-06-09', NULL, NULL, '2025-06-30 21:37:13', '2025-06-30 21:37:13', NULL, 'Confirmed'),
(99, 33, 2, 5, 5, '2025-06-05', NULL, NULL, '2025-06-30 21:37:47', '2025-06-30 21:37:47', NULL, 'Confirmed'),
(100, 34, 4, 3, 1, '2025-06-20', NULL, NULL, '2025-06-30 21:43:13', '2025-06-30 21:43:13', NULL, 'Confirmed'),
(101, 35, 2, 5, 4, '2025-06-03', NULL, NULL, '2025-06-30 21:44:57', '2025-06-30 21:44:57', NULL, 'Confirmed'),
(103, 39, 3, 3, 4, '2025-07-17', NULL, NULL, '2025-07-01 14:43:59', '2025-07-01 14:43:59', NULL, 'Confirmed'),
(105, 42, 5, 2, 1, '2025-07-09', NULL, NULL, '2025-07-02 15:13:05', '2025-07-02 15:13:05', NULL, 'Confirmed'),
(106, 44, 3, 3, 3, '2025-07-27', NULL, NULL, '2025-07-02 19:01:50', '2025-07-02 19:01:50', NULL, 'Confirmed'),
(107, 45, 1, 2, 1, '2025-07-10', NULL, NULL, '2025-07-02 19:02:25', '2025-07-02 19:02:25', NULL, 'Confirmed'),
(108, 44, 3, 1, 3, '2025-07-23', NULL, NULL, '2025-07-02 19:10:17', '2025-07-02 19:10:17', NULL, 'Confirmed'),
(109, 47, 3, 3, 3, '2025-07-29', NULL, NULL, '2025-07-02 19:11:33', '2025-07-02 19:11:33', NULL, 'Confirmed'),
(111, 49, 4, 3, 3, '2025-07-22', NULL, NULL, '2025-07-02 19:28:28', '2025-07-02 19:28:28', NULL, 'Confirmed'),
(113, 51, 4, 4, 4, '2025-07-21', NULL, NULL, '2025-07-02 19:41:04', '2025-07-02 19:41:04', NULL, 'Confirmed'),
(115, 53, 2, 1, 3, '2025-07-01', NULL, NULL, '2025-07-02 19:43:34', '2025-07-02 19:43:34', NULL, 'Confirmed'),
(116, 54, 3, 3, 2, '2025-07-14', NULL, NULL, '2025-07-02 19:54:21', '2025-07-02 19:54:21', NULL, 'Confirmed'),
(117, 55, 3, 2, 1, '2025-07-25', NULL, NULL, '2025-07-02 19:54:58', '2025-07-02 19:54:58', NULL, 'Confirmed'),
(118, 56, 2, 4, 3, '2025-07-27', NULL, NULL, '2025-07-02 19:59:04', '2025-07-02 19:59:04', NULL, 'Confirmed'),
(119, 58, 4, 4, 4, '2025-07-23', NULL, NULL, '2025-07-02 19:59:39', '2025-07-02 19:59:39', NULL, 'Confirmed'),
(121, 61, 2, 3, 1, '2025-07-24', NULL, NULL, '2025-07-02 20:05:58', '2025-07-02 20:05:58', NULL, 'Confirmed'),
(123, 64, 3, 4, 2, '2025-07-28', NULL, NULL, '2025-07-02 21:03:10', '2025-07-02 21:03:10', NULL, 'Confirmed'),
(124, 66, 1, 4, 2, '2025-07-28', NULL, NULL, '2025-07-02 21:03:47', '2025-07-02 21:03:47', NULL, 'Confirmed'),
(125, 67, 4, 2, NULL, '2025-07-12', NULL, NULL, '2025-07-02 21:09:17', '2025-07-02 21:09:17', NULL, 'Confirmed'),
(126, 68, 1, 4, 5, '2025-07-22', NULL, NULL, '2025-07-02 21:10:04', '2025-07-02 21:10:04', NULL, 'Confirmed'),
(127, 69, 4, 4, 2, '2025-08-01', NULL, NULL, '2025-07-02 21:44:35', '2025-07-02 21:44:35', NULL, 'Confirmed'),
(128, 70, 3, 4, 2, '2025-07-22', NULL, NULL, '2025-07-02 22:36:42', '2025-07-02 22:36:42', NULL, 'Confirmed'),
(131, 75, 3, 3, 3, '2025-07-31', NULL, NULL, '2025-07-02 23:03:59', '2025-07-02 23:03:59', NULL, 'Confirmed'),
(133, 77, 1, 2, 4, '2025-07-11', NULL, NULL, '2025-07-02 23:06:59', '2025-07-02 23:06:59', NULL, 'Confirmed'),
(134, 78, 1, 1, NULL, '2025-07-10', NULL, NULL, '2025-07-02 23:11:27', '2025-07-02 23:11:27', NULL, 'Confirmed'),
(143, 89, 3, 4, NULL, '2025-07-20', NULL, NULL, '2025-07-03 01:04:16', '2025-07-03 01:04:16', NULL, 'Confirmed'),
(144, 90, 3, 4, 3, '2025-07-25', NULL, NULL, '2025-07-03 01:10:06', '2025-07-03 01:10:06', NULL, 'Confirmed'),
(145, 91, 4, 5, NULL, '2025-07-25', NULL, NULL, '2025-07-03 01:10:56', '2025-07-03 01:10:56', NULL, 'Confirmed'),
(147, 93, 3, 1, 2, '2025-07-09', NULL, NULL, '2025-07-03 01:26:00', '2025-07-03 01:26:00', NULL, 'Confirmed'),
(148, 94, 3, 4, 2, '2025-07-17', NULL, NULL, '2025-07-03 06:53:37', '2025-07-03 06:53:37', NULL, 'Confirmed'),
(151, 98, 2, 2, 1, '2025-07-16', NULL, NULL, '2025-07-03 08:26:55', '2025-07-03 08:26:55', NULL, 'Confirmed'),
(152, 99, 3, 3, 2, '2025-07-16', NULL, NULL, '2025-07-03 08:27:57', '2025-07-03 08:27:57', NULL, 'Confirmed'),
(153, 102, 5, 5, 2, '2025-07-19', NULL, NULL, '2025-07-03 17:55:40', '2025-07-03 17:55:40', NULL, 'Confirmed'),
(155, 105, 5, 2, 1, '2025-07-18', NULL, NULL, '2025-07-08 09:06:12', '2025-07-08 09:06:12', NULL, 'Confirmed');

--
-- Triggers `reservation`
--
DELIMITER $$
CREATE TRIGGER `powers_duals_booking` BEFORE INSERT ON `reservation` FOR EACH ROW BEGIN
    IF EXISTS (
        SELECT 1 
        FROM reservation 
        WHERE Table_ID = NEW.Table_ID
        AND Slot_ID = NEW.Slot_ID
        AND ReservationDate = NEW.ReservationDate
        AND ReservationStatus = 'Confirmed'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This table is already booked for the same time slot and date.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `prevent_double_booking` BEFORE INSERT ON `reservation` FOR EACH ROW BEGIN
  DECLARE reservation_count INT;

  SELECT COUNT(*) INTO reservation_count
  FROM reservation
  WHERE Table_ID = NEW.Table_ID
    AND ReservationDate = NEW.ReservationDate
    AND Slot_ID = NEW.Slot_ID;

  IF reservation_count > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Slot already booked';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `reservations`
--

CREATE TABLE `reservations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) NOT NULL,
  `service_id` bigint(20) UNSIGNED NOT NULL,
  `table_id` bigint(20) UNSIGNED NOT NULL,
  `reservation_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Service`
--

CREATE TABLE `Service` (
  `Service_ID` int(11) NOT NULL,
  `Name` varchar(100) DEFAULT NULL,
  `Description` text DEFAULT NULL,
  `Cost` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Service`
--

INSERT INTO `Service` (`Service_ID`, `Name`, `Description`, `Cost`) VALUES
(1, 'Birthday Setup', NULL, 5000.00),
(2, 'Anniversary Decor', NULL, 7000.00),
(3, 'Candle Light Dinner', NULL, 3500.00),
(4, 'Corporate Setup', NULL, 8500.00),
(5, 'Custom Theme', NULL, 9500.00);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(191) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('h59VT9Ytg1q5w46JKEtU4IDLQKpL86bDZ26MmRHA', NULL, '2400:adcc:106:8900:7c23:6fb6:d23f:cea', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVDg3VkVDNGpPYnVnOEtDWWpBVnF3Qm1hdEJTZzJocXg4ZDFEalh6ZyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vbWVkaXVtb3JjaGlkLXdvcm0tMTA1OTU1Lmhvc3RpbmdlcnNpdGUuY29tIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1751968292),
('U6EJgb7DjGB0wosZIyF51k3LJBuJiVgunPSDNdFf', NULL, '223.123.88.203', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVkRMaU9HenZVUFdUOFFNaGFRWlF5YjhXUmxUNDRqVjhZN2VEYWZuYyI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vbWVkaXVtb3JjaGlkLXdvcm0tMTA1OTU1Lmhvc3RpbmdlcnNpdGUuY29tL2xvZ2luIjt9fQ==', 1751965693),
('yU1rObnMyAgGTdlBBK8SI0B0AcoGO0kr7MmskOMO', NULL, '2400:adcc:106:8900:7c23:6fb6:d23f:cea', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibjBIZTZBMlgya2hPdGp3QTZkN0p0VnVVajFWUVhVYWJoSEpsV0hWdyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vbWVkaXVtb3JjaGlkLXdvcm0tMTA1OTU1Lmhvc3RpbmdlcnNpdGUuY29tIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1751968291);

-- --------------------------------------------------------

--
-- Table structure for table `tableinfo`
--

CREATE TABLE `tableinfo` (
  `Table_ID` int(11) NOT NULL,
  `Capacity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tableinfo`
--

INSERT INTO `tableinfo` (`Table_ID`, `Capacity`) VALUES
(1, 2),
(2, 4),
(3, 6),
(4, 8),
(5, 10);

-- --------------------------------------------------------

--
-- Table structure for table `Time_Slot`
--

CREATE TABLE `Time_Slot` (
  `Slot_ID` int(11) NOT NULL,
  `Start_Time` time DEFAULT NULL,
  `End_Time` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Time_Slot`
--

INSERT INTO `Time_Slot` (`Slot_ID`, `Start_Time`, `End_Time`) VALUES
(1, '12:00:00', '13:00:00'),
(2, '13:00:00', '14:00:00'),
(3, '14:00:00', '15:00:00'),
(4, '15:00:00', '16:00:00'),
(5, '16:00:00', '17:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) NOT NULL,
  `email` varchar(191) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(191) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'zaru', '123erf@gmail.com', NULL, '$2y$12$KKU0GrikDF6UCxdOapPlxegZ763oRYscXlm0WE24b4yD111k/C6Am', NULL, '2025-06-14 16:10:47', '2025-06-14 16:10:47'),
(2, 'Goraltur', 'goraltkhan7@gmail.com', NULL, '$2y$12$lOacmcQFEjml5QrGe1VHxOoJXKfekdYe7XmZovGBZmusLqzh50e92', NULL, '2025-06-14 23:27:53', '2025-06-14 23:27:53'),
(3, 'kali', '123@gmail.com', NULL, '$2y$12$Jj.703VOhvfJ65sLXmsnaOTt38/1kI59cZM80zjtbq18Dd1iwlzmK', NULL, '2025-06-16 15:12:11', '2025-06-16 15:12:11'),
(4, 'jon', '8976@gmail.com', NULL, '$2y$12$gIsYhosBxGQxl3.HxXd3xO7sR0MtFt1TFrpqY1RgVMIalUOCmUDxC', NULL, '2025-06-16 19:31:07', '2025-06-16 19:31:07'),
(5, 'ben', 'ben234@gamil.com', NULL, '$2y$12$uZfYslSj0fSpsF7d/BWFhOgY7GTilXRE12RoVpdpwGBEbljmBYK5O', NULL, '2025-06-16 22:42:44', '2025-06-16 22:42:44'),
(6, 'xen', '23476@gmail.com', NULL, '$2y$12$irl44gS3JoGQuUvnIXDTxOmCjC5r14ICqBCs7M1zVdyB6amAJniie', NULL, '2025-06-17 17:36:08', '2025-06-17 17:36:08'),
(7, 'feg', 'feg234@gmail.com', NULL, '$2y$12$o7SjELX5CvUt8FzPQxEaY.SVOkWuDeXCcvyL10Ibhs1kdzZSHPWw.', NULL, '2025-06-17 22:26:41', '2025-06-17 22:26:41'),
(8, 'rafee', 'rafee234@gamil.com', NULL, '$2y$12$SrAFwGicZjN4vPiLgv9Bj.NNeBl4WDJh08f2/8yCRIlYfo92RPx5C', NULL, '2025-06-17 22:42:20', '2025-06-17 22:42:20'),
(9, 'jumil', 'jumil234@gmail.com', NULL, '$2y$12$oUoERh3XJhHaxHCsbMEKTuOXn13LPpVRK7ePVZodSx5DvaEs8zgRy', NULL, '2025-06-18 23:51:19', '2025-06-18 23:51:19'),
(10, 'gem', 'gem234@gmail.ocm', NULL, '$2y$12$ikm6l96dOlpbWjLkx0I/8eFhksQ.IMfkDtmyKkxdfmfKbUFOS/7uq', NULL, '2025-06-19 00:20:00', '2025-06-19 00:20:00'),
(11, 'zoi', 'zoi234@gamil.com', NULL, '$2y$12$dm/0Uiura1U8R80YMBYHmOLJ4yZy8KiiNORob993VCLP5B3YlhEj6', NULL, '2025-06-20 21:20:41', '2025-06-20 21:20:41'),
(12, 'clera', 'clera234@gmail.com', NULL, '$2y$12$VqmSBy6LOA7woRqfbVhaDOcVyltK39SmN3LNxyFrGb9ZW6ZvjMQKO', NULL, '2025-06-20 23:48:33', '2025-06-20 23:48:33'),
(13, 'zoi', 'zoi234@gmail.com', NULL, '$2y$12$1lBSRoC5AOAEhFBZ.M/4bOOxEpWrhsYWg.du7PFfhUB4zaYfAC2Q2', NULL, '2025-06-21 00:05:23', '2025-06-21 00:05:23'),
(14, 'nimra', 'nimra234@gmail.com', NULL, '$2y$12$7wZeApFIDKtiz/hvgZ0aVe4aOuJ4OCJQSGPr8b6z7RrAyNx2IeoA.', NULL, '2025-06-30 21:17:54', '2025-06-30 21:17:54'),
(15, 'khurram', 'hania234@gmail.com', NULL, '$2y$12$5NOtESGNOCt1wZnggRlIZ.RIQWfojG6yS1NTlOf/qxaJDdk.0.ia2', NULL, '2025-06-30 21:36:30', '2025-06-30 21:36:30'),
(16, 'bina', 'bina234@gmail.com', NULL, '$2y$12$oAtViSAUdd8XGCFaQhvnMORXIqxvlxSE.sSmR3WDuMomNjDFhgKeS', NULL, '2025-07-01 14:41:12', '2025-07-01 14:41:12'),
(17, 'jamal khan', 'jamal234@gmail.com', NULL, '$2y$12$GTnMHw7AMqRec/jxKCEWAurz.wAmMwp9urNuMJRlknvRlXnX6M1w6', NULL, '2025-07-02 15:09:58', '2025-07-02 15:09:58'),
(18, 'kamran khan', 'kamran234@gmail.com', NULL, '$2y$12$kxesrRRkVVCMsZc3ZFlBoeRXYvByeSnka2X8Dn7TzbWfg8n2alQ72', NULL, '2025-07-02 18:52:01', '2025-07-02 18:52:01'),
(19, 'hiba', 'hiba234@gmail.com', NULL, '$2y$12$wrWJauYMGohk0TN/qX911OMQvyd7dfY8iM6bg10JeiQxC8LbIETmK', NULL, '2025-07-02 19:42:20', '2025-07-02 19:42:20'),
(20, 'laila', 'laila234@gmaiol.com', NULL, '$2y$12$u3QBKmiGUkkU0GATW3gL4uYl01gQyd3ccYpxE2AlqdbRddVeiWcKW', NULL, '2025-07-02 19:53:51', '2025-07-02 19:53:51'),
(21, 'bakhtawar', 'batkhtawar234@gmail.com', NULL, '$2y$12$bN4T.m6VGZu3nQRp9pXyw.6yWFWpZEK6GdVxJomKSJvR0brtzBZoa', NULL, '2025-07-02 21:02:38', '2025-07-02 21:02:38'),
(22, 'yasmin', 'yasmin234@gmail.com', NULL, '$2y$12$Zwb7pZm6//dTPKfC3QkJxe1z6gVyDJRTmZhg6vFQCCWjq70oZqA2m', NULL, '2025-07-02 22:36:08', '2025-07-02 22:36:08'),
(23, 'huda', 'huda235@gmail.com', NULL, '$2y$12$x9QYvoApmLn5Mc3XEvRm6uvnG/yZF3Nhv2ZnroxOIn8VPN5F0Po5q', NULL, '2025-07-02 23:01:06', '2025-07-02 23:01:06'),
(24, 'khushi', 'khushi2342@gmail.com', NULL, '$2y$12$84dCnJpGXDbg8eqYLWRYBuV7DeufZRxZ0Pq5bg0XSDNn7cueP0mga', NULL, '2025-07-02 23:24:36', '2025-07-02 23:24:36'),
(25, 'test', 'test@gmail.com', NULL, '$2y$12$kBb1.GT8N/Wvj7fVPnRmtORqS7txVUwu75tJbG8jmFkvI1vzy/LUy', NULL, '2025-07-02 23:05:13', '2025-07-02 23:05:13'),
(26, 'atif khan', 'atif100@gmail.com', NULL, '$2y$12$R6TAneM4CdYSuAuJv2BON.7TwZMIsA.fzNTvUmXgPmq7TykyKkLy.', NULL, '2025-07-02 23:14:58', '2025-07-02 23:14:58'),
(27, 'Khizra', 'khizra@gmail.com', NULL, '$2y$12$Q/FhylwyccNUgum8scE0ge6svi5cih1koLIBA6sXQNER42NAfmlmu', NULL, '2025-07-02 23:59:37', '2025-07-02 23:59:37'),
(28, 'Aftab', 'aftab234@gmail.com', NULL, '$2y$12$FTTgC3OQ2l7AFpZj4cCaceJZ1ozfPDTj67Juhw/4UdaN8d2geBIoq', NULL, '2025-07-03 00:36:41', '2025-07-03 00:36:41'),
(29, 'Areej M', 'areejmalik192004@gmail.com', NULL, '$2y$12$DU8ckVWxfh/WbU2pDSoxOuNjblP.caQ4klHhzsa4Pz1gt2VvPNB1S', NULL, '2025-07-03 00:41:05', '2025-07-03 00:41:05'),
(30, 'Syed jalal', 'syedjalal2004@gmail.com', NULL, '$2y$12$EwORUzQ8z/zXQdgllaI.8.aKhcy80IlF0sBkqp8ctUawcuKaoIWA.', NULL, '2025-07-03 06:49:29', '2025-07-03 06:49:29'),
(31, 'saba', 'saba234@gmail.com', NULL, '$2y$12$BKJOtrvONPuYb1PjMTmJveYSe5UCAxlvItLHJ12FGyNZhb8OsdJDC', NULL, '2025-07-03 06:52:38', '2025-07-03 06:52:38'),
(32, 'Zumra', 'zumra@gmail.com', NULL, '$2y$12$bRunRXWBQClOabjuDSTCgecUCmRBelSOXyJaHvAx9JFzzIuukALUu', NULL, '2025-07-03 07:29:48', '2025-07-03 07:29:48'),
(33, 'zaman', 'zaman234@gmail.com', NULL, '$2y$12$2qGiQyNp7XaBbOyzuQAfTOf0LwR5FiEmubTYmNH/mgMFTlGNscsXC', NULL, '2025-07-03 08:12:58', '2025-07-03 08:12:58'),
(34, 'khiza', 'khiz123@gmail.com', NULL, '$2y$12$E.BOea6iyzAMGxp7zkxiuec2JUCpijnw2hUwCtfkvDQVQKuHu04VC', NULL, '2025-07-03 08:25:33', '2025-07-03 08:25:33'),
(35, 'Naib', 'naibkhan234@mail.com', NULL, '$2y$12$BCAma7DQa96aYh.ItNSJ4.TxZeplHLKGIhTMwGxtQgYnbhi2o7YpS', NULL, '2025-07-03 14:26:58', '2025-07-03 14:26:58'),
(36, 'zanib', 'zaanibkhaan@gmail.com', NULL, '$2y$12$o38XlpzjQ3BWhUiwzftJ3uWYLh2FyEtj9q0hHkilbSe7zVFlZJ6M2', NULL, '2025-07-03 14:29:14', '2025-07-03 14:29:14'),
(37, 'Zayan', 'zayan234@gmail.com', NULL, '$2y$12$T/Z9oDTr/35mmkHA62Ngs.u88vjPeBkztmC2B8bIY6yNZPXnYDiwe', NULL, '2025-07-03 17:53:52', '2025-07-03 17:53:52'),
(38, 'Yusra khan', 'yusra234@gmail.com', NULL, '$2y$12$uKIZRe7cobARevLWoOxiP.rX02MSBef96wNOtDdmesvf0aWEtNqgK', NULL, '2025-07-08 09:00:10', '2025-07-08 09:00:10');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cancellation`
--
ALTER TABLE `cancellation`
  ADD PRIMARY KEY (`Cancellation_ID`),
  ADD UNIQUE KEY `Reservation_ID` (`Reservation_ID`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`Customer_ID`),
  ADD KEY `customer_user_id_foreign` (`User_ID`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`Payment_ID`),
  ADD KEY `Reservation_ID` (`Reservation_ID`);

--
-- Indexes for table `reservation`
--
ALTER TABLE `reservation`
  ADD PRIMARY KEY (`Reservation_ID`),
  ADD KEY `Customer_ID` (`Customer_ID`),
  ADD KEY `Table_ID` (`Table_ID`),
  ADD KEY `Slot_ID` (`Slot_ID`),
  ADD KEY `Service_ID` (`Service_ID`);

--
-- Indexes for table `reservations`
--
ALTER TABLE `reservations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reservations_user_id_foreign` (`user_id`);

--
-- Indexes for table `Service`
--
ALTER TABLE `Service`
  ADD PRIMARY KEY (`Service_ID`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `tableinfo`
--
ALTER TABLE `tableinfo`
  ADD PRIMARY KEY (`Table_ID`);

--
-- Indexes for table `Time_Slot`
--
ALTER TABLE `Time_Slot`
  ADD PRIMARY KEY (`Slot_ID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cancellation`
--
ALTER TABLE `cancellation`
  MODIFY `Cancellation_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `Customer_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `Payment_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `reservation`
--
ALTER TABLE `reservation`
  MODIFY `Reservation_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=156;

--
-- AUTO_INCREMENT for table `reservations`
--
ALTER TABLE `reservations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Service`
--
ALTER TABLE `Service`
  MODIFY `Service_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tableinfo`
--
ALTER TABLE `tableinfo`
  MODIFY `Table_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `Time_Slot`
--
ALTER TABLE `Time_Slot`
  MODIFY `Slot_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cancellation`
--
ALTER TABLE `cancellation`
  ADD CONSTRAINT `cancellation_ibfk_1` FOREIGN KEY (`Reservation_ID`) REFERENCES `reservation` (`Reservation_ID`),
  ADD CONSTRAINT `fk_res_cancel` FOREIGN KEY (`Reservation_ID`) REFERENCES `reservation` (`Reservation_ID`) ON DELETE CASCADE;

--
-- Constraints for table `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `customer_user_id_foreign` FOREIGN KEY (`User_ID`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`Reservation_ID`) REFERENCES `reservation` (`Reservation_ID`);

--
-- Constraints for table `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`Customer_ID`) REFERENCES `customer` (`Customer_ID`),
  ADD CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`Table_ID`) REFERENCES `tableinfo` (`Table_ID`),
  ADD CONSTRAINT `reservation_ibfk_3` FOREIGN KEY (`Slot_ID`) REFERENCES `Time_Slot` (`Slot_ID`),
  ADD CONSTRAINT `reservation_ibfk_4` FOREIGN KEY (`Service_ID`) REFERENCES `Service` (`Service_ID`);

--
-- Constraints for table `reservations`
--
ALTER TABLE `reservations`
  ADD CONSTRAINT `reservations_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
