Consult the [patterns folder](../../patterns) for more details.

DO NOT EDIT THE OBO OR OWL - these are derived. __Edit the CSV.__

## Editors guide

You do not need to add the ID - this is done automatically by the Makefile.

For example, if editing [exposure_via_route.csv](exposure_via_route.csv), you can just add a row at the end:

```
iri,iri label,stressor,stressor label,route,route label
....
,,CHEBI:64220,monosodium glutamate,ExO:0000056,ingestion
```

in the ontology directory, type:

```
make fill
```

this will add the next ID:

```
iri,iri label,stressor,stressor label,route,route label
....
ECTO:0001590,,CHEBI:64220,monosodium glutamate,ExO:0000056,ingestion
```

Note you can override the label if you like. Or you can leave it
blank, in which case it will be derived the OWL from the pattern
specification.

Here is how this row is transformed in [exposure_via_route.omn](exposure_via_route.omn)

```
Class: CHEBI:64220 ## monosodium glutamate
Class: ExO:0000056 ## ingestion
## {"stressor": "CHEBI:64220", "route": "ExO:0000056"}
Class: ECTO:0001590
 Annotations: rdfs:label "exposure to monosodium glutamate via ingestion"
 Annotations: IAO:0000115 "A exposure event involving the interaction of an exposure receptor to monosodium glutamate via ingestion."
 Annotations: oio:hasExactSynonym "monosodium glutamate exposure, via ingestion"
 EquivalentTo: ExO:0000002 and RO:0002233 some CHEBI:64220 and BFO_0000050 some ExO:0000056 ## 'exposure event' and 'has input' some monosodium glutamate and 'part of' some ingestion
```

You can think of this as a kind of TermGenie like system.
