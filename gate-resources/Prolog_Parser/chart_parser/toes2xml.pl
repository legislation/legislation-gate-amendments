%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%


% The effects data accumulated on 'Context' edges is mapped into XML and saved to a file

effect_output:-
	current_prolog_flag(argv,[_,_,Filename]),
	effect_output(Filename).

effect_output(Filename):-
	effects_xml(XmlEff),
	open(Filename,write,OutEff,[]),
	xml_write(OutEff,[XmlEff],[header(false),layout(false)]),
	close(OutEff).

effects_xml(XmlEff):-
	fsm_end('Context',V),
	succ_setof(P0-S,P1^edge(P0,P1,V,S),Es),
	findall(S,member(_-S,Es),Ss),	
	collect_effects(Ss,Effs00),
	list_to_set(Effs00,Effs0),
	filter_effects(Effs0,Effs1),
	convert_defn_effects(Effs1,Effs2),
	%print_term(Effs2,[]),
	effects2xml(Effs2,XmlEff).

% filter_effects(Effs0,Effs1)
%   Effs1 is Effs0 filtered of effects without effecting provision
filter_effects([],[]).
filter_effects([E|Es0],[E|Es1]):-
	get_dict(affectingProvision,E,_),
	!,
	filter_effects(Es0,Es1).
filter_effects([_|Es0],Es1):-
	filter_effects(Es0,Es1).

% Where there is detail in affected provns
%   below /definition, we need to filter out the 
%   sub-provisions, and make sure the effect type 
%   is about words, not provisions.

convert_defn_effects([],[]).
convert_defn_effects([E0|Es0],[E4|Es1]):-
	get_dict(affectedProvisions,E0,Affected0),
	% We *do* want setof to fail if no solutions
	setof(
			Prv1,
			Prv0^(
				member(Prv0,Affected0),
				range_cut(Prv0,'/definition',Prv1)),
			Affected1),
	!,
	success_del_dict(substitutedProvisions,E0,_,E1),
	success_del_dict(affectedExtra,E1,_,E2),
	get_dict(effectType,E2,EffectType0),
	effect_to_words(EffectType0,EffectType1),
	put_dict(effectType,E2,EffectType1,E3),
	put_dict(affectedProvisions,E3,Affected1,E4),
	convert_defn_effects(Es0,Es1).
convert_defn_effects([E|Es0],[E|Es1]):-
	convert_defn_effects(Es0,Es1).

effect_to_words('omitted','words omitted'):-!.
effect_to_words('inserted','words inserted'):-!.
effect_to_words(T0,T1):-
	name(T0,S1),
	append(`substituted`,_,S1),
	!,
	T1='words substituted'.
effect_to_words(E,E).


collect_effects([],[]).
collect_effects([S|Ss],Effs2):-
	get_dict(effects,S,Effs0),
	!,
	append(Effs0,Effs1,Effs2),
	collect_effects(Ss,Effs1).
collect_effects([_|Ss],Effs):-
	collect_effects(Ss,Effs).

effects2xml(Effects,Xml1):-
	effect2xml(Effects,'Effects',Xml0),
	Xml1=element('Changes',
		[parsed=true,parserName="Legislation Parser",xmlns="http://www.legislation.gov.uk/namespaces/metadata"],
		[element('Effects',[],Xml0)]).

effect2xml(Effect,Tag,Xml):-
	is_dict(Effect),
	!,
	dict_pairs(Effect,_,Pairs),
	effectPairs2xml(Pairs,Elements,Attrs),
	Xml=element(Tag,Attrs,Elements).
effect2xml(Effect,_,Xml):-
	atom(Effect),
	!,
	Xml=Effect.
effect2xml(Effect,Tag,Xml):-
	Effect=[_|_],
	!,
	effectList2xml(Effect,Tag,Xml).
effect2xml([],_,[]).

effectPairs2xml([],[],[]).
effectPairs2xml([affectedProvisions-Value|Pairs],Elements0,Attrs):-
	!,
	(atomic(Value)->effectList2xml([Value],'Section',Vxml);effectList2xml(Value,'Section',Vxml)),
	Elements0=[element('AffectedProvisions',[],Vxml)|Elements1],
	effectPairs2xml(Pairs,Elements1,Attrs).
effectPairs2xml([substitutedProvisions-Value|Pairs],Elements0,Attrs):-
	!,
	(atomic(Value)->effectList2xml([Value],'Section',Vxml);effectList2xml(Value,'Section',Vxml)),
	Elements0=[element('SubstitutedProvisions',[],Vxml)|Elements1],
	effectPairs2xml(Pairs,Elements1,Attrs).
effectPairs2xml([affectingProvision-Value|Pairs],Elements0,Attrs):-
	!,
	effectList2xml([Value],'Section',Vxml),
	%(memberchk(affectedExtra-Andword,Pairs)-> Attrs=[extra=Andword] ; Attrs=[] )
	Elements0=[element('AffectingProvision',[],Vxml)|Elements1],
	effectPairs2xml(Pairs,Elements1,Attrs).
effectPairs2xml([effectType-Value|Pairs],Elements,Attrs0):-
	!,
	Attrs0=[effectType=Value|Attrs1],
	effectPairs2xml(Pairs,Elements,Attrs1).
effectPairs2xml([affectedExtra-Value|Pairs],Elements,Attrs0):-
	!,
	atom_concat('and ',Value,Value1),
	Attrs0=[affectedExtra=Value1|Attrs1],
	effectPairs2xml(Pairs,Elements,Attrs1).
effectPairs2xml([extract-Value|Pairs],Elements0,Attrs):-
	!,
	extract_pairs(Value,Elements0,Elements1),
	effectPairs2xml(Pairs,Elements1,Attrs).
effectPairs2xml([_|Pairs],Elements,Attrs):-
	!,
	effectPairs2xml(Pairs,Elements,Attrs).

effectList2xml([],_,[]).
effectList2xml([E1,E2|Effs],'Section',[RangeXml|Xmls]):-
	range_cut(E1,'/range',E11),!,
	range_cut(E2,'/range',E22),
	effectList2xml([E11],'Section',[Xml1]),
	effectList2xml([E22],'Section',[Xml2]),
	%Xml1=element('Section',[],[E11]),
	%Xml2=element('Section',[],[E22]),
	RangeXml=element('SectionRange',[],[Xml1,Xml2]),
	effectList2xml(Effs,'Section',Xmls).
effectList2xml([E1,E2|Effs],'Section',[Xml1,Xml2|Xmls]):-
	range_cut(E1,'/pair',E11),!,
	range_cut(E2,'/pair',E22),
	effectList2xml([E11],'Section',[Xml1]),
	effectList2xml([E22],'Section',[Xml2]),
	effectList2xml(Effs,'Section',Xmls).
effectList2xml([Eff|Effs],'Section',[SectionXml|Xmls]):-
	!,
	SectionXml=element('Section',['URI'=Eff],[]),
	effectList2xml(Effs,'Section',Xmls).
effectList2xml([Eff|Effs],'Effects',[Xml|Xmls]):-
	!,
	effect2xml(Eff,'Effect',Xml),
	effectList2xml(Effs,'Effects',Xmls).
effectList2xml([Eff|Effs],Tag,[element(Tag,[],[Xml])|Xmls]):-
	effect2xml(Eff,Tag,Xml),
	effectList2xml(Effs,Tag,Xmls).

extract_pairs([],Xmls,Xmls).
extract_pairs([Tag-Id|Pairs],[Xml|Xmls0],Xmls1):-
	Xml=element(Tag,[id=Id],[]),
	extract_pairs(Pairs,Xmls0,Xmls1).

range_cut(N2,N1,N0):-
	name(N2,S2),
	name(N1,S1),
	once(append(S1,_,SS1)),
	once(append(S0,SS1,S2)),
	name(N0,S0).

