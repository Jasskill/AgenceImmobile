<?php
require('functions.php');

$connexion = creerConnexion();
if ($connexion["succes"]) {
    $pdo = $connexion["pdo"];
    switch ($_SERVER["REQUEST_METHOD"]) {
        case "GET":
            $json = json_decode(file_get_contents('php://input'));
            if (isset($json->mail) && isset($json->hash)) {
                $sql = "SELECT count(*) AS nb FROM utilisateur WHERE mail = :leMail";
                $req = $pdo->prepare($sql);
                $req->bindParam(":leMail", $json->mail, \PDO::PARAM_STR);
                $res = $req->execute();
                $nombreMail = $req->fetch(\PDO::FETCH_ASSOC);
                if ($nombreMail['nb'] == 1) {
                    $sql = "SELECT mdp FROM utilisateur WHERE mail = :leMail";
                    $req = $pdo->prepare($sql);
                    $req->bindParam(":leMail", $json->mail, \PDO::PARAM_STR);
                    $res = $req->execute();
                    if ($res) {
                        //success
                        $utilisateur = $req->fetch(\PDO::FETCH_ASSOC);
                        if ($utilisateur['mdp'] == $json->hash) {
                            $sql = "SELECT id, nom, prenom FROM utilisateur WHERE mail = :leMail";
                            $req = $pdo->prepare($sql);
                            $req->bindParam(":leMail", $json->mail, \PDO::PARAM_STR);
                            $res = $req->execute();
                            $utilisateur = $req->fetch(\PDO::FETCH_ASSOC);

                            creerJson(200, $utilisateur);
                        } else {
                            creerJson(400, "Bad Request");
                        }
                    } else {
                        //error
                        creerJson(400, "Bad request");
                    }
                } else {
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
