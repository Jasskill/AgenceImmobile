<?php

function creerJson($code, $contenu)
{
    http_response_code($code);
    if ($code != 200 && $code != 201) {
        $object["message"] = $contenu;
    } else {
        $object = $contenu;
    }
    echo json_encode($object);
}

function creerConnexion()
{
    $config = parse_ini_file("config.ini");
    try {
        $pdo = new \PDO("mysql:host=" . $config["host"] . ";dbname=" . $config["database"] . ";charset=utf8", $config["user"], $config["password"]);
        $succes = true;
    } catch (Exception $e) {
        $succes = false;
        creerJson(500, "Internal Server Error");
    }
    return array("succes" => $succes, "pdo" => $pdo);
}

function genererUIDPhoto($pdo, $extension)
{
    $unique = false;
    while (!$unique) {
        $lien = bin2hex(openssl_random_pseudo_bytes(50, $cstrong));
        $lien = $lien . $extension;
        $sql = "SELECT COUNT(*) AS nb FROM photo WHERE lien = :lePotentielLien";
        $req = $pdo->prepare($sql);
        $req->bindParam(":lePotentielLien", $lien, \PDO::PARAM_STR);
        $res = $req->execute();
        if ($res) {
            $nombrePhoto = $req->fetch(\PDO::FETCH_ASSOC);
            if ($nombrePhoto["nb"] < 1) {
                $unique = true;
            }
        } else {
            creerJson(500, "Erreur Serveur");
            exit;
        }
    }

    return $lien;
}
