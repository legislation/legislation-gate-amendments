%
% (c) Crown copyright
% 
% You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence
%
% http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2
%

test(xml_map/2,to_xml_1,
	( test_data(1,Es,XmlRequired),
	  xml_map(Xml,Es) ),
	Xml=XmlRequired ).	

test(xml_map/2,from_xml_1,
	( test_data(1,EsRequired,Xml),
	  xml_map(Xml,Es) ),
	Es=EsRequired ).	
	
test_data(1,
	% Prolog Repn
	[edge(1,2,token,s{thing:val1}),
	 edge(2,3,spaceToken,s{thing:val2})],
	% Prolog XML repn.
	element(annotationSet,
        [],
        [ element(annotation,
                  [endOffset='2',startOffset='1',type=token],
                  [ element(features,
                            [],
                            [ element(listValuedMap,[],[]),
                              element(map,
                                      [],
                                      [ element(entry,
                                                [],
                                                [ element(key,
                                                          [],
                                                          [thing]),
                                                  element(value,
                                                          [],
                                                          [val1])
                                                ])
                                      ])
                            ])
                  ]),
          element(annotation,
                  [endOffset='3',startOffset='2',type=spaceToken],
                  [ element(features,
                            [],
                            [ element(listValuedMap,[],[]),
                              element(map,
                                      [],
                                      [ element(entry,
                                                [],
                                                [ element(key,
                                                          [],
                                                          [thing]),
                                                  element(value,
                                                          [],
                                                          [val2])
                                                ])
                                      ])
                            ])
                  ])
        ])
).

