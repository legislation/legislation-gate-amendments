%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

:-set_prolog_flag(stack_limit, 2_147_483_648).
debugrun(false).
:-consult(chart_parser).
:-consult(grammar_sections).
:-consult(gate_xml_annotations).
:-consult(retry_sections).
:-dispatch.
:-halt.
