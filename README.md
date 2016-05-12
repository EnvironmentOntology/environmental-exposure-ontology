[![Build Status](https://travis-ci.org/cmungall/environmental-conditions.svg?branch=master)](https://travis-ci.org/cmungall/environmental-conditions)
[![DOI](https://zenodo.org/badge/13996/cmungall/environmental-conditions.svg)](https://zenodo.org/badge/latestdoi/13996/cmungall/environmental-conditions)

## Environmental conditions, treatments and exposures ontology (ECTO)

The purpose of this ontology is to create compositional classes that
assemble existing OBO ontologies such as ExO, CHEBI and ENVO to make
ready-made precomposed classes for use in describing:

 * experimental treatments of plants and model organisms (e.g. modification of diet, lighting levels, temperature)
 * exposures of humans or any other organisms to stressors through a variety of routes
 * any kind of environmental condition or change in condition that can be experienced by an organism or population of organisms on earth

The scope is very general and can include for example plant treatment regimens, as well as human clinical exposures (although these may better be handled by a more specialized ontology)

An example of a class (in manchester syntax) is:

```
Class: ECTO:0000977
 Annotations: rdfs:label "exposure to ultrafine respirable suspended particulate matter via inhalation"
 Annotations: IAO:0000115 "A exposure event involving the interaction of an exposure receptor to ultrafine respirable suspended particulate matter via inhalation."
 Annotations: oio:hasExactSynonym "ultrafine respirable suspended particulate matter exposure, via inhalation"
 EquivalentTo: ExO:0000002 and RO:0002233 some ENVO:01000416 and BFO_0000050 some ExO:0000057 ## 'exposure event' and 'has input' some ultrafine respirable suspended particulate matter and 'part of' some inhalation
```

### Relationships to other ontologies

Ontologies used in composition:

 * ExO - used as the upper ontology, for based classes such as 'exposure', different routes such as 'ingestion'
 * CHEBI - use for both entities and roles
 * ENVO - environmental materials
 * NPO - radiation
 * RO - relations

Similar ontologies

 * ZECO - zebrafish specific conditions
 * EO - plant specific conditions
 * GO - `response to X` subset shadows many classes here
 * SNOMED - has an exposure subset
 * NCIT - has an exposure subset?
 * XCO - experimental conditions (mammal-centric?)

See below for the merger experiment with these ontologies.

### Releases

Release files are in top level

 * [obo](ecto.obo)
 * [owl](ecto.owl)

Note: these are only for testing so far, not stable! These should not be considered real releases.

The proposed ID space is very tentative

### Design Patterns

We use Dead Simple OWL Design Patterns (DOSDPs)

See [src/patterns](src/patterns)

The basic idea is that a term like 'increased exposure to arsenic through ingestion/diet' can be composed using classes from ontologies such as ExO and CHEBI

### Ontology Source

Most of the ontology is stored as CSVs in [src/ontology/modules](src/ontology/modules)

See the Makefile for how the ontology is compiled from CSV modules.

See the .omn files for a human-readable set of descriptions

### Merge Experiment

See [src/mappings](src/mappings) for an exploration of merging multiple exposure ontologies using kboom

The intent is not to use this ontology: rather to help gap fill and understand what is out there.

