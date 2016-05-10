OBO=http://purl.obolibrary.org/obo
USECAT= --catalog-xml catalog-v001.xml
SRC=oba-edit.obo

MODS = entity_attribute entity_attribute_location attribute_location

all: oba.owl oba.obo all_subsets
all_subsets: subsets/oba-basic.obo
test: all
release: all copy-release

TARGETS = oba.obo oba.owl imports subsets

ALL_MODS_OWL = $(patsubst %, modules/%.owl, $(MODS))

copy-release:
	cp -pr $(TARGETS) ../.. && cd ../.. && git add imports/*

# CORE is the edited source plus compiled modules
oba-core.owl: oba-edit.obo $(ALL_MODS_OWL)
	owltools $(USECAT) $^ --merge-support-ontologies -o -f ofn $@
oba-core.obo: oba-core.owl
	owltools $(USECAT) $< -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

#oba-combined-plus-eg.owl: oba-combined.owl modules/existential-graph.owl
#	owltools $(USECAT) $^ --merge-support-ontologies -o $@
#oba.owl: oba-combined-plus-eg.owl
oba-core-inferred.owl: oba-core.owl modules/existential-graph.owl all_imports
	owltools $(USECAT) $< modules/existential-graph.owl --merge-support-ontologies --assert-inferred-subclass-axioms --allowEquivalencies --always-assert-super-classes --markIsInferred --reasoner mexr --remove-redundant-inferred-svfs  -o $@
subsets/oba-basic.owl: oba-core-inferred.owl
	owltools $(USECAT) $< --remove-imports-declarations --make-subset-by-properties -f BFO:0000050 --remove-dangling --remove-axioms -t EquivalentClasses --set-ontology-id $(OBO)/oba/$@ -o $@
subsets/oba-basic.obo: subsets/oba-basic.owl
	owltools $< -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

oba.owl: oba-core-inferred.owl
	owltools $(USECAT) $< --set-ontology-id $(OBO)/$@ -o $@

#oba.owl: oba-core-inferred.owl modules/vt.obo
#	owltools $(USECAT) $^ --merge-support-ontologies -o $@
oba.obo: oba.owl
	owltools $(USECAT) $< -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@

oort: oba-core.owl
	ontology-release-runner $(USECAT) --ignore-selected-equivalent-pairs 'CL:0000000'  --ignoreLock --skip-release-folder --skip-format owx --skip-format obo --no-subsets --outdir target --allow-overwrite --asserted --simple --reasoner elk $<


# ----------------------------------------
# VT
# ----------------------------------------

# TODO: this is actually fetched from BioPortal
vt.obo:
	wget $(OBO)/vt.obo -O $@


# ----------------------------------------
# Regenerate imports
# ----------------------------------------
# Uses OWLAPI Module Extraction code

# Type 'make imports/X_import.owl' whenever you wish to refresh the import for an ontology X. This is when:
#
#  1. X has changed and we want to include these changes
#  2. We have added onr or more new IRI from X into oba-edit.owl
#  3. We have removed references to one or more IRIs in X from oba-edit.owl
#
# You should NOT edit these files directly, changes will be overwritten.
#
# If you want to add something to these, edit oba-edit.owl and add an axiom with a IRI from X. You don't need to add any information about X.

# Ontology dependencies
# We don't include clo, as this is currently not working
IMPORTS = pato uberon chebi po go cl so pr

# Make this target to regenerate ALL
all_imports_owl: $(patsubst %, imports/%_import.owl,$(IMPORTS))
all_imports_obo: $(patsubst %, imports/%_import.obo,$(IMPORTS))
all_imports: all_imports_owl all_imports_obo

KEEPRELS = BFO:0000050 BFO:0000051 RO:0002202 immediate_transformation_of

# File used to seed module extraction
imports/seed.tsv: oba-core.owl
	owltools $(USECAT) $< --merge-support-ontologies --export-table $@.tmp && cut -f1 $@.tmp > $@

imports/%_import.owl: $(SRC) mirror/%.owl imports/seed.tsv
	robot extract -i mirror/$*.owl -T imports/seed.tsv -m BOT -O $(OBO)/oba/$@ -o $@

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
	owltools $^ --merge-support-ontologies --set-ontology-id $(OBO)/oba/$@ -o -f ofn $@

modules/%.obo: modules/%.owl
	owltools $< -o -f obo $@.tmp && grep -v ^owl-axioms $@.tmp > $@

# VT is isolated to prevent isa-poisoning
modules/has_part.tsv:  $(patsubst %, modules/%.tsv, $(MODS))
	./util/make-vt-equiv-tsv.pl $^ > $@


modules/existential-graph.owl: oba-core.owl
	owltools $(USECAT) $< --merge-support-ontologies --reasoner elk --silence-elk --materialize-gcis --reasoner mexr --remove-redundant-inferred-svfs --reasoner elk --remove-redundant-svfs  --set-ontology-id $(OBO)/oba/$@ -o $@
#modules/existential-graph.obo: oba-combined.owl
#	owltools $(USECAT) $< --merge-support-ontologies --reasoner elk --silence-elk --materialize-gcis --set-ontology-id $(OBO)/oba/$@ -o -f obo $@

# ----------------------------------------
# OBOL
# ----------------------------------------
vocab/vt.tsv:
	blip-findall  -i modules/vt.obo entity_label_or_exact_synonym/2 -no_pred | perl -npe 's@ trait$$@@' > $@
vocab/q.tsv:
	blip-findall  -r pato entity_label_or_exact_synonym/2 -no_pred > $@

vt-new.tsv:
	obo-split-terms.pl vocab/vt.tsv vocab/e.tsv vocab/q.tsv | perl -npe 's@VT:@OBA:VT@' | sort -u > $@

vt-loc-new.tsv:
	obo-split-terms.pl vocab/vt.tsv vocab/e.tsv vocab/e.tsv vocab/q.tsv | perl -npe 's@VT:@OBA:VT@' | sort -u > $@

# merge-pattern-tsv.pl vt-new.tsv modules/entity_attribute.tsv
# merge-pattern-tsv.pl -s -b 2 -u 9999 -l 1999 -m -n -k 3,5 reports/eq_mp.tsv modules/entity_attribute.tsv modules/attribute_location.tsv modules/entity_attribute_location.tsv

# ----------------------------------------
# REPORTS
# ----------------------------------------
# See: https://github.com/Planteome/plant-trait-ontology/issues/302

reports/vt-viol.tsv: oba-edit.obo
	blip-findall  -i $< -r uberons "subclass(X,Y),P=attribute_of,differentium(X,P,XQ),id_idspace(XQ,'UBERON'),differentium(Y,P,YQ),id_idspace(YQ,'UBERON'),\+parentRT(XQ,YQ)" -select "x(X,Y,XQ,YQ)" -label -no_pred > $@

reports/pato-viol.tsv: oba-edit.obo
	blip-findall  -i $< -r pato "subclass(X,Y),P=affects_quality,differentium(X,P,XQ),differentium(Y,P,YQ),\+subclassRT(XQ,YQ)" -select "x(X,Y,XQ,YQ)" -label -no_pred > $@

reports/po-viol.tsv: oba-edit.obo
	blip-findall  -i $< -r PO "subclass(X,Y),P=attribute_of,differentium(X,P,XQ),id_idspace(XQ,'PO'),differentium(Y,P,YQ),id_idspace(YQ,'PO'),\+parentRT(XQ,YQ)" -select "x(X,Y,XQ,YQ)" -label -no_pred > $@

reports/po-sc-viol.tsv: oba-edit.obo
	blip-findall  -i $< -r PO "subclass(X,Y),P=attribute_of,differentium(X,P,XQ),id_idspace(XQ,'PO'),differentium(Y,P,YQ),id_idspace(YQ,'PO'),\+subclassRT(XQ,YQ)" -select "x(X,Y,XQ,YQ)" -label -no_pred > $@

reports/eq_hp.tsv: hp-ldefs.obo
	blip-findall -r go -r uberonp -r pato -r pato -r CL -i $< -consult util/patterns.pro eq_pheno/3 -no_pred -label -use_tabs > $@
reports/eq_mp.tsv: mp-ldefs.obo
	blip-findall -r go -r uberonp -r pato  -r CL -i $< -consult util/patterns.pro eq_pheno/3 -no_pred -label -use_tabs > $@

reports/eq.tsv: oba-edit.obo
	blip-findall -r go  -r pato -r uberonp -r pato -r CL -i $< -consult util/patterns.pro eq/3 -no_pred -label -use_tabs > $@
reports/eq_root.tsv: oba-edit.obo
	blip-findall -r go  -r pato -r uberonp -r pato -r CL -i $< -consult util/patterns.pro eq_root/3 -no_pred -label -use_tabs > $@.tmp && ./util/fix-ids.pl $@.tmp > $@
reports/eq_eroot.tsv: oba-edit.obo
	blip-findall -r go  -r pato -r uberonp -r pato -r CL -i $< -consult util/patterns.pro eq_eroot/3 -no_pred -label -use_tabs > $@.tmp && ./util/fix-ids.pl $@.tmp > $@
reports/eqw.tsv: oba-edit.obo
	blip-findall -r chebi -r go  -r pato -r uberonp -r pato -r CL -i $< -consult util/patterns.pro eqw/4 -no_pred -label -use_tabs > $@.tmp && ./util/fix-ids.pl $@.tmp > $@
reports/eqw2.tsv: oba-edit.obo
	blip-findall -r chebi -r go  -r pato -r uberonp -r pato -r CL -i $< -consult util/patterns.pro eqw2/4 -no_pred -label -use_tabs > $@.tmp && ./util/fix-ids.pl $@.tmp > $@
reports/eqw_root.tsv: oba-edit.obo
	blip-findall -r chebi -r go  -r pato -r uberonp -r pato -r CL -i $< -consult util/patterns.pro eqw_root/4 -no_pred -label -use_tabs > $@.tmp && ./util/fix-ids.pl $@.tmp > $@
reports/eqw_root2.tsv: oba-edit.obo
	blip-findall -r chebi -r go  -r pato -r uberonp -r pato -r CL -i $< -consult util/patterns.pro eqw_root2/4 -no_pred -label -use_tabs > $@.tmp && ./util/fix-ids.pl $@.tmp > $@
reports/eq_oba.tsv: oba-edit.obo
	blip-findall -r go  -r pato -r uberonp -r pato -r CL -i $< -consult util/patterns.pro eq_oba/3 -no_pred -label -use_tabs > $@

reports/patterns.tsv: oba-edit.obo
	blip-findall -i $< -consult util/patterns.pro idspace_pattern/3 -no_pred > $@
