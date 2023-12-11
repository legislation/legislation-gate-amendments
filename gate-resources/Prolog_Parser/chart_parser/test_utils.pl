%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

run_tests:-
	findall(test_id(Pred,Num),test(Pred,Num,_,_),Tests),
	run_tests(Tests,Passes,Fails),
	length(Tests,NumTests),
	length(Passes,NumPasses),
	length(Fails,NumFails),
	format('~w tests attempted~n',[NumTests]),
	format('~w passed~n',[NumPasses]),
	format('~w failed~n',[NumFails]).

run_tests([],[],[]).
run_tests([TestID|Tests],[TestID|Passes],Fails):-
	TestID=test_id(Pred,Num),
	test(Pred,Num,Goal,Check),
	once(call(Goal)),
	call(Check),
	!,
	write('PASS : '),write(TestID),nl,
	run_tests(Tests,Passes,Fails).
run_tests([TestID|Tests],Passes,[TestID|Fails]):-
	write('FAIL : '),write(TestID),nl,
	run_tests(Tests,Passes,Fails).
