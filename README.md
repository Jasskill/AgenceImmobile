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
