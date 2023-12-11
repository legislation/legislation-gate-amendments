%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

:-op(800,xfx,'~>').

fill_gaps_required:-fail.
top_down(partList).

% Hierarchy of fragment labelling
% - we can have "1(1)(a)(i)" is a single reference, but not "(i)(a)(1)1"
% These are used within the partRange rule
number~>brackettedNumber.
upperLetter~>brackettedNumber.
brackettedNumber~>brackettedLetter.
brackettedLetter~>brackettedLowerRoman.
brackettedNumber~>brackettedLowerRoman.
letterDottedPart~>numberDottedPart.
letterDottedPart~>brackettedLetter.
numberDottedPart~>brackettedLetter.
numberDottedPart~>brackettedNumber.
number~>brackettedLetter.
upperLetter~>brackettedLetter.

part ==> disj([
	number:[ptype:=number,text:= '/'+(@label)],
	upperLetter:[ptype:=upperLetter,text:= '/'+(@label)],
	brackettedNumber:[ptype:=brackettedNumber,text:= '/'+(@label)],
	brackettedLetter:[ptype:=brackettedLetter,text:= '/'+(@label)],
	brackettedLowerRoman:[ptype:=brackettedLowerRoman,text:= '/'+(@label)],
	letterDottedPart:[ptype:=letterDottedPart,text:= '/'+(@label)],
	numberDottedPart:[ptype:=numberDottedPart,text:= '/'+(@label)],
	romanNumber:[ptype:=romanNumber,text:= '/'+(@label)],
	brackettedRomanNumber:[ptype:=brackettedRomanNumber,text:= '/'+(@label)]
]).

partRange ==> disj([
	seq([ part:[ptype:= @ptype,list:= list((@text)+'/rangeStart')],
		space,to,space,
		part:[#ptype = @ptype,list:= collect((@text)+'/rangeEnd',#list)] ]),
	seq([ part:[ptype:= @ptype,text:= @text],
		partList:[#ptype ~> @ptype,list:= map_prepend(@list,#text)] ]),
	part:[ptype:= @ptype,list:= list(@text)]
]).

partList ==> seq([
	partRange:[ptype:= @ptype,list:= @list],
	*(seq([ comma,space,partRange:[#ptype= @ptype,list:=append(#list,@list)] ])),
	?(seq([ ?(comma),space,and,space,partRange:[#ptype= @ptype,list:=append(#list,@list)] ]))
]).

'LegRef' ==> disj([
	'theAnnex':[type:=annex,list:=list('/annex')],
	'theAppendix':[type:=annex,list:=list('/appendix')],
	'theSchedule':[type:=schedule,list:=list('/schedule')],
	'theForm':[type:=form,list:=list('/form')],
	seq([ partLabel:[@class='annex',type:=annex],space, partList:[ptype:= @ptype, list:= map_prepend(@list,'/annex')] ]),
	seq([ partLabel:[@class='appendix',type:=appendix],space, partList:[ptype:= @ptype, list:= map_prepend(@list,'/appendix')] ]),
	seq([ partLabel:[@class='schedule',type:=schedule,ptype:=number], space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/schedule')] ]),
	seq([ partLabel:[@class='schedule',type:=schedule,ptype:=upperLetter], space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/schedule')] ]),
	seq([ partLabel:[@class='form',type:=form], space, partList:[ptype:= @ptype, list:= map_prepend(@list,'/form')] ]),
	seq([ partLabel:[@class='chapter',type:=chapter,ptype:=romanNumber], space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/chapter')] ]),	
	seq([ partLabel:[@class='chapter',type:=chapter2,ptype:=number], space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/chapter')] ]),	
	seq([ partLabel:[@class='chapter',type:=chapter2,ptype:=upperLetter], space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/chapter')] ]),	
	seq([ partLabel:[@class='group',type:=group,ptype:=number], space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/group')] ]),	% e.g. http://www.legislation.gov.uk/ukpga/2019/1/schedule/18/paragraph/13/enacted
	seq([ partLabel:[@class='note',type:=note,ptype:=brackettedNumber], space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/note')] ]),
	seq([ partLabel:[@class='section',type:=section,ptype:=number], space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/section')] ]),
	seq([ partLabel:[@class='section',type:=section,ptype:=upperLetter], space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/section')] ]),
	seq([ partLabel:[@class='subsection',type:=subsection,ptype:=brackettedNumber], space, partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='article',type:=article,ptype:=number],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/article')] ]),
	seq([ partLabel:[@class='article',type:=article,ptype:=upperLetter],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/article')] ]),
	seq([ partLabel:[@class='regulation',type:=regulation,ptype:=number],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/regulation')] ]),
	seq([ partLabel:[@class='regulation',type:=regulation,ptype:=upperLetter],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/regulation')] ]),
	seq([ partLabel:[@class='rule',type:=rule,ptype:=number],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/rule')] ]),
	seq([ partLabel:[@class='rule',type:=rule,ptype:=upperLetter],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/rule')] ]),
	seq([ partLabel:[@class='rule',type:=rule,ptype:=numberDottedPart],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/rule')] ]),
	seq([ partLabel:[@class='paragraph',type:=paragraph1,ptype:=number],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/paragraph')] ]),
	seq([ partLabel:[@class='paragraph',type:=paragraph1,ptype:=upperLetter],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/paragraph')] ]),
	seq([ partLabel:[@class='paragraph',type:=paragraph2,ptype:=brackettedNumber],space, partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='paragraph',type:=paragraph3,ptype:=brackettedLetter],space, partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='paragraph',type:=subsubparagraph,ptype:=brackettedLowerRoman],space, partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='subparagraph',type:=subparagraph2,ptype:=brackettedNumber],space, partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='subparagraph',type:=subparagraph,ptype:=brackettedLetter],space, partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='subparagraph',type:=subsubparagraph,ptype:=brackettedLowerRoman],space, partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='subsubparagraph',type:=subsubparagraph,ptype:=brackettedLowerRoman],space, partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='point',type:=point0,ptype:=letterDottedPart],space,partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='point',type:=point0_1,ptype:=number],space,partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='point',type:=point0_1,ptype:=upperLetter],space,partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='point',type:=point1,ptype:=numberDottedPart],space,partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='point',type:=point2,ptype:=brackettedLetter],space,partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='point',type:=point3,ptype:=brackettedNumber],space,partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='point',type:=point4,ptype:=brackettedLowerRoman],space,partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='point',type:=point5,ptype:=brackettedRomanNumber],space,partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='step',type:=step,ptype:=number],space,partList:[#ptype= @ptype, list:= map_prepend(@list,'/step')] ]),  % e.g. http://www.legislation.gov.uk/ukpga/2019/1/section/7/enacted#section-7-3
	seq([ partLabel:[@class='part',type:=part,ptype:=number],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/part')] ]),
	seq([ partLabel:[@class='part',type:=part,ptype:=upperLetter],space, partList:[#ptype= @ptype, list:= map_prepend(@list,'/part')] ]),
	seq([ partLabel:[@class='subpart',type:=subpart],space, partList:[ptype:= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='table',type:=table],space, partList:[ptype:= @ptype, list:= map_prepend(@list,'/table')] ]),
	seq([ partLabel:[@class='item',type:=item,ptype:=number],space, partList:[#ptype= @ptype, list:= @list] ]),
	seq([ partLabel:[@class='item',type:=item,ptype:=upperLetter],space, partList:[#ptype= @ptype, list:= @list] ])
]).

'LegRefMapping' ==> seq([
	'LegRef':[fromList:= @list,type:= @type],
	space,as,space,
	'partRange':[toList:= @list]
]).
