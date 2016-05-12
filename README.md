[![Build Status](https://travis-ci.org/cmungall/environmental-conditions.svg?branch=master)](https://travis-ci.org/cmungall/environmental-conditions)
[![DOI](https://zenodo.org/badge/13996/cmungall/environmental-conditions.svg)](https://zenodo.org/badge/latestdoi/13996/cmungall/environmental-conditions)

## Environmental conditions, treatments and exposures ontology (ECTO)

### Releases

Release files are in top level

 * [obo](ecto.obo)
 * [owl](ecto.owl)

Note: these are only for testing so far, not stable!



### Design Patterns

We use DOSDPs

See [src/patterns](src/patterns) 

### Ontology Source

Most of the ontology is stored as CSVs in [src/ontology/modules](src/ontology/modules)

See the Makefile for how the ontology is compiled from CSV modules.

### Merge Experiment

See [src/mappings](src/mappings) for an exploration of merging multiple exposure ontologies using kboom

The intent is not to use this ontology: rather to help gap fill and understand what is out there.

