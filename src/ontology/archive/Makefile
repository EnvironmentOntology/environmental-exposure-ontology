OBO=http://purl.obolibrary.org/obo
USECAT= --catalog-xml catalog-v001.xml
SRC=ecto-edit.obo
ONTDIR=ontology

MODS = radiation

all: ecto.owl ecto.obo all_subsets
all_subsets: subsets/ecto-basic.obo
test: all
release: all copy-release

TARGETS = $(ONTDIR)/ecto.obo $(ONTDIR)/ecto.owl imports subsets

ALL_MODS_OWL = $(patsubst %, modules/%.owl, $(MODS))

copy-release:
	cp -pr $(TARGETS) ../.. && cd ../.. && git add imports/*

# CORE is the edited source plus compiled modules
ecto-core.owl: ecto-edit.obo $(ALL_MODS_OWL)
	owltools $(USECAT) $^ --merge-support-ontologies -o -f ofn $@
ecto-core.obo: ecto-core.owl
	owltools $(USECAT) $< -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

ecto-core-inferred.owl: ecto-core.owl modules/existential-graph.owl all_imports
	owltools $(USECAT) $< modules/existential-graph.owl --merge-support-ontologies --assert-inferred-subclass-axioms --allowEquivalencies --always-assert-super-classes --markIsInferred --reasoner mexr --remove-redundant-inferred-svfs  -o $@
subsets/ecto-basic.owl: ecto-core-inferred.owl
	owltools $(USECAT) $< --remove-imports-declarations --make-subset-by-properties -f BFO:0000050 --remove-dangling --remove-axioms -t EquivalentClasses --set-ontology-id $(OBO)/ecto/$@ -o $@
subsets/ecto-basic.obo: subsets/ecto-basic.owl
	owltools $< -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

ecto.owl: ecto-core-inferred.owl
	owltools $(USECAT) $< --set-ontology-id $(OBO)/$@ -o $@

#ecto.owl: ecto-core-inferred.owl modules/vt.obo
#	owltools $(USECAT) $^ --merge-support-ontologies -o $@
ecto.obo: ecto.owl
	owltools $(USECAT) $< -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

oort: ecto-core.owl
	ontology-release-runner $(USECAT) --ignore-selected-equivalent-pairs 'CL:0000000'  --ignoreLock --skip-release-folder --skip-format owx --skip-format obo --no-subsets --outdir target --allow-overwrite --asserted --simple --reasoner elk $<



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
IMPORTS = pato uberon chebi po go cl so pr

# Make this target to regenerate ALL
all_imports_owl: $(patsubst %, imports/%_import.owl,$(IMPORTS))
all_imports_obo: $(patsubst %, imports/%_import.obo,$(IMPORTS))
all_imports: all_imports_owl all_imports_obo

KEEPRELS = BFO:0000050 BFO:0000051 RO:0002202 immediate_transformation_of

# File used to seed module extraction
imports/seed.tsv: ecto-core.owl
	owltools $(USECAT) $< --merge-support-ontologies --export-table $@.tmp && cut -f1 $@.tmp > $@

imports/%_import.owl: $(SRC) mirror/%.owl imports/seed.tsv
	robot extract -i mirror/$*.owl -T imports/seed.tsv -m BOT -O $(OBO)/ecto/$@ -o $@

imports/%_import.obo: imports/%_import.owl
	owltools $(USECAT) $< -o -f obo $@


# clone remote ontology locally, perfoming some excision of relations and annotations
mirror/%.obo:
	wget --no-check-certificate $(OBO)/$*.obo -O $@
.PRECIOUS: mirror/%.obo

mirror/%.owl: mirror/%.obo
	owltools $< --remove-annotation-assertions -r -l --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS)  -o $@
.PRECIOUS: mirror/%.owl
mirror/ro.owl:
	owltools $(OBO)/ro.owl --merge-imports-closure -o $@
.PRECIOUS: mirror/%.owl
mirror/uberon.owl:
	owltools $(OBO)/uberon/basic.owl --remove-annotation-assertions -r -l -s -d --remove-axiom-annotations --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS) --set-ontology-id $(OBO)/uberon.owl -o $@
.PRECIOUS: mirror/%.owl
mirror/po.owl:
	owltools $(OBO)/po.owl --remove-annotation-assertions -r -l -s -d --remove-axiom-annotations --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS) --set-ontology-id $(OBO)/po.owl -o $@
.PRECIOUS: mirror/%.owl
ncbitaxon.obo:
	wget -N $(OBO)/ncbitaxon.obo
.PRECIOUS: ncbitaxon.obo
mirror/ncbitaxon.owl: ncbitaxon.obo
	OWLTOOLS_MEMORY=12G owltools $< --remove-annotation-assertions -r -l -s -d --remove-axiom-annotations --remove-dangling-annotations  --set-ontology-id $(OBO)/ncbitaxon.owl -o $@
.PRECIOUS: mirror/ncbitaxon.owl

mirror/pco.owl: imports/pco_basic.obo
	OWLTOOLS_MEMORY=12G owltools $< --set-ontology-id $(OBO)/pco.owl -o $@



# ----------------------------------------
# DESIGN PATTERNS AND TEMPLATES
# ----------------------------------------


all_modules: all_modules_owl all_modules_obo modules/has_part.owl
all_modules_owl: $(patsubst %, modules/%.owl, $(MODS))
all_modules_obo: $(patsubst %, modules/%.obo, $(MODS))

modules/%-main.owl: modules/%.tsv patterns/%.yaml
	apply-pattern.py -P curie_map.yaml -b http://purl.obolibrary.org/obo/ -i $< -p patterns/$*.yaml -G modules/$*-gci.owl > $@.tmp && mv $@.tmp $@
modules/%.owl: modules/%-main.owl modules/%-gci.owl
	owltools $^ --merge-support-ontologies --set-ontology-id $(OBO)/ecto/$@ -o -f ofn $@

modules/%.obo: modules/%.owl
	owltools $< -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp > $@


modules/existential-graph.owl: ecto-core.owl
	owltools $(USECAT) $< --merge-support-ontologies --reasoner elk --silence-elk --materialize-gcis --reasoner mexr --remove-redundant-inferred-svfs --reasoner elk --remove-redundant-svfs  --set-ontology-id $(OBO)/ecto/$@ -o $@
#modules/existential-graph.obo: ecto-combined.owl
#	owltools $(USECAT) $< --merge-support-ontologies --reasoner elk --silence-elk --materialize-gcis --set-ontology-id $(OBO)/ecto/$@ -o -f obo $@
