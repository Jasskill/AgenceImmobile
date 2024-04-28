<?php

require('functions.php');

$connexion = creerConnexion();
if ($connexion["succes"]) {
    $pdo = $connexion["pdo"];
    switch ($_SERVER["REQUEST_METHOD"]) {
        case "GET":
            if (isset($_GET["idPiece"])) {
                $sql = "SELECT id, idReservation, dateEtatLieux, note, commentaire, DF FROM etatLieux 
                        WHERE idPiece = :unId 
                        ORDER BY dateEtatLieux DESC 
                        LIMIT 1";
                $req = $pdo->prepare($sql);
                $req->bindParam(":unId", $_GET["idPiece"], \PDO::PARAM_INT);
                $res = $req->execute();
                if ($res) {
                    $unEtatDesLieux = $req->fetch(\PDO::FETCH_ASSOC);
                    if ($unEtatDesLieux != "") {
                        creerJson(200, $unEtatDesLieux);
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
        case "POST":
            $json = json_decode(file_get_contents('php://input'));
            if (isset($json->date) && isset($json->note) && isset($json->commentaire) && isset($json->df)) {
                $sql = "INSERT INTO etatLieux (idReservation, idPiece, dateEtatLieux, note, commentaire, DF) VALUES (:unIdReservation, :unIdPiece, :uneDateEtatLieux, :uneNote, :unCommentaire, :df)";
                $req = $pdo->prepare($sql);
                $req->bindParam(":unIdReservation", $json->idReservation, \PDO::PARAM_INT);
                $req->bindParam(":unIdPiece", $json->idPiece, \PDO::PARAM_INT);
                $req->bindParam(":uneDateEtatLieux", $json->date, \PDO::PARAM_STR);
                $req->bindParam(":uneNote", $json->note, \PDO::PARAM_STR);
                $req->bindParam(":unCommentaire", $json->commentaire, \PDO::PARAM_STR);
                $req->bindParam(":df", $json->df, \PDO::PARAM_STR);
                $res = $req->execute();
                if ($res) {
                    //success
                    $sql = "SELECT LAST_INSERT_ID() as ID ;";
                    $req = $pdo->prepare($sql);
                    $req->execute();
                    $id = $req->fetch(\PDO::FETCH_ASSOC);

                    $sqlUpdate = "UPDATE etatEquipement SET idEtatLieux = :unId WHERE idEtatLieux = NULL";
                    $reqUpdate = $pdo->prepare($sqlUpdate);
                    $reqUpdate->bindParam(":unId", $id->ID, \PDO::PARAM_INT);
                    $resUpdate = $reqUpdate->execute();
                    if ($resUpdate) {
                        creerJson(201, $id);
                    } else {
                        creerJson(400, "Bad request");
                    }
                } else {
                    //error
                    creerJson(400, "Bad request");
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
