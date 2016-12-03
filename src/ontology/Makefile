OBO=http://purl.obolibrary.org/obo
USECAT= --catalog-xml catalog-v001.xml
SRC=ecto-edit.obo
ONTDIR=.
MODDIR=modules
DATE=`date +%Y-%m-%d`

MODS = exposure_to_radiation exposure_to_material exposure_to_environmental_process exposure_to_environmental_condition exposure_to_chemical exposure_to_chemical_with_role exposure_to_levels_in_medium exposure_to_change_in_levels exposure_via_route activity prenatal surgical_procedure exposure_to_infection
MODS_CSV = $(patsubst %,$(MODDIR)/%.csv,$(MODS))

all: all_imports all_modules ecto.owl ecto.obo all_subsets 
all_subsets: subsets/ecto-basic.obo
test: all
release: all copy-release

TARGETS = $(ONTDIR)/ecto.obo $(ONTDIR)/ecto.owl imports subsets

ALL_MODS_OWL = $(patsubst %, $(MODDIR)/%.owl, $(MODS))

copy-release:
	cp -pr $(TARGETS) catalog-v001.xml ../.. && cd ../.. && git add imports/*

# CORE is the edited source plus compiled modules
ecto-core.owl: ecto-edit.obo $(ALL_MODS_OWL)
	owltools $(USECAT) $^ --merge-support-ontologies -o -f ofn $@
ecto-core.obo: ecto-core.owl
	owltools $(USECAT) $< -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

ecto-core-inferred.owl: ecto-core.owl all_imports
	robot reason --input $< --reasoner elk reduce --reasoner elk -o $@

subsets/ecto-basic.owl: ecto-core-inferred.owl
	owltools $(USECAT) $< --remove-imports-declarations --make-subset-by-properties -f BFO:0000050 --remove-dangling --remove-axioms -t EquivalentClasses --set-ontology-id $(OBO)/ecto/$@ -o $@
subsets/ecto-basic.obo: subsets/ecto-basic.owl
	robot convert -i $< -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@
##	owltools $< -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

ecto.owl: ecto-core-inferred.owl
	robot annotate -i $< -O $(OBO)/$@ -V $(OBO)/ecto/releases/$(DATE)/ecto.owl -o $@
#	owltools $(USECAT) $< --set-ontology-id $(OBO)/$@ -o $@

#ecto.owl: ecto-core-inferred.owl $(ONTDIR)/vt.obo
#	owltools $(USECAT) $^ --merge-support-ontologies -o $@
ecto.obo: ecto.owl
	owltools $(USECAT)  $< --merge-imports-closure -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

oort: ecto-core.owl
	ontology-release-runner $(USECAT) --ignore-selected-equivalent-pairs 'CL:0000000'  --ignoreLock --skip-release-folder --skip-format owx --skip-format obo --no-subsets --outdir target --allow-overwrite --asserted --simple --reasoner elk $<

top-report: ecto.obo
	obo-grep.pl -r 'is_a: BFO' ecto.obo | obo-grep.pl -r 'id: ECTO' -


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

KEEPRELS = BFO:0000050 BFO:0000051 RO:0002202 immediate_transformation_of

# File used to seed module extraction
imports/seed.tsv: ecto-core.owl imports/seed_curated.tsv
	owltools $(USECAT) $< --merge-support-ontologies --export-table $@.tmp &&\
	cut -f1 $@.tmp imports/seed_curated.tsv | sort -u > $@

imports/%_import.owl: $(SRC) mirror/%.owl.gz imports/seed.tsv
	gzip -dc mirror/$*.owl.gz > mirror/$*.owl &&\
	robot extract -i mirror/$*.owl -T imports/seed.tsv -m BOT -O $(OBO)/ecto/$@ -o $@.tmp.owl && mv $@.tmp.owl $@ &&\
	rm mirror/$*.owl

imports/%_import.obo: imports/%_import.owl
	owltools $(USECAT) $< -o -f obo --no-check $@

mirror/%.gz: mirror/%
	gzip -f $<
.PRECIOUS: mirror/%.gz

# clone remote ontology locally, perfoming some excision of relations and annotations
mirror/%.obo:
	wget --no-check-certificate $(OBO)/$*.obo -O $@
.PRECIOUS: mirror/%.obo

mirror/%.owl: mirror/%.obo
	owltools $< --remove-annotation-assertions -r -l -s --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS)  -o $@
.PRECIOUS: mirror/%.owl
mirror/ro.owl:
	owltools $(OBO)/ro.owl --merge-imports-closure -o $@
.PRECIOUS: mirror/%.owl

mirror/exo.obo:
	wget --no-check-certificate https://raw.githubusercontent.com/CTDbase/exposure-ontology-draft/master/src/ontology/exo.obo -O $@
.PRECIOUS: mirror/%.owl

mirror/activity.obo:
	blip ontol-query -r ncit -query "class(R,'Activity'),subclassRT(ID,R)" -to obo > $@.tmp && mv $@.tmp $@

mirror/chebi.obo:
	wget $(OBO)/chebi.obo -O $@
.PRECIOUS: mirror/chebi.obo

mirror/chebi.owl: mirror/chebi.obo
	owltools --use-catalog $<  --rename-entity $(OBO)/chebi#has_part $(OBO)/BFO_0000051 --rename-entity $(OBO)/chebi#has_role $(OBO)/RO_0000087  --remove-annotation-assertions -r -l -s  --set-ontology-id $(OBO)/chebi.owl -o $@

#mirror/chebi.owl:
#	wget $(OBO)/chebi.obo -O $@.tmp && owltools $@.tmp --make-subset-by-properties -f --extract-mingraph --set-ontology-id $(OBO)/chebi.owl -o $@

#mirror/chebi.owl:
#	owltools $(OBO)/go/extensions/chebi_import.obo --set-ontology-id $(OBO)/chebi.owl -o $@
.PRECIOUS: mirror/chebi.owl

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
# SYNS
# ----------------------------------------

# avoid circular dependencies with imports;
# some patterns refer to ECTO classes; we use the previous version for this
SYNFILES = imports/uberon_import.obo ecto.obo
syns.json: mirror/chebi.obo imports/curated_synonyms.obo
	extract-obo-syns.pl $^ $(SYNFILES) > $@.tmp && mv $@.tmp $@


# ----------------------------------------
# DESIGN PATTERNS AND TEMPLATES
# ----------------------------------------


all_modules: all_modules_omn all_modules_owl all_modules_obo
all_modules_owl: $(patsubst %, $(MODDIR)/%.owl, $(MODS))
all_modules_omn: $(patsubst %, $(MODDIR)/%.omn, $(MODS))
all_modules_obo: $(patsubst %, $(MODDIR)/%.obo, $(MODS))

$(MODDIR)/%.omn: $(MODDIR)/%.csv ../patterns/%.yaml syns.json
	apply-pattern.py -S syns.json -P curie_map.yaml -b http://purl.obolibrary.org/obo/ -i $< -p ../patterns/$*.yaml -G $(MODDIR)/$*-gci.owl > $@.tmp && mv $@.tmp $@

#$(MODDIR)/%-gci.owl: $(MODDIR)/%.omn

$(MODDIR)/%.rdf: $(MODDIR)/%.omn 
	owltools $^ --merge-support-ontologies --set-ontology-id $(OBO)/ecto/$@ -o  $@

$(MODDIR)/%.owl: $(MODDIR)/%.rdf
	owltools $< -o -f ofn $@

$(MODDIR)/%.obo: $(MODDIR)/%.owl
	owltools $< -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp > $@


# NOT CURRENTLY USED
$(MODDIR)/existential-graph.owl: ecto-core.owl
	owltools $(USECAT) $< --merge-support-ontologies --reasoner elk --silence-elk --materialize-gcis --reasoner mexr --remove-redundant-inferred-svfs --reasoner elk --remove-redundant-svfs  --set-ontology-id $(OBO)/ecto/$@ -o $@
#$(MODDIR)/existential-graph.obo: ecto-combined.owl
#	owltools $(USECAT) $< --merge-support-ontologies --reasoner elk --silence-elk --materialize-gcis --set-ontology-id $(OBO)/ecto/$@ -o -f obo $@


## HACKS

# for reporting
ecto-edit.csv: ecto-edit.obo
	owltools $(USECAT) $< --merge-support-ontologies --export-table $@.tmp && cut -f1 $@.tmp  > $@

fill: ecto-edit.csv
	fill-col1-ids.pl $(MODS_CSV)
#	fill-col1-ids.pl $(MODS_CSV) $<
testfill: ecto-edit.csv
	fill-col1-ids.pl -n $(MODS_CSV)
#	fill-col1-ids.pl -n $(MODS_CSV) $<

radiation-npo.tsv:
	blip-findall  -i mirror/npo.obo "subclassRT(X,'NPO:1731')"  -label -select "x('',X)" -no_pred -use_tabs > $@
material-envo.tsv:
	blip-findall  -r envo "subclassRT(X,'ENVO:00010483')"  -label -select "x('',X)" -no_pred -use_tabs > $@
material-envop.tsv:
	blip-findall  -r envo "subclassRT(X,'ENVO:02500000')"  -label -select "x('',X)" -no_pred -use_tabs > $@

candidates-chemicals-obol.csv: ../mapping/obol.obo modules/exposure_to_chemical.pro
	blip-findall -r chebi -i $< -i modules/exposure_to_chemical.pro "class_cdef(A,cdef('ExO:0000002',['RO:0002233'=X])),id_idspace(A,'MRE'),id_idspace(X,'CHEBI'),\+ct(_,_,X,_)" -select "x('',X)" -no_pred -label -use_tabs > $@.tmp && tsv2csv.py $@.tmp > $@
candidates-route-obol.csv: ../mapping/obol.obo modules/exposure_via_route.pro
	blip-findall -r chebi -r exo -i $< -i modules/exposure_via_route.pro "class_cdef(A,cdef('ExO:0000002',['BFO:0000050'=Route,'RO:0002233'=Chemical])),id_idspace(A,'MRE'),id_idspace(Chemical,'CHEBI'),\+ct(_,_,Chemical,_,Route,_)" -select "x('',Chemical,Route)" -no_pred -label -use_tabs > $@.tmp && tsv2csv.py $@.tmp > $@

#candidates-chemicals0.csv: ../mapping/mre-xp-chebi.obo modules/exposure_to_chemical.pro
#	blip-findall -r chebi -i $< -i modules/exposure_to_chemical.pro "differentium(A,_,X),id_idspace(A,'MRE'),id_idspace(X,'CHEBI'),\+ct(_,_,X,_)" -select "x('',X)" -no_pred -label -use_tabs > $@.tmp && tsv2csv.py $@.tmp > $@

candidates-chemicals1.csv: modules/exposure_to_chemical.pro
	blip-findall -i $<  -r chebi "class(R,'environmental contaminant'),parentT(X,R),\+ct(_,_,X,_)"  -label -select "x('',X)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

candidates-chemicals2.csv: modules/exposure_to_chemical.pro
	blip-findall -i $<  -r chebi "class(R,'biological role'),subclassT(Z,R),parent(X,has_role,Z),\+ct(_,_,X,_)"  -label -select "x('',X)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

candidates-chemicals3.csv: modules/exposure_to_chemical.pro
	blip-findall -i $< -r chebi  -i ../resources/wikidata/chebi-hazard.obo "entity_xref(W,X),id_idspace(W,'Wikidata'),\+ct(_,_,X,_)"  -label -select "x('',X)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

#candidates-roles.csv: modules/exposure_to_chemical_with_role.pro
#	blip-findall -i $<  -r chebi "class(R,'pesticide'),subclassRT(X,R),\+ct(_,_,X,_)"  -label -select "x('',X)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

candidates-roles.csv: modules/exposure_to_chemical_with_role.pro
	blip-findall -i $<  -r chebi "class(R,'pesticide'),subclassRT(X,R),\+ct(_,_,X,_)"  -label -select "x('',X)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

candidates-condition.csv: modules/exposure_to_environmental_condition.pro
	blip-findall -i $<  -r pato -r envo "ct(_,_,A,_,E,_),subclass(A2,A),entity_partition(A2,value_slim),\+ct(_,_,A2,_,E,_)"  -label -select "x('',A2,E)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

candidates-levels.csv: modules/exposure_to_change_in_levels.pro
	blip-findall -i $<  -r pato -r chebi -r envo "ct(_,_,A,_,E,_,W,_),parent(A2,subclass,A),entity_partition(A2,value_slim),\+ct(_,_,A2,_,E,_,W,_)"  -label -select "x('',A2,E,W)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

candidate-procedures.csv: modules/activity.pro
	blip-findall -i $<  -r ncit "class(R,'Therapeutic Procedure'),subclassRT(X,R),\+ct(_,_,X,_)"  -label -select "x('',X)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

candidate-behaviors.csv: modules/activity.pro
	blip-findall -i $<  -r ncit "class(R,'Personal Behavior'),subclassRT(X,R),\+ct(_,_,X,_)"  -label -select "x('',X)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

candidate-occ.csv: modules/activity.pro
	blip-findall -i $<  -r ncit "class(R,'Occupation'),subclassRT(X,R),\+ct(_,_,X,_)"  -label -select "x('',X)" -no_pred -use_tabs | sort -u > $@.tmp && tsv2csv.py $@.tmp > $@ && cat $@

modules/%.pro: modules/%.csv
	csv2tsv.py $< | tbl2p -p ct > $@.tmp && mv $@.tmp $@

#%.csv: %.tsv
#	tsv2csv.py $< $@

mirror/%.jsonld: mirror/%.owl
	rdfcat -out JSONLD $< > $@.tmp && mv $@.tmp $@
