<?php

require('functions.php');

$connexion = creerConnexion();
if ($connexion["succes"]) {
    $pdo = $connexion["pdo"];
    switch ($_SERVER["REQUEST_METHOD"]) {
        case "POST":
            $json = json_decode(file_get_contents('php://input'));

            if ((isset($json->extension) && ((isset($json->idEtatLieux) && isset($json->idPiece)) || (isset($json->idEtatEquipement) && isset($json->idEquipement))))) {

                $lien = genererUIDPhoto($pdo, $json->extension);

                if (isset($json->idEtatLieux) && isset($json->idPiece)) {
                    $id = $json->idPiece;
                    $sql = "INSERT INTO photo(lien, idPiece, idEtatLieux) VALUES (:unLien, :unId, :unId2)";
                } else if (isset($json->idEtatEquipement) && isset($json->idEquipement)) {
                    $id = $json->idEquipement;
                    $sql = "INSERT INTO photo(lien, idEquipement, idEtatLieux) VALUES (:unLien, :unId, :unId2)";
                } else {
                    creerJson(400, "Bad Request");
                    break;
                }
                $req = $pdo->prepare($sql);
                $req->bindParam(":unLien", $lien, \PDO::PARAM_STR);
                $req->bindParam(":unId", $id, \PDO::PARAM_INT);
                $req->bindParam(":unId2", $json->idEtatEquipement, \PDO::PARAM_INT);
                $res = $req->execute();
                if ($res) {
                    //success
                    $objet = array("lien" => $lien);
                    creerJson(201, $objet);
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
