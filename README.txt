Mise en place de l'environnement de test :

Importé la base de données immobilier.sql :
Users avec reservations :
mail : john.doe@example.com
mdp : JohnDoe

mail : alice.smith@example.com
mdp : AliceSmith

mail : bob.johnson@example.com
mdp : BobJohnson

mail : emilie.dubois@example.com
mdp : EmilieDubois

Modification a apporté à l'application mobile React Native : 
Changer l'IP dans les fichiers suivant :
-AuthentificationScreen.js
-Piece.js
-PieceDetailsScreen.js (ligne 85 & 114)
-PieceScreen.js

Si les photos ne sont pas enregistré, essayer de redémarrer l'ordinateur après avoir installer le projet.

Penser à placer le dossier API du côté serveur et de le placer directement à la racine de manière 
à l'atteindre de cette façon : "http://votreip/api/fichier.php"