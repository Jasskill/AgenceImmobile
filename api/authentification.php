<?php
require('functions.php');

$connexion = creerConnexion();
if ($connexion["succes"]) {
    $pdo = $connexion["pdo"];
    switch ($_SERVER["REQUEST_METHOD"]) {
        case "POST":
            $json = json_decode(file_get_contents('php://input'));
            if (isset($json->mail) && isset($json->mdp)) {
                $mdp = base64_decode($json->mdp);

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
                        if (password_verify($mdp, $utilisateur['mdp'])) {
                            $sql = "SELECT id, nom, prenom FROM utilisateur WHERE mail = :leMail";
                            $req = $pdo->prepare($sql);
                            $req->bindParam(":leMail", $json->mail, \PDO::PARAM_STR);
                            $res = $req->execute();
                            $utilisateur = $req->fetch(\PDO::FETCH_ASSOC);

                            creerJson(200, $utilisateur);
                            addLog("Connexion", "Tentative de connexion au compte N°".$utilisateur["id"]." : réussi");
                            break;
                        } else {
                            creerJson(401, "Unauthorized : Email ou mot de passe incorrect");
                            addLog("Connexion", "Tentative de connexion avec le mail '".$json->mail."' : échec");
                            break;
                        }
                    } else {
                        //error
                        creerJson(500, "Internal Server Error");
                        break;
                    }
                } else {
                    creerJson(404, "Not found : mail inconnu");
                    break;
                }
            } else {
                creerJson(400, "Bad request : Les éléments nécessaires ne sont pas fournies");
                break;
            }
            break;
        default:
            creerJson(405, "Method Not Allowed");
            addLog("Connexion", "Usage d'une mauvaise méthode" );
            break;
    }
}
