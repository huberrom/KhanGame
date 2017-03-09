/* 
Joueur.pl
Version : 1.0
Auteur : Gaudefroy Mathilde et Huber Romain

Description : contient l'ensemble des fonctions propre aux joueurs. Fait fonctionner le mode joueur (joueur contre joueur ou joueur contre IA).
*/

/* All moves renvoie dans Res tous les mouvements d'une piece. Ses mouvements dependent forcment du Khan, des pi�ces sur son chemin etc..*/
allMove(Piece, []) :- position(Piece, X, Y), currentPlayer(Player), get_mvmtsPiece(Piece, M), \+setof(S, movesDispo(Piece,M,Player,X,Y,S), Res), !.
allMove(Piece, Res) :- position(Piece, X, Y), currentPlayer(Player), get_mvmtsPiece(Piece, M), setof(S, movesDispo(Piece,M,Player,X,Y,S), Res).

/* Recup les pieces dispo : Une pi�ce est dite dispo quand elle a au moins un mouvement disponible*/
getPieceDispo(Player, Res) :- boardSelected(Board), khan(K), position(K, X, Y), get_mvmts(Board, X, Y, M), pieces(Player, P), en_vies(P, V), piecesDispo(Board, M, V, Res).

/***** TOUR RESPECT : Tour qui respecte le Khan : on a donc trois choix : voir les pieces qu'on peut deplacer, voir le plateau et choisir la piece qu'on deplace *****/
tourRespect :- write('Que voulez-vous faire ?'), nl, 
write('1 pour voir les pi�ces que vous pouvez deplacer'), nl, 
write('2 pour voir le plateau'), nl, 
write('3 pour choisir une pi�ce'), nl, 
read(X), choix(X).

/* Le choix 1 permet de recuperer toutes les pi�ces disponibles pour le joueur. Le cut permet de ne pas passer dans le choix(_) */
choix(1) :- currentPlayer(P), getPieceDispo(P, Z), write(Z), nl, !, tourRespect.
/* Le choix 2 permet d'afficher la grille. Le cut permet de ne pas passer dans le choix(_) */
choix(2) :- affichage_pion, !, tourRespect.
/* Le choix 3 permet permet au joueur de choisir la piece qu'il veut deplacer et d'appeler la m�thode pour la deplacer. Le cut permet de ne pas passer dans le choix(_) */
choix(3) :- write('Entrez la pi�ce que vous voulez d�placer'), nl, read(Y), choixPiece(Y), !.
/* Si le chiffre est diff�rent de 1, 2 ou 3 */
choix(_) :- write('Chiffre incorrect'), nl, tourRespect.

/* Choix piece v�rifie que la pi�ce choisit est bien deplacable et qu'elle correspond � une pi�ce du joueur actuel. Si c'est le cas alorsi l peut choisir parmis les moves dispo qui lui sont affich�s. On appelle ensuite la m�thode pour d�placer la piece. Si la m�thode s'est bien pass�, on change la position du Khan et on change de tour*/
choixPiece(Piece) :- currentPlayer(P), getPieceDispo(P, Z), element(Piece,Z), 
write('Choisissez la position X et Y de votre piece parmi les d�placements suivantes'), allMove(Piece,Moves), nl, write(Moves), nl, read(X), read(Y), deplacementPiece(Piece, X, Y, Moves), retract(khan(_)), asserta(khan(Piece)), boucleTourJeu, !.
choixPiece(_) :- write('Cette piece nest pas deplacable.'), nl, tourRespect.

/* On v�rifie que le mouvement est bien un element de la liste des moves disponibles. Si �a l'est on deplace la piece, sinon on revient � la m�thode du choix*/
deplacementPiece(Piece, X, Y, Moves) :- element([X,Y], Moves), deplacer_piece(Piece, X, Y), !.
deplacementPiece(Piece, _, _, _) :- write('Veuillez choisir parmi les d�placements propos�s'), nl, !, choixPiece(Piece).
/****** FIN TOUR RESPECT ****


****** TOUR NON RESPECT : Tour qui ne respecte pas le Khan *****/
tourNonRespect :- write('Que voulez-vous faire ?'), nl, 
write('1 pour voir les pi�ces que vous pouvez deplacer'), nl, 
write('2 pour voir le plateau'), nl, 
write('3 pour voir vos pi�ces mortes'), nl,
write('4 pour remettre une pi�ce sur le plateau'), nl, 
write('5 pour deplacer une pi�ce'), nl, 
read(X), choixNonRespect(X).

/* Le choix 1 permet de recuperer toutes les pi�ces disponibles pour le joueur. Elles ne sont pas les m�mes que si on avait d� respecter le Khan. On utilise la m�thode du choix au premier tour car, comme au premier tour, on ne prend pas en compte le khan. Le cut permet de ne pas passer dans le choix(_) */
choixNonRespect(1) :- currentPlayer(P), getPieceDispoPremierTour(P, Z), write(Z), nl, !, tourNonRespect.
/* Le choix 2 permet d'afficher la grille. Le cut permet de ne pas passer dans le choix(_) */
choixNonRespect(2) :- affichage_pion, !, tourNonRespect.
/* Le choix 3 permet d'afficher les pi�ces qu'on peut remettre en jeu, donc celles qui sont mortes. Le cut permet de ne pas passer dans le choix(_) */
choixNonRespect(3) :- currentPlayer(X), pieces(X,P), getPieceMorte(P,PM), write(PM), nl, !, tourNonRespect.
/* Le choix 4 permet de choisir la piece que l'on compte remettre en jeu et d'appeler la m�thode pour le faire. Le cut permet de ne pas passer dans le choix(_) */
choixNonRespect(4) :- write('Entrez la pi�ce que vous voulez remettre sur le jeu'), nl, read(Y), putBackPiece(Y), !.
/* Le choix 5 permet de choisir la piece que l'on veut d�placer. Le cut permet de ne pas passer dans le choix(_) */
choixNonRespect(5) :- write('Entrez la pi�ce que vous voulez d�placer'), nl, read(Y), choixPieceNonRespect(Y), !. 
/* Si le chiffre est diff�rent de 1, 2, 3, 4 ou 5 */
choixNonRespect(_) :- write('Chiffre incorrect'), nl, tourNonRespect.

/* Choix piece v�rifie que la pi�ce choisit est bien deplacable et qu'elle correspond � une pi�ce du joueur actuel. Si c'est le cas alors il peut choisir parmis les moves dispo qui lui sont affich�s. On appelle ensuite la m�thode pour d�placer la piece. Si la m�thode s'est bien pass�, on change la position du Khan et on change de tour. La seule diff�rence avec choixPiece c'est qu'il a le choix entre toutes les pi�ces en vie, il n'a pas � respecter le Khan.*/
choixPieceNonRespect(Piece) :- currentPlayer(P), getPieceDispoPremierTour(P, Z), element(Piece,Z), 
write('Choisissez la position X et Y de votre piece parmi les d�placements suivantes'), allMove(Piece,Moves), nl, write(Moves), nl, read(X), read(Y), deplacementPiece(Piece, X, Y, Moves), retract(khan(_)), asserta(khan(Piece)), boucleTourJeu, !.
choixPieceNonRespect(_) :- write('Cette piece nest pas deplacable.'), nl, tourNonRespect.

/* Permet de remettre en une piece sur le plateau. Le joueur a le choix entre les pieces mortes.*/
putBackPiece(Piece) :-  currentPlayer(X), pieces(X,P), getPieceMorte(P,PM), element(Piece, PM), posBackPiece(Piece), !, boucleTourJeu.
putBackPiece(Piece) :- write('Cette pi�ce est d�j� en vie. Appuyez sur 3 pour voir les pieces que vous pouvez remettre en jeu'), nl, tourNonRespect.

/* Permet de v�rifier que l'endroit o� on veut remettre la piece est bien valide (Sur le plateau et qu'aucun pi�ce s'y situe. Si c'est le cas alors on ajoute la piece � cette position */
posBackPiece(Piece) :- write('Choisissez X et Y o� vous voulez remettre votre piece'), nl, read(X), read(Y), X>0, X<7, Y>0, Y<7, \+position(_,X,Y), asserta(position(Piece,X,Y)), retract(khan(_)), asserta(khan(Piece)), !, boucleTourJeu.
posBackPiece(Piece) :- write('Position invalide, X et Y doivent �tre entre 1 et 6 et aucun pion doit se situer � cet endroit'), nl, tourNonRespect.
/* FIN TOUR NON RESPECT 

************* PREMIER TOUR : Particulier car le joueur peut deplacer n'importe quelle piece *************/
premierTour :- write('Que voulez-vous faire ?'), nl, write('1 pour voir les pi�ces que vous pouvez deplacer'), nl, 
write('2 pour voir le plateau'), nl, 
write('3 pour choisir une pi�ce'), nl, 
read(X), choixPremierTour(X).

choixPremierTour(1) :- currentPlayer(P), getPieceDispoPremierTour(P, Z), write(Z), nl, !, premierTour.
choixPremierTour(2) :- affichage_pion, !, premierTour.
choixPremierTour(3) :- write('Entrez la pi�ce que vous voulez d�placer'), nl, read(Y), choixPiecePremierTour(Y), !.
choixPremierTour(_) :- write('Chiffre incorrect'), nl, premierTour.

/* Liste des pi�ces qui peuvent bouger (au premier tour)*/
piecesDispoPremierTour(_, [], []) :- !.
piecesDispoPremierTour(Board, [T|Q], [T|Res]) :- position(T,X,Y), allMove(T, Moves), \+isVide(Moves), piecesDispoPremierTour(Board, Q, Res), !.
piecesDispoPremierTour(Board, [T|Q], Res) :- piecesDispoPremierTour(Board, Q, Res).

/* Methode globale qui appelle celle du dessus pour recuperer la liste des pieces dispo au premier tour */
getPieceDispoPremierTour(Player, Res) :- boardSelected(Board), pieces(Player, P), en_vies(P, V), piecesDispoPremierTour(Board, V, Res).

/* Comme pour les autres, on choisit une piece, on choisit ses deplacements et on selectionne le khan */
choixPiecePremierTour(Piece) :- currentPlayer(P), getPieceDispoPremierTour(P, Z), element(Piece,Z), 
write('Choisissez la position X et Y de votre piece parmi les d�placements suivantes'), nl, allMove(Piece,Moves), write(Moves), nl, read(X), flush_output, read(Y),
deplacementPiece(Piece, X, Y, Moves), asserta(khan(Piece)), lancementIA, boucleTourJeu, !.
choixPiecePremierTour(_) :- write('Cette piece nest pas deplacable.'), nl, premierTour.

/************* FIN PREMIER TOUR ********************.


****************** BOUCLE DE JEU : ****************** 
se divise en trois parties. Soit c'est la fin du jeu, soit c'est un tour normal : on change de joueur et on regarde si il a des pieces � deplacer. Si oui on lance un tourRespect, sinon un tour non respect */
boucleTour :- nl,affichage_pion, nl, /*changementPlayer,*/ currentPlayer(X), write('Au tour du joueur : '), write(X), nl, getPieceDispo(X, P), \+isVide(P), tourRespect.
boucleTour :- tourNonRespect.

/* Le jeu est fini si, lors c'est que le tour du joueur , la Khalista des ocres est morte, si c'est le joueur deux celle des rouges */
finDuJeu :- currentPlayer(X), X=1, \+position(kaO, Y, Z), nl.
finDuJeu :- currentPlayer(X), X=2, \+position(kaR, Y, Z), nl.

/* Met � jour le joueur */
changementPlayer :- currentPlayer(1), retract(currentPlayer(1)), asserta(currentPlayer(2)), !.
changementPlayer :- currentPlayer(2), retract(currentPlayer(2)), asserta(currentPlayer(1)).

/* Remet � zero le jeu les faits dynamiques lorsqu'on lance une partie */
remiseZero :- asserta(boardSelected(1)), retractall(boardSelected(_)), 
asserta(khan(1)), retractall(khan(_)),
asserta(currentPlayer(1)), retractall(currentPlayer(_)),
asserta(actifIA(0)), retractall(actifIA(_)),
asserta(profondeur(1)), retractall(profondeur(_)),
asserta(position(Sr1,1,1)), retractall(position(_,_,_)).

 

/* Faits dynamique seulement pour les tests*/
%khan(sR2).
%currentPlayer(1).
%boardSelected([[3,1,2,3,3,1],[2,1,1,2,3,1],[3,1,2,1,3,3],[2,1,2,3,2,1],[3,3,2,1,1,2],[3,2,3,2,1,2]]).
