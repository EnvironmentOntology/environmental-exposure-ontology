# Mining wikidata for exposures

See the [Makefile](Makefile) for details

Ontology subgraphs are pulled from wikidata using SPARQL queries
(turtle format - we also convert to obo for convenience purposes).

The convention is

 * foo.rq -- base query
 * foo.rdf -- turtle obtained from query on WD
 * foo.obo -- for human readability only, derived from rdf

See https://github.com/cmungall/environmental-conditions/issues/5

## exposure-symptom-assocs

associations between exposures and symptoms, also includes routes

TODO: make route and cause optional

TODO: fix modeling

## symptoms

The symptoms found in the above, as a hierarchy

## exposures

The exposures found in the above, as a hierarchy



