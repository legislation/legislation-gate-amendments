%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

% This is the retry strategy for effects parse.
% We know the structure of the amending document, so
% we use that patch parts which failed to parse.
% This is done by adding empty 'Context' for leaf fragments,
% then adding 'BrokenBranch' for fragments which contain sub-parts.

retry:-
	write('Removing ragged context'),nl,
	remove_ragged_context,
	write('Covering leaf fragments'),nl,
	cover_leaf_fragments,
	write('Removing redundant'),nl,
	remove_contained('Context'),
	write('Running parser'),nl,
	once(loop_agenda),
	write('Removing redundant'),nl,
	(debugrun(false)->remove_contained('Context');true),
	(debugrun(false)->thorough_remove_contained('Context');true),
	write('Covering branch fragments'),nl,
	cover_branch_fragments,
	write('Re-running parser'),nl,
	once(loop_agenda).

% Not really part of retrying - but remove context which stops halfway through a LegRefCompound
remove_ragged_context:-
	fsm_end('Context',Vc),
	fsm_end('LegRefCompound',Vr),
	findall(P1-E,(E=edge(P0,P1,Vc,S),call(E)),Cs0),
	findall(E,(E=edge(P0,P1,Vr,S),call(E)),Rs0),
	sort(Cs0,Cs1),
	sort(Rs0,Rs1),
	remove_ragged(Rs1,Cs1).

remove_ragged(_,[]):-!.
remove_ragged([],_):-!.
remove_ragged(Rs0,Cs0):-
	Rs0=[edge(Pr0,_,_,_)|_],
	Cs0=[Pc1-_|Cs1],
	Pc1=<Pr0, % context finishes before legref starts - next context
	!,
	remove_ragged(Rs0,Cs1).
remove_ragged(Rs0,Cs0):-
	Rs0=[edge(_,Pr1,_,_)|Rs1],
	Cs0=[Pc1-_|_],
	Pr1=<Pc1, % legref finishes before context finishes - next legref
	!,
	remove_ragged(Rs1,Cs0).
remove_ragged(Ers0,Ecs0):-
	% Pr0 < Pc1 < Pr1
	%  - retract context - move to next context
	Ecs0=[_-Ec|Ecs1],
	retractall(Ec),
	remove_ragged(Ers0,Ecs1).

cover_leaf_fragments:-
	fsm_end('LegPnumber',V),
	setof(edge(P0,P1,V,S),edge(P0,P1,V,S),Pns),
	make_leaf_fragments(Pns,Leafs),
	assert_leaf_fragments(Leafs),
	%print_term(Leafs,[]),
	!.
	%length(Leafs,N),
	%write(N),nl.
cover_leaf_fragments.  % prev clause may fail at setof

make_leaf_fragments([],[]).
make_leaf_fragments([_],[]):-!.
	% Last fragment is awkward, because we it's liable to drift off into an explanatory note
	% Let's ignore it.  It's not as though it can break anything downstream.
make_leaf_fragments([Na,Nb|Pns],[Leaf|Leafs]):-
	Na=edge(Pa0,_,_,Sa),
	Nb=edge(Pb0,_,_,Sb),
	get_dict(level,Sa,Levela),
	get_dict(level,Sb,Levelb),
	atom_number(Levela,Deptha),
	atom_number(Levelb,Depthb),
	Deptha>=Depthb,
	!, % It's a leaf
	end_of_previous_token(Pb0,Pc1),
	fsm_end('Leaf',V),
	Leaf=edge(Pa0,Pc1,V,s{depth:Deptha,ll:words,body:[]}),
	make_leaf_fragments([Nb|Pns],Leafs).
make_leaf_fragments([_|Pns],Leafs):-
	make_leaf_fragments(Pns,Leafs).

assert_leaf_fragments([]).
assert_leaf_fragments([Leaf|Leafs]):-
	Leaf=edge(P0,P1,_,_),
	fsm_end('Context',Vc),
	edge(P0,P1,Vc,_),
	%format('Context ~w\n',[Leaf]),
	!,
	assert_leaf_fragments(Leafs).
assert_leaf_fragments([Leaf|Leafs]):-
	%format('Adding ~w\n',[Leaf]),
	Leaf=edge(P0,P1,_,S),
	fsm_end('Context',Vc),
	Context=edge(P0,P1,Vc,S),
	add_to_agenda(Leaf),
	add_to_agenda(Context),
	assert_leaf_fragments(Leafs).

% P0 is end of token at or before P1
end_of_previous_token(P1,P0):-
	gap(P0,P1),
	!.
end_of_previous_token(P,P).

cover_branch_fragments:-
	fsm_end('Context',Vc),
	setof(context(P0,P1),S^edge(P0,P1,Vc,S),Cs),
	context_holes(Cs,Hs),
	%print_term(Hs,[]),
	fsm_end('LegPnumber',Vpn),
	setof(pn(P0,P1,D),S^L^(edge(P0,P1,Vpn,S),get_dict(level,S,L),atom_number(L,D)),Pns),
	%print_term(Pns,[]),
	make_branch_fragments(Pns,Frags),
	%print_term(Frags,[]),
	frags_in_holes(Hs,Frags,FragsInHoles),
	%print_term(FragsInHoles,[]),
	assert_branch_fragments(FragsInHoles),
	!.
cover_branch_fragments.

% Holes are the gaps between Contexts
% This only works properly after removing overlapping contexts
context_holes([C1,C2|Cs],[H|Hs]):-
	C1=context(_,P1),
	C2=context(P2,_),
	\+equivalent_place(P1,P2),
	!,
	H=hole(P1,P2),
	context_holes([C2|Cs],Hs).
context_holes([_|Cs],Hs):-
	!,
	context_holes(Cs,Hs).
context_holes([],[]):-!.

make_branch_fragments([],[]):-!.
make_branch_fragments([Pna,Pnb|Pns],[Frag|Frags]):-
	Pna=pn(Pa0,Pa1,Da),
	Pnb=pn(Pb0,_Pb1,Db),
	\+equivalent_place(Pa1,Pb0),
	Da<Db,
	!,
	Frag=frag(Pa0,Pb0,Da),
	make_branch_fragments(Pns,Frags).
make_branch_fragments([_|Pns],Frags):-
	!,
	make_branch_fragments(Pns,Frags).

frags_in_holes([],_,[]):-!.
frags_in_holes(_,[],[]):-!.
frags_in_holes(Holes,[Frag|Frags0],[Frag|Frags1]):-
	Holes=[hole(Ph0,Ph1)|_],
	Frag=frag(Pf0,Pf1,_),
	Ph0=<Pf0,
	Pf1=<Ph1,
	!, % Frag within hole; next Frag
	frags_in_holes(Holes,Frags0,Frags1).
frags_in_holes([hole(_,Ph1)|Holes],Frags0,Frags1):-
	Frags0=[frag(_,Pf1,_)|_],
	Ph1<Pf1,
	!, % Hole ends before Frag ends; next hole
	frags_in_holes(Holes,Frags0,Frags1).
frags_in_holes(Holes,[Frag|Frags0],Frags1):-
	Holes=[hole(Ph0,_)|_],
	Frag=frag(Pf0,_,_),
	Pf0<Ph0,
	!, % Frag starts before hole starts; next frag
	frags_in_holes(Holes,Frags0,Frags1).

assert_branch_fragments([]).
assert_branch_fragments([Frag|Frags]):-
	Frag=frag(P0,P1,D),
	%format('Adding ~w\n',[Frag]),
	fsm_end('BrokenBranch',V),
	Edge=edge(P0,P1,V,s{body:[],depth:D}),
	add_to_agenda(Edge),
	assert_branch_fragments(Frags).
