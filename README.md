# Appli ImMobile

## Mise en place de l'environnement de test :

1. Importer la base de données immobilier.sql et la nommer "immo": \
Users avec reservations : 
mail : john.doe@example.com
mdp : JohnDoe \

mail : alice.smith@example.com
mdp : AliceSmith \

mail : bob.johnson@example.com
mdp : BobJohnson \

mail : emilie.dubois@example.com
mdp : EmilieDubois \

1. Modification a apporter à l'application mobile React Native : 
Changer l'IP dans les fichiers suivant :
1 .AuthentificationScreen.js
1. Piece.js
1. PieceDetailsScreen.js (ligne 85 & 114)
1. PieceScreen.js
\
Si les photos ne sont pas enregistré, essayer de redémarrer l'ordinateur après avoir installer le projet.
Promis des fois ça règle les soucis 🤠

Penser à placer le dossier API du côté serveur et de le placer directement à la racine de manière 
à l'atteindre de cette façon : "http://votreip/api/fichier.php"
