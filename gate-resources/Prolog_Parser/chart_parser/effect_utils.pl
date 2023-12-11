%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%


% Utilities specific to handling legislation effects
% - most called from actions within grammar to manipulate constructed data.

update_effects([],_,_,[]).
update_effects([E0|Es0],Prefixes,IdURI,Es1):-
	update_affecting_provision(E0,IdURI,E1),
	update_substituted_provisions(E1,Prefixes,E2),
	update_affected_provisions(E2,Prefixes,Es1,Es2),
	update_effects(Es0,Prefixes,IdURI,Es2).

% We are expecting either 
% singular prefix and potentially multiple AffecTed provisions,
%    in which case prepend the prefix to each provision
% or multiple prefix,
%    in which case just use the prefixes
update_affected_provisions(E0,[Prefix],Es0,Es1):-
	Teds0=E0.get(affectedProvisions),
	Teds0=[_|_], 
	!,
	ranges(Teds0,Teds1),
	affected_prepend(Teds1,E0,Prefix,Es0,Es1).
update_affected_provisions(E0,Prefixes0,Es0,Es1):-
	ranges(Prefixes0,Prefixes1),
	affected_prepend(Prefixes1,E0,'',Es0,Es1).

update_substituted_provisions(E0,[Prefix],E1):-
	Teds0=E0.get(substitutedProvisions),
	!,
	map_prepend(Teds0,Prefix,Teds1),
	maplist(uri_fixes,Teds1,Teds2),
	E1=E0.put(substitutedProvisions,Teds2).
update_substituted_provisions(E0,_Prefixes,E0).


% Expand list of Affected into multiple effects
% ... while adding prefix Prefix to each
affected_prepend([],_,_,Es,Es).
affected_prepend([Ted0-''|Teds0],E0,Prefix,[E2|Es0],Es1):-
	!,
	format(atom(Ted1),'~w~w',[Prefix,Ted0]),
	uri_fixes(Ted1,Ted2),
	and_word_fix(Ted2,Ted3,E0,E1),
	E2=E1.put(affectedProvisions,[Ted3]),
	affected_prepend(Teds0,E0,Prefix,Es0,Es1).
affected_prepend([TedStart-TedEnd|Teds0],E0,Prefix,[E1|Es0],Es1):-
	format(atom(TedStart1),'~w~w',[Prefix,TedStart]),
	format(atom(TedEnd1),'~w~w',[Prefix,TedEnd]),
	uri_fixes(TedStart1,TedStart2),
	uri_fixes(TedEnd1,TedEnd2),
	E1=E0.put(affectedProvisions,[TedStart2,TedEnd2]),
	affected_prepend(Teds0,E0,Prefix,Es0,Es1).

update_affecting_provision(E,_,E):-
	_=E.get(affectingProvision),
	!.
update_affecting_provision(E,'',E):-!.
update_affecting_provision(E1,IdURI,E2):-
	E2=E1.put(affectingProvision,IdURI).

% Set same key-value in a list of dictionaries
map_put([],_,_,[]).
map_put([Dict0|Dicts0],Key,Value,[Dict1|Dicts1]):-
	Dict1=Dict0.put(Key,Value),
	map_put(Dicts0,Key,Value,Dicts1).

% map_put_cons(+Dicts0,+Key,+Value,-Dicts1)
% For each dictionary in Dicts0,
%   cons value to beginning of list stored under key
% to form new dictionary list Dicts1
map_put_cons([],_,_,[]).
map_put_cons([Dict0|Dicts0],Key,Value,[Dict1|Dicts1]):-
	List0=Dict0.get(Key),
	List1=[Value|List0],
	Dict1=Dict0.put(Key,List1),
	map_put_cons(Dicts0,Key,Value,Dicts1).

combine_acts_with_affected(ActEffects,TedEffects,CombinedEffects):-
	findall( CombinedEffect,
		(
			member(TedEff,TedEffects),
			member(ActEff,ActEffects),
			CombinedEffect=TedEff
				.put(effectType,ActEff.get(effectType))
				.put(extract,ActEff.get(extract))
		),
		CombinedEffects
	).

% For the situations in which this is called from grammar,
% it is moot whether conceptually we want the shared path,
% or whether we want to 
% drop the last fragment of path plus any modifiers like '/rangeStart'
%  shared_path(['/section/1/a/1'],X), X=['/section/1/a'].
%  shared_path(['/section/1/a/1/rangeStart','/section/1/a/2/rangeEnd'],X),  X = ['/section/1/a'].
shared_path([Uri0],[Uri1]):-
	!, % Input list is a singleton, we want to drop the last fragment
	drop_last_frag(Uri0,Uri1).
shared_path(Uris,[Shared]):-
	% Input list has >1 URI, actually find shared part
	shared_path1(Uris,_,SharedFrags),
	atomic_list_concat(SharedFrags,'/',Shared).

% shared_path(['/section/1/a/1/rangeStart','/section/1/a/2/rangeEnd'],_,Y), Y = ["", "section", "1", "a"].
shared_path1([],Shared,Shared).
shared_path1([Uri|Uris],Shared0,Shared2):-
	split_string(Uri,['/'],[],Frags),
	matching_prefix(Frags,Shared0,Shared1),
	shared_path1(Uris,Shared1,Shared2).

% matching_prefix([a,b,c,e],[a,b,c,d],X),  X = [a, b, c].
% matching_prefix([a,b,c,e],_,X), X = [a, b, c, e].
matching_prefix([H|Ta],[H|Tb],[H|Tc]):-
	!,
	matching_prefix(Ta,Tb,Tc).
matching_prefix(_,_,[]).

/*
shared_path(Uris,Shared):-
	setof(Uri1,Uri0^(member(Uri0,Uris),drop_last_frag(Uri0,Uri1)),Shared).
*/

drop_last_frag(Uri0,Uri2):-
	split_string(Uri0,['/'],[],Frags0),
	once(append(Frags1,[_],Frags0)),
	atomics_to_string(Frags1,'/',Uri1),
	atom_string(Uri2,Uri1).
	
%uri_fixes(Uri0,Uri1):-
%	re_replace('/article/([^/]*)/paragraph/(.*)$','/article/$1/$2',Uri0,Uri1).

% Workaround for no pcre (regex) library
uri_fixes(Uri0,Uri1):-
	atomic_list_concat(Frags0,'/',Uri0),
	uri_fix_pattern(Frags0,Frags1),
	!,
	atomic_list_concat(Frags1,'/',Uri1). 
uri_fixes(Uri,Uri).

% Drop '/paragraph' fragment if preceded by '/article'
%  - this is a fudge to cope with inconsistencies 
%    in notation conventions.
uri_fix_pattern(
	['','article',A,'paragraph'|Frags],
	['','article',A|Frags] ):-!.

% If the uri Ted0 ends in /and-{suffix}
% then chop off that bit and add suffix
% to effect with key affectedExtra
and_word_fix(Ted0,Ted1,E0,E1):-
	atom_codes(Ted0,Codes0),
	append(`/and-`,SuffixCodes,Pattern),
	append(PrefixCodes,Pattern,Codes0),
	!,
	write('and_word_fix'),nl,
	atom_codes(Ted1,PrefixCodes),
	atom_codes(Suffix,SuffixCodes),
	E1=E0.put(affectedExtra,Suffix).
and_word_fix(Ted,Ted,E,E).

% singleton_pair_range(['/a'],X), X=['/a'].
% singleton_pair_range(['/a/rangeStart','/c/rangeEnd'],X), X=['/a/rangeStart','/c/rangeEnd'].
% singleton_pair_range(['/a','/b'],X), X=['/a/pairStart','/b/pairEnd'].
% singleton_pair_range(['/a','/b','/c'],X), X=['/a/rangeStart','/c/rangeEnd'].
singleton_pair_range([Prov],[Prov]):-!.
singleton_pair_range(Pair1,Pair2):-
	% Already a range
	Pair1=[Prov1,_],
	rangeStart(Prov1),
	!,
	Pair2=Pair1.
singleton_pair_range([Prov1,Prov2],[Prov3,Prov4]):-
	!, % label a pair
	atom_concat(Prov1,'/pairStart',Prov3),
	atom_concat(Prov2,'/pairEnd',Prov4).
singleton_pair_range([Prov1,Prov2],[Prov3,Prov4]):-
	!, % 3 or more elements - turn into a range
	atom_concat(Prov1,'/rangeStart',Prov3),
	atom_concat(Prov2,'/rangeEnd',Prov4).
singleton_pair_range(Provs1,Provs2):-
	!, % 3 or more elements - turn into a range
	Provs1=[Prov1,_,_|_],
	!,
	last(Provs1,Prov2),
	Provs2=[Prov3,Prov4],
	atom_concat(Prov1,'/rangeStart',Prov3),
	atom_concat(Prov2,'/rangeEnd',Prov4).

% Turn a list that may contain range starts and ends into a list of pairs
% ranges(['section/1','/section/2/rangeStart','/section/4/rangeEnd','/section/5'],
%		['section/1'-'', '/section/2/rangeStart'-'/section/4/rangeEnd', '/section/5'-'']).
ranges([],[]).
ranges([L1,L2|Ls0],[L1-L2|Ls1]):-
	rangeStart(L1),
	rangeEnd(L2),
	!,
	ranges(Ls0,Ls1).
ranges([L|Ls0],[L-''|Ls1]):-
	ranges(Ls0,Ls1).

rangeStart(Uri):-
	name(Uri,UriCodes),
	append(_,`rangeStart`,UriCodes),
	!.
rangeStart(Uri):-
	name(Uri,UriCodes),
	append(_,`pairStart`,UriCodes),
	!.
rangeEnd(Uri):-
	name(Uri,UriCodes),
	append(_,`rangeEnd`,UriCodes),
	!.
rangeEnd(Uri):-
	name(Uri,UriCodes),
	append(_,`pairEnd`,UriCodes),
	!.

% Check that provisions are equivalent, when they may 
% vary according to whether they are tagged as pair
% (or range?).
equivalent_provisions([],[]).
equivalent_provisions([P0|Ps0],[P1|Ps1]):-
	filter_suffix(P0,'/pair',Q),
	filter_suffix(P1,'/pair',Q),
	equivalent_provisions(Ps0,Ps1).

filter_suffix(N2,N1,N0):-
	name(N2,S2),
	name(N1,S1),
	once(append(S1,_,SS1)),
	once(append(S0,SS1,S2)),
	!,
	name(N0,S0).
filter_suffix(N,_,N).
