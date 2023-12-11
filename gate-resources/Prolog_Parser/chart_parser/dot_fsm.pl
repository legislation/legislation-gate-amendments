%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

% Output a file 'graph.dot' which is a representation of the parser state machines
%  in a format for the visualisation using the graphviz 'dot' tool.

dot_fsm:-
	tell('graph.dot'),
	dot_preamble,
	%dot_nodes,
	dot_edges,
	dot_fsm_names,
	dot_postamble,
	told.

dot_preamble:-
	write('digraph g {'),nl,
	write('rankdir=LR;'),nl.

dot_postamble:-
	write('}'),nl.

dot_edges:-
	arc(V0,Label,Acts,V1),
	type_label(Acts,Type),
	format('~w -> ~w [label="~w~w",labeltooltip="~w"];~n',[V0,V1,Label,Type,Acts]),
	fail.
dot_edges.

dot_fsm_names:-
	fsm_end(Label,V),
	once(arc(_,_,_,V)),
	format('label_~w [label="~w",shape=none];~n',[V,Label]),
	format('~w -> label_~w [style=invisible,dir=none];~n',[V,V]),
	fail.
dot_fsm_names.

type_label(Acts,Label):-
	memberchk(@type=(Type),Acts),
	format(string(Label),'(~w)',[Type]),
	!.
type_label(_,'').