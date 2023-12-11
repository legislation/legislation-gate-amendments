%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

:-op(800,xfx,'==>').
:-op(790,xfx,':=').
:-op(790,xfx,':==').
:-op(790,xfx,'+=').
:-op(660,xfy,'~').
:-op(650,fx,'@').
:-op(650,fx,'#').

:-dynamic(arc/3).
:-dynamic(agenda/1).
:-dynamic(edge/4).
:-dynamic(fsm_start/2).
:-dynamic(fsm_end/2).
:-dynamic(gap/2).

% EBNF-ish/ATN chart parser
%:-use_module(library(pcre)).

% Called from java
dispatch:-
	current_prolog_flag(argv,[Filein,Fileout|_]),
	write(Filein),nl,
	write(Fileout),nl,
	dispatch(Filein,Fileout).

% dispatch(+Filein,+Fileout)
%   Read annotations as XML from Filein, parse, and write XML annotations to Fileout
dispatch(Filein,Fileout):-
	load_xml(Filein,[Xml],[space(remove)]),
	% read xml to edges
	write('Mapping from XML'),nl,
	xml_map(Xml,Es0),
	% assert edges
	write('Initialising'),nl,
	initialise_from_dispatch(Es0,_Es1),
	write('Filling gaps (maybe)'),nl,
	(fill_gaps_required->process_gaps(Es0);true),
	% run parser 
	write('Running parser'),nl,
	once(loop_agenda),
	retry,
	write('Removing redundant'),nl,
	(debugrun(false)->remove_contained(_);true),
	(debugrun(false)->thorough_remove_contained('Context');true),
	% collect complete edges
	findall(edge(P0,P1,L,S1),
		(edge(P0,P1,V,S),
			fsm_end(L,V),
			del_dict(body,S,_,S11),
			success_del_dict(effects,S11,_,S111),
			success_del_dict(extract,S111,_,S1111),
			success_del_dict(substituted,S1111,_,S11111),
			success_del_dict(act_effects,S11111,_,S1)
		),
		Es2),
	write('Mapping to XML'),nl,
	xml_map(Xml1,Es2),
	% write edges to xml,
	open(Fileout,write,Out,[]),
	xml_write(Out,[Xml1],[layout(false)]),
	close(Out).

% success_del_dict(+Key,+D0,?Val,D1)
%   D1 is D0 with Key-Val removed
%   succeeding anyway if Key isn't there
success_del_dict(Key,D0,Val,D1):-
	del_dict(Key,D0,Val,D1),!.
success_del_dict(_,D,_,D).


initialise_from_dispatch(Es0,Es1):-
	retractall(edge(_,_,_,_)),
	retractall(agenda(_)),
	retractall(arc(_,_,_,_)),
	retractall(fsm_start(_,_)),
	retractall(fsm_end(_,_)),
	retractall(gap(_,_)),
	compile_token_types_from_dispatch(Es0,V1),
	compile_grammar(V1),
	% initialise_chart
	findall(edge(P0,P1,T,S1),
		(
			member(edge(P0,P1,T,S0),Es0),
			S1=S0.put(head,T)
		),
		Es00),
	map_edges_dispatch(Es00,Es1),
	forall(member(edge(P0,P1,V,S),Es1),
		(
			%S1=S.put(body,[S.get(text)]),
			extract_term(S,S1),
			assertz(agenda(edge(P0,P1,V,S1))) 
		)).

extract_term(S0,S1):-
	ID=S0.get(id),
	!,
	Text=S0.get(text),
	S1=S0.put(body,[ID-Text]).
extract_term(S0,S1):-
	S1=S0.put(body,[S0.get(text)]).

map_edges_dispatch([],[]).
map_edges_dispatch([edge(P0,P1,Label,S)|Es0],[edge(P0,P1,V,S)|Es1]):-
	fsm_end(Label,V),
	map_edges_dispatch(Es0,Es1).

% Assert facts to record gaps in sequence of edges.
% This is to enable JAPE-like behaviour, where gaps are ignored between
% those annotation identified as relevant.

process_gaps(Edges):-
	process_gaps1(Edges,Gaps),
	assert_all(Gaps).

process_gaps1(Edges,Gs):-
	succ_setof(P0,P1^V^St^member(edge(P0,P1,V,St),Edges),Ss),
	succ_setof(P1,P0^V^St^member(edge(P0,P1,V,St),Edges),Es),
	find_gaps(Es,Ss,Gs).

% find_gaps(+Ends,+Starts,-Gaps)
find_gaps([],_,[]):-!.
find_gaps(_,[],[]):-!.
find_gaps(Es,[S|Ss],Gs):-
	Es=[E|_],
	S<E,
	!,
	find_gaps(Es,Ss,Gs).
find_gaps([P|Es],[P|Ss],Gs):-
	!,
	find_gaps(Es,Ss,Gs).
find_gaps([E|Es],Ss,[gap(E,S)|Gs]):-
	Ss=[S|_],
	E<S,
	!,
	find_gaps(Es,Ss,Gs).

dump_init_edges:-
	E=edge(P0,P1,V,S),
	agenda(E),
	fsm_end(Label,V),
	(Label='Pnumber'->nl;true),
	write(Label=edge(P0,P1,V,S)),nl,
	fail.
dump_init_edges.
 
%------------------------------------------------------------
% Parsing algorithm
%------------------------------------------------------------

loop_agenda:-
	agenda(_),!,
	process_agenda,
	loop_agenda.
loop_agenda.
 
process_agenda:-
	retract(agenda(E)),
	careful_assertz(E),
	process_edge(E),
	predict(E),
	fail.
process_agenda.

% process_edge(+Edge)
%  - Combine Edge from agenda with existing edges on chart
%    adding resulting edges to agenda
process_edge(E0):-
	fundamental(E0,_E1,E2),
	add_to_agenda(E2),
	fail.
process_edge(E1):-
	fundamental(_E0,E1,E2),
	add_to_agenda(E2),
	fail.
process_edge(_).

% We already checked that V1 is complete
fundamental(E0,E1,E2):-
	% Freeze is used so that we can use same order for clauses whether it is E0 or E1 that is already bound
	freeze(P1a,equivalent_place(P1a,P1b)),  
	freeze(P1b,equivalent_place(P1a,P1b)),
	E0=edge(P0,P1a,V0,FM0),
	E1=edge(P1b,P2,V,FM1),
	edge(P0,P1a,V0,FM0),
	arc(V0,Label1,Acts,V1),
	edge(P1b,P2,V,FM1),
	% V is end state of nested FSM labelled by Label1
	fsm_end(Label1,V),
	
	(debugrun(false)->
		FM2=FM0;
		(   % Extend syntax tree
			S0=FM0.body,
			S1=FM1.body,
			SS1=..[Label1|S1],
			append(S0,[SS1],S2),
			FM2=FM0.put(body,S2)
		)
	),
	do_acts(Acts,FM1,FM2,FM22),
	% New combined edge
	E2=edge(P0,P2,V1,FM22).

equivalent_place(Pa,Pb):-
	gap(Pa,Pb).
equivalent_place(P,P).

% predict(+Edge)
%   if Edge is completes Label1
%      and Label1 is possible first transition from start V0 in another FSM
%    add empty edge for V0 to agenda

% Bottom-up predict
predict(edge(P0,_,V,_)):-
	% State V means we have complete edge for Label0
	fsm_end(Label0,V),
	% Where label is a transition from some FSM start state add unfound Label1 to agenda
	arc(V0,Label0,_,_),
	fsm_start(Label1,V0),
	\+top_down(Label1),
	add_to_agenda(edge(P0,P0,V0,s{head:Label1,body:[]})).
% Top-down predict
predict(edge(_,P1,V,_)):-
	arc(V,Label0,_,_),
	top_down(Label0),
	fsm_start(Label0,V1),
	add_to_agenda(edge(P1,P1,V1,s{head:Label0,body:[]})).

add_to_agenda(E0):-
	% Already exists as an edge (maybe with differing FM)
	E0=edge(P0,P1,V,_),
	edge(P0,P1,V,_),
	!.
add_to_agenda(E0):-
	% Already exists as agenda edge
	E0=edge(P0,P1,V,_),
	E1=edge(P0,P1,V,_),
	agenda(E1),
	!.
add_to_agenda(E):-
	% Does exist already so really add to agenda
	E=edge(P0,P1,V0,FM0),
	assertz(agenda(E)),
	P0\==P1,
	% Add edges for Vertices reachable by skips
	arc(V0,skip,Acts,V1),
	once(do_acts(Acts,s{},FM0,FM1)),
	add_to_agenda(edge(P0,P1,V1,FM1)),
	fail.
add_to_agenda(_).

careful_assertz(C):-
	call(C),!.
careful_assertz(C):-
	assertz(C).

%------------------------------------------------------------
% do_acts(+Acts,+FM1,+FM2,-FM3)
% Perform tests/ actions on arcs
%    FM1 - item feature map
%    FM2 - rule feature map - before act
%    FM3 - rule feature map - after act

do_acts([],_,FM,FM).
do_acts([@Label|Acts],FM1,FM2,FM4):-
	!,
	% Store FM1 in FM2 with Label as key
	FM3=FM2.put(Label,FM1),
	do_acts(Acts,FM1,FM3,FM4).
do_acts([X:=Y|Acts],FM1,FM2,FM4):-
	eval(FM1,FM2,Y,Yval),
	!,
	FM3=FM2.put(X,Yval),
	do_acts(Acts,FM1,FM3,FM4).
do_acts([X:==Y|Acts],FM1,FM2,FM4):-
	eval(FM1,FM2,Y,Yval),
	!,
	check_or_set(X,Yval,FM2,FM3),
	FM3=FM2.put(X,Yval),
	do_acts(Acts,FM1,FM3,FM4).
do_acts([X+=Y|Acts],FM1,FM2,FM4):-
	eval(FM1,FM2,collect(Y,#X~[]),Yval),
	!,
	FM3=FM2.put(X,Yval),
	do_acts(Acts,FM1,FM3,FM4).
do_acts([if(X,Yacts,_)|Acts],FM1,FM2,FM5):-
	do_acts([X],FM1,FM2,FM3),
	!,
	do_acts(Yacts,FM1,FM3,FM4),
	do_acts(Acts,FM1,FM4,FM5).
do_acts([if(_,_,Zacts)|Acts],FM1,FM2,FM4):-
	!,
	do_acts(Zacts,FM1,FM2,FM3),
	do_acts(Acts,FM1,FM3,FM4).
% try(Acts) - do all the Acts or none of them
do_acts([try(Zacts)|Acts],FM1,FM2,FM4):-
	do_acts(Zacts,FM1,FM2,FM3),
	!,
	do_acts(Acts,FM1,FM3,FM4).
do_acts([try(_)|Acts],FM1,FM2,FM3):- 
	!,
	do_acts(Acts,FM1,FM2,FM3).
do_acts([unset(Key)|Acts],FM1,FM2,FM4):-
	!,
	del_dict(Key,FM2,_,FM3),
	do_acts(Acts,FM1,FM3,FM4).
do_acts([assigned(Expr)|Acts],FM1,FM2,FM4):-
	!,
	eval(FM1,FM2,Expr,_),
	do_acts(Acts,FM1,FM2,FM4).
do_acts([Term|Acts],FM1,FM2,FM3):-
	Term=..[Head|Args],
	maplist(eval(FM1,FM2),Args,Vals),
	!,
	once(apply(Head,Vals)),
	do_acts(Acts,FM1,FM2,FM3).

%------------------------------------------------------------
% eval(+FM1,+FM2,+Expr,-Val)
%   FM1 is item dict (featuremap)
%   FM2 is rule dict
%   Expr is the expression being evaluated
%   Val is the result
% Evaluate expressions occurring in actions on arcs
%------------------------------------------------------------
eval(FM,_,(@),FM):-!.  % value is whole item dict
eval(_,FM,(#),FM):-!.  % value is whole rule dict
eval(_,_,E,Val):-
	(atom(E);number(E)),
	!,
	Val=E.
eval(_,_,[],[]):-!.
eval(FM1,_,@Att,Val):- % Value named Att from item dict
	!,
	Val=FM1.get(Att).
eval(_,FM2,#Att,Val):- % Value named Att from rule dict
	!,
	Val=FM2.get(Att).
eval(FM1,FM2,FM_expr/Att,Val):- % Recursive evaluation allows feature paths
	!,
	eval(FM1,FM2,FM_expr,FM),
	Val=FM.get(Att).
eval(FM1,FM2,E~_,Val):-  % Default ignored
	eval(FM1,FM2,E,Val),
	!.
eval(FM1,FM2,_~E,Val):-  % Default used
	!,
	eval(FM1,FM2,E,Val).
eval(FM1,FM2,E0-E1,Val0-Val1):-
	!, % '-' as term constructor
	eval(FM1,FM2,E0,Val0),
	eval(FM1,FM2,E1,Val1).
eval(FM1,FM2,Term,Val):-    % 1-arg functor
	Term=..[Functor,E0],
	!,
	eval(FM1,FM2,E0,Val0),
	call(Functor,Val0,Val).
eval(FM1,FM2,Term,Val):-    % 2-arg functor
	Term=..[Functor,E0,E1],
	!,
	eval(FM1,FM2,E0,Val0),
	eval(FM1,FM2,E1,Val1),
	call(Functor,Val0,Val1,Val).
eval(FM1,FM2,Term,Val):-    % 3-arg functor
	Term=..[Functor,E0,E1,E2],
	!,
	eval(FM1,FM2,E0,Val0),
	eval(FM1,FM2,E1,Val1),
	eval(FM1,FM2,E2,Val2),
	call(Functor,Val0,Val1,Val2,Val).

%------------------------------------------------------------
% Predicates called as functions from within grammar rules
%------------------------------------------------------------
collect(E,L0,L1):-
	append(L0,[E],L1).

head([H|_],H).

map_prepend([],_,[]).
map_prepend([L0|Ls0],H,[L1|Ls1]):-
	format(atom(L1),'~w~w',[H,L0]),
	map_prepend(Ls0,H,Ls1).

map_append([],_,[]).
map_append([L0|Ls0],H,[L1|Ls1]):-
	format(atom(L1),'~w~w',[L0,H]),
	map_append(Ls0,H,Ls1).

'+'(X,Y,Z):-
	format(atom(Z),'~w~w',[X,Y]).

list(X,[X]).

% check_or_set(+Key,Val,FM0,FM1)
% if FM0 has same value for key, FM1=FM0
% If FM0 has incompatible value for key, fail
% If FM0 has no value for key, FM1 has value set
check_or_set(Key,Val0,FM0,FM1):-
	Val1=FM0.get(Key),
	!,
	Val0=Val1,
	FM1=FM0.
check_or_set(Key,Val,FM0,FM1):-
	FM1=FM0.put(Key,Val).

%------------------------------------------------------------
% compile_fsm EBNF into ATN
%------------------------------------------------------------
compile_grammar(N0):-
	findall(X==>Y,X==>Y,Rules),
	compile_rules(Rules,N0).

compile_rules([],_).
compile_rules([R|Rs],N0):-
	compile_rule(R,N0,N1),
	compile_rules(Rs,N1).

compile_rule(X==>Expr,N0,N1):-
	%compile_fsm(Expr,V0,V1,Es0,[]),
	%filtered_redundant_arcs(Es0,Es0,Es1),
	%bake(Es1,N0,N1),
	rule_machine(Expr,N0,N1,V0,V1,Es1),
	assert_all(Es1),
	skippable(V0,VSs),
	forall(member(VS,VSs),assertz(fsm_start(X,VS))),
	assertz(fsm_end(X,V1)),!.
compile_rule(LHS==>_,_,_):-
	format('Failed to compile rule: ~w~n',[LHS]),
	fail.

rule_machine(Expr,N0,N1,V0,V1,Es1):-
	compile_fsm(Expr,V0,V1,Es0,[]),
	filtered_redundant_arcs(Es0,Es0,Es1),
	bake(Es1,N0,N1).

assert_all([]).
assert_all([C|Cs]):-
	assertz(C),
	assert_all(Cs).

% Find all vertices reachable by a path of skips
skippable(V,Vs):-
	Vs=[V|_],
	skippable1(Vs,Vs).

%  - call with both args bound to [V0|_], where V0 is initial vertex
skippable1([],_):-!.
skippable1([V0|Vs],Vs0):-
	findall(V1,arc(V0,skip,_,V1),Vs1),
	skippable_list(Vs1,Vs0),
	skippable1(Vs,Vs0).

skippable_list([],_).
skippable_list([V1|Vs1],Vs0):-
	memberchk(V1,Vs0), % Add if not already there
	skippable_list(Vs1,Vs0).

% compile_fsm(seq([cat(cat),cat(dog)]),V0,V1,Es0,Es1).
% compile_fsm(seq([cat(cat),disj([cat(dog),cat(newt)])]),V0,V1,Es0,Es1)
% compile_fsm( seq([cat(cat),md(disj([cat(dog),cat(newt)]),*)]),V0,V1,Es0,[]).
% compile_fsm( seq([cat(cat),md(disj([cat(dog),cat(newt)]),+)]),V0,V1,Es0,[]).
% compile_fsm( seq([cat(cat),md(disj([cat(dog),cat(newt)]),+)]),V0,V1,Es0,[]).

compile_fsm(seq(Seq),V0,V1,Es0,Es1):-
	!,
	compile_fsm_seq(Seq,V0,V1,Es0,Es1).
compile_fsm(disj(Disj),V0,V1,Es0,Es1):-
	!,
	compile_fsm_disj(Disj,V0,V1,Es0,Es1).
compile_fsm(*(Ex),V0,V2,[E0,E1|Es0],Es1):-
	!, % subnet loop to same vertex
	E0=arc(V0,skip,[],V1),
	E1=arc(V1,skip,[],V2),
	compile_fsm(Ex,V1,V1,Es0,Es1).
compile_fsm(+(Ex),V0,V3,[E0,E1,E2|Es0],Es1):-
	!, % transition with backward skip
	E0=arc(V0,skip,[],V1),
	E1=arc(V2,skip,[],V1),
	E2=arc(V2,skip,[],V3),
	compile_fsm(Ex,V1,V2,Es0,Es1).
compile_fsm(?(Ex),V0,V1,[E|Es0],Es1):-
	!, % subnet or skip
	E=arc(V0,skip,[],V1),
	compile_fsm(Ex,V0,V1,Es0,Es1).
compile_fsm(Cat:Acts,V0,V1,[E|Es],Es):-
	atom(Cat),
	!,
	E=arc(V0,Cat,Acts,V1).
compile_fsm(Cat,V0,V1,[E|Es],Es):-
	atom(Cat),
	!,
	E=arc(V0,Cat,[],V1).
compile_fsm(Term:Acts,V0,V2,[E|Es0],Es1):-
	compile_fsm(Term,V0,V1,Es0,Es1),
	!,
	E=arc(V1,skip,Acts,V2).

compile_fsm_seq([],V,V,Es,Es).
compile_fsm_seq([Ex|Exs],V0,V2,Es0,Es2):-
	compile_fsm(Ex,V0,V1,Es0,Es1),
	compile_fsm_seq(Exs,V1,V2,Es1,Es2).

compile_fsm_disj([],_,_,Es,Es).
compile_fsm_disj([Ex|Exs],V0,V1,Es0,Es2):-
	compile_fsm(Ex,V0,V1,Es0,Es1),
	compile_fsm_disj(Exs,V0,V1,Es1,Es2).


% filtered_redundant_arcs(+Arcs1,+AllArcs,-Arcs2)
%
% Arcs2 omits any skip arcs that are obviously redundant
% For any arc V1=>V2 with label 'skip'
%  If arc has no action and
%    there is no other arc FROM V1
%  	 or
%    there is no other arc TO V2
%  arc is redundant,so merge V1 and V2

% Note that vertices are unbound variables at this stage,
% so compared using ==
% and merged using =

filtered_redundant_arcs([],_,[]).
filtered_redundant_arcs([arc(V1,skip,[],V2)|Arcs1],AllArcs,Arcs2):-
	findall(VV,(member(arc(V,_,_,VV),AllArcs),V==V1),[_]),
    !,
	V1=V2,
	filtered_redundant_arcs(Arcs1,AllArcs,Arcs2).
filtered_redundant_arcs([arc(V1,skip,[],V2)|Arcs1],AllArcs,Arcs2):-
	findall(VV,(member(arc(VV,_,_,V),AllArcs),V==V2),[_]),
    !,
	V1=V2,
	filtered_redundant_arcs(Arcs1,AllArcs,Arcs2).
filtered_redundant_arcs([Arc|Arcs1],AllArcs,[Arc|Arcs2]):-
	filtered_redundant_arcs(Arcs1,AllArcs,Arcs2).

% bake(?Arcs,+N0,_N1)
%   Arcs - list of arcs initially with unbound vertex variables
%   N0 - initial Vertex count
%   N1 - final vertex count 
% Assign identifiers to unbound vertex variables

bake([],N,N):-!.
bake([arc(V1,_,_,V2)|Es],N0,N3):-
	fill(V1,N0,N1),
	fill(V2,N1,N2),
	bake(Es,N2,N3).

% fill(?V,+N0,-N1)
% if V is unbound then bind it to next N
fill(N0,N0,N1):-
	!,
	N1 is N0+1.
fill(_,N,N).

compile_token_types_from_dispatch(Es0,V1):-
	succ_setof(Label,P0^P1^S^(member(edge(P0,P1,Label,S),Es0)),Heads),
	compile_token_types(Heads,0,V1).

% Wrapper for setof that doesn't fail when no results	
succ_setof(X,Y,Z):-
	setof(X,Y,Z),!.
succ_setof(_,_,[]).
	

% compile_token_types(+Tokens,+N0,-N1)
%
% Tokens - list of token symbols
% N0 - initial vertex count
% N1 - final vertex count

% Assert clauses for simple tokens as though they are complete fsms
% Due to the way we use FSMs, it's possible for something to be 
% both an active and complete edge
compile_token_types([],N,N).
compile_token_types([T|Ts],N0,N3):-
	N1 is N0+1,
	N2 is N1+1,
	assertz(fsm_start(T,N0)),
	assertz(fsm_end(T,N1)),
	compile_token_types(Ts,N2,N3).

edge_type(L,E):-
	fsm_end(L,V),
	E=edge(_,_,V,_),
	call(E).

within(E0,E1):-
	E0=edge(P0,P1,_,_),
	E1=edge(P2,P3,_,_),
	P2=<P0,
	P1=<P3.

% Process results by removing edges within another edge of same type

% Efficient version, removes contained edges
% sharing start or end positions, but may miss some
remove_contained(Label):-
	fsm_end(Label,V),
	E0=edge(P0a,P1,V,_),
	E1=edge(P0b,P1,V,_),
	call(E0),
	call(E1),
	P0b>P0a,
	%write(+retracting),nl,
	retract(E1),
	fail.
remove_contained(Label):-
	fsm_end(Label,V),
	E0=edge(P0,P1a,V,_),
	E1=edge(P0,P1b,V,_),
	call(E0),
	call(E1),
	P1b<P1a,
	%write(+retracting),nl,
	retract(E1),
	fail.
remove_contained(_).

% This is thorough but inefficient
thorough_remove_contained(Label):-
	edge_type(Label,E0),
	edge_type(Label,E1),
	within(E1,E0),
	E0\==E1,
	retract(E1),
	fail.
thorough_remove_contained(_).
