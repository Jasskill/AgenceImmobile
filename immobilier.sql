-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 05, 2024 at 02:22 PM
-- Server version: 8.4.0
-- PHP Version: 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `immo`
--
CREATE DATABASE IF NOT EXISTS `immo` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `immo`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `fusion`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `fusion` (`idDispo1` INT, `idDispo2` INT)   BEGIN

    DECLARE count, idDispoNew INT;
    DECLARE idDispoDate DATETIME;

    DECLARE IdateDebut, IdateFin DATETIME;
    DECLARE IidLogement INT;
    DECLARE Itarif DECIMAL(10,2);

    -- Sauvegarde dans une variable le nombre de disponibilité
    -- qui sont dérivé de la disponibilité idDispo1 (paramètre)
    -- ET dont la dateDebut est postérieur à la dateFin de la reservation de la disponiblité
    SELECT COUNT(*) INTO count 
    FROM disponibilite 
    WHERE derive = idDispo1 AND dateDebut >= (
        SELECT dateFin 
        FROM reservation 
        WHERE idDisponibilite = idDispo1
    );

    -- On vérifie que la dérivé de la disponibilité en paramètre existe
    IF count = 1 THEN

        -- On sauvegarde dans une variable l'id de cette disponibilité dérivé
        SELECT id INTO idDispoNew 
        FROM disponibilite 
        WHERE derive = idDispo1 AND dateDebut >= (
            SELECT dateFin 
            FROM reservation 
            WHERE idDisponibilite = idDispo1
        );

        -- On rappelle la fonction qui va faire la même chose avec la dérivé
        CALL fusion(idDispoNew, idDispo2);

        -- On modifie la dateFin pour mettre celle de la disponibilité idDispo2
        SET idDispoDate = (SELECT dateFin FROM disponibilite WHERE id = idDispo2);
        UPDATE disponibilite SET dateFin = idDispoDate WHERE id = idDispo1;

    -- S'il n'y a pas de dérivé correspondante 
    -- Alors on vérifie le cas où il y a une reservation de cette dérivé mais pas de disponibilité dérivé postérieur
    ELSEIF (SELECT COUNT(*) FROM reservation WHERE idDisponibilite = idDispo1) = 1 THEN

        SET IdateDebut = (SELECT dateDebut FROM reservation WHERE id = (SELECT id FROM reservation WHERE idDisponibilite = idDispo1));
        SET IdateFin = (SELECT dateFin FROM disponibilite WHERE id = idDispo2);
        SET IidLogement = (SELECT idLogement FROM disponibilite WHERE id = idDispo2);
        SET Itarif = (SELECT tarif FROM disponibilite WHERE id = idDispo2);

        -- On insère une disponibilité dans le cas où il n'y en a pas.
        INSERT INTO disponibilite(dateDebut, dateFin, idLogement, tarif, valide, derive) VALUES (IdateDebut, IdateFin, IidLogement, Itarif, 1, idDispo1);

        -- On sauvegarde dans une variable l'id de cette disponibilité dérivé
        SELECT id INTO idDispoNew 
        FROM disponibilite 
        WHERE derive = idDispo1 AND dateDebut = (
            SELECT dateFin 
            FROM reservation 
            WHERE idDisponibilite = idDispo1
        );

        -- On rappelle la fonction qui va faire la même chose avec la dérivé
        CALL fusion(idDispoNew, idDispo2);
    ELSE

        -- On modifie l'idDisponibilite de la reservation lié à la disponibilité idDispo2 pour mettre à la place celle de la nouvelle idDispo1
        UPDATE reservation SET idDisponibilite = idDispo1 WHERE idDisponibilite = idDispo2;
        -- On modifie les derivés de idDispo2 pour qu'elles pointent vers la disponibilité idDispo1
        UPDATE disponibilite SET derive = idDispo1 WHERE derive = idDispo2;

        -- On modifie la dateFin de cette nouvelle disponibilité pour qu'elle reprenne celle de idDispo2
        SET idDispoDate = (SELECT dateFin FROM disponibilite WHERE id = idDispo2);
        UPDATE disponibilite SET dateFin = idDispoDate WHERE id = idDispo1;

        UPDATE disponibilite SET valide = 0 WHERE id = idDispo1;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `get_last`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_last` (`idDispo` INT, OUT `idOut` INT)   BEGIN
    
    DECLARE count, idDispoNew, idOut2 INT;

    SELECT COUNT(*) INTO count 
        FROM disponibilite 
        WHERE derive = idDispo AND dateDebut >= (
            SELECT dateFin 
            FROM reservation 
            WHERE idDisponibilite = idDispo
        );

    -- On vérifie que la dérivé de la disponibilité en paramètre existe
    IF count = 1 THEN

        -- Si elle existe, alors sauvegarde dans une variable l'id de la disponibilité dérivé
        SELECT id INTO idDispoNew 
        FROM disponibilite 
        WHERE derive = idDispo AND dateDebut >= (
            SELECT dateFin 
            FROM reservation 
            WHERE idDisponibilite = idDispo
        );

        CALL get_last(idDispoNew, idOut2);

        SET idOut = idOut2;
        
    ELSE
        SET idOut = idDispo;
    END IF;

END$$

DROP PROCEDURE IF EXISTS `nouvelle_dates_anterieur`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `nouvelle_dates_anterieur` (`idDispo1` INT)   BEGIN

    DECLARE count, idDispoNew, idReserv INT;
    DECLARE idDispoDate DATETIME;

    DECLARE IdateDebut, IdateFin DATETIME;
    DECLARE IidLogement INT;
    DECLARE Itarif DECIMAL(10,2);

    -- Récupère le nombre de disponibilité dont la derive est celle en paramètre 
    -- ET dont la date de fin se passe avant celle de début de la reservation de la disponibilité
    SELECT COUNT(*) INTO count 
    FROM disponibilite 
    WHERE derive = idDispo1 AND dateFin <= (
        SELECT dateDebut 
        FROM reservation 
        WHERE idDisponibilite = idDispo1
    );

    -- On vérifie que la dérivé de la disponibilité en paramètre existe
    IF count = 1 THEN

        -- Si elle existe, alors sauvegarde dans une variable l'id de la disponibilité dérivé
        SELECT id INTO idDispoNew 
        FROM disponibilite 
        WHERE derive = idDispo1 AND dateFin <= (
            SELECT dateDebut 
            FROM reservation 
            WHERE idDisponibilite = idDispo1
        );

        SELECT dateDebut INTO idDispoDate FROM disponibilite WHERE id = idDispo1;

        -- On change la dateDebut pour mettre celle de la disponibilité en paramètre
        UPDATE disponibilite SET dateDebut = idDispoDate WHERE id = idDispoNew;

        -- On rappelle la fonction pour qu'elle face pareille avec la dérivé
        call nouvelle_dates_anterieur(idDispoNew);
    ELSEIF (SELECT COUNT(*) FROM reservation WHERE idDisponibilite = idDispo1) = 1 THEN
        SELECT id INTO idReserv FROM reservation WHERE idDisponibilite = idDispo1;

        SET IdateDebut = (SELECT dateDebut FROM disponibilite WHERE id = idDispo1);
        SET IdateFin = (SELECT dateDebut FROM reservation WHERE id = idReserv);
        SET IidLogement = (SELECT idLogement FROM disponibilite WHERE id = idDispo2);
        SET Itarif = (SELECT tarif FROM disponibilite WHERE id = idDispo2);

        -- On insère une disponibilité dans le cas où il n'y en a pas.
        INSERT INTO disponibilite(dateDebut, dateFin, idLogement, tarif, valide, derive) VALUES (IdateDebut, IdateFin, IidLogement, Itarif, 1, idDispo1);
    END IF;
END$$

DROP PROCEDURE IF EXISTS `nouvelle_dates_posterieur`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `nouvelle_dates_posterieur` (`idDispo1` INT)   BEGIN

    DECLARE count, idDispoNew INT;
    DECLARE idDispoDate DATETIME;

    -- Sauvegarde dans une variable le nombre de disponibilité
    -- qui sont dérivé de la disponibilité idDispo1 (paramètre)
    -- ET dont la dateDebut est postérieur à la dateFin de la reservation de la disponiblité
    SELECT COUNT(*) INTO count 
    FROM disponibilite 
    WHERE derive = idDispo1 AND dateDebut >= (
        SELECT dateFin 
        FROM reservation 
        WHERE idDisponibilite = idDispo1
    );

    -- On vérifie que la dérivé de la disponibilité en paramètre existe
    IF count = 1 THEN

        -- Si elle existe, alors on sauvegarde dans une variable l'id de cette disponibilité dérivé
        SELECT id INTO idDispoNew 
        FROM disponibilite 
        WHERE derive = idDispo1 AND dateDebut >= (
            SELECT dateFin 
            FROM reservation 
            WHERE idDisponibilite = idDispo1
        );

        SELECT dateFin INTO idDispoDate FROM disponibilite WHERE id = idDispo1;

        -- On change la dateFin pour mettre celle de la disponibilité en paramètre
        UPDATE disponibilite SET dateFin = idDispoDate WHERE id = idDispoNew;

        -- On rappelle la fonction pour qu'elle face pareille avec la dérivé
        call nouvelle_dates_posterieur(idDispoNew);
    END IF;
END$$

DROP PROCEDURE IF EXISTS `supprimer_reservation`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `supprimer_reservation` (`idReservation` INT)   BEGIN
    DECLARE countDispoDerive, idDispo, idDispoDerive1, idDispoDerive2, idDispoDerive3, idDispoDerive4, idReserv1, idFus1, idFus2, count INT;
    DECLARE idDispoDate DATE;

    DECLARE IdateDebut, IdateFin DATETIME;
    DECLARE IidLogement INT;
    DECLARE Itarif DECIMAL(10,2);

    -- Augmenter la limite récursive
    SET max_sp_recursion_depth = 100;

    -- Sauvegarde dans (idDispo) l'idDisponibilite de la reservation qu'on veut supprimer
    SELECT idDisponibilite INTO idDispo 
    FROM reservation 
    WHERE id = idReservation;

    -- Sauvegarde dans (countDispoDerive) le nombre de reservations qui ont pour disponibilités des dérivés de (idDispo)
    SELECT COUNT(*) INTO countDispoDerive 
    FROM reservation 
    WHERE idDisponibilite IN (
        SELECT id 
        FROM disponibilite 
        WHERE derive = idDispo
    );
    -- S'il n'y en a qu'une
    IF countDispoDerive = 1 THEN

        -- Sauvegarde dans (idDispoDerive1) la disponibilité qui est une dérivé de (idDispo)
        -- ET qui possède une reservation
        SELECT id INTO idDispoDerive1 -- 2
        FROM disponibilite 
        WHERE derive = idDispo AND id IN (SELECT idDisponibilite FROM reservation)
        LIMIT 1;

        -- Sauvegarde dans (idReserv1) la reservation de idDispoDerive1
        -- ET qui possède une reservation
        SELECT id INTO idReserv1 -- 2
        FROM reservation 
        WHERE idDisponibilite = idDispoDerive1;

        -- Sauvegarde dans une variable le nombre de reservations qui ont pour disponibilités des dérivés de celle de base (idDispo) 
        -- ET dont les dérivés ne possède pas de reservation
        SELECT COUNT(*) INTO count 
        FROM disponibilite 
        WHERE derive = idDispo AND id NOT IN (SELECT idDisponibilite FROM reservation);

        IF count = 1 THEN
            -- Sauvegarde dans une variable la disponibilité qui est une dérivé de idDispo
            -- ET qui NE possède PAS de reservation
            SELECT id INTO idDispoDerive2
            FROM disponibilite 
            WHERE derive = idDispo AND id NOT IN (SELECT idDisponibilite FROM reservation);

            -- Supprime le disponibilité dérivé de idDispo qui ne possède pas de reservation
            DELETE FROM disponibilite WHERE id = idDispoDerive2;    
        END IF;

        -- Si (idDispo) et (idDispoDerive1) ont la même dateDebut
        IF (SELECT dateDebut FROM disponibilite WHERE id = idDispo) = (SELECT dateDebut FROM disponibilite WHERE id = idDispoDerive1) THEN

            -- Sauvegarde dans (count) le nombre de disponibilités (1 ou 0)
            -- qui sont dérivé de (idDispoDerive1)
            -- ET dont la dateDebut est postérieur à la dateFin (idReserv1) (la reservation de idDispoDerive1)
            SELECT COUNT(*) INTO count 
            FROM disponibilite 
            WHERE derive = idDispoDerive1 AND dateDebut >= (
                SELECT dateFin 
                FROM reservation 
                WHERE id = idReserv1
            );

            -- On vérifie qu'elle existe
            IF count = 1 THEN

                -- Sauvegarde dans (idDispoDerive3) de la disponibilité dans dérivé de (idDispoDerive1)
                SELECT id INTO idDispoDerive3 
                FROM disponibilite 
                WHERE derive = idDispoDerive1 AND dateDebut >= (
                    SELECT dateFin 
                    FROM reservation 
                    WHERE id = idReserv1
                );
                -- Sauvegarde dans (idDispoDate) de la dateFin de (idDispo)
                SELECT dateFin INTO idDispoDate FROM disponibilite WHERE id = idDispo;

                -- Modifie la dateFin pour qu'elle corresponde à celle de (idDispo)
                UPDATE disponibilite SET dateFin = idDispoDate WHERE id = idDispoDerive3;

                -- Répète cette opération pour toutes les reservations qui sont dérivé de (idDispoDerive3)
                CALL nouvelle_dates_posterieur(idDispoDerive3);
            ELSE

                SET IdateDebut = (SELECT dateFin FROM reservation WHERE id = idReserv1);
                SET IdateFin = (SELECT dateFin FROM disponibilite WHERE id = idDispo);
                SET IidLogement = (SELECT idLogement FROM disponibilite WHERE id = idDispo);
                SET Itarif = (SELECT tarif FROM disponibilite WHERE id = idDispo);

                -- Si elle n'existe pas, on la crée
                INSERT INTO disponibilite(dateDebut, dateFin, idLogement, tarif, valide, derive) VALUES (IdateDebut, IdateFin, IidLogement, Itarif, 1, idDispo);

            END IF;
        -- Sinon ils ont la même dateFin
        ELSE

            -- Sauvegarde dans (count) le nombre de disponibilités (1 ou 0)
            -- qui sont dérivé de (idDispoDerive1)
            -- ET dont la dateFin est antérieur à la dateDebut (idReserv1) (la reservation de idDispoDerive1)
            SELECT COUNT(*) INTO count 
            FROM disponibilite 
            WHERE derive = idDispoDerive1 AND dateFin <= (
                SELECT dateDebut 
                FROM reservation 
                WHERE id = idReserv1
            );
            
            -- On vérifie qu'elle existe
            IF count = 1 THEN

                -- Sauvegarde dans (idDispoDerive3) de la disponibilité dans dérivé de (idDispoDerive1)
                SELECT id INTO idDispoDerive3 
                FROM disponibilite 
                WHERE derive = idDispoDerive1 AND dateFin <= (
                    SELECT dateDebut 
                    FROM reservation 
                    WHERE id = idReserv1
                );

                -- Sauvegarde dans (idDispoDate) de la dateDebut de (idDispo)
                SELECT dateDebut INTO idDispoDate FROM disponibilite WHERE id = idDispo;

                -- Modifie la dateFin pour qu'elle corresponde à celle de (idDispo)
                UPDATE disponibilite SET dateDebut = idDispoDate WHERE id = idDispoDerive3;

                -- Répète cette opération pour toutes les reservations qui sont dérivé de (idDispoDerive3)
                CALL nouvelle_dates_anterieur(idDispoDerive3);
            ELSE

                SET IdateDebut = (SELECT dateDebut FROM disponibilite WHERE id = idDispo);
                SET IdateFin = (SELECT dateFin FROM reservation WHERE id = idReserv1);
                SET IidLogement = (SELECT idLogement FROM disponibilite WHERE id = idDispo);
                SET Itarif = (SELECT tarif FROM disponibilite WHERE id = idDispo);

                -- Si elle n'existe pas, on la crée
                INSERT INTO disponibilite(dateDebut, dateFin, idLogement, tarif, valide, derive) VALUES (IdateDebut, IdateFin, IidLogement, Itarif, 1, idDispo);

            END IF;
        END IF;

        -- Modification des derivés de (idDispoDerive1) pour qu'elles pointent vers la disponibilité (idDispo)
        UPDATE disponibilite SET derive = idDispo WHERE derive = idDispoDerive1;
        -- Modification de l'idDisponibilite de la reservation lié à la disponibilité (idDispoDerive1) pour mettre à la place celle de la nouvelle (idDispo)
        UPDATE reservation SET idDisponibilite = idDispo WHERE idDisponibilite = idDispoDerive1;
        
        -- Supprime la disponibilité dérivé de idDispo
        DELETE FROM disponibilite WHERE id = idDispoDerive1;
    ELSEIF countDispoDerive = 2 THEN

        -- Sauvegarder dans (idDispoDerive1) la 1er disponibilité dérivé de (idDispo)
        SELECT id INTO idDispoDerive1 
        FROM disponibilite 
        WHERE derive = idDispo 
        LIMIT 1;

        -- Sauvegarder dans (idDispoDerive2) la 2e disponibilité dérivé de (idDispo)
        SELECT id INTO idDispoDerive2 
        FROM disponibilite 
        WHERE derive = idDispo 
        LIMIT 1 OFFSET 1;

        -- Sauvegarder dans (idReserv1) la reservation (idDispoDerive1)
        SELECT id INTO idReserv1 
        FROM reservation 
        WHERE idDisponibilite = idDispoDerive1;

        -- On change la disponibilité de reservation pour lui mettre celle de base
        UPDATE reservation SET idDisponibilite = idDispo WHERE id = idReserv1;

        -- Vérifie s'il y a une dérivée de idDispoDerive1 avec des dates antérieures à idReserv1
        -- si oui, on lui change sa dérivée pour mettre celle de base
        SELECT COUNT(*) INTO count 
        FROM disponibilite 
        WHERE derive = idDispoDerive1 AND dateFin <= (
            SELECT dateDebut 
            FROM reservation 
            WHERE id = idReserv1
        );

        IF count = 1 THEN

            SELECT id INTO idDispoDerive3
            FROM disponibilite 
            WHERE derive = idDispoDerive1 AND dateFin <= (
                SELECT dateDebut 
                FROM reservation 
                WHERE id = idReserv1
            );

            UPDATE disponibilite SET derive = idDispo WHERE id = idDispoDerive3;
        END IF;

        -- Vérifie s'il y a une dérivée de idDispoDerive1 avec des dates postérieures à idReserv1
        -- si oui, on lui change sa dérivée pour mettre celle de base
        SELECT COUNT(*) INTO count 
        FROM disponibilite 
        WHERE derive = idDispoDerive1 AND dateDebut >= (
            SELECT dateFin 
            FROM reservation 
            WHERE id = idReserv1
        );

        IF count = 1 THEN

            SELECT id INTO idDispoDerive3
            FROM disponibilite 
            WHERE derive = idDispoDerive1 AND dateDebut >= (
                SELECT dateFin 
                FROM reservation 
                WHERE id = idReserv1
            );

            UPDATE disponibilite SET derive = idDispo WHERE id = idDispoDerive3;
            CALL get_last(idDispoDerive3, idDispoDerive4);
            CALL fusion(idDispoDerive3, idDispoDerive2);
            CALL nouvelle_dates_anterieur(idDispoDerive4);
        ELSE

            SET IdateDebut = (SELECT dateFin FROM reservation WHERE id = idReserv1);
            SET IdateFin = (SELECT dateFin FROM disponibilite WHERE id = idDispo);
            SET IidLogement = (SELECT idLogement FROM disponibilite WHERE id = idDispo);
            SET Itarif = (SELECT tarif FROM disponibilite WHERE id = idDispo);

            INSERT INTO disponibilite(dateDebut, dateFin, idLogement, tarif, valide, derive) VALUES (IdateDebut, IdateFin, IidLogement, Itarif, 1, idDispo);

            SELECT id INTO idDispoDerive3
            FROM disponibilite 
            WHERE derive = idDispo AND dateDebut = IdateDebut AND dateFin = IdateFin;

            CALL get_last(idDispoDerive3, idDispoDerive4);

            CALL fusion(idDispoDerive3, idDispoDerive2);

            CALL nouvelle_dates_anterieur(idDispoDerive4);
        END IF;



        DELETE FROM disponibilite WHERE id = idDispoDerive1 OR id = idDispoDerive2;
    ELSE
        DELETE FROM disponibilite WHERE derive = idDispo;
        UPDATE disponibilite SET valide = 1 WHERE id = idDispo;
    END IF;

    DELETE FROM reservation WHERE id = idReservation;

    -- Réinitialiser la limite récursive à sa valeur par défaut
    SET max_sp_recursion_depth = DEFAULT;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `disponibilite`
--

DROP TABLE IF EXISTS `disponibilite`;
CREATE TABLE IF NOT EXISTS `disponibilite` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dateDebut` date NOT NULL,
  `dateFin` date NOT NULL,
  `idLogement` int NOT NULL,
  `tarif` decimal(10,0) NOT NULL,
  `valide` tinyint(1) NOT NULL,
  `derive` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idLogement` (`idLogement`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `disponibilite`
--

INSERT INTO `disponibilite` (`id`, `dateDebut`, `dateFin`, `idLogement`, `tarif`, `valide`, `derive`) VALUES
(1, '2024-01-01', '2024-01-30', 1, '30', 1, NULL),
(2, '2024-04-20', '2024-05-31', 2, '30', 1, NULL),
(3, '2024-07-30', '2024-08-31', 3, '30', 1, NULL),
(4, '2024-01-01', '2024-01-30', 4, '30', 0, NULL),
(5, '2024-01-08', '2024-01-27', 5, '30', 0, NULL),
(6, '2024-01-05', '2024-02-04', 6, '30', 0, NULL),
(7, '2024-01-17', '2024-02-12', 9, '30', 0, NULL),
(8, '2024-01-08', '2024-01-16', 5, '30', 1, 5),
(9, '2024-01-19', '2024-02-04', 6, '30', 1, 6),
(10, '2024-01-17', '2024-01-25', 9, '30', 1, 7),
(11, '2024-02-01', '2024-02-12', 9, '30', 1, 7),
(12, '2024-04-15', '2024-05-31', 4, '30', 0, NULL),
(13, '2024-04-20', '2024-05-11', 5, '30', 0, NULL),
(14, '2024-04-12', '2024-05-06', 10, '30', 0, NULL),
(15, '2024-05-02', '2024-05-30', 7, '30', 0, NULL),
(16, '2024-04-20', '2024-04-30', 5, '30', 1, 13),
(17, '2024-04-28', '2024-05-06', 10, '30', 1, 14),
(18, '2024-05-02', '2024-05-10', 7, '30', 1, 15),
(19, '2024-05-18', '2024-05-30', 7, '30', 1, 15),
(20, '2024-05-08', '2024-06-10', 4, '30', 0, NULL),
(21, '2024-07-10', '2024-07-30', 5, '30', 0, NULL),
(22, '2024-08-05', '2024-08-24', 6, '30', 0, NULL),
(23, '2024-09-01', '2024-10-31', 8, '30', 0, NULL),
(24, '2024-07-10', '2024-07-20', 5, '30', 1, 21),
(25, '2024-08-20', '2024-08-24', 6, '30', 1, 22),
(26, '2024-09-01', '2024-09-10', 8, '30', 1, 23),
(27, '2024-10-01', '2024-10-31', 8, '30', 1, 23);

-- --------------------------------------------------------

--
-- Table structure for table `equipement`
--

DROP TABLE IF EXISTS `equipement`;
CREATE TABLE IF NOT EXISTS `equipement` (
  `id` int NOT NULL AUTO_INCREMENT,
  `libelle` varchar(100) NOT NULL,
  `idPiece` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Equipement_Piece_FK` (`idPiece`)
) ENGINE=InnoDB AUTO_INCREMENT=2113 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `equipement`
--

INSERT INTO `equipement` (`id`, `libelle`, `idPiece`) VALUES
(1, 'Canapé', 1),
(2, 'Télévision', 1),
(3, 'Table basse', 1),
(4, 'Fauteuil', 1),
(5, 'Fauteuil', 2),
(6, 'Lit double', 2),
(7, 'Table de nuit', 2),
(8, 'Lampe de chevet', 2),
(9, 'Chaise', 3),
(10, 'Lit simple', 3),
(11, 'Armoire', 3),
(12, 'Table de nuit', 3),
(13, 'Lampe de chevet', 3),
(14, 'Lit enfant', 4),
(15, 'Bibliothèque enfant', 4),
(16, 'Veilleuse', 4),
(17, 'Berceau', 4),
(18, 'Table de jeu', 4),
(19, 'Frigo', 5),
(20, 'Four', 5),
(21, 'Plaque de cuisson', 5),
(22, 'Micro-ondes', 5),
(23, 'Hotte aspirante', 5),
(24, 'Lave-vaisselle', 5),
(25, 'Miroir', 6),
(26, 'Douche', 6),
(27, 'Lavabo', 6),
(28, 'Armoire de toilette', 6),
(29, 'Porte-serviettes', 6),
(30, 'Tapis de bain', 6),
(31, 'Support de papier', 7),
(32, 'Etagère murale', 7),
(33, 'Tapis WC', 7),
(34, 'Poubelle', 7),
(35, 'Brosse WC', 7),
(36, 'Table', 8),
(37, 'Chaises', 8),
(38, 'Service de table', 8),
(39, 'Verres', 8),
(40, 'Couverts', 8),
(41, 'Assiettes', 8),
(42, 'Buffet', 8),
(43, 'Canapé', 9),
(44, 'Fauteuil', 9),
(45, 'Table basse', 9),
(46, 'Télévision', 9),
(47, 'Tableau', 9),
(48, 'Lit double', 10),
(49, 'Table de nuit', 10),
(50, 'Lampe de chevet', 10),
(51, 'Lit enfant', 11),
(52, 'Berceau', 11),
(53, 'Veilleuse', 11),
(54, 'Stickers muraux', 11),
(55, 'Coffre à jouets', 11),
(56, 'Chaises de jardin', 12),
(57, 'Table de jardin', 12),
(58, 'Parasol', 12),
(59, 'Plantes en pots', 12),
(60, 'Coussins de chaise', 12),
(61, 'Frigo', 13),
(62, 'Four', 13),
(63, 'Plaque de cuisson', 13),
(64, 'Micro-ondes', 13),
(65, 'Hotte aspirante', 13),
(66, 'Lave-vaisselle', 13),
(67, 'Machine à café', 13),
(68, 'Miroir', 14),
(69, 'Douche', 14),
(70, 'Lavabo', 14),
(71, 'Armoire de toilette', 14),
(72, 'Etagère de rangement', 14),
(73, 'Tapis de bain', 14),
(74, 'Brosse WC', 15),
(75, 'Chaise longue', 16),
(76, 'Pot de fleurs', 16),
(77, 'Canapé', 17),
(78, 'Fauteuil', 17),
(79, 'Table basse', 17),
(80, 'Bibliothèque', 17),
(81, 'Lit double', 18),
(82, 'Table de nuit', 18),
(83, 'Lampe de chevet', 18),
(84, 'Plaid', 18),
(85, 'Lit simple', 19),
(86, 'Armoire', 19),
(87, 'Table de nuit', 19),
(88, 'Lampe de chevet', 19),
(89, 'Tapis', 19),
(90, 'Plaid', 19),
(91, 'Frigo', 20),
(92, 'Four', 20),
(93, 'Plaque de cuisson', 20),
(94, 'Micro-ondes', 20),
(95, 'Hotte aspirante', 20),
(96, 'Grille-pain', 20),
(97, 'Mixeur', 20),
(98, 'Miroir', 21),
(99, 'Douche', 21),
(100, 'Lavabo', 21),
(101, 'Armoire de toilette', 21),
(102, 'Etagère de rangement', 21),
(103, 'Tapis de bain', 21),
(104, 'Poubelle', 21),
(105, 'Miroir', 22),
(106, 'Lave-mains', 22),
(107, 'Support de papier', 22),
(108, 'Etagère murale', 22),
(109, 'Tapis WC', 22),
(110, 'Brosse WC', 22),
(111, 'Chaises de jardin', 23),
(112, 'Table de jardin', 23),
(113, 'Parasol', 23),
(114, 'Barbecue', 23),
(115, 'Canapé', 24),
(116, 'Fauteuil', 24),
(117, 'Table basse', 24),
(118, 'Télévision', 24),
(119, 'Lit double', 25),
(120, 'Table de nuit', 25),
(121, 'Lampe de chevet', 25),
(122, 'Miroir', 25),
(123, 'Frigo', 26),
(124, 'Four', 26),
(125, 'Plaque de cuisson', 26),
(126, 'Micro-ondes', 26),
(127, 'Hotte aspirante', 26),
(128, 'Mixeur', 26),
(129, 'Grille-pain', 26),
(130, 'Miroir', 27),
(131, 'Douche', 27),
(132, 'Lavabo', 27),
(133, 'Armoire de toilette', 27),
(134, 'Tapis de bain', 27),
(135, 'Miroir', 28),
(136, 'Lave-mains', 28),
(137, 'Support de papier', 28),
(138, 'Tapis WC', 28),
(139, 'Poubelle', 28),
(140, 'Brosse WC', 28),
(141, 'Baby-foot', 29),
(142, 'Jeux de société', 29),
(143, 'Haut-parleurs', 29),
(144, 'Canapé', 30),
(145, 'Fauteuil', 30),
(146, 'Table basse', 30),
(147, 'Télévision', 30),
(148, 'Lit double', 31),
(149, 'Table de nuit', 31),
(150, 'Lampe de chevet', 31),
(151, 'Tableau', 31),
(152, 'Lit simple', 32),
(153, 'Armoire', 32),
(154, 'Table de nuit', 32),
(155, 'Lampe de chevet', 32),
(156, 'Bureau', 32),
(157, 'Ventilateur', 32),
(158, 'Frigo', 33),
(159, 'Four', 33),
(160, 'Plaque de cuisson', 33),
(161, 'Micro-ondes', 33),
(162, 'Hotte aspirante', 33),
(163, 'Lave-vaisselle', 33),
(164, 'Mixeur', 33),
(165, 'Miroir', 34),
(166, 'Douche', 34),
(167, 'Lavabo', 34),
(168, 'Armoire de toilette', 34),
(169, 'Porte-serviettes', 34),
(170, 'Miroir', 35),
(171, 'Lave-mains', 35),
(172, 'Support de papier', 35),
(173, 'Poubelle', 35),
(174, 'Brosse WC', 35),
(175, 'Outils de bricolage', 36),
(176, 'Etabli', 36),
(177, 'Etagère de rangement', 36),
(178, 'Boîte à outils', 36),
(179, 'Console de jeu', 37),
(180, 'Billard', 37),
(181, 'Canapé', 37),
(182, 'Canapé', 38),
(183, 'Fauteuil', 38),
(184, 'Table basse', 38),
(185, 'Télévision', 38),
(186, 'Coussins', 38),
(187, 'Lit double', 39),
(188, 'Table de nuit', 39),
(189, 'Lampe de chevet', 39),
(190, 'Lit simple', 40),
(191, 'Armoire', 40),
(192, 'Table de nuit', 40),
(193, 'Lampe de chevet', 40),
(194, 'Frigo', 41),
(195, 'Four', 41),
(196, 'Plaque de cuisson', 41),
(197, 'Micro-ondes', 41),
(198, 'Hotte aspirante', 41),
(199, 'Machine à café', 41),
(200, 'Lave-vaisselle', 41),
(201, 'Miroir', 42),
(202, 'Douche', 42),
(203, 'Lavabo', 42),
(204, 'Armoire de toilette', 42),
(205, 'Porte-serviettes', 42),
(206, 'Miroir', 43),
(207, 'Lave-mains', 43),
(208, 'Support de papier', 43),
(209, 'Poubelle', 43),
(210, 'Brosse WC', 43),
(211, 'Pot de fleurs', 44),
(212, 'Coussins de jardin', 44),
(213, 'Table', 45),
(214, 'Chaises', 45),
(215, 'Service de table', 45),
(216, 'Verres', 45),
(217, 'Couverts', 45),
(218, 'Assiettes', 45),
(219, 'Lustre', 45),
(220, 'Table de ping-pong', 46),
(221, 'Télévision', 46),
(222, 'Console de jeux vidéo', 46),
(223, 'Fauteuil', 46),
(224, 'Canapé', 47),
(225, 'Fauteuil', 47),
(226, 'Table basse', 47),
(227, 'Télévision', 47),
(228, 'Lit double', 48),
(229, 'Table de nuit', 48),
(230, 'Lampe de chevet', 48),
(231, 'Tapis', 48),
(232, 'Lit simple', 49),
(233, 'Armoire', 49),
(234, 'Table de nuit', 49),
(235, 'Lampe de chevet', 49),
(236, 'Miroir', 49),
(237, 'Tableau', 49),
(238, 'Frigo', 50),
(239, 'Four', 50),
(240, 'Plaque de cuisson', 50),
(241, 'Micro-ondes', 50),
(242, 'Hotte aspirante', 50),
(243, 'Bouilloire électrique', 50),
(244, 'Miroir', 51),
(245, 'Douche', 51),
(246, 'Lavabo', 51),
(247, 'Armoire de toilette', 51),
(248, 'Tapis de bain', 51),
(249, 'Support de papier', 52),
(250, 'Brosse WC', 52),
(251, 'Chaises de jardin', 53),
(252, 'Table de jardin', 53),
(253, 'Parasol', 53),
(254, 'Barbecue', 53),
(255, 'Lumière extérieure', 53),
(256, 'Coussins de chaise', 53),
(257, 'Fontaine décorative', 53),
(258, 'Parasol', 54),
(259, 'Plante verte', 54),
(260, 'Table', 55),
(261, 'Chaises', 55),
(262, 'Service de table', 55),
(263, 'Verres', 55),
(264, 'Couverts', 55),
(265, 'Assiettes', 55),
(266, 'Nappe', 55),
(267, 'Canapé', 56),
(268, 'Fauteuil', 56),
(269, 'Table basse', 56),
(270, 'Télévision', 56),
(271, 'Bibliothèque', 56),
(272, 'Lit double', 57),
(273, 'Table de nuit', 57),
(274, 'Lampe de chevet', 57),
(275, 'Coussins', 57),
(276, 'Lit simple', 58),
(277, 'Armoire', 58),
(278, 'Table de nuit', 58),
(279, 'Lampe de chevet', 58),
(280, 'Chaise', 58),
(281, 'Miroir', 58),
(282, 'Frigo', 59),
(283, 'Four', 59),
(284, 'Plaque de cuisson', 59),
(285, 'Micro-ondes', 59),
(286, 'Hotte aspirante', 59),
(287, 'Lave-vaisselle', 59),
(288, 'Machine à café', 59),
(289, 'Miroir', 60),
(290, 'Douche', 60),
(291, 'Lavabo', 60),
(292, 'Armoire de toilette', 60),
(293, 'Porte-serviettes', 60),
(294, 'Poubelle', 60),
(295, 'Miroir', 61),
(296, 'Lave-mains', 61),
(297, 'Support de papier', 61),
(298, 'Etagère murale', 61),
(299, 'Tapis WC', 61),
(300, 'Poubelle', 61),
(301, 'Brosse WC', 61),
(302, 'Chaises de jardin', 62),
(303, 'Table de jardin', 62),
(304, 'Parasol', 62),
(305, 'Plantes en pots', 62),
(306, 'Coussins de chaise', 62),
(307, 'Table de balcon', 63),
(308, 'Pot de fleurs', 63),
(309, 'Table', 64),
(310, 'Chaises', 64),
(311, 'Service de table', 64),
(312, 'Verres', 64),
(313, 'Couverts', 64),
(314, 'Assiettes', 64),
(315, 'Buffet', 64),
(316, 'Canapé', 65),
(317, 'Fauteuil', 65),
(318, 'Table basse', 65),
(319, 'Tapis', 65),
(320, 'Lampe de salon', 65),
(321, 'Plaid', 65),
(322, 'Lit double', 66),
(323, 'Table de nuit', 66),
(324, 'Lampe de chevet', 66),
(325, 'Lit simple', 67),
(326, 'Armoire', 67),
(327, 'Table de nuit', 67),
(328, 'Lampe de chevet', 67),
(329, 'Ventilateur', 67),
(330, 'Micro-ondes', 68),
(331, 'Plaque de cuisson', 68),
(332, 'Frigo', 68),
(333, 'Four', 68),
(334, 'Bouilloire électrique', 68),
(335, 'Hotte aspirante', 68),
(336, 'Lavabo', 69),
(337, 'Porte-serviettes', 69),
(338, 'Douche', 69),
(339, 'Armoire de toilette', 69),
(340, 'Miroir', 69),
(341, 'Brosse WC', 70),
(342, 'Tapis WC', 70),
(343, 'Support de papier', 70),
(344, 'Miroir', 70),
(345, 'Lave-mains', 70),
(346, 'Poubelle', 70),
(347, 'Table', 71),
(348, 'Assiettes', 71),
(349, 'Chaises', 71),
(350, 'Service de table', 71),
(351, 'Nappe', 71),
(352, 'Verres', 71),
(353, 'Couverts', 71),
(354, 'Outils de bricolage', 72),
(355, 'Etagère de rangement', 72),
(356, 'Aspirateur', 72),
(357, 'Canapé', 73),
(358, 'Fauteuil', 73),
(359, 'Table basse', 73),
(360, 'Télévision', 73),
(361, 'Lit double', 74),
(362, 'Table de nuit', 74),
(363, 'Lampe de chevet', 74),
(364, 'Lit simple', 75),
(365, 'Armoire', 75),
(366, 'Table de nuit', 75),
(367, 'Lampe de chevet', 75),
(368, 'Plaid', 75),
(369, 'Frigo', 76),
(370, 'Four', 76),
(371, 'Plaque de cuisson', 76),
(372, 'Micro-ondes', 76),
(373, 'Hotte aspirante', 76),
(374, 'Grille-pain', 76),
(375, 'Bouilloire électrique', 76),
(376, 'Miroir', 77),
(377, 'Douche', 77),
(378, 'Lavabo', 77),
(379, 'Armoire de toilette', 77),
(380, 'Tapis de bain', 77),
(381, 'Poubelle', 77),
(382, 'Baignoire', 77),
(383, 'Support de papier', 78),
(384, 'Poubelle', 78),
(385, 'Brosse WC', 78),
(386, 'Table', 79),
(387, 'Chaises', 79),
(388, 'Service de table', 79),
(389, 'Verres', 79),
(390, 'Couverts', 79),
(391, 'Assiettes', 79),
(392, 'Lustre', 79);

-- --------------------------------------------------------

--
-- Table structure for table `etatequipement`
--

DROP TABLE IF EXISTS `etatequipement`;
CREATE TABLE IF NOT EXISTS `etatequipement` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idEtatLieux` int DEFAULT NULL,
  `idEquipement` int NOT NULL,
  `note` int DEFAULT NULL,
  `commentaire` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idEtatLieux` (`idEtatLieux`),
  KEY `idEquipement` (`idEquipement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `etatlieux`
--

DROP TABLE IF EXISTS `etatlieux`;
CREATE TABLE IF NOT EXISTS `etatlieux` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idReservation` int DEFAULT NULL,
  `idPiece` int DEFAULT NULL,
  `dateEtatLieux` date DEFAULT NULL,
  `note` int DEFAULT NULL,
  `commentaire` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DF` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idReservation` (`idReservation`),
  KEY `idPiece` (`idPiece`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `etatlieux`
--

INSERT INTO `etatlieux` (`id`, `idReservation`, `idPiece`, `dateEtatLieux`, `note`, `commentaire`, `DF`) VALUES
(1, 1, 24, '2024-01-01', 5, 'RAS', 'D'),
(2, 1, 25, '2024-01-01', 5, 'RAS', 'D'),
(3, 1, 26, '2024-01-01', 5, 'RAS', 'D'),
(4, 1, 27, '2024-01-01', 5, 'RAS', 'D'),
(5, 1, 28, '2024-01-01', 5, 'RAS', 'D'),
(6, 1, 29, '2024-01-01', 5, 'RAS', 'D'),
(7, 3, 38, '2024-01-05', 4, 'Petit trou dans le plancher', 'D'),
(8, 3, 39, '2024-01-05', 5, 'RAS', 'D'),
(9, 3, 40, '2024-01-05', 5, 'RAS', 'D'),
(10, 3, 41, '2024-01-05', 5, 'RAS', 'D'),
(11, 3, 42, '2024-01-05', 5, 'RAS', 'D'),
(12, 3, 43, '2024-01-05', 5, 'RAS', 'D'),
(13, 3, 44, '2024-01-05', 5, 'RAS', 'D'),
(14, 3, 45, '2024-01-05', 5, 'RAS', 'D'),
(15, 3, 46, '2024-01-05', 5, 'RAS', 'D'),
(16, 2, 30, '2024-01-16', 5, 'RAS', 'D'),
(17, 2, 31, '2024-01-16', 5, 'RAS', 'D'),
(18, 2, 32, '2024-01-16', 5, 'RAS', 'D'),
(19, 2, 33, '2024-01-16', 5, 'RAS', 'D'),
(20, 2, 34, '2024-01-16', 5, 'RAS', 'D'),
(21, 2, 35, '2024-01-16', 5, 'RAS', 'D'),
(22, 2, 36, '2024-01-16', 5, 'RAS', 'D'),
(23, 2, 37, '2024-01-16', 5, 'RAS', 'D'),
(24, 3, 38, '2024-01-19', 4, 'Petit trou dans le plancher', 'F'),
(25, 3, 39, '2024-01-19', 5, 'RAS', 'F'),
(26, 3, 40, '2024-01-19', 5, 'RAS', 'F'),
(27, 3, 41, '2024-01-19', 5, 'RAS', 'F'),
(28, 3, 42, '2024-01-19', 5, 'RAS', 'F'),
(29, 3, 43, '2024-01-19', 5, 'RAS', 'F'),
(30, 3, 44, '2024-01-19', 5, 'RAS', 'F'),
(31, 3, 45, '2024-01-19', 5, 'RAS', 'F'),
(32, 3, 46, '2024-01-19', 5, 'RAS', 'F'),
(33, 4, 65, '2024-01-25', 5, 'RAS', 'D'),
(34, 4, 66, '2024-01-25', 5, 'RAS', 'D'),
(35, 4, 67, '2024-01-25', 5, 'RAS', 'D'),
(36, 4, 68, '2024-01-25', 5, 'RAS', 'D'),
(37, 4, 69, '2024-01-25', 5, 'RAS', 'D'),
(38, 4, 70, '2024-01-25', 5, 'RAS', 'D'),
(39, 4, 71, '2024-01-25', 5, 'RAS', 'D'),
(40, 4, 72, '2024-01-25', 5, 'RAS', 'D'),
(41, 2, 30, '2024-01-27', 5, 'RAS', 'F'),
(42, 2, 31, '2024-01-27', 5, 'RAS', 'F'),
(43, 2, 32, '2024-01-27', 5, 'RAS', 'F'),
(44, 2, 33, '2024-01-27', 5, 'RAS', 'F'),
(45, 2, 34, '2024-01-27', 5, 'RAS', 'F'),
(46, 2, 35, '2024-01-27', 5, 'RAS', 'F'),
(47, 2, 36, '2024-01-27', 5, 'RAS', 'F'),
(48, 2, 37, '2024-01-27', 5, 'RAS', 'F'),
(49, 1, 24, '2024-01-30', 5, 'RAS', 'F'),
(50, 1, 25, '2024-01-30', 5, 'RAS', 'F'),
(51, 1, 26, '2024-01-30', 5, 'RAS', 'F'),
(52, 1, 27, '2024-01-30', 5, 'RAS', 'F'),
(53, 1, 28, '2024-01-30', 5, 'RAS', 'F'),
(54, 1, 29, '2024-01-30', 5, 'RAS', 'F'),
(55, 4, 65, '2024-02-01', 5, 'RAS', 'F'),
(56, 4, 66, '2024-02-01', 5, 'RAS', 'F'),
(57, 4, 67, '2024-02-01', 5, 'RAS', 'F'),
(58, 4, 68, '2024-02-01', 5, 'RAS', 'F'),
(59, 4, 69, '2024-02-01', 5, 'RAS', 'F'),
(60, 4, 70, '2024-02-01', 5, 'RAS', 'F'),
(61, 4, 71, '2024-02-01', 5, 'RAS', 'F'),
(62, 4, 72, '2024-02-01', 5, 'RAS', 'F'),
(63, 7, 73, '2024-04-13', 5, 'RAS', 'D'),
(64, 7, 74, '2024-04-13', 5, 'RAS', 'D'),
(65, 7, 75, '2024-04-13', 5, 'RAS', 'D'),
(66, 7, 76, '2024-04-13', 5, 'RAS', 'D'),
(67, 7, 77, '2024-04-13', 5, 'RAS', 'D'),
(68, 7, 78, '2024-04-13', 5, 'RAS', 'D'),
(69, 7, 79, '2024-04-13', 5, 'RAS', 'D'),
(70, 5, 24, '2024-04-16', 5, 'RAS', 'D'),
(71, 5, 25, '2024-04-16', 5, 'RAS', 'D'),
(72, 5, 26, '2024-04-16', 4, 'Tâche sur le papier peint', 'D'),
(73, 5, 27, '2024-04-16', 5, 'RAS', 'D'),
(74, 5, 28, '2024-04-16', 5, 'RAS', 'D'),
(75, 5, 29, '2024-04-16', 5, 'RAS', 'D'),
(76, 6, 30, '2024-04-30', 5, 'RAS', 'D'),
(77, 6, 31, '2024-04-30', 5, 'RAS', 'D'),
(78, 6, 32, '2024-04-30', 5, 'RAS', 'D'),
(79, 6, 33, '2024-04-30', 5, 'RAS', 'D'),
(80, 6, 34, '2024-04-30', 5, 'RAS', 'D'),
(81, 6, 35, '2024-04-30', 5, 'RAS', 'D'),
(82, 6, 36, '2024-04-30', 5, 'RAS', 'D'),
(83, 6, 37, '2024-04-30', 5, 'RAS', 'D');

-- --------------------------------------------------------

--
-- Table structure for table `logement`
--

DROP TABLE IF EXISTS `logement`;
CREATE TABLE IF NOT EXISTS `logement` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rue` varchar(200) NOT NULL,
  `codePostal` varchar(10) NOT NULL,
  `ville` varchar(150) NOT NULL,
  `description` varchar(255) NOT NULL,
  `idProprietaire` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Logement_Utilisateur_FK` (`idProprietaire`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `logement`
--

INSERT INTO `logement` (`id`, `rue`, `codePostal`, `ville`, `description`, `idProprietaire`) VALUES
(1, 'Rue de la République', '13001', 'Marseille', 'Appartement en plein centre historique', 4),
(2, 'Place du Capitole', '31000', 'Toulouse', 'Loft avec vue sur la Garonne', 5),
(3, 'Rue du Vieux Port', '13002', 'Marseille', 'Appartement avec balcon sur le port', 6),
(4, 'Rue des Lombards', '75004', 'Paris', 'Appartement moderne dans le Marais', 4),
(5, 'Rue Sainte-Catherine', '33000', 'Bordeaux', 'Maison de ville avec jardin', 6),
(6, 'Place Bellecour', '69002', 'Lyon', 'Appartement avec vue sur la place', 4),
(7, 'Quai de la Fosse', '44000', 'Nantes', 'Appartement avec vue sur la Loire', 5),
(8, 'Place des Terreaux', '69001', 'Lyon', 'Loft rénové dans le Vieux Lyon', 6),
(9, 'Rue de Siam', '29200', 'Brest', 'Maison avec vue sur la mer', 6),
(10, 'Rue Nationale', '37000', 'Tours', 'Appartement en centre-ville', 6);

-- --------------------------------------------------------

--
-- Table structure for table `photo`
--

DROP TABLE IF EXISTS `photo`;
CREATE TABLE IF NOT EXISTS `photo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `lien` varchar(300) NOT NULL,
  `idLogement` int DEFAULT NULL,
  `idPiece` int DEFAULT NULL,
  `idEquipement` int DEFAULT NULL,
  `idEtatLieux` int DEFAULT NULL,
  `idEtatEquipement` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idLogement` (`idLogement`),
  KEY `idPiece` (`idPiece`),
  KEY `idEquipement` (`idEquipement`),
  KEY `idEtatLieux` (`idEtatLieux`),
  KEY `idEtatEquipement` (`idEtatEquipement`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `piece`
--

DROP TABLE IF EXISTS `piece`;
CREATE TABLE IF NOT EXISTS `piece` (
  `id` int NOT NULL AUTO_INCREMENT,
  `surface` int NOT NULL,
  `type` varchar(255) NOT NULL,
  `idLogement` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Piece_Logement_FK` (`idLogement`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `piece`
--

INSERT INTO `piece` (`id`, `surface`, `type`, `idLogement`) VALUES
(1, 50, 'Salon', 1),
(2, 20, 'Chambre principale', 1),
(3, 15, 'Chambre d amis', 1),
(4, 15, 'Chambre d enfant', 1),
(5, 10, 'Cuisine', 1),
(6, 7, 'Salle de bain', 1),
(7, 3, 'Toilettes', 1),
(8, 30, 'Salle à manger', 1),
(9, 40, 'Salon', 2),
(10, 25, 'Chambre principale', 2),
(11, 20, 'Chambre d enfant', 2),
(12, 15, 'Terasse', 2),
(13, 12, 'Cuisine', 2),
(14, 8, 'Salle de bain', 2),
(15, 5, 'Toilettes', 2),
(16, 10, 'Balcon', 2),
(17, 45, 'Salon', 3),
(18, 30, 'Chambre principale', 3),
(19, 25, 'Chambre d amis', 3),
(20, 15, 'Cuisine', 3),
(21, 10, 'Salle de bain', 3),
(22, 5, 'Toilettes', 3),
(23, 40, 'Terrasse', 3),
(24, 50, 'Salon', 4),
(25, 35, 'Chambre principale', 4),
(26, 20, 'Cuisine', 4),
(27, 15, 'Salle de bain', 4),
(28, 10, 'Toilettes', 4),
(29, 20, 'Salle de jeux', 4),
(30, 60, 'Salon', 5),
(31, 40, 'Chambre principale', 5),
(32, 30, 'Chambre d amis', 5),
(33, 20, 'Cuisine', 5),
(34, 15, 'Salle de bain', 5),
(35, 10, 'Toilettes', 5),
(36, 40, 'Garage', 5),
(37, 20, 'Salle de jeux', 5),
(38, 55, 'Salon', 6),
(39, 35, 'Chambre principale', 6),
(40, 25, 'Chambre d amis', 6),
(41, 20, 'Cuisine', 6),
(42, 15, 'Salle de bain', 6),
(43, 10, 'Toilettes', 6),
(44, 10, 'Balcon', 6),
(45, 30, 'Salle à manger', 6),
(46, 20, 'Salle de jeux', 6),
(47, 60, 'Salon', 7),
(48, 40, 'Chambre principale', 7),
(49, 30, 'Chambre d amis', 7),
(50, 20, 'Cuisine', 7),
(51, 15, 'Salle de bain', 7),
(52, 10, 'Toilettes', 7),
(53, 40, 'Terrasse', 7),
(54, 10, 'Balcon', 7),
(55, 30, 'Salle à manger', 7),
(56, 65, 'Salon', 8),
(57, 45, 'Chambre principale', 8),
(58, 35, 'Chambre d amis', 8),
(59, 25, 'Cuisine', 8),
(60, 20, 'Salle de bain', 8),
(61, 15, 'Toilettes', 8),
(62, 40, 'Terrasse', 8),
(63, 10, 'Balcon', 8),
(64, 30, 'Salle à manger', 8),
(65, 70, 'Salon', 9),
(66, 50, 'Chambre principale', 9),
(67, 40, 'Chambre d amis', 9),
(68, 30, 'Cuisine', 9),
(69, 25, 'Salle de bain', 9),
(70, 15, 'Toilettes', 9),
(71, 35, 'Salle à manger', 9),
(72, 40, 'Garage', 9),
(73, 75, 'Salon', 10),
(74, 55, 'Chambre principale', 10),
(75, 45, 'Chambre d amis', 10),
(76, 35, 'Cuisine', 10),
(77, 30, 'Salle de bain', 10),
(78, 20, 'Toilettes', 10),
(79, 40, 'Salle à manger', 10);

-- --------------------------------------------------------

--
-- Table structure for table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
CREATE TABLE IF NOT EXISTS `reservation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dateDebut` date NOT NULL,
  `dateFin` date NOT NULL,
  `idDisponibilite` int NOT NULL,
  `idClient` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idLogement` (`idDisponibilite`),
  KEY `idClient` (`idClient`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `reservation`
--

INSERT INTO `reservation` (`id`, `dateDebut`, `dateFin`, `idDisponibilite`, `idClient`) VALUES
(1, '2024-01-01', '2024-01-30', 4, 1),
(2, '2024-01-16', '2024-01-27', 5, 2),
(3, '2024-01-05', '2024-01-19', 6, 3),
(4, '2024-01-25', '2024-02-01', 7, 7),
(5, '2024-04-15', '2024-05-31', 12, 1),
(6, '2024-04-30', '2024-05-11', 13, 2),
(7, '2024-04-12', '2024-04-28', 14, 3),
(8, '2024-05-10', '2024-05-18', 15, 7),
(9, '2024-05-08', '2024-06-10', 20, 1),
(10, '2024-07-20', '2024-07-30', 21, 2),
(11, '2024-08-05', '2024-08-20', 22, 3),
(12, '2024-09-10', '2024-10-01', 23, 7);

-- --------------------------------------------------------

--
-- Table structure for table `utilisateur`
--

DROP TABLE IF EXISTS `utilisateur`;
CREATE TABLE IF NOT EXISTS `utilisateur` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mdp` varchar(300) NOT NULL,
  `nom` varchar(150) NOT NULL,
  `prenom` varchar(150) NOT NULL,
  `mail` varchar(150) NOT NULL,
  `proprietaire` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `utilisateur`
--

INSERT INTO `utilisateur` (`id`, `mdp`, `nom`, `prenom`, `mail`, `proprietaire`) VALUES
(1, '$2y$10$BXy2vTIoNR5dK8kTCJTofufdmsBnaFRanvsI9VdjE5jx8.NwWYBea', 'Doe', 'John', 'john.doe@example.com', 0),
(2, '$2y$10$2qq1GbOALZHb0uZ/vZD3gOW2p5nS5VH/ey9.LTe84VfgwTF9ycmwe', 'Smith', 'Alice', 'alice.smith@example.com', 0),
(3, '$2y$10$nqbw9nmjQ49OW3V3BS6xqOpxei.9NXXbfUgofQ.dsXWj674pJ3A3u', 'Johnson', 'Bob', 'bob.johnson@example.com', 0),
(4, '$2y$10$UXpJBXSWlpHST9Pv/5cA5ODsbFT3PM5iOdc/3SJIPUwqclvEWLzeW', 'Brown', 'Emma', 'emma.brown@example.com', 1),
(5, '$2y$10$HnaIcangviSATwGIMEljhOmVEZ/IrplS4lZ.liKUT7cN8WkG.5UPy', 'Davis', 'Michael', 'michael.davis@example.com', 1),
(6, '$2y$10$VKexlufKr.TWqptS.lMnMe4afLtuFmcv30/7/Orqx2g1mub2Rr3kC', 'Wilson', 'Sophia', 'sophia.wilson@example.com', 1),
(7, '$2y$10$C94kQQW1VpoRCEC/Vx6Un.BXQedPMg9BBxAp5iGcwTwF8kqaVF7TO', 'Dubois', 'Émilie', 'emilie.dubois@example.com', 0);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `disponibilite`
--
ALTER TABLE `disponibilite`
  ADD CONSTRAINT `disponibilite_ibfk_1` FOREIGN KEY (`idLogement`) REFERENCES `logement` (`id`);

--
-- Constraints for table `equipement`
--
ALTER TABLE `equipement`
  ADD CONSTRAINT `equipement_ibfk_1` FOREIGN KEY (`idPiece`) REFERENCES `piece` (`id`);

--
-- Constraints for table `etatequipement`
--
ALTER TABLE `etatequipement`
  ADD CONSTRAINT `etatEquipement_ibfk_1` FOREIGN KEY (`idEtatLieux`) REFERENCES `etatlieux` (`id`),
  ADD CONSTRAINT `etatEquipement_ibfk_2` FOREIGN KEY (`idEquipement`) REFERENCES `equipement` (`id`);

--
-- Constraints for table `etatlieux`
--
ALTER TABLE `etatlieux`
  ADD CONSTRAINT `etatlieux_ibfk_1` FOREIGN KEY (`idPiece`) REFERENCES `piece` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
