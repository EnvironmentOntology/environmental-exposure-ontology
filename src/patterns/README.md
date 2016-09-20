# Design Patterns

This folder contains design patterns for groupings of classes in the ontology.

The design patterns are specified in YAML, and follow the [dead_simple_design_patterns](https://github.com/dosumis/dead_simple_owl_design_patterns/) specification

Consult each yaml file for details on the specific pattern.

# Implementation

The design patterns act as templates, with template values coming from the CSVs in the [ontology/modules](../ontology/modules) directory. [pattern2owl](https://github.com/cmungall/pattern2owl) is used to translate the TSVs to OWL. See the [Makefile](../ontology/Makefile) for more details

# General Design Principles

## Species-neutrality

We strive for species-neutrality. This means that we do not bake in
assumptions such as the surroundings of the organism being air; the
ontology can be used for fish and other aquatic organisms.

In some circumstances some assumptions are already baked in, e.g. via
CHEBI roles such as 'toxin'.

Some non-human use cases:

 * http://www.nature.com/articles/srep33207 - bee exposome       

## Experimental vs Non-experimental conditions

Some ontologies designed for model organisms bake in assumptions that
certain kinds of conditions are experiments - e.g. surgical
manipulations.

In general, we try and represent conditions in a way that is neutral
w.r.t the experimental context. When specifying the context is
necessary, we will follow a standard subclass pattern, e.g.

 * surgical manipulation
    * surgical manipulation in experimental context
    * surgical manipulation in clinical context

