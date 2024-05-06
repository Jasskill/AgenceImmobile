# Appli ImMobile

## Mise en place de l'environnement de test :

1. Importer la base de données immobilier.sql et la nommer "immo":  
Users avec reservations : 
mail : john.doe@example.com
mdp : JohnDoe  

mail : alice.smith@example.com
mdp : AliceSmith  

mail : bob.johnson@example.com
mdp : BobJohnson  

mail : emilie.dubois@example.com
mdp : EmilieDubois  

1. Modification a apporter à l'application mobile React Native : 
Changer l'IP dans les fichiers suivant :
- AuthentificationScreen.js
- Piece.js
- PieceDetailsScreen.js (ligne 85 & 114)
- PieceScreen.js

Pour recevoir les photos, il faut créer un répertoire "photos" dans le dossier API s'il n'est pas présent.
Si les photos ne sont pas enregistré, essayer de redémarrer l'ordinateur après avoir installer le projet.
Promis des fois ça règle les soucis 🤠

Penser à placer le dossier API du côté serveur et de le placer directement à la racine de manière 
à l'atteindre de cette façon : "http://votreip/api/fichier.php"

## Comment marche l'appli ?
### Coté React :
1. Nous avons app.js qui définit les différents chemin/screen possible
2. Ensuite, le code est découpé en deux parties, les screens et les components
3. Les screens sont toutes les pages de l'appli, donc en premier la connexion puis l'authentification PUIS on affiche les réservations sur la page d'accueil ENFIN nous affichons les pièces, puis les détails de chaque pièce, pour pouvoir les noter
4. Pour les components, ils servent à séprarer une partie de la page en une fonctionnalité réutilisable, comme des photos, des reservations, des pièces et des équipements.


### Coté API :
L'API est décomposé en plusieurs fichiers PHP ayant chacun une ou plusieurs fonctionnalités en rapport à un élément du projet :
- functions.php                   : Contient des fonctions se répétant dans plusieurs fichiers comme la réponse http et la connexion à la base de données.
- authentification.php (POST)     : Vérifie le couple mail/mdp fournie en JSON et renvoie l'id du client en cas de succès.
- reservation.php (GET)           : Récupère les reservations du client (idClient à fournir) qui ont une date postèrieur à celle d'aujourd'hui, on récupère également les infos du logement concerné.
- piece.php (GET)                 : Récupère toutes les pieces concernés par une réservation (idReservation à fournir), récupère également les dernières infos d'état des lieux de la pièce ainsi que tous les équipements de la pièce.
- photo.php (POST)                : Permet d'envoyer des photos qui sont crées dans le répertoire photos de l'API (s'il n'est pas présent alors le crée), il génère également un UID pour la photo.
- etatLieux.php (GET & POST)      : En GET, il faut fournir idPiece et idReservation, l'api se charge de communiquer à l'application s'il existe déjà un état des lieux pour la pièce ou non.
                                    En POST, créer un etat des Lieux en fournissant (idPiece, idReservation, note et commentaire), la date utiliser et celle du jour.
- etatEquipement.php (GET & POST) : En GET, récupère les états des equipement en rapport à un état des Lieux.
                                    En POST, créer un état de l'équipement en fournissant idEtatLieux, idEquipement, note et commentaire.
