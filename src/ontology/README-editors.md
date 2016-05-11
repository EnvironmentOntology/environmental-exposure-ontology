These notes are for the EDITORS of ecto

For more details on ontology management, please see the OBO tutorial:

 * https://github.com/jamesaoverton/obo-tutorial

## Source Files

All source files are in this directory (src/ontology)

This is arranged differently than other ontologies. The source is in
two parts:

 * The editors core [ecto-edit.obo](ecto-edit.obo)
 * [modules](modules/)

Most of the classes in ECTO conform to a stereotypical compositional
pattern. Rather than edit these in an ontology editor, they are
specified in tabular format in the TSV files.

These are then compiled down into OBO/OWL during the build process,
according to design pattern specifications. See the [patterns folder](../patterns) for more details.

## Building the ontology

The ontology is built by running

    make

From the src/ontology directory

As a first step, all modules are compiled down into OWL (see the
[travis config](../../.travis.yml) for dependencies).

The OWL versions of the module files are combined with the core module
using OWL tools.


## ID Ranges

This uses a different approach from other ontologies. Terms are added to the CSV. IDs are added by the makefile.

## Release Manager notes

You should only attempt to make a release AFTER the edit version is
committed and pushed, and the travis build passes.

to release:

    cd src/ontology
    make

If this looks good type:

    make prepare_release

This generates derived files such as ecto.owl and ecto.obo and places
them in the top level (../..). The versionIRI will be added.

Commit and push these files.

    git commit -a

And type a brief description of the release in the editor window

IMMEDIATELY AFTERWARDS (do *not* make further modifications) go here:

 * https://github.com/obophenotype/ecto/releases
 * https://github.com/obophenotype/ecto/releases/new

The value of the "Tag version" field MUST be

    vYYYY-MM-DD

The initial lowercase "v" is REQUIRED. The YYYY-MM-DD *must* match
what is in the versionIRI of the derived ecto.owl (data-version in
ecto.obo).

Release title should be YYYY-MM-DD, optionally followed by a title (e.g. "january release")

Then click "publish release"

__IMPORTANT__: NO MORE THAN ONE RELEASE PER DAY.

The PURLs are already configured to pull from github. This means that
BOTH ontology purls and versioned ontology purls will resolve to the
correct ontologies. Try it!

 * http://purl.obolibrary.org/obo/ecto.owl <-- current ontology PURL
 * http://purl.obolibrary.org/obo/ecto/releases/YYYY-MM-DD.owl <-- change to the release you just made

For questions on this contact Chris Mungall or email obo-admin AT obofoundry.org

# Travis Continuous Integration System

Check the build status here: [![Build Status](https://travis-ci.org/obophenotype/ecto.svg?branch=master)](https://travis-ci.org/ecto-ontology/ecto)

This replaces Jenkins for this ontology

## General Guidelines

See:
http://wiki.geneontology.org/index.php/Curator_Guide:_General_Conventions
