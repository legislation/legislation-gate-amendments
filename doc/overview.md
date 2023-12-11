# Overview of the eMarkup Pipeline #

## Overall Workflow ##

The legislation.gov.uk eMarkup pipeline was developed to automate the process of identifying amendments in legislation&mdash;that is, instructions in the text of legislation that specify changes or modifications to be made to other items of legislation.

The pipeline ingests an item of legislation as CLML (a dialect of XML for encoding the content of UK legislation), and it produces both an enriched version of the document CLML and a separate XML file that contains the amendments. This XML is transformed into a &ldquo;table of effects&rdquo; (or TOES) that the editorial team at Legislation.gov.uk use to identify where and how to apply amendments.

Currently, the pipeline successfully identifies many amendments. However, we expect to further refine the pipeline in future to improve the accuracy and scope of the mark-up process. Some known limitations and areas for potential improvement are noted below.

In the Expert Participation Programme (EPP) for [Legislation.gov.uk](https://www.legislation.gov.uk), the eMarkup pipeline runs on top of a bespoke data enrichment platform called the Data Enrichment Service (DES). However, it can also be run in the GATE developer environment or called from other code.

## GATE Pipeline ##

The first few pipeline components are out-of-the-box GATE components. These do basic jobs required in almost any text processing pipeline. The legislation-specific components then follow.

### ANNIE English Tokeniser ###
The tokeniser splits the document into tokens. For the most part, tokens correspond to words, although for certain words (such as hyphenated words or abbreviations), the tokeniser may split the word into multiple separate tokens (for example, “don't” becomes “do” and “n't”).

This is a part of the core GATE distribution.

### ANNIE Sentence Splitter ###
The sentence splitter finds the start and end of sentences. It normally performs well at this task, but can be thrown by unusual punctuation.

This is a part of the core GATE distribution.

### ANNIE POS Tagger ###
The Part-of-speech tagger (or POS tagger) identifies the part of speech to which each token belongs. This is a challenging task and there are superior POS tagging implementations available&mdash;for example, the Stanford parser is a more modern and capable tagger.

This is a part of the core GATE distribution.

### GATE Morphological Analyser ###
The analyser looks at words, along with their part-of-speech tags, and attempts to compute a morphological root. For instance, the result of processing the word “enforcing” is “enforce”.

The use of morphological analysis and part-of-speech tagging to identify word roots is a more sophisticated alternative to stemming, an different approach for computing the root of a word that involves identifying and removing common affixes (the result of which is a root that may not be a real word).

This is a part of the core GATE distribution.

### Initialisation Jape Transducer ###

This transducer contains the following components:

#### legislation\_retain\_from\_XML ####
This component extracts certain elements of the legislation mark-up that are useful to the extraction process. This initialisation process first executes a JAPE grammar that transfers the necessary mark-up into a “Legislation” annotation set, which is then the annotation set that most of the subsequent steps use. (GATE permits multiple annotation sets to be used concurrently, which provides a means to separate out annotations.)

#### legislation\_footnote\_citations ####
This component deals with legislation details in footnotes.  It builds a look-up table of footnote reference and legislation URI, which it then attaches to the feature map of the document.

#### legislation\_footnote\_citations\_2 ####
This component extends footnote annotations so that they are not empty and so can be matched on LHS (left-hand side) of JAPE rules.

### Legislation Prepare Transducer ###
This transducer performs a number of tasks that do some preliminary tests to highlight/fix things for later use.

#### legislation-prework ####
This component undertakes the task of trying to determine whether the word “the” is a potential candidate for the start of the title of an item of legislation.

#### legislation-prework_2 ####
This component corrects an issue with the tokeniser which leaves dashes at the ends of words as part of the word, rather than a separate token.

#### legislation\_secondary\_legislation ####
This component undertakes the task of trying to identify the titles of secondary legislation simply from the words in a sentence. This is to supplement the later stage that uses look-up lists for identifying legislation. The problem arises, especially in secondary legislation, that the length and complexity of the titles makes it very likely that subtle differences occur (such as the use of brackets or punctuation). This JAPE grammar creates a normalised version of the title it has identified that can later be compared against a similarly normalised version of the title used for look-up.

### Flexible Legislation Gazetteer ###
This component makes use of the normalised titles produced by the preceding transducer. It match the computed normalised titles against a gazetteer (a set of lists containing the names of entities, in this case legislation titles).

The component uses a &ldquo;[flexible gazetteer](https://gate.ac.uk/userguide/sec:gazetteers:flexgazetteer)&rdquo;. Unlike a regular [GATE gazetteer](http://gate.ac.uk/userguide/chap:gazetteers), which only looks up names in the text of a document, a flexible gazetteer allows for look-ups to use features other than document text. In this case, the component uses the normalised title of the legislation, which the preceding transducer stores in a “normalText” feature on a TempLegislation annotation.

### Generic Gazetteer ###
The generic gazetteer applies a range of look-ups to the document, mainly covering legislation titles and dates. It looks up names using the following lists:

 * des\_legislation\_ukpga.lst
 * des\_legislation\_ukpga_short.lst
 * des\_legislation\_asp.lst
 * des\_legislation\_nia.lst
 * des\_legislation\_apni.lst
 * des\_legislation\_mnia.lst
 * des\_legislation\_mwa.lst
 * des\_legislation\_ukcm.lst
 * des\_legislation\_ukla.lst
 * des\_legislation\_uksi.lst
 * des\_legislation\_key.lst
 * des\_month.lst
 * des\_day.lst
 * des\_dateday.lst

### Sections Prepare Transducer ###
This transducer prepares a set of annotations relating to citations of provision of legislation. The Prolog parser for sections (see below) uses these annotations as input. The transducer contains two components, “sections_prepare_1” and “sections_prepare_2”.

#### sections\_prepare\_1 ####
This component identifies primitive components of citations of provisions of legislation, such as numbers, letters, bracketted roman numerals etc.

#### sections\_prepare\_2 ####
This component removes annotations in certain places where they are not relevant to effects.

### Prolog Parser&mdash;Sections ###
The purpose of the Prolog parser for sections is to identify citations of provisions, including ranges and sequences of provisions, and to create corresponding LegRef annotations. Each output LegRef annotation has a **list** feature, which contains a list of partial URI paths to the relevant provisions.

The input and output of the parser are the annotations sets **Section0** and **Section1**, respectively. At the end of the process, the parser transfers the LegRef annotations into the Legislation annotation set.

### Generic Transducer ###
This transducer contains the following components:

#### bracketted_phrase ####
This component identifies phrases enclosed in parentheses, possibly containing bracketed provision citations.

#### block\_amendment\_context ####
This component marks annotations which are within LegAmendments.

#### number\_in\_amendment ####
This component collects provisions within LegAmendments so they can be cited in the table of effects.

#### number\_in\_amendment_2 ####
This component identifies leading words in LegAmendment which may need to be represented in an affected provision, as “and word”, “and cross-heading” etc. These are recorded as LegAmendmentModified annotations.

#### number\_in\_amendment_3 ####
This component copies the information from LegAmendmentModified annotations onto feature of corresponding LegAmendment annotation.

#### legislation\_legislation\_prework ####
This component is a simple grammar to identify sentences that potentially contain primary legislation references. It helps with performance.

#### legislation\_legislation\_1 ####
This component identifies references to primary legislation using look-up lists

#### legislation\_legislation\_2 ####
This component identifies references to other legislation using look-up lists

#### legislation\_legislation\_3 ####
This component identifies references to primary legislation from the text to cover where items may have been missed by look-ups.

#### legislation\_legislation\_3a ####
This component removes annotations in certain places.

#### legislation\_legislation\_4 ####
This component looks up URI references from footnotes for legislation citations.

#### legislation\_legislation\_EU ####
This component identifies citations of EU legislation.

#### legislation\_fake\_sections ####
This component is a grammar that attempts to identify references to sections that aren”t actually normal sections.

#### legislation\_quote\_1 ####
This component identifies simple quotes (quoted blocks of text that normally denote the text to be amended in an affected provision).

#### legislation\_quote\_2 ####
This component identifies more complex quotes, including those with other quotes nested inside them.

#### legislation\_quote\_3 ####
This component classifies whether a quote will be represented in the table of effects as “word”, “words” or “sum”. It also identfies signatures.

#### des_date ####
This component identifies dates. (The “des” in its title refers to its origin as a component of TSO's Data Enrichment Service, or DES.)

#### des\_day\_resolution ####
This component performs identification of days and months, and also performs some checks on the dates identified in “des_date” to confirm that they are dates.

#### legislation\_paren\_blocks ####
This component identifies bracketed sections of the document. Normally these can be ignored, but sometimes additional information is provided by these sections. Later stages handle any relevant sections that this component identifies.

#### legislation_extents ####
This component identifies references to phrases that mention the extent of provisions of legislation (that is, the geographical region within which the provisions are in force), where the extent relates to any of the nations of the UK.

#### legislation_interpretation ####
This component identifies terms defined in the interpretation section of a document.

#### legislation\_interpretation\_ref ####
This component takes the phrases identified in the previous stage and finds them within the document. These phrases can usually be identified in this way without ambiguity. However, this component may fail to identify correctly the use of a term that has been defined and then redefined elsewhere within the same document.

#### legislation_anaphor ####
This component identifies anaphoric references, which are phrases that do not directly identify a subject and whose meaning can only be determined using preceding or document-wide information.

#### legislation_actions ####
This component identifies phrases that relate to editorial actions, such as “omit”, “substitute”, and so on.

#### legislation_provisions ####
This component identifies phrases that relate to cross-references within the document generally referring to provisions.

#### legislation_chronology ####
This component creates Chronology/CrossRef annotations dependent on phrases “after the commencement”, “may be cited”, “the title of”.

#### legislation\_amendment\_related ####
This component identifies phrases that refer to parts of the document in a relative manner (e.g. “after the related entry”).

#### legislation\_amendment\_location ####
This component identifies phrases that mention the location at which an amendment should happen (e.g. “after the words”).

#### legislation\_enabling\_power ####
This component identifies phrases relating to the enabling power for the legislation.

#### legislation\_anaphor\_2 ####
This component identifies further anaphors, making use of information identified in earlier phases, which is why it follows later than the first anaphor identification.

#### legislation\_actions\_2 ####
This component identifies further actions making use of other annotations.

#### legislation\_amendment\_location_2 ####
This component identifies more locations at which amendments can take place.

#### legislation_exception ####
This component identifies phrases that indicate exceptions to lists of things.

### Assign IDs Transducer ###
This transducer assigns identifiers to any elements in the body of the document that may be useful to link to from the changes XML that is extracted.

### Prolog Parser&mdash;Effects ###
This parser performs the final parsing of extended contexts across the document (i.e. tracking where we are in the affecting and affected document), identifying descriptions of textual amendments, and cross referencing to construct fully resolved descriptions of effects.

The bottom-up strategy used is robust to the common situation where the parse is imperfect, but we still wish to use those structures that have been found.

The Prolog code also carries out these steps:

 * A retry strategy which allows for stepping over provisions of the affecting document where the parse failed.
 * The conversion of detected effects to XML. The pipeline attaches this XML to the &ldquo;xmlContent&rdquo; feature of the document.

This package contains separate documentation for the Prolog parser, which includes detailed information regarding the parser's operation and its grammar language.

### Namespace Transducer ###
This component adds namespace prefixes to  the annotations that are included in the XML of the processed document.

