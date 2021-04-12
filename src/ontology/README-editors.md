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

# ECTO Workflows

## Making a new release

There are three major steps involved in creating a new release:
1. Preparation
   1. Make sure that all pull requests that are supposed to be merged are merged
   1. Make sure that all changes to master are committed to Github (`git status` should say that there are no modified files)
   1. Wait for the travis QC to finish
   1. On you local machine, go to the master branch and run `git pull` to ensure that all your remote changes are available locally.
   1. Make sure you have the latest ODK installed by running `docker pull obolibrary/odkfull`
2. Building the ontology
   1. Open a command line terminal window and navigate to the src/ontology directory (`cd myectordir/src/ontology`)
   1. Create a new branch (ecto-release-20200131 or similar)
   1. If you have recently modified your patterns, run `sh run.sh make IMP=false patterns` once. This will be run again in the next step, but there is a bit of a bug in the ODK (as of January 2020) that it does not understand to look for imported terms in pattern that have just been added. 
   1. Run the build script: `sh run.sh make prepare_release -B`. This command will compile the patterns, refresh the imports and build the ontology release files. Note that this step can take between 45 and 90 minutes - so make sure you do it over night or befor you go to the gym.
   1. If everything went well, you should see the following output on your machine: `Release files are now in ../.. - now you should commit, push and make a release on your git hosting site such as GitHub or GitLab`.
   1. Open the file `myectordir/ecto.owl` in Protege and sanity check for classes with missing labels (on the top level of the hierarchy) and general weirdnesses. In particular, you want to know whether your latest changes to pattern are what you expected.
   1. If it looks sane, commit everything to the new branch you have created, push and create a pull request. Wait for travis to run one last time, but that should not reveal surprises.
   1. In an ideal world, let at least one other person sanity check the ecto release. A good file to sanity check is `ecto-base.obo`, and perhaps even `ecto.obo`: their diffs are easy to review.
   1. Merge the changes into master. 
3. Creating a GitHub release
   1. Go to [ECTO releases](https://github.com/EnvironmentOntology/environmental-exposure-ontology/releases) on GitHub, click "Draft new release"
   1. As the tag version you **need to choose the date on which your ontologies were build.** You can find this, for example, by looking at the `ecto.obo` file and check the `data-version:` property. The date needs to be prefixed with a `v`, so, for example `v2020-02-06`.
   1. You can write whatever you want in the release title, but I typically write the date again. The description underneath should contain a concise list of changes or term additions - Chris has a whole philosophy on this. For now, I recommend you to simply summarising the changed, in particular, which terms have been added or removed.
   1. Click "Publish release". Done.

## Deprecating terms

* Delete the term from the pattern in src/ontology/data/default/x.tsv
* Add a row to src/templates/obsolete.tsv
* run cd src/ontology && sh run.sh make templates components/obsoletes.owl