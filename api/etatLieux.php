<?php

require('functions.php');

$connexion = creerConnexion();
if ($connexion["succes"]) {
    $pdo = $connexion["pdo"];
    switch ($_SERVER["REQUEST_METHOD"]) {
        case "GET":
            // OBJECTIF : Renvoyer un attribut EtatLieuxNecessaire qui indique si l'etat des Lieux souhaiter existe déjà ou non
            if (isset($_GET["idPiece"]) && isset($_GET["idReservation"])) {
                //Determiner si les prochains etats des lieux à réaliser sont ceux de DEBUT ou de FIN
                // 1 = FIN / 0 = DEBUT
                $sql = "SELECT COUNT(*) AS nbReservationCorrespondante FROM reservation WHERE id = :unId AND dateFin < NOW()";
                $req = $pdo->prepare($sql);
                $req->bindParam(":unId", $_GET["idReservation"], \PDO::PARAM_INT);
                $res = $req->execute();
                if ($res) {
                    $nbReservation = $req->fetch(\PDO::FETCH_ASSOC);
                    if ($nbReservation["nbReservationCorrespondante"] == 0) {
                        //DEBUT
                        $sql = "SELECT COUNT(*) AS nbEtatLieux FROM etatlieux WHERE idReservation = :unId1 AND idPiece = :unId2 AND DF = 'D'";
                        $req = $pdo->prepare($sql);
                        $req->bindParam(":unId1", $_GET["idReservation"], \PDO::PARAM_INT);
                        $req->bindParam(":unId2", $_GET["idPiece"], \PDO::PARAM_INT);
                        $res = $req->execute();
                        if ($res) {
                            $nbEtatLieux = $req->fetch(\PDO::FETCH_ASSOC);
                            if ($nbEtatLieux["nbEtatLieux"] == 0) {
                                $etatLieux["etatLieuxNecessaire"] = true;
                                creerJson(200, $etatLieux);
                                break;
                            } else {
                                $etatLieux["etatLieuxNecessaire"] = false;
                                creerJson(200, $etatLieux);
                                break;
                            }
                        } else {
                            creerJson(500, "Internal Server Error");
                            break;
                        }
                    } else {
                        //FIN
                        $sql = "SELECT COUNT(*) AS nbEtatLieux FROM etatlieux WHERE idReservation = :unId1 AND idPiece = :unId2 AND DF = 'F'";
                        $req = $pdo->prepare($sql);
                        $req->bindParam(":unId1", $_GET["idReservation"], \PDO::PARAM_INT);
                        $req->bindParam(":unId2", $_GET["idPiece"], \PDO::PARAM_INT);
                        $res = $req->execute();
                        if ($res) {
                            $nbEtatLieux = $req->fetch(\PDO::FETCH_ASSOC);
                            if ($nbEtatLieux["nbEtatLieux"] == 0) {
                                $etatLieux["etatLieuxNecessaire"] = true;
                                creerJson(200, $etatLieux);
                                break;
                            } else {
                                $etatLieux["etatLieuxNecessaire"] = false;
                                creerJson(200, $etatLieux);
                                break;
                            }
                        } else {
                            creerJson(500, "Internal Server Error");
                            break;
                        }
                    }
                }
            } else {
                creerJson(400, "Bad request");
                break;
            }
            break;
        case "POST":
            $json = json_decode(file_get_contents('php://input'));
            if (isset($json->idReservation) && isset($json->idPiece) && isset($json->note) && isset($json->commentaire)) {
                //Determiner si les prochains etats des lieux à réaliser sont ceux de DEBUT ou de FIN
                // 1 = FIN / 0 = DEBUT
                $sql = "SELECT COUNT(*) AS nbReservationCorrespondante FROM reservation WHERE id = :unId AND dateFin < NOW()";
                $req = $pdo->prepare($sql);
                $req->bindParam(":unId", $json->idReservation, \PDO::PARAM_INT);
                $res = $req->execute();
                if ($res) {
                    $nbReservation = $req->fetch(\PDO::FETCH_ASSOC);
                    if ($nbReservation["nbReservationCorrespondante"] == 0) {
                        $sql = "INSERT INTO etatlieux (idReservation, idPiece, dateEtatLieux, note, commentaire, DF) VALUES (:unIdReservation, :unIdPiece, NOW(), :uneNote, :unCommentaire, 'D')";
                    } else {
                        $sql = "INSERT INTO etatlieux (idReservation, idPiece, dateEtatLieux, note, commentaire, DF) VALUES (:unIdReservation, :unIdPiece, NOW(), :uneNote, :unCommentaire, 'F')";
                    }
                }
                $req = $pdo->prepare($sql);
                $req->bindParam(":unIdReservation", $json->idReservation, \PDO::PARAM_INT);
                $req->bindParam(":unIdPiece", $json->idPiece, \PDO::PARAM_INT);
                $req->bindParam(":uneNote", $json->note, \PDO::PARAM_STR);
                $req->bindParam(":unCommentaire", $json->commentaire, \PDO::PARAM_STR);
                $res = $req->execute();
                if ($res) {
                    //success
                    $sql = "SELECT LAST_INSERT_ID() as ID ;";
                    $req = $pdo->prepare($sql);
                    if ($req->execute()) {
                        $id = $req->fetch(\PDO::FETCH_ASSOC);
                        creerJson(201, $id);
                    } else {
                        creerJson(400, "Bad request");
                        break;
                    }
                } else {
                    //error
                    creerJson(400, "Bad request");
                    break;
                }
            } else {
                creerJson(400, "Bad request");
                break;
            }
            break;
        default:
            creerJson(405, "Method Not Allowed");
            break;
    }
}
