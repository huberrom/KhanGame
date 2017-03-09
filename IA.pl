/* 
IA.pl
Version : 1.0
Auteur : Gaudefroy Mathilde et Huber Romain

Description : contient l'ensemble des fonctions de l'IA. Création du plateau virtuel, calcule du score du plateau, algorithme minmax etc...
De nombreuses fonctions sont des copier-coller des fonctions pour permettre le fonctionnement du joueur, mais en utilisant les faits dynamique de l'IA (positionTest, khanTest, etc..).
*/

/** Permet un choix aleatoire dans une liste d'element **/
choose([], []).
choose(List, Elt) :-
        length(List, Length),
        random(0, Length, Index),
        nth0(Index, List, Elt).

/** Position disponible de départ pour le joueur 1 et le joueur 2 **/
posDispo(1, [[1,1],[1,2],[1,3],[1,4],[1,5],[1,6],[2,1],[2,2],[2,3],[2,4],[2,5],[2,6]]).
posDispo(2, [[5,1],[5,2],[5,3],[5,4],[5,5],[5,6],[6,1],[6,2],[6,3],[6,4],[6,5],[6,6]]).

/** Gere le placement aléatoire de toutes les pièces de la liste envoyé en paramètre, selon le numéro du joueur **/
placementIA(_, []) :- !.
placementIA(Player, [T|Q]) :- posDispo(Player, Pos), choose(Pos, [X,Y]), \+position(_,X,Y), asserta(position(T,X,Y)), !, placementIA(Player,Q).
placementIA(Player, X) :-  placementIA(Player, X).

/** Positionnement de toutes les pièces d'un joueur envoyé en paramètre **/
choosePos(Player) :- asserta(position(sR10,10,20)), retract(position(sR10,10,20)), pieces(Player,P), placementIA(Player,P).


/* Mouvement disponible possibleMovesIA(Piece, Compteur, Joueur, Positionnement X, Positionnement Y, Resultat) */
movesDispoIA(_,0, Player, X, Y, [X,Y]) :- positionTest(T,X,Y), pieces(Player, P), \+element(T,P), !.

movesDispoIA(Piece, 0, Player, X, Y, [X,Y]) :- positionTest(T,X,Y), T == Piece, !.

movesDispoIA(_, 0,_, X, Y,[X,Y]) :- X>0, Y>0, X<7, Y<7, \+positionTest(T,X,Y), !.

movesDispoIA(P, C,Player, X, Y, Res) :- X1 is X-1, C=\=0, X1>0, Y>0, X1<7, Y<7, checkMoveIA(P,X1,Y), C1 is C-1, movesDispoIA(P, C1,Player,X1,Y, Res).

movesDispoIA(P, C,Player, X, Y, Res) :- X1 is X+1, C=\=0, X1>0, Y>0, X1<7, Y<7, checkMoveIA(P,X1,Y), C1 is C-1, movesDispoIA(P, C1,Player,X1,Y, Res).

movesDispoIA(P, C,Player, X, Y, Res) :- Y1 is Y-1, C=\=0, X>0, Y>0, X<7, Y1<7, checkMoveIA(P,X,Y1), C1 is C-1, movesDispoIA(P, C1,Player,X,Y1, Res).

movesDispoIA(P, C,Player, X, Y, Res) :- Y1 is Y+1, C=\=0, X>0, Y>0, X<7, Y1<7, checkMoveIA(P,X,Y1), C1 is C-1, movesDispoIA(P, C1,Player,X,Y1, Res).

movesDispoIA(P, C,Player, X, Y, Res) :- X1 is X-1, C=\=0, X1>0, Y>0, X1<7, Y<7, C1 is C-1, C1=0, movesDispoIA(P, C1,Player,X1,Y, Res).

movesDispoIA(P, C,Player, X, Y, Res) :- X1 is X+1, C=\=0, X1>0, Y>0, X1<7, Y<7, C1 is C-1, C1=0, movesDispoIA(P, C1,Player,X1,Y, Res).

movesDispoIA(P, C,Player, X, Y, Res) :- Y1 is Y-1, C=\=0, X>0, Y>0, X<7, Y1<7, C1 is C-1, C1=0, movesDispoIA(P, C1,Player,X,Y1, Res).

movesDispoIA(P, C,Player, X, Y, Res) :- Y1 is Y+1, C=\=0, X>0, Y>0, X<7, Y1<7, C1 is C-1, C1=0, movesDispoIA(P, C1,Player,X,Y1, Res).

/** Verifie qu'on peut se deplacer. On peut y aller si il n'y a rien dessus ou si celui qui est dessus est la pièce elle même. */
checkMoveIA(Piece, X, Y) :- \+positionTest(T,X,Y), !.
checkMoveIA(Piece, X, Y) :- positionTest(T,X,Y), T == Piece.

/** Renvoie l'ensemble d'un mouvement d'une pièce **/
allMoveIA(Piece, Player, []) :- positionTest(Piece, X, Y),  get_mvmtsPiece(Piece, M), \+movesDispoIA(Piece,M,Player,X,Y,S), !.
allMoveIA(Piece, Player, Res) :- positionTest(Piece, X, Y),  get_mvmtsPiece(Piece, M), setof(S, movesDispoIA(Piece,M,Player,X,Y,S), Res).

/** Renvoie la liste des pièces disponibles par rapport à la liste nevoyé en parametre et le mouvement du Khan. Une pièce est disponible si elle peut se déplacer. **/
piecesDispoIA(_,_,_, [], []) :- !.
piecesDispoIA(Board, Player, Mov, [T|Q], [T|Res]) :- positionTest(T,X,Y), get_mvmts(Board, X, Y, M), M = Mov, allMoveIA(T, Player, Moves), \+isVide(Moves), piecesDispoIA(Board, Player, Mov, Q, Res), !.
piecesDispoIA(Board, Player, Mov, [T|Q], Res) :- piecesDispoIA(Board, Player, Mov, Q, Res).

/** Renvoie la liste des pièces disponible pour un joueur. Si aucune pièce est disponible en respectant le khan, alors toutes les pièces qui ont un mouvement disponible sont dispo **/
getPieceDispoIA(Player, Res) :- boardSelected(Board), khanIA(K), positionTest(K, X, Y), get_mvmts(Board, X, Y, M), pieces(Player, P), en_viesIA(P, V), piecesDispoIA(Board, Player, M, V, Res), Res \= [], !.
getPieceDispoIA(Player, Res) :- boardSelected(Board), khanIA(K), positionTest(K, X, Y), get_mvmts(Board, X, Y, M), pieces(Player, P), en_viesIA(P, EV), getPieceDeplacable(EV, Player, Res).

/** Renvoie la liste des pièces deplacable, càd qui, sans respecter, peuvent se déplacer */
getPieceDeplacable([], _, []) :- !.
getPieceDeplacable([T|Q], Player, [T|Res]) :- allMoveIA(T, Player, Move), \+isVide(Move), getPieceDeplacable(Q, Player, Res), !.
getPieceDeplacable([T|Q], Player, Res) :- getPieceDeplacable(Q, Player, Res).

/* Duplique les pos du vrai jeu */
duplicateCurrentPos :- position(X,Y,Z), \+positionTest(X,Y,Z), asserta(positionTest(X,Y,Z)), duplicateCurrentPos.
duplicateCurrentPos :- countPosi(X), countPosiTest(Y), X > Y, duplicateCurrentPos.
duplicateCurrentPos :- countPosi(X), countPosiTest(Y), X =< Y.

/* Renvoie le nombre de position test */
countPosiTest(X) :-
    findall(X, positionTest(X,Y,Z), Z),
    length(Z, X).
	

/* Renvoie la liste des moves dispo pour une liste de pieces données */
getMovesDispoIA([], _,[]) :- !.
getMovesDispoIA([T|Q], Player, Res3 ):- allMoveIA(T, Player, Res), getMovesDispoIA(Q, Player, Res2), concat([T], Res, PionMove), concat([PionMove], Res2, Res3).  


/* Renvoie pour un joueur la liste de ses pieces dispo avec les moves dispo pour chaque piece */
allMoveDispoIA(Player, Res) :- getPieceDispoIA(Player, R), getMovesDispoIA(R, Player, Res).

/* Fonction d'évaluation : Calculer le nombre de piece restant chez l'adversaire, chez soi, la distance avec la khalista et voir si il lui reste des mov dispo */
calculScorePlateau(Player, NbCoupsRestants, Resultat) :- 	Score=0, (victoireIA(Player) -> ScoreVictoire is Score+10000 ; ScoreVictoire is Score), 
															getAdversaire(Player, Adv), (victoireIA(Adv) -> ScoreDefaite is ScoreVictoire-10000 ; ScoreDefaite is ScoreVictoire),
															distanceKalista(Player, DistanceSaKalista), Distancex10 is DistanceSaKalista*10,
															distanceKalista(Adv, DistanceMaKalista), DistanceNegKal is -DistanceMaKalista, 
															DistanceKal is Distancex10+(DistanceNegKal-2)*10,
															ScoreDistance is ScoreDefaite+DistanceKal*NbCoupsRestants,
															scoreNbPiece(Player, Res),
															allMoveDispoIA(Adv, AllMoveRes),
															length(AllMoveRes, NumberMove),
															scoreDeplacement(Adv, NumberMove, ScoreD),
															Resultat is ScoreDistance+Res+ScoreD.

/** Calcule un score de déplacement, plus le joueur adversaire a de mouvement disponibles, moins bien c'est pour nous. Si il n'a aucun mouvement disponible (en respectant le khan), on renvoie une très grosse valeur car cela veut dire qu'il peut bouger n'importe quelle pièce ou remettre une pièce sur le jeu */												scoreDeplacement(Adv, _, -7000) :- \+respectKhan(Adv), !.
scoreDeplacement(_, NumberMove, Score) :- NegMove is -NumberMove, Score is NegMove*10.					

/** Verifie si le joueur peut respecter le khan à ce tour **/
respectKhan(Player) :- pieces(Player, P), en_viesIA(P, Res), khanIA(X), get_mvmtsPieceIA(X, M), pieceRespect(M, Res, Bool), Bool \= 0.

/** Calcule le nombre de pièce qui respecte le khan, si le nobmre vaut 0 alors respectKhan renverra faux */
pieceRespect(_, [], 0) :- !.
pieceRespect(M, [T|Q], Bool) :- get_mvmtsPieceIA(T, MT), M == MT, pieceRespect(M,Q, Res), Bool is Res+1, !.
pieceRespect(M, [T|Q], Bool) :- pieceRespect(M, Q, Bool).

/** permet de recuperer le numéro de l'adversaire. Si le joueur est 1, l'adversaire sera 2 et vice versa **/
getAdversaire(1, 2).
getAdversaire(2, 1).

/** Calcule un score pour le nombre de pièce. Elle correspond à la différence entre notre nombre de pièce et celui de l'adversaire **/						 
scoreNbPiece(1, Res) :- pieces(1,P1), en_viesIA(P1, V), pieces(2,P2), en_viesIA(P2, VA), length(V, SizeV), length(VA, SizeVa), Res is SizeV*100-SizeVa*100.
scoreNbPiece(2, Res) :- pieces(2,P1), en_viesIA(P1, V), pieces(1,P2), en_viesIA(P2, VA), length(V, SizeV), length(VA, SizeVa), Res is SizeV*100-SizeVa*100.			 

/** Vérifie si la partie est finie en regardant si la kalista adversaire est en vie **/
victoireIA(1) :- \+positionTest(kaO, _, _).
victoireIA(2) :- \+positionTest(kaR, _, _).

/* Donne la distance du pion le plus proche de la kalista adverse si elle est en vie, sinon 0 */
distanceKalista(1, 0) :- pieces(2, R), en_viesIA(R, V), \+element(kaO, V), !.
distanceKalista(2, 0) :- pieces(1, O), en_viesIA(O, V), \+element(kaR, V), !.
distanceKalista(Player, Distance) :- pieces(Player, P), en_viesIA(P, V), distanceMinKalista(Player, V, Distance).

/* Calcule la distance pour chaque pion et garde le minimum */
distanceMinKalista(_, [], 1000) :- !.
distanceMinKalista(Player, [T|Q], Distance) :- calculeDistance(Player, T, D), distanceMinKalista(Player, Q, D1), Distance is min(D,D1).

/* Calcule la distance entre un pion et la kalista et garde le minimum */
calculeDistance(1, Pion, Res) :- 
	positionTest(Pion, X, Y), positionTest(kaO, X1, Y1),  
	DistanceX is X - X1,
    valAbs(DistanceX,XAbs),
    DistanceY is Y - Y1,
    valAbs(DistanceY, YAbs),
    Res is XAbs + YAbs.

calculeDistance(2, Pion, Res) :- positionTest(Pion, X, Y), positionTest(kaR, X1, Y1),  
	DistanceX is X - X1,
    valAbs(DistanceX,XAbs),
    DistanceY is Y - Y1,
    valAbs(DistanceY, YAbs),
    Res is YAbs + XAbs.
	
/*Renvoie la valeur absolue de Val dans Res*/
valAbs(Val, Res) :- Val<0, Res is -Val, !.
valAbs(Val, Val).

/* Simuler coup (Piece, position X où on va, position Y où on va, position X où on est , position Y où on est et M renvoie un nuéro si une pièce est morte quand on s'est deplacé.
Les trois derniers parametres permettent de remettre en place l'état du jeu après avoir calculer le score pour le coup. */
simuler_coup(Piece,X1,Y1,X1,Y1, _) :- positionTest(Piece,X1, Y1), !.
simuler_coup(Piece,X1,Y1,X2,Y2, M1) :- M1\=0, positionTest(Piece,X2, Y2), deplacer_pieceIA(Piece,X1,Y1), pieceMorte(M1, P, XP, YP), asserta(positionTest(P,XP,YP)), !.
simuler_coup(Piece,X1,Y1,X2,Y2, M1) :- positionTest(P,X1, Y1),  numMorte(M), retract(numMorte(M)), M1 is M+1, asserta(numMorte(M1)), asserta(pieceMorte(M1, P, X1, Y1)), positionTest(Piece,X2, Y2), deplacer_pieceIA(Piece,X1,Y1), !.
simuler_coup(Piece,X1,Y1,X2,Y2, _) :- positionTest(Piece,X2, Y2), deplacer_pieceIA(Piece,X1,Y1).

/** Permet de renvoyer le khan actuel et de le modifier par celui qu'on a actuellement **/
simuler_khan(Piece, OldKhan) :- khanIA(OldKhan), retract(khanIA(OldKhan)), asserta(khanIA(Piece)).

/** Deplace une pièce virtuellement **/
deplacer_pieceIA(N,X,Y) :- \+verifPosIA(_,X,Y), retract(positionTest(N,_,_)),retract(positionTest(_,X,Y)),asserta(positionTest(N,X,Y)), !.
deplacer_pieceIA(N,X,Y) :- retract(positionTest(N,_,_)),asserta(positionTest(N,X,Y)).

/** Verifie qu'on peut la déplacer à cet endroit **/
verifPosIA(_,X,Y) :- \+positionTest(_,X,Y), X =< 6, X >= 1, Y =< 6, Y >= 1.

/* Renvoie le mouvement sur laquelle une pièce est posée */
get_mvmtsPieceIA(Piece, Moves) :- boardSelected(B), positionTest(Piece,X,Y), get_mvmts(B,X,Y,Moves).

/* Pion en vie, on envoie la liste des pièces rouges ou des pièces ocre, n regarde si elles ont une pos */
en_viesIA([], []).
en_viesIA([T|Q], [T|Res]) :- positionTest(T,_,_), en_viesIA(Q, Res), !.
en_viesIA([_|Q], V) :- en_viesIA(Q, V).

/* PROFONDEUR SERA LE NIVEAU DE L'IA, ON DEMANDERA UN CHIFFRE ENTRE 1 ET 10 (MAX A TESTER) AU JOUEUR AU DEBUT */
lancementIA :- asserta(positionTest(sR1,1,2)), retractall(positionTest(_,_,_)), duplicateCurrentPos, asserta(khanIA(sR2)), retractall(khanIA(_)), asserta(pieceMorteIA(1, sR1, 1, 1)), retractall(pieceMorteIA(_,_,_,_)), asserta(numMorte(0)).

/* Refresh l'IA. Remet à jour les positions virtuelles et le khan virtuel */
refreshIA :- retractall(positionTest(_,_,_)), duplicateCurrentPos, khan(X), retractall(khanIA(_)), asserta(khanIA(X)).

/** Premier tour **/
premierTourIA :- asserta(khan(sR1)), lancementIA, affichage_pion, nl, boucleTourJeu.



/** BOUCLE DE L'IA QUI DEPLACERA UNE PIECE **/
tourIA :- refreshIA, currentPlayer(P), bestMoveIA(P, X, Y, Piece, Score), !, write('Score : '), write(Score), write(' '), write('Deplace la piece : '), write(Piece), write(', vers la position : ['), write(X), write(','), write(Y), write(']'), nl, deplacer_piece(Piece, X, Y), retract(khan(_)), asserta(khan(Piece)), boucleTourJeu.

/** ALGORITHME MIN MAX; Recupere le meilleur mouvement selon un score pour le joueur **/
bestMoveIA(Player, X, Y, Piece, Score) :- allMoveDispoIA(Player,AM), getBestMoveJoueur(Player, AM, X, Y, Score, Piece).

/** On va tester pour la liste de mouvement lequel est le meilleur. La liste est sous la forme [[Piece, [Mouvements]], [Piece2, [Mouvements2]], ...] **/
getBestMoveJoueur(_, [], _, _, -1000000, _) :- !. 
getBestMoveJoueur(Player, [[T|Q1]|Q2], X, Y, Score, Piece) :- 
													   getBestMovePion(Player, T, Q1, X1, Y1, ScorePion),
													   getBestMoveJoueur(Player, Q2, X2, Y2, ScorePion2, PieceMove),
													   BestScore is max(ScorePion,ScorePion2),
													   (BestScore is ScorePion2 -> Score=ScorePion2, X=X2, Y=Y2, Piece=PieceMove; Score=ScorePion, X=X1, Y=Y1, Piece=T).

/** Pour chaque pion on va simuler le mouvement (donc le déplacer, puis lancer l'algorithme minmax qui s'occupera lui aussi de simuler à tour de rôle pour l'adversaire puis pour le joueur jusqu'à une profondeur donnée. Une fois qu'on a calculé le score, on remet en place et on test une nouvelle pièce **/												   
getBestMovePion(_, _, [], _, _, -1000000) :- !.
getBestMovePion(Player, Piece, [[PX,PY]|Q], X, Y, Score) :- simuler_coup(Piece, PX, PY, SX, SY, M),
															simuler_khan(Piece, OldKhan),
															getAdversaire(Player, Adv),
															profondeur(Prof),
															minBoucle(Adv, Prof, ScoreMin),
															simuler_coup(Piece, SX, SY, _, _, M),
															simuler_khan(OldKhan, _),
															getBestMovePion(Player, Piece, Q, X1, Y1, ScorePion),
															BestScore is max(ScoreMin,ScorePion),
															(BestScore is ScoreMin -> Score=ScoreMin, X=PX, Y=PY; Score=ScorePion, X=X1, Y=Y1).


/************* MIN **************/															
minBoucle(Player, 0, ScoreMin) :-  getAdversaire(Player, Adv), calculScorePlateau(Adv, 1, ScoreMin), !.
minBoucle(Player, Profondeur, ScoreMin) :- allMoveDispoIA(Player,AM), Profondeur1 is Profondeur-1, minJoueur(Player, AM, Profondeur1, ScoreMin).

minJoueur(_,[],_,1000000) :- !.
minJoueur(Player, [[T|Q1]|Q2], Profondeur, Score) :- 	minPion(Player, T, Q1, Profondeur, ScorePion),
														minJoueur(Player, Q2, Profondeur, ScorePion2),
														BestScore is min(ScorePion,ScorePion2),
														(BestScore is ScorePion2 -> Score=ScorePion2; Score=ScorePion).

minPion(_, _, [], _, 1000000) :- !.
minPion(Player, Piece, [[PX,PY]|Q], Profondeur, Score) :-   simuler_coup(Piece, PX, PY, SX, SY, M),
															simuler_khan(Piece, OldKhan),
															getAdversaire(Player, Adv),
															maxBoucle(Adv, Profondeur, ScoreMax),
															simuler_coup(Piece, SX, SY, _, _, M),
															simuler_khan(OldKhan, _),
															minPion(Player, Piece, Q, Profondeur, ScorePion),
															BestScore is min(ScoreMax, ScorePion),
															(BestScore is ScoreMax -> Score=ScoreMax; Score=ScorePion).
							
							
/************ MAX *************/
maxBoucle(Player, 0, ScoreMax) :- calculScorePlateau(Player, 1, ScoreMax), !.
maxBoucle(Player, Profondeur, ScoreMax) :-  allMoveDispoIA(Player,AM),Profondeur1 is Profondeur-1, maxJoueur(Player, AM, Profondeur1, ScoreMax).

maxJoueur(_,[],_,-1000000) :- !.
maxJoueur(Player, [[T|Q1]|Q2], Profondeur, Score) :- 	%getAdversaire(Player, Adv),
														%minBoucle(Adv, Profondeur, ScorePion),
														maxPion(Player, T, Q1, Profondeur, ScorePion),
														maxJoueur(Player, Q2, Profondeur, ScorePion2),
														BestScore is max(ScorePion,ScorePion2),
														(BestScore is ScorePion2 -> Score=ScorePion2; Score=ScorePion).

maxPion(_, _, [], _, -1000000) :- !.
maxPion(Player, Piece, [[PX,PY]|Q], Profondeur, Score) :-   simuler_coup(Piece, PX, PY, SX, SY, M),
															simuler_khan(Piece, OldKhan),
															getAdversaire(Player, Adv),
															minBoucle(Adv, Profondeur, ScoreMin),
															simuler_coup(Piece, SX, SY, _, _, M),
															simuler_khan(OldKhan, _),
															maxPion(Player, Piece, Q, Profondeur, ScorePion),
															BestScore is max(ScoreMin, ScorePion),
															(BestScore is ScoreMin -> Score=ScoreMin; Score=ScorePion).
												


/* L'algorithme sur lequel on s'est basé pour faire notre IA 

fonction Max : entier

     si profondeur = 0 OU fin du jeu alors
          renvoyer eval(etat_du_jeu)

     max_val <- -infini

     Pour tous les coups possibles
          simuler(coup_actuel)
          val <- Min(etat_du_jeu, profondeur-1)

          si val > max_val alors
               max_val <- val
          fin si

          annuler_coup(coup_actuel)
     fin pour

     renvoyer max_val
fin fonction


fonction Min : entier

     si profondeur = 0 OU fin du jeu alors
          renvoyer eval(etat_du_jeu)

     min_val <- infini

     Pour tous les coups possibles
          simuler(coup_actuel)
          val <- Max(etat_du_jeu, profondeur-1)

          si val < min_val alors
               min_val <- val
          fin si

          annuler_coup(coup_actuel)
     fin pour

     renvoyer min_val
fin fonction

fonction jouer : void
     max_val <- -infini

     Pour tous les coups possibles
          simuler(coup_actuel)
          val <- Min(etat_du_jeu, profondeur)
     
          si val > max_val alors
               max_val <- val
               meilleur_coup <- coup_actuel
          fin si
     
          annuler_coup(coup_actuel)
     fin pour

     jouer(meilleur_coup)
fin fonction*/