-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mer. 17 nov. 2021 à 15:29
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

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `InsertUserIdentifiant`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertUserIdentifiant` (IN `nom` VARCHAR(50), IN `prenom` VARCHAR(50), IN `mail` VARCHAR(50), IN `num` VARCHAR(50), IN `adresse` VARCHAR(50), IN `sous_traitant` INT(11), IN `metier` INT(11))  NO SQL
INSERT into employee 
(identifiant_employee,`nom_employee`,`prenom_employee`,`mail_employee`,`num_employee`,`adresse_employee`,id_sous_traitant, id_metier) 
VALUES (
    concat(IF(
    sous_traitant = 0
    ,"I"
    ,"C"
    )
	,YEAR(CURRENT_DATE)
	,LEFT(nom,2)
    ,LEFT(prenom,2)
          )
    ,nom
        ,prenom
        ,mail
        ,num
        ,adresse
		,IF(sous_traitant != 0,sous_traitant,NULL)
		,metier)$$

DROP PROCEDURE IF EXISTS `insert_new_capture`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_new_capture` (IN `reference_capture` VARCHAR(6), `date_capture` DATE, `heure_capture` TIME, `captures_capture` LONGTEXT, `incidents_capture` VARCHAR(50), `coordonneesGPS_capture` VARCHAR(50), `jalonGANT_capture` VARCHAR(50), `etapeDeCapture_capture` VARCHAR(50), `type_capture` TINYINT(1), `id_chantier` INT(11))  BEGIN
INSERT INTO capture (
 reference_capture,
 date_capture,
 heure_capture,
 captures_capture,
 incidents_capture,
 coordonneesGPS_capture,
 jalonGANT_capture,
 etapeDeCapture_capture,
 type_capture,
 id_chantier
 )
VALUES (
 reference_capture,
 date_capture,
 heure_capture,
 captures_capture,
 incidents_capture,
 coordonneesGPS_capture,
 jalonGANT_capture,
 etapeDeCapture_capture,
 type_capture,
 id_chantier);
END$$

DROP PROCEDURE IF EXISTS `LoadAllForProject`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadAllForProject` (IN `nom_project` VARCHAR(255))  NO SQL
SELECT 
  p.creationDate_project 							as "Date"
, c.nom_chantier 									as "Nom de chantier"
, GROUP_CONCAT(DISTINCT(st.nom_sous_traitant)) 		as "nom des entreprise concerné"
, m.metier_metier									as "métier"
, ca.captures_capture								as "vidéo de capture"

FROM
		project 				p
Join 	chantier 				c 					on c.id_project = p.id_project 
join 	chantier_employee_maps 	maps 				on maps.id_chantier = c.id_chantier
join 	employee 				e 					on maps.id_employee = e.id_employee 
join 	metier 					m 					on e.id_metier = m.id_metier
join 	sous_traitant			st 					on st.id_sous_traitant = e.id_sous_traitant
join 	capture					ca 					on ca.id_chantier = c.id_chantier 
Where p.nom_project LIKE CONCAT("%",nom_project,"%")
group by c.id_chantier, ca.captures_capture$$

DROP PROCEDURE IF EXISTS `LoadCaptureChantier`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadCaptureChantier` ()  NO SQL
SELECT c.* 
, e.nom_employee AS "Employee"
, ch.nom_chantier AS "Chantier"
FROM capture c
JOIN chantier ch ON c.id_chantier = ch.id_chantier
JOIN chantier_employee_maps cem ON ch.id_chantier = cem.id_chantier
JOIN employee e ON cem.id_employee = e.id_employee
GROUP BY c.reference_capture$$

DROP PROCEDURE IF EXISTS `LoadChantierForAdmin`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadChantierForAdmin` (`nom` VARCHAR(50))  BEGIN
SELECT nom_employee, nom_chantier, adresse_chantier, creationDate_chantier, closedDate_chantier, status_chantier
FROM employee, chantier
WHERE nom_employee = nom;
END$$

DROP PROCEDURE IF EXISTS `LoadChantierForCEmployee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadChantierForCEmployee` (IN `employee` INTEGER(11))  NO SQL
SELECT *
FROM chantier
Join chantier_employee_maps   	maps 		on maps.id_chantier = chantier.id_chantier
Join employee 					e 			on maps.id_employee = e.id_employee
WHERE id_sous_traitant IS NOT NULL
and e.id_employee = employee$$

DROP PROCEDURE IF EXISTS `LoadEmployeeProject`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadEmployeeProject` ()  NO SQL
SELECT e.nom_employee AS "Employee",
p.nom_project AS "Projet"

FROM project p 
JOIN chantier c ON p.id_project = c.id_project
JOIN chantier_employee_maps cem ON c.id_chantier = cem.id_chantier
JOIN employee e ON cem.id_employee = e.id_employee$$

DROP PROCEDURE IF EXISTS `loadIncidentForCapture`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `loadIncidentForCapture` (IN `reference_capture` VARCHAR(6))  NO SQL
SELECT *
FROM capture c
Join capture_incident_maps mc on mc.id_capture = c.id_capture 
JOin incident i on i.numéro_incident = mc.id_incident 
Join incident_métier_maps mi on mi.id_incident = i.numéro_incident 
Join metier m on m.id_metier = mi.id_metier
where c.reference_capture = reference_capture$$

DROP PROCEDURE IF EXISTS `LoadProjetAfterThisDate`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadProjetAfterThisDate` (`date` DATE)  BEGIN
SELECT nom_chantier
FROM chantier
WHERE creationDate_chantier >= date;
END$$

DROP PROCEDURE IF EXISTS `nb_finish_project`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `nb_finish_project` (IN `date1` DATE, `date2` DATE)  BEGIN
SELECT nom_project,
 creationDate_project,
 closedDate_project,
 c.adresse_chantier,
  GROUP_CONCAT(Distinct(st.nom_sous_traitant))
FROM project
JOIN chantier 					c 			ON project.id_project = c.id_project
Join chantier_employee_maps   	maps 		on maps.id_chantier = c.id_chantier
Join employee 					e 			on maps.id_employee = e.id_employee
Join sous_traitant 				st 			on e.id_sous_traitant = st.id_sous_traitant

WHERE closedDate_project BETWEEN date1 AND date2
group by c.id_chantier;
END$$

DROP PROCEDURE IF EXISTS `NombreSousTraitantEmployee`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `NombreSousTraitantEmployee` ()  NO SQL
SELECT COUNT(e.nom_employee) AS "Nombre_Employee_Sous_Traitan",
p.nom_project AS "Project",
m.metier_metier AS "Metier"

FROM metier m  
JOIN employee e ON m.id_metier = e.id_metier
JOIN sous_traitant s ON e.id_sous_traitant = s.id_sous_traitant
JOIN chantier_employee_maps cem ON e.id_employee = cem.id_employee
JOIN chantier c ON cem.id_chantier = c.id_chantier
JOIN project p ON c.id_project = p.id_project
GROUP BY p.id_project, m.id_metier$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `capture`
--

DROP TABLE IF EXISTS `capture`;
CREATE TABLE IF NOT EXISTS `capture` (
  `id_capture` int(11) NOT NULL AUTO_INCREMENT,
  `reference_capture` varchar(6) NOT NULL,
  `date_capture` date NOT NULL,
  `heure_capture` time NOT NULL,
  `captures_capture` longtext NOT NULL,
  `incidents_capture` varchar(50) NOT NULL,
  `coordonneesGPS_capture` varchar(50) NOT NULL,
  `jalonGANT_capture` varchar(50) NOT NULL,
  `etapeDeCapture_capture` varchar(50) NOT NULL,
  `type_capture` tinyint(1) NOT NULL,
  `id_chantier` int(11) NOT NULL,
  PRIMARY KEY (`id_capture`),
  KEY `Capture_Chantier_FK` (`id_chantier`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `capture`
--

INSERT INTO `capture` (`id_capture`, `reference_capture`, `date_capture`, `heure_capture`, `captures_capture`, `incidents_capture`, `coordonneesGPS_capture`, `jalonGANT_capture`, `etapeDeCapture_capture`, `type_capture`, `id_chantier`) VALUES
(1, '#00121', '2021-10-22', '08:10:17', 'daafafafasfasfa', 'fafafa', 'afafafa', 'afafaz', 'afafa', 2, 1),
(2, '#00122', '2020-10-19', '08:10:00', '\"https://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPF https://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPG https://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPH\"', 'Carence rouleau cable 0.2', '44.917639, -0.735070', 'Préparation énergie Lot 2', 'Montage R0 R1', 2, 3),
(3, '#00123', '2020-10-21', '08:02:00', '\"https://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPF\r\nhttps://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPG\"', 'Montage défectueux compteurs', '44.917639, -0.735070', 'Préparation énergie Lot 3', 'Montage R0 R1', 2, 3),
(4, '#00124', '2020-10-26', '07:59:00', 'https://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPF', 'néant', '44.917639, -0.735070', 'Préparation énergie Lot 2', 'Montage R0 R1', 2, 3),
(5, '#00125', '2021-10-29', '08:24:00', '\"https://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPF\r\nhttps://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPH\r\nhttps://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPH\r\nhttps://my.matterport.com/folders/uP8wSdfuhbC?page=1&ordering=-created&page_size=24&type=all&parent=uP8wSdfuhbC&organization=snn2BCakTPH\"', 'néant', '44.917639, -0.735070', 'Préparation énergie Lot 3', 'Montage R0 R1', 2, 3),
(6, '#00234', '2020-09-21', '18:39:00', '\"09776545.jpg\r\nIG2234.mp4\r\nIG2235.mp4\"', 'néant', '44.634074, -1.083128', 'Excavation / Fondations', 'Stockage Matériel', 1, 2),
(7, '#00235', '2020-09-28', '18:29:00', '\"IG2236.mp4\r\nIG2237.mp4\r\nIG2238.mp4\r\nIG2239.mp4\r\nIG2240.mp4\r\nIG2241.mp4\"', 'Carence ciment fondation Nord-Est', '44.634074, -1.083128', 'Excavation / Fondations', 'Etat fondations', 1, 2),
(8, '#00236', '2020-10-05', '18:12:00', '\"IG2242.mp4\r\nIG2243.mp4\r\n23467567.jpg\r\n35654356.jpg\"', 'néant', '44.634074, -1.083128', 'Installation Grues', 'Banchage', 1, 2);

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

-- --------------------------------------------------------

--
-- Structure de la table `chantier`
--

DROP TABLE IF EXISTS `chantier`;
CREATE TABLE IF NOT EXISTS `chantier` (
  `id_chantier` int(11) NOT NULL AUTO_INCREMENT,
  `nom_chantier` varchar(50) NOT NULL,
  `adresse_chantier` varchar(50) NOT NULL,
  `creationDate_chantier` date NOT NULL,
  `closedDate_chantier` date NOT NULL,
  `status_chantier` varchar(50) NOT NULL,
  `id_project` int(11) NOT NULL,
  PRIMARY KEY (`id_chantier`),
  KEY `Chantier_Project_FK` (`id_project`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `chantier`
--

INSERT INTO `chantier` (`id_chantier`, `nom_chantier`, `adresse_chantier`, `creationDate_chantier`, `closedDate_chantier`, `status_chantier`, `id_project`) VALUES
(1, 'Notre-Dame de Paris', 'fqfeqfafafafaf', '2021-10-21', '2021-10-29', 'En cours', 1),
(2, 'Gujan Mestras', 'dadafafaf', '2021-10-22', '2021-10-31', 'En cours', 2),
(3, 'Saint Aubin de Médoc', 'fafafdasdazd', '2021-11-16', '2021-11-29', 'Non commencer', 3);

-- --------------------------------------------------------

--
-- Structure de la table `chantier_employee_maps`
--

DROP TABLE IF EXISTS `chantier_employee_maps`;
CREATE TABLE IF NOT EXISTS `chantier_employee_maps` (
  `id_chantier` int(11) NOT NULL,
  `id_employee` int(11) NOT NULL,
  PRIMARY KEY (`id_chantier`,`id_employee`),
  KEY `Chantier_Employee_Maps_Employee0_FK` (`id_employee`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `chantier_employee_maps`
--

INSERT INTO `chantier_employee_maps` (`id_chantier`, `id_employee`) VALUES
(1, 1),
(3, 2),
(3, 3),
(2, 4);

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

DROP TABLE IF EXISTS `client`;
CREATE TABLE IF NOT EXISTS `client` (
  `id_client` int(11) NOT NULL AUTO_INCREMENT,
  `nom_client` varchar(50) NOT NULL,
  `siret_client` varchar(50) NOT NULL,
  `mail_client` varchar(50) NOT NULL,
  `num_client` varchar(12) NOT NULL,
  `adresse_client` varchar(150) NOT NULL,
  PRIMARY KEY (`id_client`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`id_client`, `nom_client`, `siret_client`, `mail_client`, `num_client`, `adresse_client`) VALUES
(1, 'Jean-Louis', '4514258752', 'jean-louis@gmail.com', '0454859565', 'dadafafafafafafafafa'),
(2, 'hubert', '6445161296', 'hubert@mail.com', '0545895625', 'afaegafazfazfazfazfazfazf'),
(3, 'Erwan', '788451259584', 'erwan@gmail.com', '8545856525', 'afafaefasfasfasfafza');

-- --------------------------------------------------------

--
-- Structure de la table `employee`
--

DROP TABLE IF EXISTS `employee`;
CREATE TABLE IF NOT EXISTS `employee` (
  `id_employee` int(11) NOT NULL AUTO_INCREMENT,
  `nom_employee` varchar(50) NOT NULL,
  `prenom_employee` varchar(50) NOT NULL,
  `mail_employee` varchar(50) DEFAULT NULL,
  `num_employee` varchar(12) DEFAULT NULL,
  `adresse_employee` varchar(150) DEFAULT NULL,
  `identifiant_employee` varchar(50) DEFAULT NULL,
  `mdp_employee` varchar(50) DEFAULT NULL,
  `isBlocked_employee` tinyint(1) NOT NULL DEFAULT '0',
  `id_metier` int(11) NOT NULL,
  `id_sous_traitant` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_employee`),
  KEY `Employee_Metier_FK` (`id_metier`),
  KEY `Employee_Sous_traitant0_FK` (`id_sous_traitant`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `employee`
--

INSERT INTO `employee` (`id_employee`, `nom_employee`, `prenom_employee`, `mail_employee`, `num_employee`, `adresse_employee`, `identifiant_employee`, `mdp_employee`, `isBlocked_employee`, `id_metier`, `id_sous_traitant`) VALUES
(1, 'Moulin', 'Jean-Marc', 'jean_marc@gmail.com', '0487895682', 'fcqfqfazdQDqxXQsczfa', 'I2019_JeanMarc', 'jm', 0, 1, 1),
(2, 'PAIN', 'Robert', 'robert.pain@gmail.com', '0625847562', '56 avenue despoulican', 'C2019Robert', 'fafafkaef', 0, 2, 2),
(3, 'Melki', 'Charles', 'dadaf', '0202145487', 'dadafaefasfascazdfa', 'C2019Charles', 'fafafaf', 0, 1, 3),
(4, 'Léo', 'Charasse', 'fafaada', '48589562', 'kqpoqjcpoaz', 'C2019Leo', 'fafa', 0, 3, 4),
(5, 'dar', 'claud', 'daafafa', '0457821256', 'afgafazfacacac', 'I2019_DarClaud', 'afaagaga', 0, 4, 4),
(6, 'zle', 'ada', 'afafaga', '01548759', 'afgafacada', 'C2019_ZleAda', 'afagaga', 0, 2, 1),
(8, 'Pic', 'Théo', 'adafgag', '02125485', 'dafafgdfafa', 'CPiTh', NULL, 0, 1, 2),
(9, 'Capiaux', 'Charles', 'fagagav', '15513181', 'gazvavaz', 'C2021CaCh', NULL, 0, 2, 3),
(11, 'Abdulla', 'Yassin', 'fagagav', '15513181', 'gazvavaz', 'I2021AbYa', NULL, 0, 3, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `incident`
--

DROP TABLE IF EXISTS `incident`;
CREATE TABLE IF NOT EXISTS `incident` (
  `numéro_incident` int(11) NOT NULL AUTO_INCREMENT,
  `nom_incident` varchar(55) NOT NULL,
  `priorité_incident` int(1) NOT NULL,
  PRIMARY KEY (`numéro_incident`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `incident`
--

INSERT INTO `incident` (`numéro_incident`, `nom_incident`, `priorité_incident`) VALUES
(1, 'Incendie', 5),
(2, 'Matériel Endommagé', 2),
(3, 'Dégâts des eaux', 5),
(4, 'Gitan in the place', 1),
(5, 'Incident humain (potentiellement mortelle', 5),
(6, 'gaz (Aymeric in the place) by Ilan', 3),
(7, 'Plus de pq ', 2);

-- --------------------------------------------------------

--
-- Structure de la table `incident_métier_maps`
--

DROP TABLE IF EXISTS `incident_métier_maps`;
CREATE TABLE IF NOT EXISTS `incident_métier_maps` (
  `id_incident` int(11) NOT NULL,
  `id_metier` int(11) NOT NULL,
  PRIMARY KEY (`id_incident`,`id_metier`) USING BTREE,
  KEY `id_metier` (`id_metier`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `incident_métier_maps`
--

INSERT INTO `incident_métier_maps` (`id_incident`, `id_metier`) VALUES
(1, 2),
(1, 3),
(2, 1),
(2, 2),
(2, 3),
(3, 1);

-- --------------------------------------------------------

--
-- Structure de la table `metier`
--

DROP TABLE IF EXISTS `metier`;
CREATE TABLE IF NOT EXISTS `metier` (
  `id_metier` int(11) NOT NULL AUTO_INCREMENT,
  `metier_metier` varchar(50) NOT NULL,
  PRIMARY KEY (`id_metier`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `metier`
--

INSERT INTO `metier` (`id_metier`, `metier_metier`) VALUES
(1, 'Menuisier'),
(2, 'Toiturier'),
(3, 'Développeur'),
(4, 'marchant de fruit');

-- --------------------------------------------------------

--
-- Structure de la table `project`
--

DROP TABLE IF EXISTS `project`;
CREATE TABLE IF NOT EXISTS `project` (
  `id_project` int(11) NOT NULL AUTO_INCREMENT,
  `nom_project` varchar(50) NOT NULL,
  `creationDate_project` date NOT NULL,
  `closedDate_project` date NOT NULL,
  `GANT_project` varchar(50) NOT NULL,
  `status_project` varchar(50) NOT NULL,
  `id_client` int(11) NOT NULL,
  PRIMARY KEY (`id_project`),
  KEY `Project_Client_FK` (`id_client`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `project`
--

INSERT INTO `project` (`id_project`, `nom_project`, `creationDate_project`, `closedDate_project`, `GANT_project`, `status_project`, `id_client`) VALUES
(1, 'de votre vie', '2021-10-21', '2021-10-28', 'qfqfqfq', 'qfqfqfq', 1),
(2, 'Résidence les Capucines', '2021-10-22', '2021-10-31', 'faaafa', 'En cours', 1),
(3, 'Lotissement des Anges', '2021-11-11', '2021-11-30', 'afafaef', 'en préparation', 2);

-- --------------------------------------------------------

--
-- Structure de la table `sous_traitant`
--

DROP TABLE IF EXISTS `sous_traitant`;
CREATE TABLE IF NOT EXISTS `sous_traitant` (
  `id_sous_traitant` int(11) NOT NULL AUTO_INCREMENT,
  `nom_sous_traitant` varchar(50) NOT NULL,
  `siret_sous_traitant` varchar(50) NOT NULL,
  `IBAN_sous_traitant` varchar(50) NOT NULL,
  `adresseComplete_sous_traitant` varchar(250) NOT NULL,
  PRIMARY KEY (`id_sous_traitant`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `sous_traitant`
--

INSERT INTO `sous_traitant` (`id_sous_traitant`, `nom_sous_traitant`, `siret_sous_traitant`, `IBAN_sous_traitant`, `adresseComplete_sous_traitant`) VALUES
(1, 'Xefi', '587595625', 'FR02457859526', '2507 Av. de l\'Europe, 69140 Rillieux-la-Pape'),
(2, 'Azur Elec', '586895857', 'FR8547879654625', '23 avenue du maréchal Juin, 33160 St Aubin de Médoc'),
(3, 'Etbs NovoPlomberie', '77961619539', 'FR8956525458', ' 334 avenue de Rouli, 33300 Bordeaux'),
(4, 'GP Fondation SA', '79794623168', 'FR85458895642', '3 rue du Bourg 33520 BRUGES');

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `capture`
--
ALTER TABLE `capture`
  ADD CONSTRAINT `Capture_Chantier_FK` FOREIGN KEY (`id_chantier`) REFERENCES `chantier` (`id_chantier`);

--
-- Contraintes pour la table `chantier`
--
ALTER TABLE `chantier`
  ADD CONSTRAINT `Chantier_Project_FK` FOREIGN KEY (`id_project`) REFERENCES `project` (`id_project`);

--
-- Contraintes pour la table `chantier_employee_maps`
--
ALTER TABLE `chantier_employee_maps`
  ADD CONSTRAINT `Chantier_Employee_Maps_Chantier_FK` FOREIGN KEY (`id_chantier`) REFERENCES `chantier` (`id_chantier`),
  ADD CONSTRAINT `Chantier_Employee_Maps_Employee0_FK` FOREIGN KEY (`id_employee`) REFERENCES `employee` (`id_employee`);

--
-- Contraintes pour la table `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `Employee_Metier_FK` FOREIGN KEY (`id_metier`) REFERENCES `metier` (`id_metier`),
  ADD CONSTRAINT `Employee_Sous_traitant0_FK` FOREIGN KEY (`id_sous_traitant`) REFERENCES `sous_traitant` (`id_sous_traitant`);

--
-- Contraintes pour la table `project`
--
ALTER TABLE `project`
  ADD CONSTRAINT `Project_Client_FK` FOREIGN KEY (`id_client`) REFERENCES `client` (`id_client`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
