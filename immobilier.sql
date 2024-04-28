-- phpMyAdmin SQL Dump
-- version 5.2.1deb1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : mer. 17 jan. 2024 à 16:20
-- Version du serveur : 11.2.2-MariaDB-1:11.2.2+maria~deb12
-- Version de PHP : 8.2.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `Immo`
--

DELIMITER $$
--
-- Procédures
--
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
-- Structure de la table `disponibilite`
--

CREATE TABLE `disponibilite` (
  `id` int(11) NOT NULL,
  `dateDebut` date NOT NULL,
  `dateFin` date NOT NULL,
  `idLogement` int(11) NOT NULL,
  `tarif` decimal(10,0) NOT NULL,
  `valide` tinyint(1) NOT NULL,
  `derive` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Déchargement des données de la table `disponibilite`
--

INSERT INTO `disponibilite` (`id`, `dateDebut`, `dateFin`, `idLogement`, `tarif`, `valide`, `derive`) VALUES
(1, '2023-12-01', '2023-12-07', 1, 120, 1, NULL),
(2, '2023-11-25', '2023-11-30', 2, 90, 0, NULL),
(3, '2024-01-10', '2024-01-20', 3, 150, 1, NULL),
(4, '2023-12-15', '2023-12-20', 4, 100, 1, NULL),
(5, '2024-02-01', '2024-02-10', 5, 130, 1, NULL),
(6, '2024-04-17', '2024-05-08', 5, 180, 0, NULL),
(7, '2024-04-17', '2024-04-25', 5, 180, 0, 6),
(8, '2024-04-30', '2024-05-08', 5, 180, 1, 6),
(9, '2024-04-17', '2024-04-20', 5, 180, 1, 7),
(10, '2024-04-23', '2024-04-25', 5, 180, 1, 7),
(11, '2024-03-14', '2024-04-14', 3, 99, 1, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `equipement`
--

CREATE TABLE `equipement` (
  `id` int(11) NOT NULL,
  `libelle` varchar(100) NOT NULL,
  `idPiece` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Déchargement des données de la table `equipement`
--

INSERT INTO `equipement` (`id`, `libelle`, `idPiece`) VALUES
(1, 'Lit double', 1),
(2, 'Cuisinière', 2),
(3, 'Canapé-lit', 3),
(4, 'Douche', 4),
(5, 'Lit simple', 5),
(6, 'Lampe', 1),
(7, 'Armoire', 1),
(8, '12 assiettes en porcelaine', 2),
(9, 'Évier', 3),
(10, 'Lit simple', 4),
(11, 'Bureau', 4),
(12, 'Douche', 5),
(13, 'Cuisinière', 6),
(14, 'Lit double', 7),
(15, 'Armoire', 7),
(16, 'Douche', 8),
(17, 'Canapé', 9),
(18, 'Table à manger', 9),
(19, 'Balcon', 10),
(20, 'Lit simple', 11),
(21, 'Armoire', 11),
(22, 'Douche', 12),
(23, 'Cuisinière', 13),
(24, 'Canapé', 14),
(25, 'Table de jeux', 15),
(26, 'Lit double', 17),
(27, 'Armoire', 17),
(28, 'Douche', 18),
(29, 'Évier', 19),
(30, 'Lit simple', 20),
(31, 'Bureau', 21),
(32, 'Canapé', 22);

-- --------------------------------------------------------

--
-- Structure de la table `etatEquipement`
--

CREATE TABLE `etatEquipement` (
  `id` int(11) NOT NULL,
  `idEtatLieux` int(11) DEFAULT NULL,
  `idEquipement` int(11) NOT NULL,
  `note` int(11) DEFAULT NULL,
  `commentaire` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `etatEquipement`
--

INSERT INTO `etatEquipement` (`id`, `idEtatLieux`, `idEquipement`, `note`, `commentaire`) VALUES
(1, 1, 1, 5, 'Bonne Etat'),
(2, 1, 6, 5, 'Bonne Etat'),
(3, 1, 7, 5, 'Bonne Etat'),
(4, 2, 1, 4, 'Une des latte du lit est cassé'),
(5, 2, 6, 5, 'Bonne Etat'),
(6, 2, 7, 5, 'Bonne Etat'),
(7, 3, 2, 5, 'Bonne Etat'),
(8, 3, 8, 5, 'Bonne Etat');

-- --------------------------------------------------------

--
-- Structure de la table `etatLieux`
--

CREATE TABLE `etatLieux` (
  `id` int(11) NOT NULL,
  `idReservation` int(11) DEFAULT NULL,
  `idPiece` int(11) DEFAULT NULL,
  `dateEtatLieux` date DEFAULT NULL,
  `note` int(11) DEFAULT NULL,
  `commentaire` varchar(500) DEFAULT NULL,
  `DF` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `etatLieux`
--

INSERT INTO `etatLieux` (`id`, `idReservation`, `idPiece`, `dateEtatLieux`, `note`, `commentaire`, `DF`) VALUES
(1, 1, 1, '2023-12-01', 5, 'RAS', 'D'),
(2, 1, 1, '2023-12-07', 5, 'RAS', 'F'),
(3, 1, 2, '2023-12-01', 5, 'RAS', 'D');

-- --------------------------------------------------------

--
-- Structure de la table `logement`
--

CREATE TABLE `logement` (
  `id` int(11) NOT NULL,
  `rue` varchar(200) NOT NULL,
  `codePostal` varchar(10) NOT NULL,
  `ville` varchar(150) NOT NULL,
  `description` varchar(255) NOT NULL,
  `idProprietaire` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Déchargement des données de la table `logement`
--

INSERT INTO `logement` (`id`, `rue`, `codePostal`, `ville`, `description`, `idProprietaire`) VALUES
(1, '20 rue de la Liberté', '75001', 'Paris', 'Bel appartement près de la Tour Eiffel', 7),
(2, '5 avenue des Champs-Élysées', '75008', 'Paris', 'Studio moderne au cœur de la ville', 7),
(3, '10 rue du Vieux Port', '13001', 'Marseille', 'Maison avec vue sur la mer', 7),
(4, '25 rue de la République', '69001', 'Lyon', 'Appartement en plein centre-ville', 7),
(5, '8 rue Saint-Michel', '33000', 'Bordeaux', 'Duplex élégant près de la Garonne', 7),
(6, '30 rue de la Paix', '75002', 'Paris', 'Appartement lumineux en plein centre-ville', 7);

-- --------------------------------------------------------

--
-- Structure de la table `photo`
--

CREATE TABLE `photo` (
  `id` int(11) NOT NULL,
  `lien` varchar(300) NOT NULL,
  `idLogement` int(11) DEFAULT NULL,
  `idPiece` int(11) DEFAULT NULL,
  `idEquipement` int(11) DEFAULT NULL,
  `idEtatLieux` int(11) DEFAULT NULL,
  `idEtatEquipement` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Déchargement des données de la table `photo`
--

INSERT INTO `photo` (`id`, `lien`, `idLogement`, `idPiece`, `idEquipement`, `idEtatLieux`, `idEtatEquipement`) VALUES
(1, 'aeb74e-bca7844ff52-7b41aed-fd6ea84b5.jpg', 1, NULL, NULL, NULL, NULL),
(2, 'bde8779-78fdb7da89-adc1214db47-dacebf78.jpg', 2, NULL, NULL, NULL, NULL),
(3, 'ebcd4d3c-6a00-47d2-8165-6d9e192082af.jpg', 3, NULL, NULL, NULL, NULL),
(4, 'ebda4-affe587-5754-afbbc5-fed485a4dc.jpg', 4, NULL, NULL, NULL, NULL),
(5, 'ebebc456d3c-8add00-47d2-8765-67875fedbf.jpg', 5, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `piece`
--

CREATE TABLE `piece` (
  `id` int(11) NOT NULL,
  `surface` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `idLogement` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Déchargement des données de la table `piece`
--

INSERT INTO `piece` (`id`, `surface`, `type`, `idLogement`) VALUES
(1, 25, 'Chambre', 1),
(2, 40, 'Cuisine', 1),
(3, 30, 'Salon', 1),
(4, 20, 'Salle de bain', 1),
(5, 35, 'Chambre', 2),
(6, 30, 'Chambre principale', 2),
(7, 20, 'Salle de bain', 2),
(8, 15, 'Cuisine', 2),
(9, 25, 'Salon', 2),
(10, 40, 'Chambre', 3),
(11, 30, 'Salle de bain', 3),
(12, 25, 'Cuisine', 3),
(13, 35, 'Salon', 3),
(14, 35, 'Chambre', 4),
(15, 20, 'Salle de bain', 4),
(16, 30, 'Cuisine', 4),
(17, 40, 'Salon', 4),
(18, 25, 'Chambre', 5),
(19, 15, 'Salle de bain', 5),
(20, 20, 'Cuisine', 5),
(21, 30, 'Salon', 5),
(22, 30, 'Chambre principale', 6),
(23, 20, 'Salle de bain', 6),
(24, 15, 'Cuisine', 6),
(25, 25, 'Salon', 6),
(26, 10, 'Bureau', 6),
(27, 15, 'Balcon', 6);

-- --------------------------------------------------------

--
-- Structure de la table `reservation`
--

CREATE TABLE `reservation` (
  `id` int(11) NOT NULL,
  `dateDebut` date NOT NULL,
  `dateFin` date NOT NULL,
  `idDisponibilite` int(11) NOT NULL,
  `idClient` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Déchargement des données de la table `reservation`
--

INSERT INTO `reservation` (`id`, `dateDebut`, `dateFin`, `idDisponibilite`, `idClient`) VALUES
(1, '2023-12-01', '2023-12-07', 1, 6),
(2, '2023-11-25', '2023-11-30', 2, 6),
(4, '2023-12-18', '2023-12-22', 4, 6),
(5, '2024-02-05', '2024-02-08', 5, 6),
(6, '2024-04-25', '2024-04-30', 6, 6),
(7, '2024-04-20', '2024-04-23', 7, 6),
(8, '2023-11-25', '2023-11-30', 2, 6);

-- --------------------------------------------------------

--
-- Structure de la table `utilisateur`
--

CREATE TABLE `utilisateur` (
  `id` int(11) NOT NULL,
  `mdp` varchar(300) NOT NULL,
  `nom` varchar(150) NOT NULL,
  `prenom` varchar(150) NOT NULL,
  `mail` varchar(150) NOT NULL,
  `proprietaire` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Déchargement des données de la table `utilisateur`
--

INSERT INTO `utilisateur` (`id`, `mdp`, `nom`, `prenom`, `mail`, `proprietaire`) VALUES
(6, '$2y$10$aUtOC0HDRIFDZX2wD.QgBuQK0dy6BZYr1bNaeNNvZ6zjh8lLllNEO', 'jacque', 'luc', 'a@a.a', 0),
(7, '$2y$10$syNQ9RVuVksCQ1kGUvrUP.zWMvbbFJ8a734TYW8Gi7TJT9dBuxLpK', 'b', 'b', 'b@b.b', 1);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `disponibilite`
--
ALTER TABLE `disponibilite`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idLogement` (`idLogement`);

--
-- Index pour la table `equipement`
--
ALTER TABLE `equipement`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Equipement_Piece_FK` (`idPiece`);

--
-- Index pour la table `etatEquipement`
--
ALTER TABLE `etatEquipement`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idEtatLieux` (`idEtatLieux`),
  ADD KEY `idEquipement` (`idEquipement`);

--
-- Index pour la table `etatLieux`
--
ALTER TABLE `etatLieux`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idReservation` (`idReservation`),
  ADD KEY `idPiece` (`idPiece`);

--
-- Index pour la table `logement`
--
ALTER TABLE `logement`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Logement_Utilisateur_FK` (`idProprietaire`);

--
-- Index pour la table `photo`
--
ALTER TABLE `photo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idLogement` (`idLogement`),
  ADD KEY `idPiece` (`idPiece`),
  ADD KEY `idEquipement` (`idEquipement`),
  ADD KEY `idEtatLieux` (`idEtatLieux`),
  ADD KEY `idEtatEquipement` (`idEtatEquipement`);

--
-- Index pour la table `piece`
--
ALTER TABLE `piece`
  ADD PRIMARY KEY (`id`),
  ADD KEY `Piece_Logement_FK` (`idLogement`);

--
-- Index pour la table `reservation`
--
ALTER TABLE `reservation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idLogement` (`idDisponibilite`),
  ADD KEY `idClient` (`idClient`);

--
-- Index pour la table `utilisateur`
--
ALTER TABLE `utilisateur`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `disponibilite`
--
ALTER TABLE `disponibilite`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `equipement`
--
ALTER TABLE `equipement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT pour la table `etatEquipement`
--
ALTER TABLE `etatEquipement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `etatLieux`
--
ALTER TABLE `etatLieux`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `logement`
--
ALTER TABLE `logement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `photo`
--
ALTER TABLE `photo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `piece`
--
ALTER TABLE `piece`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT pour la table `reservation`
--
ALTER TABLE `reservation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `utilisateur`
--
ALTER TABLE `utilisateur`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `disponibilite`
--
ALTER TABLE `disponibilite`
  ADD CONSTRAINT `disponibilite_ibfk_1` FOREIGN KEY (`idLogement`) REFERENCES `logement` (`id`);

--
-- Contraintes pour la table `equipement`
--
ALTER TABLE `equipement`
  ADD CONSTRAINT `equipement_ibfk_1` FOREIGN KEY (`idPiece`) REFERENCES `piece` (`id`);

--
-- Contraintes pour la table `etatEquipement`
--
ALTER TABLE `etatEquipement`
  ADD CONSTRAINT `etatEquipement_ibfk_1` FOREIGN KEY (`idEtatLieux`) REFERENCES `etatLieux` (`id`),
  ADD CONSTRAINT `etatEquipement_ibfk_2` FOREIGN KEY (`idEquipement`) REFERENCES `equipement` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
