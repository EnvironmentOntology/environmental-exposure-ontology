# ----------------------------------------
# Standard Constants
# ----------------------------------------
OBO=http://purl.obolibrary.org/obo
USECAT= --catalog-xml catalog-v001.xml
SRC=ecto-edit.obo
ONTDIR=.
MODDIR=modules
DATE=`date +%Y-%m-%d`

# ----------------------------------------
# Modules (by design pattern)
# ----------------------------------------
# we stratify into two groups,
# tuples should unique in each group
MODS1 =\
exposure_to_radiation\
exposure_to_material\
exposure_to_environmental_process\
exposure_to_environmental_condition\
exposure_to_chemical\
exposure_to_chemical_with_role\
exposure_to_levels_in_medium\
exposure_to_change_in_levels\
exposure_via_route\
activity\
surgical_procedure\
exposure_to_infection

MODS2 =\
prenatal\
dietary_exposure_to_chemical_with_role\
dietary_exposure_to_chemical

MODS = $(MODS1) $(MODS2)
MODS_CSV = $(patsubst %,$(MODDIR)/%.csv,$(MODS))
MODS1_CSV = $(patsubst %,$(MODDIR)/%.csv,$(MODS1))
MODS2_CSV = $(patsubst %,$(MODDIR)/%.csv,$(MODS2))

# Additional includes
CONSTRUCTS= embedded-definition make-subset
INCLUDES_OWL = $(patsubst %,include-%.owl,$(CONSTRUCTS))

# ----------------------------------------
# Top level targets
# ----------------------------------------
#
# Main steps:
#
# (ecto-edit + modules) --[merge]--> ecto-core --[reason]--> ecto-core-inferred --[add CONSTRUCTS]--> pre --[annotate]--> ecto
# 
all: all_imports all_modules ecto.json.gz ecto.owl ecto.obo all_subsets 
all_subsets: subsets/ecto-basic.obo
test: all
release: all copy-release

# Last step:
# Copy from staged release to destination
TARGETS = $(ONTDIR)/ecto.obo $(ONTDIR)/ecto.owl $(ONTDIR)/ecto.json.gz imports subsets
copy-release:
	cp -pr $(TARGETS) catalog-v001.xml ../.. && cd ../.. && git add imports/*

# CORE is the edited source (minimal) plus compiled modules
ALL_MODS_OWL = $(patsubst %, $(MODDIR)/%.owl, $(MODS))
ecto-core.owl: ecto-edit.obo xrefs/ecto-xrefs.owl $(ALL_MODS_OWL)
	owltools $(USECAT) $^ --merge-support-ontologies -o -f ofn $@
ecto-core.obo: ecto-core.owl
	owltools $(USECAT) $< -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

# Basic inference
ecto-core-inferred.owl: ecto-core.owl
	robot reason --input $< --reasoner elk -e false reduce --reasoner elk -o $@
.PRECIOUS: ecto-core-inferred.owl

ecto-pre.owl: ecto-core-inferred.owl $(INCLUDES_OWL)
	owltools $^ --merge-support-ontologies -o $@


# Annotate with version info
ecto.owl: ecto-pre.owl
	robot annotate -i $< -O $(OBO)/$@ -V $(OBO)/ecto/releases/$(DATE)/ecto.owl -o $@

# convert
ecto.obo: ecto.owl
	owltools $(USECAT)  $< --merge-imports-closure -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

# convert
ecto.json: ecto.owl
	owltools $(USECAT)  $<  -o -f json  $@.tmp && mv $@.tmp $@
ecto.json.gz: ecto.json
	gzip -f $<

# ----------------------------------------
# Subsets
# ----------------------------------------

# Simple version (isa/partof)
subsets/ecto-basic.owl: ecto-pre.owl
	owltools $(USECAT) $< --remove-imports-declarations --make-subset-by-properties -f BFO:0000050 --remove-dangling --remove-axioms -t EquivalentClasses --set-ontology-id $(OBO)/ecto/$@ -o $@

subsets/%.obo: subsets/%.owl
	robot convert -i $< -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@

subsets/mrex.owl: subsets/ecto-basic.owl
	owltools $< --extract-ontology-subset -s mrex --fill-gaps --set-ontology-id $(OBO)/ecto/$@ -o $@

# ----------------------------------------
# SPARQL
# ----------------------------------------


# generate includes from sparql CONSTRUCT queries;
# these can then be merged in to the main ontology
include-%.owl: sparql/construct-%.sparql ecto-core.owl
	robot merge -i ecto-core.owl query -c $< $@.tmp.ttl -f ttl && robot annotate -i $@.tmp.ttl -O $(OBO)/ecto/$@ -o $@

# ----------------------------------------
# Regenerate imports
# ----------------------------------------
# Uses OWLAPI Module Extraction code

# Type 'make imports/X_import.owl' whenever you wish to refresh the import for an ontology X. This is when:
#
#  1. X has changed and we want to include these changes
#  2. We have added onr or more new IRI from X into ecto-edit.owl
#  3. We have removed references to one or more IRIs in X from ecto-edit.owl
#
# You should NOT edit these files directly, changes will be overwritten.
#
# If you want to add something to these, edit ecto-edit.owl and add an axiom with a IRI from X. You don't need to add any information about X.

# Ontology dependencies
# We don't include clo, as this is currently not working
IMPORTS = pato envo npo exo xco ro chebi activity uberon ncbitaxon

# Make this target to regenerate ALL
all_imports_owl: $(patsubst %, imports/%_import.owl,$(IMPORTS))
all_imports_obo: $(patsubst %, imports/%_import.obo,$(IMPORTS))
all_imports: all_imports_owl all_imports_obo


# SEED: File used to seed module extraction
# Derives from (1) curated list (2) whatever is referenced in core (edit+modules)
imports/seed.tsv: ecto-core.owl imports/seed_curated.tsv
	owltools $(USECAT) $< --merge-support-ontologies --export-table $@.tmp &&\
	cut -f1 $@.tmp imports/seed_curated.tsv | sort -u > $@

# IMPORT MODULE
imports/%_import.owl: $(SRC) mirror/%.owl.gz imports/seed.tsv
	gzip -dc mirror/$*.owl.gz > mirror/copy-$*.owl &&\
	robot extract -i mirror/copy-$*.owl -T imports/seed.tsv -m BOT -O $(OBO)/ecto/$@ -o $@.tmp.owl && mv $@.tmp.owl $@ &&\
	rm mirror/copy-$*.owl

imports/%_import.obo: imports/%_import.owl
	owltools $(USECAT) $< -o -f obo --no-check $@

# MIRRORING: default is to download obo (faster)
# wget-obo --[convert]--> owl --[gzip] --> owl.gz
#mirror/%.gz: mirror/%
#	gzip -f $<
#.PRECIOUS: mirror/%.gz

# wget from OBO
mirror/%.obo:
	wget --no-check-certificate $(OBO)/$*.obo -O $@.tmp && mv $@.tmp $@ && touch $@
.PRECIOUS: mirror/%.obo

OGZIP =  -o mirror/$*.owl && gzip -f mirror/$*.owl

# convert and trim
KEEPRELS = BFO:0000050 BFO:0000051 RO:0002202 immediate_transformation_of
mirror/%.owl.gz: mirror/%.obo
	owltools $< --remove-annotation-assertions -r -l -s --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS) $(OGZIP)
.PRECIOUS: mirror/%.owl

# custom mirror: RO
mirror/ro.owl.gz:
	owltools $(OBO)/ro.owl --merge-imports-closure -o mirror/ro.owl && gzip -f mirror/ro.owl
.PRECIOUS: mirror/ro.owl

# custom mirror: ExO
# (not yet in OBO Lib)
mirror/exo.obo:
	wget --no-check-certificate https://raw.githubusercontent.com/CTDbase/exposure-ontology-draft/master/src/ontology/exo.obo -O $@ && touch $@
.PRECIOUS: mirror/%.owl

# custom mirror: NCIT activity subset
# (not yet in OBO Lib)
mirror/activity.obo:
	wget --no-check-certificate $(OBO)/ncit.obo -O $@
#	blip ontol-query -r ncit -query "class(R,'Activity'),subclassRT(ID,R)" -to obo > $@.tmp && grep -v ^property $@.tmp | perl -npe 's@(.*)@lc($1)@e if m@^name@' > $@

# TODO: why is this different from generic?
mirror/chebi.obo:
	wget $(OBO)/chebi.obo -O $@.tmp && mv $@.tmp $@ && touch $@
.PRECIOUS: mirror/chebi.obo

mirror/npo.obo:
	cp mirror/npo-orig.obo $@

# CHEBI: need to transform their internal properties
mirror/chebi.owl.gz: mirror/chebi.obo
	owltools --use-catalog $<  --rename-entity $(OBO)/chebi#has_part $(OBO)/BFO_0000051 --rename-entity $(OBO)/chebi#has_role $(OBO)/RO_0000087  --remove-annotation-assertions -r -l -s -d --set-ontology-id $(OBO)/chebi.owl -o mirror/chebi.owl && gzip -f mirror/chebi.owl
.PRECIOUS: mirror/chebi.owl

# UBERON: use basic
mirror/uberon.owl:
	owltools $(OBO)/uberon/basic.owl --remove-annotation-assertions -r -l -s -d --remove-axiom-annotations --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS) --set-ontology-id $(OBO)/uberon.owl -o mirror/uberon.owl && gzip -f mirror/uberon.owl
.PRECIOUS: mirror/%.owl

# PO
mirror/po.owl.gz:
	owltools $(OBO)/po.owl --remove-annotation-assertions -r -l -s -d --remove-axiom-annotations --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS) --set-ontology-id $(OBO)/po.owl -o mirror/po.owl && gzip -f mirror/po.owl
.PRECIOUS: mirror/%.owl

# NCBITaxon
ncbitaxon.obo:
	wget -N $(OBO)/ncbitaxon.obo
.PRECIOUS: ncbitaxon.obo
mirror/ncbitaxon.owl.gz: ncbitaxon.obo
	OWLTOOLS_MEMORY=12G owltools $< --remove-annotation-assertions -r -l -s -d --remove-axiom-annotations --remove-dangling-annotations  --set-ontology-id $(OBO)/ncbitaxon.owl -o mirror/ncbitaxon.owl && gzip -f mirror/ncbitaxon.owl
.PRECIOUS: mirror/ncbitaxon.owl

# PCO
#mirror/pco.owl: imports/pco_basic.obo
#	OWLTOOLS_MEMORY=12G owltools $< --set-ontology-id $(OBO)/pco.owl -o $@

# ----------------------------------------
# SYNS
# ----------------------------------------

# avoid circular dependencies with imports;
# some patterns refer to ECTO classes; we use the previous version for this
# TODO: use obographs, and don't centralize assumptions about synonyms in central pattern2owl script.
# Note that this pipeline also introduces a dependency on the perl JSON.pm module..
SYNFILES = imports/uberon_import.obo
syns.json: mirror/chebi.obo last-ecto.obo mirror/envo.obo imports/curated_synonyms.obo
	extract-obo-syns.pl $^ $(SYNFILES) > $@.tmp && mv $@.tmp $@

# temp hack: use last version to avoid cycle dependencies
last-ecto.obo:
	wget --no-check-certificate https://raw.githubusercontent.com/EnvironmentOntology/environmental-exposure-ontology/master/ecto.obo -O $@


# ----------------------------------------
# DESIGN PATTERNS AND TEMPLATES
# ----------------------------------------

#
# (yaml + csv) --[apply-pattern]--> (omn + gci) --[owltools-set-oid]--> rdf --[convert]-->{owl,obo}
#

all_modules: all_modules_omn all_modules_owl all_modules_obo
all_modules_owl: $(patsubst %, $(MODDIR)/%.owl, $(MODS))
all_modules_omn: $(patsubst %, $(MODDIR)/%.omn, $(MODS))
all_modules_obo: $(patsubst %, $(MODDIR)/%.obo, $(MODS))

$(MODDIR)/%.omn: $(MODDIR)/%.csv ../patterns/%.yaml syns.json
	apply-pattern.py -S syns.json -P curie_map.yaml -b http://purl.obolibrary.org/obo/ -i $< -p ../patterns/$*.yaml -G $(MODDIR)/$*-gci.owl > $@.tmp && mv $@.tmp $@

$(MODDIR)/%.rdf: $(MODDIR)/%.omn 
	owltools $^ --merge-support-ontologies --set-ontology-id $(OBO)/ecto/$@ -o  $@

$(MODDIR)/%.owl: $(MODDIR)/%.rdf
	owltools $< -o -f ofn $@

$(MODDIR)/%.obo: $(MODDIR)/%.owl
	owltools $< -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp > $@


# NOT CURRENTLY USED
$(MODDIR)/existential-graph.owl: ecto-core.owl
#	owltools $(USECAT) $< --merge-support-ontologies --reasoner elk --silence-elk --materialize-gcis --reasoner mexr --remove-redundant-inferred-svfs --reasoner elk --remove-redundant-svfs  --set-ontology-id $(OBO)/ecto/$@ -o $@


## HACKS

# for reporting
#ecto-edit.csv: ecto-edit.obo
#	owltools $(USECAT) $< --merge-support-ontologies --export-table $@.tmp && cut -f1 $@.tmp  > $@

# ----------------------------------------
# CSV QC and auto-filling
# ----------------------------------------
checkcsvs:
	fill-col1-ids.pl --skip-dupes -n $(MODS_CSV)
	fill-col1-ids.pl -n $(MODS1_CSV)
	fill-col1-ids.pl -n $(MODS2_CSV)
fill: ecto-edit.csv checkcsvs
	fill-col1-ids.pl --skip-dupes $(MODS_CSV)
testfill: ecto-edit.csv checkcsvs
	fill-col1-ids.pl -n --skip-dupes $(MODS_CSV)

testfill2: ecto-edit.csv
	fill-col1-ids.pl --skip-dupes -n $(MODS_CSV)

