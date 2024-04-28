<?php

require('functions.php');

$connexion = creerConnexion();
if ($connexion["succes"]) {
    $pdo = $connexion["pdo"];
    switch ($_SERVER["REQUEST_METHOD"]) {
        case "GET":
            if (isset($_GET["idReservation"])) {
                //Etape 1 : Recupèrer les id des Pièces
                $sql = "SELECT DISTINCT piece.id FROM piece
                        INNER JOIN logement ON piece.idLogement = logement.id
                        INNER JOIN disponibilite ON logement.id = disponibilite.idLogement
                        INNER JOIN reservation ON disponibilite.id = reservation.idDisponibilite
                        WHERE reservation.id = :unId;";
                $req = $pdo->prepare($sql);
                $req->bindParam(":unId", $_GET["idReservation"], \PDO::PARAM_INT);
                $res = $req->execute();
                if ($res) {
                    $lesIdDesPieces = $req->fetchAll(\PDO::FETCH_ASSOC);

                    $lesPieces = array();
                    foreach ($lesIdDesPieces as $Id) {
                        //Etape 2 : Recupérer type, Ancienne note et ancien commentaire
                        //Faire si la piece n'a pas d'ancien etat des lieux
                        $sql = "SELECT piece.id AS id, piece.type AS type, etatLieux.note AS ancienneNote, etatLieux.commentaire AS ancienCommentaire FROM etatLieux
                        INNER JOIN piece ON piece.id = etatLieux.idPiece
                        WHERE etatlieux.idPiece = :unId
                        ORDER BY etatlieux.dateEtatLieux DESC
                        LIMIT 1;";
                        $req = $pdo->prepare($sql);
                        $req->bindParam(":unId", $Id["id"], \PDO::PARAM_INT);
                        $res = $req->execute();
                        if ($res) {
                            $lesInfosPiece = $req->fetch(\PDO::FETCH_ASSOC);
                            $laPiece["infos"] = $lesInfosPiece;
                        } else {
                            creerJson(500, "Internal Server Error");
                            break;
                        }

                        //Etape 3 : Recupérer equipement
                        $sql = "SELECT DISTINCT id FROM equipement WHERE idPiece = :unId;";
                        $req = $pdo->prepare($sql);
                        $req->bindParam(":unId", $Id["id"], \PDO::PARAM_INT);
                        $res = $req->execute();
                        if ($res) {
                            $lesIdDesEquipement = $req->fetchAll(\PDO::FETCH_ASSOC);
                        } else {
                            creerJson(500, "Internal Server Error");
                            break;
                        }
                        $lesEquipements = array();
                        foreach ($lesIdDesEquipement as $Equipement) {
                            $sql = "SELECT equipement.id AS id, equipement.libelle AS libelle, etatEquipement.note AS ancienneNote, etatEquipement.commentaire AS ancienCommentaire FROM etatEquipement
                            INNER JOIN equipement ON equipement.id = etatEquipement.idEquipement
                            INNER JOIN etatLieux ON etatLieux.id = etatEquipement.idEtatLieux
                            WHERE etatEquipement.idEquipement = :unId
                            ORDER BY etatlieux.dateEtatLieux DESC
                            LIMIT 1;";
                            $req = $pdo->prepare($sql);
                            $req->bindParam(":unId", $Equipement["id"], \PDO::PARAM_INT);
                            $res = $req->execute();
                            if ($res) {
                                $unEquipement = $req->fetch(\PDO::FETCH_ASSOC);

                                //Etape 3.5 Recupérer les photos des equipements
                                $sql = "SELECT lien FROM photo WHERE idEquipement = :unId AND idEtatLieux IS NOT NULL LIMIT 50";
                                $req = $pdo->prepare($sql);
                                $req->bindParam(":unId", $Equipement["id"], \PDO::PARAM_INT);
                                $res = $req->execute();
                                if ($res) {
                                    $lesPhotosEquipements = $req->fetchAll(\PDO::FETCH_ASSOC);
                                    //var_dump($lesPhotosEquipements);
                                    $lesLiens = array();
                                    if ($lesPhotosEquipements != array()) {

                                        foreach ($lesPhotosEquipements as $laPhoto) {
                                            array_push($lesLiens, $laPhoto["lien"]);
                                        }
                                    }
                                    $unEquipement["listePhoto"] = $lesLiens;
                                } else {
                                    creerJson(500, "Internal Server Error");
                                    break;
                                }

                                array_push($lesEquipements, $unEquipement);
                            } else {
                                creerJson(500, "Internal Server Error");
                                break;
                            }
                        }
                        $laPiece["equipements"] = $lesEquipements;

                        //Etape 4 : Recupérer les Photos de la pieces
                        $sql = "SELECT lien FROM photo
                        WHERE idPiece = :unId AND idEtatLieux IS NOT NULL
                        ORDER BY id DESC
                        LIMIT 4;";
                        $req = $pdo->prepare($sql);
                        $req->bindParam(":unId", $Id["id"], \PDO::PARAM_INT);
                        $res = $req->execute();
                        if ($res) {
                            $lesPhotosPiece = $req->fetchAll(\PDO::FETCH_ASSOC);
                            $lesLiens = array();
                            foreach ($lesPhotosPiece as $laPhoto) {
                                array_push($lesLiens, $laPhoto["lien"]);
                            }
                            $laPiece["listePhoto"] = $lesLiens;
                        } else {
                            creerJson(500, "Internal Server Error");
                            break;
                        }

                        array_push($lesPieces, $laPiece);
                    }
                    if (count($lesPieces) > 0) {
                        creerJson(200, $lesPieces);
                        break;
                    } else {
                        creerJson(404, "Erreur, les pieces sont introuvables");
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
        default:
            creerJson(405, "Method Not Allowed");
            break;
    }
}
/*
lesPieces
├── 1=>{
│   ├── "infos"=>{"type"=>type,"aciennenote"=>1,"ancienCommentaire"=>"bad"}
│   ├── "equipements"=>[{"id"=1, "libellé"=>libelle, "listePhoto"=>["lien", "lien"], "anciennenote"=>1, "anciencommentaire"=>"oui"},{"id"=2, "libellé"=>libelle, "listePhoto"=>["lien", "lien"], "anciennenote"=>1, "anciencommentaire"=>"oui"}],
│   └── "listePhoto"=>["lien", "lien"]}
├── 2
└── 3
*/

/*
SELECT DISTINCT piece.type AS type, etatLieux.dateEtatLieux AS date, etatLieux.note AS ancienneNote, etatLieux.commentaire AS ancienCommentaire FROM etatLieux
INNER JOIN reservation ON reservation.id = etatLieux.idReservation
INNER JOIN disponibilite ON disponibilite.id = reservation.idDisponibilite
INNER JOIN logement ON logement.id = disponibilite.idLogement
INNER JOIN piece ON piece.idLogement = logement.id
WHERE etatlieux.idPiece = 1
ORDER BY etatlieux.dateEtatLieux DESC;
*/