/* 
utilityFonction
Version : 1.0
Auteur : Gaudefroy Mathilde et Huber Romain

Description : contient l'ensemble des fonctions qui ne sont pas clé dans le sujet mais qui permettent le fonctionnement des autres.
*/

/* Concactene deux listes */
concat([], L2, L2).
concat([T|Q], L2, [T|L]) :- concat(Q, L2, L).

/* Renvoie la position d'un element dans une liste */
element_at(X,[X|_],1).
element_at(X,[_|L],K) :- element_at(X,L,K1), K is K1 + 1.

/* Renvoie vrai si l'element se situe dans la liste */
element(X, [X|_]).
element(X, [T|Q]) :- element(X,Q).

/* Renvoie le nombre de position, pour la duplication lors de l'IA */
countPosi(X) :-
    findall(X, position(X,Y,Z), Z),
    length(Z, X).

/* Verifie qu'une liste est vide (pas sur qu'on l'utilise) */
isVide([]).

/* Pion en vie, on envoie la liste des pièces rouges ou des pièces ocre, n regarde si elles ont une pos */
en_vies([], []).
en_vies([T|Q], [T|Res]) :- position(T,_,_), en_vies(Q, Res), !.
en_vies([_|Q], V) :- en_vies(Q, V).

/* Renvoie la liste des pieces mortes. On envoie la lsite des peices ocre ou ou rouge et on regarde si elles ont une pos */
getPieceMorte([], []).
getPieceMorte([T|Q], [T|Res]) :- \+position(T,_,_), getPieceMorte(Q, Res), !.
getPieceMorte([_|Q], V) :- getPieceMorte(Q, V).

/* Renvoie la valeur de la case à la position [X,Y] */
get_mvmts(G,X,Y,R) :- element_at(Z,G,X), element_at(R,Z,Y).

/* Renvoie le mouvement sur laquelle une pièce est posée */
get_mvmtsPiece(Piece, Moves) :- boardSelected(B), position(Piece,X,Y), get_mvmts(B,X,Y,Moves).

/* Ajout de position pour tester rapidement */
positionTest :- retractall(position(_,_,_)),
				asserta(position(sR1, 1, 2)), asserta(position(sR2, 1, 1)), asserta(position(sR3, 1, 3)), asserta(position(sR4, 1, 4)), asserta(position(sR5, 1, 5)), asserta(position(kaR, 1, 6)), 
				asserta(position(sO1, 6, 2)), asserta(position(sO2, 5, 2)), asserta(position(sO3, 5, 3)), asserta(position(sO4, 5, 4)),asserta(position(sO5, 5, 5)) , asserta(position(kaO, 6, 6)).
				


/*Répond non si il n'y a pas de pièece en [X,Y] */
verifPos(_,X,Y) :- \+position(_,X,Y), X =< 6, X >= 1, Y =< 6, Y >= 1.

 /* Verifie que les pos rentrées par le joueur au début sont valide, par exemple le joueur 1 doit se situer dans les deux premiers lignes et le 2 entre les deux dernières */
verifPosStart(P,X,Y) :- \+position(_,X,Y), pieces(1,Z), element(P,Z), X =< 2, X >= 1, Y =< 6, Y >= 1,!.
verifPosStart(P,X,Y) :- \+position(_,X,Y), pieces(2,Z), element(P,Z), X =< 6, X >= 5, Y =< 6, Y >= 1,!.
/*verifPosStart(P,_,_) :- write('Position invalide, X = [1..2] si vous êtes rouges et [5..6] si vous êtes ocre et Y = [1..6] et la position ne doit pas être déjà prise'), nl, choix_pion(P, X, Y).*/

/* Demande la position pour un pion */
choix_pion(P, X, Y) :- write('Choisissez la position pour le pion '), write(P), nl, read(X), read(Y), verifPosStart(P,X,Y), !.
choix_pion(P,X,Y) :-  write('Position invalide, X = [1..2] si vous êtes rouges et [5..6] si vous êtes ocre et Y = [1..6] et la position ne doit pas être déjà prise'), nl, choix_pion(P,X,Y).

/* Demande pour chaque pion et ajoute leur position dans un fait position(Pion,ligne,colonne) */	
choix_pions([]).					
choix_pions([P|Q]) :- choix_pion(P, X, Y), asserta(position(P, X, Y)), 	choix_pions(Q).

/* Lance la procédure de positionnement des pièces */
positionnement(Player) :- asserta(position(res,-1,-1)), retractall(position(res,-1,-1)), pieces(Player, X), choix_pions(X).

/* Supprime une pièce qui a pour nom N */
delete_piece(N) :- retract(position(N,_,_)).

/* Deplace la pièce N vers la position [X,Y], en supprimant la pièce à cette pos si elle existe */
deplacer_piece(N,X,Y) :- position(N,X,Y), !.
deplacer_piece(N,X,Y) :- \+verifPos(_,X,Y), retract(position(_,X,Y)), retract(position(N,_,_)), asserta(position(N,X,Y)), !.
deplacer_piece(N,X,Y) :- retract(position(N,_,_)),asserta(position(N,X,Y)).

/* AFFICHAGE DE LA GRILLE */
affiche_lignes([]).
affiche_lignes([L|G]) :- write('| '), affiche_ligne(L), nl, affiche_lignes(G).

affiche_ligne([]).
affiche_ligne([X|L]) :- write(X), write(' | '), affiche_ligne(L).

%affiche_grille([]).
affiche_grille :- boardSelected(G), affiche_lignes(G).

/* AFFICHAGE DES POSITIONS CHANGER AFFICHAGE */
affichage_pos(X,Y) :- khan(K), position(K,X,Y), boardSelected(G), get_mvmts(G,X,Y,R), write(K), write('*'), write('  '), write(R), !.
affichage_pos(X,Y) :- position(Z,X,Y), boardSelected(G), get_mvmts(G,X,Y,R), write(Z), write('   '), write(R), !.
affichage_pos(X,Y) :- boardSelected(G), get_mvmts(G,X,Y,R),  write('   '), write(R), write('   ').


affichage_pos_ligne(X) :- write('| '), 	affichage_pos(X,1), write(' | '),
										affichage_pos(X,2), write(' | '),
										affichage_pos(X,3), write(' | '),
										affichage_pos(X,4), write(' | '),
										affichage_pos(X,5), write(' | '),
										affichage_pos(X,6), write(' | '), nl.

affichage_pion(X) :- X < 0, !.
affichage_pion(X) :- X > 6, !.
affichage_pion :- 	write('  |    1    |    2    |    3    |    4    |    5    |    6    |'), nl,
					write('---------------------------------------------------------------'), nl,
					write('1 '), affichage_pos_ligne(1), 
					write('---------------------------------------------------------------'), nl,
					write('2 '),affichage_pos_ligne(2), 
					write('---------------------------------------------------------------'), nl,
					write('3 '),affichage_pos_ligne(3), 
					write('---------------------------------------------------------------'), nl,
					write('4 '),affichage_pos_ligne(4), 
					write('---------------------------------------------------------------'), nl,
					write('5 '),affichage_pos_ligne(5), 
					write('---------------------------------------------------------------'), nl,
					write('6 '),affichage_pos_ligne(6),
					write('---------------------------------------------------------------'), nl.
					

/* Mouvement disponible possibleMoves(Board, Player, Piece, PossibleMove) */
movesDispo(_,0, Player, X, Y, [X,Y]) :- position(T,X,Y), pieces(Player, P), \+element(T,P), !.

movesDispo(Piece, 0, Player, X, Y, [X,Y]) :- position(T,X,Y), T == Piece, !.

movesDispo(_, 0,_, X, Y,[X,Y]) :- X>0, Y>0, X<7, Y<7, \+position(T,X,Y), !.

movesDispo(P, C,Player, X, Y, Res) :- X1 is X-1, C=\=0, X1>0, Y>0, X1<7, Y<7, checkMove(P,X1,Y), C1 is C-1, movesDispo(P, C1,Player,X1,Y, Res).

movesDispo(P, C,Player, X, Y, Res) :- X1 is X+1, C=\=0, X1>0, Y>0, X1<7, Y<7, checkMove(P,X1,Y), C1 is C-1, movesDispo(P, C1,Player,X1,Y, Res).

movesDispo(P, C,Player, X, Y, Res) :- Y1 is Y-1, C=\=0, X>0, Y>0, X<7, Y1<7, checkMove(P,X,Y1), C1 is C-1, movesDispo(P, C1,Player,X,Y1, Res).

movesDispo(P, C,Player, X, Y, Res) :- Y1 is Y+1, C=\=0, X>0, Y>0, X<7, Y1<7, checkMove(P,X,Y1), C1 is C-1, movesDispo(P, C1,Player,X,Y1, Res).

movesDispo(P, C,Player, X, Y, Res) :- X1 is X-1, C=\=0, X1>0, Y>0, X1<7, Y<7, C1 is C-1, C1=0, movesDispo(P, C1,Player,X1,Y, Res).

movesDispo(P, C,Player, X, Y, Res) :- X1 is X+1, C=\=0, X1>0, Y>0, X1<7, Y<7, C1 is C-1, C1=0, movesDispo(P, C1,Player,X1,Y, Res).

movesDispo(P, C,Player, X, Y, Res) :- Y1 is Y-1, C=\=0, X>0, Y>0, X<7, Y1<7, C1 is C-1, C1=0, movesDispo(P, C1,Player,X,Y1, Res).

movesDispo(P, C,Player, X, Y, Res) :- Y1 is Y+1, C=\=0, X>0, Y>0, X<7, Y1<7, C1 is C-1, C1=0, movesDispo(P, C1,Player,X,Y1, Res).

/* Verifie que le move est bon */
checkMove(Piece, X, Y) :- \+position(T,X,Y), !.
checkMove(Piece, X, Y) :- position(T,X,Y), T == Piece.

/* Liste des pièces qui peuvent bouger (valeur Mov, liste piece rouge ou ocre, piece dispo*/
piecesDispo(_,_, [], []) :- !.
piecesDispo(Board, Mov, [T|Q], [T|Res]) :- position(T,X,Y), get_mvmts(Board, X, Y, M), M = Mov, allMove(T, Moves), \+isVide(Moves), piecesDispo(Board, Mov, Q, Res), !.
piecesDispo(Board, Mov, [T|Q], Res) :- piecesDispo(Board, Mov, Q, Res).