
MODDIR=../patterns/data/old_modules

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

# CORE is the edited source (minimal) plus compiled modules
ALL_MODS_OWL = $(patsubst %, $(MODDIR)/%.owl, $(MODS))
../patterns/ecto_old_modules.owl: $(ALL_MODS_OWL)
	owltools $(USECAT) $^ --merge-support-ontologies -o -f ofn $@


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

touch:
	echo $(all_modules_omn)
	
imports/npo_import.owl:
	echo "!!!!!NPO currently skipped!"
	
mirror/npo.owl:
	echo "!!!!!NPO currently skipped!"

# https://github.com/enpadasi/Ontology-for-Nutritional-Studies/issues/33
#$(IMPORTDIR)/ons_import.owl: $(MIRRORDIR)/ons.owl $(IMPORTDIR)/ons_terms_combined.txt
#	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
#		extract -T $(IMPORTDIR)/ons_terms_combined.txt --force true --copy-ontology-annotations true --individuals include --method BOT \
#		remove --axioms Declaration \
#		remove --select "<http://purl.obolibrary.org/obo/FOODON_*>" --axioms annotation \
#		remove --term RO:0002434 --term RO:0000052 --term RO:0002018 --term RO:0002233 --term RO:0002248 --term RO:0002434 --term RO:0002437 --term RO:0002501 --term RO:0002506 --term RO:0002507 --term RO:0002509 --term RO:0002574 --term RO:0002595 --trim true \
#		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
#		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi


$(ONT)-full.owl: $(SRC) $(OTHER_SRC)
	echo "!!!!!! FULL RELEASE IS OVERWRITTEN, REMOVING DISJOINTS - ecto.Makefile. See https://github.com/EnvironmentOntology/environmental-exposure-ontology/issues/79 !!!!!!"
	$(ROBOT) merge --input $< \
		remove --axioms disjoint --preserve-structure false \
		reason --reasoner ELK --equivalent-classes-allowed asserted-only --exclude-tautologies structural \
		relax \
		reduce -r ELK \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@

$(ONT)-incl-mappings.owl: ../../$(ONT).owl ../mapping/axioms.owl ../mapping/axioms-boomer.owl
	$(ROBOT) merge -i ../../$(ONT).owl -i ../mapping/axioms.owl -i ../mapping/axioms-boomer.owl \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@

$(ONT)-incl-mappings.obo: $(ONT)-incl-mappings.owl
	$(ROBOT) convert --input $< --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo


test: odkversion sparql_test all_reports
	echo "!!!!!! FULL TEST RUN IS OVERWRITTEN, REMOVING DISJOINTS - ecto.Makefile. See https://github.com/EnvironmentOntology/environmental-exposure-ontology/issues/79 !!!!!!"
	$(ROBOT) merge --input $(SRC) \
		remove --axioms disjoint --preserve-structure false \
		reason --reasoner ELK  --equivalent-classes-allowed asserted-only --exclude-tautologies structural --output test.owl && rm test.owl && echo "Success"

$(TMPDIR)/$(ONT)-quick.obo: | $(TMPDIR)
	$(ROBOT) merge -i $(SRC) reason -o $@.owl && mv $@.owl $@

$(TMPDIR)/$(ONT)-main.obo: | $(TMPDIR)
	git show master:src/ontology/$(SRC) > $@
	$(ROBOT) merge -i $@ reason -o $@.owl && mv $@.owl $@
	
$(TMPDIR)/$(ONT)-base-quick.owl: $(ONT)-base.owl | $(TMPDIR)
	$(ROBOT) merge -i $< remove --base-iri $(URIBASE)/ECTO_ --axioms external --trim false -o $@.owl && mv $@.owl $@

$(TMPDIR)/$(ONT)-base-release.owl: | $(TMPDIR)
	$(ROBOT) merge -I $(ONTBASE)/$(ONT)-base.owl remove --base-iri $(URIBASE)/ECTO_ --axioms external --trim false -o $@.owl && mv $@.owl $@

reports/robot_base_diff.md: $(TMPDIR)/$(ONT)-base-quick.owl $(TMPDIR)/$(ONT)-base-release.owl
	$(ROBOT) diff --left $(TMPDIR)/$(ONT)-base-quick.owl --right $(TMPDIR)/$(ONT)-base-release.owl -f markdown -o $@

reports/robot_base_diff.txt: $(TMPDIR)/$(ONT)-base-quick.owl $(TMPDIR)/$(ONT)-base-release.owl
	$(ROBOT) diff --left $(TMPDIR)/$(ONT)-base-quick.owl --right  $(TMPDIR)/$(ONT)-base-release.owl -o $@

.PHONY: feature_diff
feature_diff:
	make IMP=false PAT=false reports/robot_base_diff.md reports/robot_base_diff.txt
	
#########################################
### Generating all ROBOT templates ######
#########################################

TEMPLATESDIR=../templates

TEMPLATES=$(patsubst %.tsv, $(TEMPLATESDIR)/%.owl, $(notdir $(wildcard $(TEMPLATESDIR)/*.tsv)))

$(TEMPLATESDIR)/%.owl: $(TEMPLATESDIR)/%.tsv $(SRC)
	$(ROBOT) merge -i $(SRC) template --template $< --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/components/$*.owl -o $@

templates: $(TEMPLATES)
	
$(COMPONENTSDIR)/obsoletes.owl:
	$(ROBOT) merge -i $(TEMPLATESDIR)/obsolete.owl annotate --ontology-iri $(ONTBASE)/$@ -o $@

tmp/mre_seed.txt:
	

mre: tmp/mre_seed.txt
	$(ROBOT) filter -i $(SRC) -T tmp/mre_seed.txt -o $@