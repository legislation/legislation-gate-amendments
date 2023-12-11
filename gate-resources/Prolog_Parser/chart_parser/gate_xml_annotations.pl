%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

:-use_module(library(sgml)).

xml_map(element(annotationSet,[],AnnsXml),Edges):-
	xml_map_anns(AnnsXml,Edges).

xml_map_anns([],[]):-!.
xml_map_anns([AnnXml|AnnsXml],[edge(P0,P1,Type,Dict)|Edges]):-
	AnnXml=element(annotation,Attrs,FeaturesXml),
	%write(AnnXml),nl,
	Attrs=[endOffset=Pa1,startOffset=Pa0,type=Type],
	atom_number(Pa0,P0),
	atom_number(Pa1,P1),
	FeaturesXml=[element(features,[],[element(listValuedMap,[],LvmXml),element(map,[],EntriesXml)])],
	features(EntriesXml,LvmXml,Dict),
	xml_map_anns(AnnsXml,Edges).

features(EntriesXml,LvmXml,Dict):-
	ground(Dict),
	!,
	dict_pairs(Dict,_,Pairs),
	xml_map_features(EntriesXml,LvmXml,Pairs).
features(EntriesXml,LvmXml,Dict):-
	xml_map_features(EntriesXml,LvmXml,Pairs),
	dict_pairs(Dict,s,Pairs).

xml_map_features([],[],[]):-!.
xml_map_features([EntryXml|EntriesXml],LvmXml,[Key-Val|Pairs]):-
	EntryXml=element(entry,[],[element(key,[],[Key]),element(value,[],[Val])]),
	atomic(Val),
	!,
	xml_map_features(EntriesXml,LvmXml,Pairs).
xml_map_features(EntriesXml,[EntryXml|LvmXml],[Key-Val|Pairs]):-
	EntryXml=element(entry,[],[element(key,[],[Key]),element(value,[],List)]),
	List=[_|_],
	Val=[_|_],
	!,
	xml_map_lvm_val(List,Val),
	xml_map_features(EntriesXml,LvmXml,Pairs).
xml_map_features([EntryXml|EntriesXml],LvmXml,[Key-'_'|Pairs]):-
	EntryXml=element(entry,[],[element(key,[],[Key]),element(value,[],[])]),
	!,
	xml_map_features(EntriesXml,LvmXml,Pairs).

xml_map_lvm_val([],[]).
xml_map_lvm_val([element(item,[],[Item])|Xml],[Item|Items]):-
	xml_map_lvm_val(Xml,Items).
