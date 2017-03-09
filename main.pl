/* 
main.pl
Version : 1.0
Auteur : Gaudefroy Mathilde et Huber Romain

Description : Fonction main. définit les faits et lance le jeu. 
*/

:- include('Joueur.pl').
:- include('utilityFonction.pl').
:- include('IA.pl').

/* GRILLES */
board([[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]).
/* METTRE AU MOINS UN 1 A CHAQUE BORD */
grille(1,[[3,1,2,3,3,1],[1,2,1,2,3,1],[3,1,2,1,3,3],[2,1,2,3,2,1],[3,3,2,1,1,2],[3,2,3,2,1,2]]).
grille(2,[[3,3,2,3,2,3],[2,3,1,1,1,1],[3,2,2,2,1,2],[2,1,3,1,2,3],[1,2,2,3,3,3],[2,1,1,3,1,1]]).
grille(3,[[2,1,2,3,2,3],[2,1,1,2,3,3],[1,2,3,2,1,2],[3,3,1,2,1,3],[1,3,2,1,2,1],[1,3,3,2,1,3]]).
grille(4,[[1,1,3,1,1,2],[3,3,3,2,2,1],[3,2,1,3,1,2],[2,1,2,2,2,3],[1,1,1,1,3,2],[3,2,3,2,3,3]]).

/* PIECES */
pieces([sR1,sR2,sR3,sR4,sR5,kaR, sO1,sO2,sO3,sO4,sO5,kaO]).
pieces(1, [sR1,sR2,sR3,sR4,sR5,kaR]).
pieces(2, [sO1,sO2,sO3,sO4,sO5,kaO]).

/* LANCEMENT DU JEU */
jeu :- write('Bonjour, bienvenue dans le jeu de Khan !'), nl, initBoard.

/** Permet de lancer le jeu */
initBoard :- 
	remiseZero,
	write('Dans quelle position voulez-vous jouer ?'), 
	read(X), 
	grille(X,Y),
	asserta(boardSelected(Y)),
	%positionTest,
	%affichage_pion,
	asserta(currentPlayer(1)),
	askMode,
	actifIA(IA),
	(IA=2 -> premierTourIA, boucleTourJeu; premierTour).

/** Trois modes de jeu : Homme vs Homme, Homme vs IA, IA vs IA **/
askMode :- write('Voulez-vous jouer joueur contre joueur (tapez 1), joueur contre IA ? (tapez 2) ou IA contre IA (tapez 3)'), nl, read(Mode), active(Mode).

/** Si on choisit homme vs IA, on va devoir choisir notre positionnement puis l'IA choisira le sien **/
active(1) :- asserta(actifIA(0)), positionnement(1), positionnement(2), !.
active(2) :- asserta(actifIA(1)), positionnement(1), choosePos(2), choixNiveau, !.
active(3) :- asserta(actifIA(2)), asserta(profondeur(0)), choosePos(1), choosePos(2), !.
active(_) :- write('Veuillez rentrer 1 ou 2'), nl, askMode.

/** Choisir le niveau (donc la profondeur de l'IA). L'algo n'étant pas optimum, on gère jusqu'à 1 de profondeur (2 coups) **/
choixNiveau :- write('Choisissez le niveau de l IA. Son niveau va de 0 à 1'), nl, read(Niveau), choixNiv(Niveau).

choixNiv(X) :-  X<2, X>=0, asserta(profondeur(X)), !.
choixNiv(_) :- write('Veuillez choisir entre 1 et 3'), nl, choixNiveau.

/***** BOUCLE DE JEU *****/
boucleTourJeu :- finDuJeu, currentPlayer(X), write('Felicitation, le joueur '), write(X),  write(' a gagne'), nl, !.
boucleTourJeu :- actifIA(0), changementPlayer, boucleTour, !.
boucleTourJeu :- actifIA(2), changementPlayer, affichage_pion, nl, sleep(5), tourIA, !.
boucleTourJeu :- changementPlayer, currentPlayer(P), P==1, boucleTour, !.
boucleTourJeu :- tourIA.

/** Test **/
lancementTest :- grille(1,Y), asserta(boardSelected(Y)), retractall(boardSelected(_)), asserta(boardSelected(Y)) , positionTest, lancementIA.