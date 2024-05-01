<?php

require('functions.php');

$connexion = creerConnexion();
if ($connexion["succes"]) {
    $pdo = $connexion["pdo"];
    switch ($_SERVER["REQUEST_METHOD"]) {
        case "GET":
            if (isset($_GET["idEtatLieux"])) {
                $sql = "SELECT etatEquipement.id, equipement.libelle, note, commentaire FROM etatEquipement
                        INNER JOIN equipement ON equipement.id = etatEquipement.idEquipement 
                        WHERE idEtatLieux = :unId";
                $req = $pdo->prepare($sql);
                $req->bindParam(":unId", $_GET["idEtatLieux"], \PDO::PARAM_INT);
                $res = $req->execute();
                if ($res) {
                    $lesEtatsDEquipements = $req->fetchAll(\PDO::FETCH_ASSOC);
                    if ($lesEtatsDEquipements != array()) {
                        creerJson(200, $lesEtatsDEquipements);
                        break;
                    } else {
                        creerJson(404, "Not Found");
                        break;
                    }
                } else {
                    creerJson(500, "Internal Server Error");
                    break;
                }
            } else {
                creerJson(400, "Bad request");
                break;
            }
            break;
        case "POST":
            $json = json_decode(file_get_contents('php://input'));
            if (isset($json->idEquipement) && isset($json->note) && isset($json->commentaire)) {
                $sql = "INSERT INTO etatEquipement(idEtatLieux, idEquipement, note, commentaire) VALUES (NULL, :unIdEquipement, :uneNote, :unCommentaire)";
                $req = $pdo->prepare($sql);
                $req->bindParam(":unIdEquipement", $json->idEquipement, \PDO::PARAM_INT);
                $req->bindParam(":uneNote", $json->note, \PDO::PARAM_INT);
                $req->bindParam(":unCommentaire", $json->commentaire, \PDO::PARAM_STR);
                $res = $req->execute();
                if ($res) {
                    //success
                    $sql = "SELECT LAST_INSERT_ID() as ID ;";
                    $req = $pdo->prepare($sql);
                    $req->execute();
                    $id = $req->fetch(\PDO::FETCH_ASSOC);

                    creerJson(201, $id);
                    break;
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
