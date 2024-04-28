<?php

require('functions.php');

$connexion = creerConnexion();
if ($connexion["succes"]) {
    $pdo = $connexion["pdo"];
    switch ($_SERVER["REQUEST_METHOD"]) {
        case "GET":
            if (isset($_GET["idClient"])) {
                $sql = "SELECT reservation.id, reservation.dateDebut, reservation.dateFin, 
                                logement.id AS logementID, logement.rue, logement.codePostal, logement.ville, 
                                logement.description, logement.idProprietaire FROM reservation 
                        INNER JOIN disponibilite ON disponibilite.id = reservation.idDisponibilite
                        INNER JOIN logement ON disponibilite.idLogement = logement.id
                        WHERE idClient = :unId AND reservation.dateFin >= NOW()
                        ORDER BY reservation.dateFin";
                $req = $pdo->prepare($sql);
                $req->bindParam(":unId", $_GET["idClient"], \PDO::PARAM_INT);
                $res = $req->execute();
                if ($res) {
                    $reservations = $req->fetchAll(\PDO::FETCH_ASSOC);
                    $lesReservations = array();
                    foreach ($reservations as $reservation) {
                        $laReservation["id"] = $reservation["id"];
                        $laReservation["dateDebut"] = $reservation["dateDebut"];
                        $laReservation["dateFin"] = $reservation["dateFin"];

                        $leLogement["id"] = $reservation["logementID"];
                        $leLogement["rue"] = $reservation["rue"];
                        $leLogement["codePostal"] = $reservation["codePostal"];
                        $leLogement["ville"] = $reservation["ville"];
                        $leLogement["description"] = $reservation["description"];
                        $leLogement["idProprietaire"] = $reservation["idProprietaire"];

                        $laReservation["Logement"] = $leLogement;

                        array_push($lesReservations, $laReservation);
                    }
                    if ($lesReservations != array()) {
                        creerJson(200, $lesReservations);
                    } else {
                        creerJson(404, "Not Found");
                    }
                } else {
                    creerJson(500, "Internal Server Error");
                }
            } else {
                creerJson(400, "Bad request");
            }

            break;
        default:
            creerJson(405, "Method Not Allowed");
            break;
    }
}
