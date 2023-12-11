%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

:-op(800,xfx,'~>').
:-op(800,xfx,'~>>').

% Define '~>>' as transitive closure of '~>'
X ~>> Y:-
	X ~> Y,!.
X ~>> Z:-
	X ~> Y,
	Y ~>> Z,
	!.

fill_gaps_required.

% Some things to parse only in top-down
top_down('LegRefCompound').

%------------------------- 
% Document structure model
%------------------------- 
 
none ~> legislation .
 
legislation~>section.
legislation~>schedule.
legislation~>article.
legislation~>regulation.
legislation~>rule.
legislation~>schedule.
legislation~>chapter.
legislation~>part.
legislation~>signature.

section~>subsection.
section~>subpart.
section~>paragraph1. % Happens in eur/2011/1178 (modified aviation safety reg 316)
subsection~>paragraph3.
subsection~>step.

definition~>_.

article~>paragraph2.
article~>paragraph1.
regulation~>paragraph2.
regulation~>paragraph3.
rule~>paragraph2.
rule~>paragraph3.
paragraph2~>subparagraph.
paragraph2~>paragraph3.
subparagraph~>subsubparagraph.
paragraph3~>subsubparagraph.

appendix~>point0.
appendix~>item.
appendix~>form.
form~>point0_1.
paragraph1~>subparagraph2.
paragraph1~>subparagraph.
subparagraph2~>paragraph3.
paragraph1~>point0.
paragraph1~>point1.
point0~>paragraph3.
point0~>point0_1.
point0_1~>point1.
point0~>point1.
point1~>point2.
point2~>point3.
point3~>point4.
point4~>point5.

schedule~>paragraph1.
schedule~>part.
schedule~>rule.
schedule~>group.
group~>note.
note~>paragraph3. %suspect
part~>paragraph1.
part~>item.
part~>chapter.
part~>rule.
chapter~>section.
section~>chapter2.

annex~>words.
appendix~>words.
section~>words.
article~>words.
regulation~>words.
rule~>words.
subsection~>words.
paragraph1~>words.
paragraph2~>words.
paragraph3~>words.
subparagraph~>words.
subparagraph2~>words.
subsubparagraph~>words.
point0~>words.
point0_1~>words.
point1~>words.
point2~>words.
point3~>words.
point4~>words.
point5~>words.
schedule~>words.
part~>words.
item~>words.
heading~>words.
form~>words.
chapter2~>words.
group~>words.
note~>words.
step~>words.

section~>heading.
article~>heading.
regulation~>heading.
rule~>heading.
subsection~>heading.
paragraph1~>heading.
paragraph2~>heading.
paragraph3~>heading.
subparagraph~>heading.
subparagraph2~>heading.
subsubparagraph~>heading.
point0~>heading.
point0_1~>heading.
point1~>heading.
point2~>heading.
point3~>heading.
point4~>heading.
point5~>heading.
schedule~>heading.
part~>heading.
item~>heading.

(table)~>words.
regulation~>table.
article~>table.
section~>table.
subsection~>table.
paragraph1~>table.
paragraph2~>table.
paragraph3~>table.
subparagraph~>table.
subparagraph2~>table.
schedule~>table.

legislation~>annex.
paragraph1~>point2.
annex~>part.
annex~>subpart.
annex~>section.
annex~>appendix.
subpart~>point0.
subpart~>point0_1.
subpart~>point1.
subpart~>point2.

% These are used in getting provision URIs from block amendments
struct(Type,Prefix):-
	struct(Type,_,Prefix),
	!.
struct(_,'').

struct(schedule,1,'/schedule').
struct(section,1,'/section').
struct(subsection,2,'').
struct(article,1,'/article').
struct(regulation,1,'/regulation').
struct(rule,1,'/rule').
struct(part,2,'/part').
struct(paragraph1,1,'/paragraph').
struct(paragraph2,2,'').
struct(paragraph3,3,'').
struct(subparagraph2,3,''). % in 2nd col of Table A, but really 3rd below schedule and para.
struct(subparagraph,3,'').
struct(subsubparagraph,4,'').


% Conventions for feature names:
% type - type e.g. of Location
% ll - level in affected document structure (e.g. section) to match on left
% lr - level                                               to match on right
% list - list of (possibly partial) provision URIs
% idURI - URI of affecting doc
% level - depth (in document structure) on LegPnumber
% depth - depth (in document structure) in affecting doc
% id - identifier for cross-reference to source annotation - used eventually to highlight text
% extract - list of associated annotations to be highlighted in text


'LocationRelative'==>disj([
	'Location':[@type='AfterWords', type:= @type, id:= @id],
	'Location':[@type='AtEndOfDefinition', type:= @type, id:= @id],
	'Location':[@type='AtEndOfHeading', type:= @type, id:= @id],
	'Location':[@type='AtTheBeginning', type:= @type, id:= @id],
	'Location':[@type='BeforeDefinition', type:= @type, id:= @id],
	'Location':[@type='BeforeEntryForRef', type:= @type, id:= @id],
	'Location':[@type='BeforeHeading', type:= @type, id:= @id],
	'Location':[@type='AfterHeading', type:= @type, id:= @id],
	'Location':[@type='BeforeRef', type:= @type, id:= @id],
	'Location':[@type='BeforeRelatedEntry', type:= @type, id:= @id],
	'Location':[@type='BeforeWords', type:= @type, id:= @id],
	'Location':[@type='InDefinition', type:= @type, id:= @id],
	'Location':[@type='AfterDefinition', type:= @type, id:= @id],
	'Location':[@type='AfterRef', type:= @type, id:= @id],
	'Location':[@type='Misc', type:= @type, id:= @id]
]).

'LocationContext'==>disj([
	'Location':[@type='ForRef', type:= @type, id:= @id],
	'Location':[@type='In', type:= @type, id:= @id],
	'Location':[@type='AtEndOf', type:= @type, id:= @id]
]).


% Doesn't set lr
'LegRefAny'==> 
	disj([ 
		'LegRef':[ll:= @type,list:= @list,id:= @id],
		'Location':[@type='Table',ll:=table,list:=list('/table'),id:= @id],
		'Location':[@type='form',ll:=form,list:= @list,id:= @id],
		'Legislation':[ll:= legislation,list:= list(@context)],
		'Location':[@type='Signature',list:= list('/signature'),ll:=signature ],
		seq([ 
			?('Location':[@type='In']),
			'Location':[@type='CrossHeading',id:= @id],
			'Location':[@type='BeforeRef'],
			'LegRef':[ll:= @type,lr:=heading,list:=list(head(@list)+'/cross-heading')]
		]),
		seq([ 
			'Location':[@type='In'],
			disj([
				'Location':[@type='Heading',ll:=heading,list:=list('/heading'),id:= @id],
				'Location':[@type='Sub-heading',ll:=heading,list:=list('/sub-heading'),id:= @id]
			])
		])
	]).

% Must set lr
'LegRefCompound'==> 
	disj([
		'LegRefAny':[ll:= @ll, lr:= @ll, list:= @list],
		seq([
			'LegRefCompound':[ll:= @ll,lr:= @lr,list:= @list],
			disj([
				% Ascending level e.g. paragraph 1 of regulation 1
				seq([
					disj([
						'Location':[@type='Of'],
						'Location':[@type='Legislation'],
						'Location':[@type='In']]),
					'LegRefCompound':[@lr~>> #ll,ll:= @ll,list:=map_prepend(#list,head(@list)),try(suffix:= @suffix)]
				]),
				% Descending level e.g. regulation 1, paragraph 1
				'LegRefCompound':[#lr~>> @ll,length(#list)=1,lr:= @lr,list:=map_prepend(@list,head(#list)),try(suffix:= @suffix)],
				% Same level e.g. paragraph 1, paragraph 2 e.g. http://www.legislation.gov.uk/id/ukpga/2019/1/schedule/15/paragraph/21/1
				seq([
					?('Location':[@type='And']),
					'LegRefCompound':[@ll\=heading,#ll= @ll,#lr= @lr,list:=append(#list,@list)]
				]),
				seq([
					?('Location':[@type='And']),
					'LegRefCompound':[
						@ll=heading,
						lr:= @lr,
						list:=append(#list,@list)
					]
				]),
				% ... and cross-heading
				'AndWord':[lr:= words,suffix:= @suffix]
			])
		])
	]).


'Context'==>seq([
	?('LegPnumber':[depth:= atom_number(@level),idURI:= @idURI]),
	?(disj([
		seq([
			disj([
				seq([disj([
					'Legislation':[
						ll:=legislation,
						lr:= #ll,
						prefix:= list(@context~'')],
					'LegRefCompound':[
						%@ll=legislation,
						ll:= @ll,
						lr:= @lr,
						prefix:= @list]
					]),
					?(seq(['Action':[@type='Amendment'],?('Controller')]))
				]),
				seq([
					disj([
						%'Location':[@type='In'],
						'LocationContext',
						seq(['Location':[@type='AtTheBeginning'],'Location':[@type='Of']])
					]),
					'LegRefCompound':[ll:= @ll,lr:= @lr,prefix:= @list]
				])
			]),
			*('ActionDescription':[
				#lr ~>> (@ll)~words,
				effects:=list(@),
				empty:=false
			]),
			*('Place'),
			*('Context':[
				#lr ~>> @ll,
				% #lr ~>> (@ll)~words,
				cdepth:== @depth~5,
				(#depth~0)=<(#cdepth),
				effects:= append( #effects~[], @effects~[] ),
				empty:=false
			])
		]):[#empty=false], % Don't allow empty context
		seq([
			'ActionDescription':[
				ll:= @ll,
				effects:=list(@)
			],
			*('Context':[
				#ll ~>> @ll,
				% #ll ~> (@ll)~words,
				cdepth:== @depth~5,
				(#depth~0)=<(#cdepth),
				effects:= append(#effects,@effects~[])
			])
		]),
		% In the definition of " ... "
		seq([
			'Location':[@type='In'],
			'Location':[@type='Definition'],
			'Quote':[prefix:= list('/definition')],
			+('Context':[
				ll:= @ll,
				cdepth:== @depth~5,
				(#depth~0)=<(#cdepth),
				effects:= append(#effects~[],@effects~[])
			])
		]),
		% Context only - only valid if we already had a Pnumber that has set #depth
		% (BrokenBranch can now also set depth
		% Use of cdepth is to prevent treating grandchildren as children
		seq([	?('BrokenBranch':[depth:= @depth]),
			*('Place':[extract:=append(#extract~[],@extract)]),
			+('Context':[
				ll:== @ll,
				cdepth:== @depth~5,
				(#depth)=<(#cdepth),
				effects:= append(#effects~[],@effects)
			])
		]),
		
		% Action first, followed by list of affecting provns
		'ActionThenAffectedList':[effects:= @effects,ll:= @ll,#depth< @depth],

		% List of actions first, followed by another provision with a list of affecting + affected provns.
		'ActionListThenAffectedList':[
			effects:= @effects,
			ll:= @ll,
			#depth = @depth % Provn. listing actions (this context) same depth as provn. introducing affected list
		],

		% Omit the definitions of ...
		% Omit the following ...
		seq(['Action':[@type='Delete',
				effectType:='words omitted',
				extract+='Action'-(@id)],
			?('Location':[@type='Definition',@count='Many']),
			'AffectedQuoteList':[
				effects:= 
					map_put_cons(
						map_put(@effects,effectType,#effectType),
						extract,
						head(#extract)),
				ll:= words
			]
		])

	]))
]):[
	effects:= update_effects(
		#effects~[],
		#prefix~list(''),
		#idURI~''),
	#ll = #ll % fail if not set
].

'ActionListThenAffectedList'==>
	seq([
		'Location':[@type='In'],
		'Location':[@type='Each'],
		'Location':[@type='SetOutIn'],
		'LegRefCompound',
		'ActionDescriptionList':[act_effects:= @effects],
		'AppliesToFollowing':[
			effects:= combine_acts_with_affected(#act_effects,@effects),
			ll:= @ll,
			depth:= @depth
		]
	])
.

'AppliesToFollowing'==>
	seq([
		'LegPnumber':[depth:= atom_number(@level)],
		'SpecifiedRefsFollow',
		'AffectedList':[
			effects:= @effects,
			ll:= @ll,
			#depth< @depth]
	]).

'ActionThenAffectedList'==>
	seq([
		?('Location':[@type='In']),
		'Location':[@type='TheFollowing'],
		disj([
			seq([
				'Action':[@type='Repeal',actID:= @id],
				'AffectedList':[
					effects:=
						map_put(
							map_put(@effects,effectType,'revoked'),
							extract,
							list('Action'-(#actID))),
					ll:= @ll,
					depth:= @depth]
			]),
			seq([
				'ActionDescriptionList':[act_effects:= @effects],
				'AffectedList':[
					effects:= combine_acts_with_affected(#act_effects,@effects),
					ll:= @ll,
					depth:= @depth ]
			])
		])
	]).

'AffectedList'==> 
	+(
		disj([
			'AffectedListItem':[effects+= @,depth:== @depth,ll:== @ll],
			seq([
				'AffectedListItem':[depth:== @depth,ll:== @ll,prefix:= @affectedProvisions ],
				?('AffectedList':[#ll~> @ll,#depth < @depth,
					effects:= append(#effects,update_effects(@effects,#prefix,''))
				])  % sublist of lower provision type
			])
		])
	).

'AffectedListItem'==>
	seq([
		'LegPnumber':[depth:= atom_number(@level),idURI:= @idURI],
		'LegRefCompound':[affectedProvisions:= @list,affectingProvision:= #idURI,ll:= @ll]
	]).

% Used e.g. http://www.legislation.gov.uk/uksi/2019/93/regulation/21/made#regulation-21-2
% Omit the definitions of -
'AffectedQuoteList'==>
	+('AffectedQuoteItem':[effects+= @,depth:== @depth]).

'AffectedQuoteItem'==>
	seq([
		'LegPnumber':[depth:= atom_number(@level),idURI:= @idURI],
		'Quote':[
			affectingProvision:= #idURI,
			affectedProvisions:= list(''),
			ll:=words,
			extract+= 'OmittedWords'-(@id)]
	]).

'Place'==>
	disj([
		seq([	
			disj([
				'LocationRelative':[extract+='LocationRelative'-(@id)],
				seq([
					'Location':[@type='Table',extract+='LocationRelative'-(@id)],
					'Location':[@type='Of']
				])
			]),
			disj([
				'Quote':[ll:= words,extract+='Words'-(@id)],
				'LegRefAny':[ll:= @ll,extract+='Ref'-(@id)],
				'LegRefCompound':[ll:= @ll,lr:= @lr,list:= @list]
			])
		]),
		seq([
			'Location':[@type='In',extract+='In'-(@id)],
			disj([
				'Location':[@type='Sentence',ll:=words,extract+='Location'-(@id)],
				'Location':[@type='TheWords',ll:=words,extract+='Location'-(@id)],
				'Location':[@type='OpeningWords',ll:=words,extract+='Location'-(@id)],
				'Location':[@type='Misc',ll:=words,extract+='Location'-(@id)],
				'Location':[@type='Introduction',ll:=words,extract+='Location'-(@id)],
				'Location':[@type='Column',ll:=words,extract+='Location'-(@id)],
				seq([
					'Location':[@type='Entry',ll:=words,extract+='Location'-(@id)],
					?(seq([
						'Location':[@type='For'],
						'Quote'
					]))
				])
			])
		]),
		'Location':[@type='AppropriatePlace',ll:= words,extract+='Location'-(@id)],
		%'Location':[@type='Heading',ll:= words,extract+='Heading'-(@id)],
		%'Location':[@type='Table',ll:= words,extract+='Table'-(@id)],
		'Location':[@type='AtTheEnd',ll:=words,extract+='Location'-(@id)],
		'Location':[@type='AtTheBeginning',ll:=words,extract+='Location'-(@id)],
		'Location':[@type='NthWordInstance',ll:=words,extract+='Location'-(@id)],
		'Location':[@type='BeforeTable',ll:=words,extract+='Location'-(@id)],
		'Location':[@type='AfterTable',ll:=words,extract+='Location'-(@id)],
		'Location':[@type='ThoseWords',ll:=words,extract+='Location'-(@id)],
		seq(['Location':[@type='AfterMisc'],'Location':[@type='Misc',ll:=words,extract+='Location'-(@id)]])
	]).

% Quotes or things which are equivalent to quotes as target text
'QuoteCompound'==>
	disj([
		seq([
			'Location':[@type='WordsFrom',extract+='Location'-(@id),effectText:='words'],
			?('Quote':[extract+='Words'-(@id)]),
			?('Location':[@type='WordsTo',extract+='Location'-(@id)]),
			disj([
				'Quote':[extract+='Words'-(@id)],
				'Location':[@type='TheEnd']
			])
		]),
		+('Quote':[
			extract+='Words'-(@id),
			effectText:= @effectText  % bit dubious - last one wins
		]),
		seq([
			'Location':[@type='TheWords'],
			disj([
				'Location':[@type='BeforeRef'],
				'Location':[@type='AfterRef']
			]),
			'LegRef':[ll:=words]
		]),
		seq([
			'Location':[@type='Entry',ll:=words,extract+='Location'-(@id)],
			'Location':[@type='For'],
			'Quote':[effectText:='words']
		]),
		'Location':[@type='Sentence',ll:=words,extract+='Location'-(@id),effectText:='words'],
		'Location':[@type='Misc',ll:=words,extract+='Location'-(@id),effectText:='words'],
		'Location':[@type='Entry',ll:=words,extract+='Location'-(@id),effectText:='words']
	]).


'ActionDescriptionList'==>
	+('ActionDescription':[effects+= @]).

'ActionDescription'==>
	disj([
		% REVOKE / REPEAL
		seq([
			disj(['Legislation':[
					ll:=legislation,
					affectedProvisions:=list(@context~''),
					extract+='Legislation'-(@id)],
				'LegRefCompound':[
					ll:= @ll,
					affectedProvisions:= @list
					%,extract+='RevokedRef'-(@id)
					]
			]),
			'Action':[@type='Repeal',effectType:='revoked']
		]),

		% DELETE
		seq([*('Place':[extract:=append(#extract~[],@extract)]),
			'Action':[@type='Delete',
				effectType:='words omitted',
				extract+='Action'-(@id)],
			?('Location':[extract+='Location'-(@id)]),
			disj([
				+(seq([
					'QuoteCompound':[
						ll:= words,
						extract:=append(#extract~[],@extract),
						effectType:= (@effectText) + ' omitted'],
					*(
						disj([
							'Place',
							% at the end of paragraph (b)
							seq(['LocationContext',
								'LegRef'
							])
						])
					)
				]))
			])
		]),

		seq([*('Place':[extract:=append(#extract~[],@extract)]),
			'Action':[@type='Delete',
				effectType:='omitted',
				extract+='Action'-(@id) ],
			'LegRefCompound':[ll:= @ll,
				affectedProvisions:= @list,
				try([affectedExtra:= @suffix])]
		]),

		seq([*('Place':[extract:=append(#extract~[],@extract)]),
			'LegRefAny':[ll:= @ll,
				affectedProvisions:= @list,
				extract+='DeletedRef'-(@id) ],
			'Action':[@type='Delete',
				effectType:='omitted',
				extract+='Action'-(@id) ]
		]),
		
		% INSERT
		seq([+('Place':[
				ll:= #ll ~ @ll,
				place:= (@lr)~(@ll),
				if(assigned(@list),
					[nearbyList:= (@list)],
					[]
				),
				extract:=append(#extract~[],@extract)
			]),
			'Action':[
				@type='Insert',
				extract+='Action'-(@id) ],
			+disj([
				'Quote':[
					effectType:= (@effectText) + ' inserted',
					extract+='InsertedWords'-(@id) ],
				'LegAmendment':[
					effectType:='inserted',
					if(assigned(@list_includes_label),
						[affectedProvisions:= @list],
						[if(assigned(#nearbyList),
							[affectedProvisions:=map_prepend(@list,head(shared_path(#nearbyList)))],
							[affectedProvisions:=map_prepend(@list,struct(#place)~'')~[]]
						)]
					),
					try([affectedExtra:= @affectedExtra]),
					extract+='InsertedBlock'-(@id) ],
				seq([
					'LegRefAny':[
						effectType:='inserted',
						affectedProvisions:= @list,
						extract+='InsertedRef'-(@id)],
					?(seq([
						'Location':[
							@type='SetOutIn',
							extract+='Location'-(@id)],
						'LegRefAny':[
							affectingProvision:= head(@list),
							extract+='AffectingRef'-(@id)]
					]))
				])
			])
		]),
		seq(['Action':[
				@type='Insert',
				extract+='Action'-(@id) ],
			*('Place':[ll:= @ll,
				place:= (@lr)~(@ll),
				extract:=append(#extract~[],@extract) ]),
			+(disj([
				'Quote':[
					ll:= (#ll)~words,
					effectType:= (@effectText)+' inserted',
					extract+='InsertedWords'-(@id) ],
				'LegAmendment':[
					effectType:='inserted',
					%affectedProvisions:= map_prepend(@list,struct(#place))~[],
					list:= @list,
					try([list_includes_label= @list_includes_label]),
					try([affectedExtra:= @affectedExtra]),
					extract+='InsertedRef'-(@id) ]
			])),
			?(seq([
				'Location':[@type='AtEndOf'],
				'LegRefAny':[ll:= @ll, place:= @ll, list:= @list]
			]))
		]):[
			%affectedProvisions:= map_prepend(#list~[],struct(#place))~[]
			if(#list_includes_label = #list_includes_label,
				[affectedProvisions:= (#list)~[] ],
				[affectedProvisions:=map_prepend(#list,struct(#place)~'')~[]]
			)
		],

		% SUBSTITUTION
		seq([*('Place':[extract:=append(#extract~[],@extract)]),
			?('Location':[
				@type='For',
				extract+='Location'-(@id) ]),
			?(disj([
				'Location':[@type='WordsFrom',extract+=(@type)-(@id)],
				'Location':[@type='Definition',extract+=(@type)-(@id)],
				'Place'%:[extract:=append(#extract~[],@extract)]
			])),
			'QuoteCompound':[
				ll:= words,
				extract:=append(#extract~[],@extract~[])
				%effectType:= (@effectText) + ' substituted'
			],
			?('Place'),
			'Action':[
				@type='Substitution',
				extract+='Action'-(@id)
			],
			disj([
				'Quote':[
					ll:= words,
					extract+='SubstitutingWords'-(@id),
					effectType:= (@effectText) + ' substituted'
				],
				'LegAmendment':[
					ll:= words,
					extract+='SubstitutingBlock'-(@id),
					try([affectedExtra:= @affectedExtra]),
					effectType:= 'words substituted'
				]
			])
		]),
		seq([*('Place':[extract:=append(#extract~[],@extract)]),
			'Action':[@type='Substitution',
				extract+='Action'-(@id)],
			'QuoteCompound':[
				ll:= words,
				extract:=append(#extract~[],@extract),
				effectType:= (@effectText) + ' substituted'
			],
			%'Quote':[ll:=words,
			%	extract+='SubstitutedWords'-(@id)],
			disj([
				'Quote':[
					extract+='SubstitutingWords'-(@id),
					effectType:= (@effectText) + ' substituted'],
				'LegAmendment':[
					extract+='SubstitutingBlock'-(@id),
					effectType:= 'words substituted',
					try([affectedExtra:= @affectedExtra])]
			])
		]),
		seq([?(disj([
				'Location':[@type='ForRef',extract+=(@type)-(@id)], % why did we make this distinction in the first place?
				'Location':[@type='For',extract+=(@type)-(@id)]
			])),
			'LegRefCompound':[
				ll:= @ll,
				substitutedProvisions:= @list,
				affectedProvisions:= list(head(@list)), % This is a questionable default
				try([affectedExtra:= @suffix])
			],
			'Action':[
				@type='Substitution',
				effectType:='substituted',
				extract+='Action'-(@id)
			],
			disj([
				'Quote':[
					extract+='SubstitutingWords'-(@id),
					if(equivalent_provisions(#substitutedProvisions,#affectedProvisions),
						[unset(substitutedProvisions)],
						[])
				],
				'LegAmendment':[
					if(assigned(@list_includes_label),
						[affectedProvisions:=map_prepend(@list,drop_last_frag(head(shared_path(#substitutedProvisions))))],
						[affectedProvisions:=map_prepend(@list,head(shared_path(#substitutedProvisions)))]
					),
					extract+='SubstitutingBlock'-(@id),
					if(equivalent_provisions(#substitutedProvisions,#affectedProvisions),
						[unset(substitutedProvisions)],
						[]),
					try([affectedExtra:= @affectedExtra]),
					rule:=legref_subst_legamend
				],
				seq([
					'LegRefAny':[extract+='SubstitutingRef'-(@id)],
					?(seq([
						'Location':[
							@type='SetOutIn',
							extract+='Location'-(@id)],
						'LegRefAny':[
							affectingProvision:= head(@list),
							extract+='AffectingRef'-(@id)
						]
					]))
				])
			])
		]),

		% RENUMBER
		seq([
			'Action':[@type='Renumber',extract+='Action'-(@id)],
			'LegRefMapping':[
				affectedProvisions:= singleton_pair_range(@toList),
				substitutedProvisions:= @fromList,
				ll:= @type,
				effectType:= renumbered
			]
		])

	]).


% Just so we allocate an fsm_end vertex to the label
'Leaf'==>'Nothing'.
'BrokenBranch'==>'Nothing'.


