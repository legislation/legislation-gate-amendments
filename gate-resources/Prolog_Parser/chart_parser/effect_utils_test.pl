%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

test(update_effects/3,1,
	update_effects(
		 [ s{ affectedProvisions:[''],
			  affectingProvision:'http://www.legislation.gov.uk/id/uksi/2018/1299/regulation/11/b/i',
			  body:[],
			  effectType:'words substituted',
			  head:'ActionDescription',
			  ll:words
			},
		   s{ affectedProvisions:['/a/i'],
			  affectingProvision:'http://www.legislation.gov.uk/id/uksi/2018/1299/regulation/11/b/ii',
			  body:[],
			  effectType:'words substituted',
			  head:'ActionDescription',
			  ll:words
			}
		 ],
		 % Affected	 
		 ['/1B'],
		 % Affecting
		 'http://www.legislation.gov.uk/id/uksi/2018/1299/regulation/11/b',
		 Result),
	Result=
		[ s{ affectedProvisions:['/1B'],
			  affectingProvision:'http://www.legislation.gov.uk/id/uksi/2018/1299/regulation/11/b/i',
			  body:[],
			  effectType:'words substituted',
			  head:'ActionDescription',
			  ll:words
			},
		   s{ affectedProvisions:['/1B/a/i'],
			  affectingProvision:'http://www.legislation.gov.uk/id/uksi/2018/1299/regulation/11/b/ii',
			  body:[],
			  effectType:'words substituted',
			  head:'ActionDescription',
			  ll:words
			}
		]
	).
