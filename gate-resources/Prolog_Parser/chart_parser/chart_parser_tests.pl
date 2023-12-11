%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%


test(rule_machine/6,seq1,
	rule_machine( seq( [a, b, c] ), 1, _N, _V0, _V1, Es ),
	Es=[arc(1, a, [], 2), arc(2, b, [], 3), arc(3, c, [], 4)]).

test(rule_machine/6,disj1,
	rule_machine( disj( [a, b, c] ), 1, _N, _V0, _V1, Es ),
	Es=[arc(1, a, [], 2), arc(1, b, [], 2), arc(1, c, [], 2)]).
	
test(rule_machine/6,seq_disj1,
	rule_machine( seq( [a,disj([b, c])] ), 1, _N, _V0, _V1, Es ),
	Es=[arc(1, a, [], 2), arc(2, b, [], 3), arc(2, c, [], 3)]).

test(rule_machine/6,seq_q1,
	rule_machine( seq( [a,?(b),c] ), 1, _N, _V0, _V1, Es ),
	Es=[arc(1, a, [], 2), arc(2, skip, [], 3), arc(2, b, [], 3), arc(3, c, [], 4)]).

test(rule_machine/6,seq_star1,
	rule_machine( seq( [a,*(b),c] ), 1, _N, _V0, _V1, Es ),
	Es=[arc(1, a, [], 2), arc(2, b, [], 2), arc(2, c, [], 3)]).

test(rule_machine/6,seq_plus1,
	rule_machine( seq( [a,+(b),c] ), 1, _N, _V0, _V1, Es ),
	Es=[arc(1, a, [], 2), arc(3, skip, [], 2), arc(2, b, [], 3), arc(3, c, [], 4)]).

test(rule_machine/6,disj_plus1,
	rule_machine( disj( [a,+(b),c] ), 1, _N, _V0, _V1, Es ),
	Es=[arc(1, a, [], 2), arc(1, skip, [], 3), arc(4, skip, [], 3), arc(4, skip, [], 2), arc(3, b, [], 4), arc(1, c, [], 2)]).

test(rule_machine/6,plus_act1,
	rule_machine( +(a), 1, _N, _V0, _V1, Es ),
	Es=[arc(1, skip, [], 2), arc(2, a, [], 1)]).

test(rule_machine/6,plus_skip1,
	rule_machine( +(a):[act], 1, _N, _V0, _V1, Es ),
	Es=[arc(1, skip, [act], 2), arc(1, skip, [], 3), arc(3, a, [], 1)]).

test(eval/4,at1,
	eval( s{key1:val1}, s{}, @key1, Val),
	Val=val1).

test(eval/4,hash1,
	eval( s{}, s{key1:val1}, #key1, Val),
	Val=val1).

test(eval/4,nil1,
	eval( s{}, s{}, [], Val),
	Val=[]).

test(eval/4,at_path1,
	eval(s{a:s{b:val1}},s{}, (@a)/b, Val),
	Val=val1).

test(eval/4,hash_path1,
	eval(s{}, s{a:s{b:val1}}, (#a)/b, Val),
	Val=val1).

test(eval/4,default1,
	eval(s{key1:val1}, s{}, (@key1)~val2, Val),
	Val=val1).

test(eval/4,default2,
	eval(s{}, s{}, (@key1)~val2, Val),
	Val=val2).

test(eval/4,construct1,
	eval(s{a:val1}, s{b:val2}, (@a)-(#b), Val),
	Val=(val1-val2)).

test(eval/4,predicate_as_function3,
	eval(s{a:[1,2]}, s{b:[3,4]}, append(@a,#b), Val),
	Val=[1,2,3,4]).

test(do_acts/4,assignment1,
	do_acts([b:= @a],s{a:val1},s{},FM2),
	get_dict(b,FM2,val1)).

test(do_acts/4,assignment1,
	do_acts([b:= @a],s{a:val1},s{},FM2),
	get_dict(b,FM2,val1)).

test(do_acts/4,assignment_eq1,
	do_acts([b:== @a],s{a:val1},s{b:val1},FM2),
	get_dict(b,FM2,val1)).

test(do_acts/4,assignment_eq2,
	do_acts([b:== @a],s{a:val1},s{},FM2),
	get_dict(b,FM2,val1)).

test(do_acts/4,assignment_eq3,
	\+(do_acts([b:== @a],s{a:val1},s{b:val2},_FM2)),
	true).

test(do_acts/4,plus_eq1,
	do_acts([b+= @a],s{a:3},s{b:[1,2]},FM2),
	get_dict(b,FM2,[1,2,3])).

test(do_acts/4,eq1,
	do_acts([1=1],s{},s{},_),
	true).

test(do_acts/4,eq2,
	\+(do_acts([1=2],s{},s{},_)),
	true).

test(do_acts/4,if1,
	do_acts([if(1=1, [b := val1], [b := val2])],s{},s{},FM2),
	get_dict(b,FM2,val1)).

test(do_acts/4,if2,
	do_acts([if(1=2, [b := val1], [b := val2])],s{},s{},FM2),
	get_dict(b,FM2,val2)).

test(do_acts/4,try1,
	do_acts([try([b:=val1])],s{},s{},FM2),
	get_dict(b,FM2,val1)).

test(do_acts/4,try2,
	do_acts([try([b:=val1,@a=val0])],s{},s{},FM2),
	FM2=s{}).

test(do_acts/4,unset1,
	do_acts([unset(b)],s{},s{b:val1},FM2),
	FM2=s{}).

test(do_acts/4,assigned1,
	do_acts([assigned(#b)],s{},s{b:val1},_FM2),
	true).

test(do_acts/4,assigned2,
	\+do_acts([assigned(#b)],s{},s{},_FM2),
	true).

test(process_gaps1/2,gap1,
	process_gaps1([edge(1,2,a,s{}),edge(3,4,b,s{})],X),
	X=[gap(2, 3)]).

test(process_gaps1/2,gap2,
	process_gaps1([edge(1,3,a,s{}),edge(2,5,b,s{}),edge(4,6,c,s{}),edge(7,8,c,s{})],X),
	X=[gap(3, 4), gap(5, 7), gap(6, 7)]).

test(process_gaps1/2,gap3,
	process_gaps1([edge(1,2,a,s{}),edge(2,3,b,s{})],X),
	X=[]).

test(process_gaps1/2,gap4,
	process_gaps1([edge(1,2,a,s{})],X),
	X=[]).

test(process_gaps1/2,gap5,
	process_gaps1([],X),
	X=[]).

test(map_prepend/3,map_prepend1,
	map_prepend(['/a','/b','/c'],'/1',X),
	X=['/1/a', '/1/b', '/1/c']).

test(map_prepend/3,map_append1,
	map_append(['/a','/b','/c'],'/1',X),
	X = ['/a/1', '/b/1', '/c/1']).
