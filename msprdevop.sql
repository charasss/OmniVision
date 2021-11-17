-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mer. 17 nov. 2021 à 14:31
-- Version du serveur :  5.7.31
-- Version de PHP : 7.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `msprdevops`
--

-- --------------------------------------------------------

--
-- Structure de la table `capture_incident_maps`
--

DROP TABLE IF EXISTS `capture_incident_maps`;
CREATE TABLE IF NOT EXISTS `capture_incident_maps` (
  `id_capture` int(11) NOT NULL,
  `id_incident` int(11) NOT NULL,
  PRIMARY KEY (`id_capture`,`id_incident`),
  KEY `id_incident` (`id_incident`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `capture_incident_maps`
--

INSERT INTO `capture_incident_maps` (`id_capture`, `id_incident`) VALUES
(1, 3),
(2, 2),
(2, 3),
(3, 5),
(4, 6),
(5, 2),
(7, 2);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
