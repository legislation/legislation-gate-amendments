# GATE Legislation Amendments pipeline

A [GATE](https://gate.ac.uk/) natural language processing pipeline that takes in UK legislation XML (in the [CLML](https://legislation.github.io/clml-schema/) dialect) and outputs:

 * a marked-up XML copy of that legislation with various features identified, which you can convert to an annotated PDF using a transform bundled with this package;
 * a set of “effects” (a representation of the amendments to other legislation) that the input document contains—you can convert these to an Excel spreadsheet using another transform bundled with this package.

For more information, you can read:

 * the [getting started](doc/getting-started/getting-started.md) guide, to find out how to run the pipeline;
 * the [technical overview](doc/overview.md) of the pipeline; and
 * the [Prolog Parser](doc/prolog-chart-parser/prolog-chart-parser.md) overview, which explains the purpose of that parser.

## Licence

Copyright © Crown copyright 2023.

This code is released under the GNU Lesser General Public License v3.0, as it contains code from the [GATE](https://gate.ac.uk) project licenced under the LGPLv3. For more information, read the [licence](LICENCE.txt).
