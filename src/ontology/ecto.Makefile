
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

imports/ncit_import.owl:
	echo "!!!!!NCIT currently skipped for performance reasons"
	
mirror/ncit.owl:
	echo "!!!!!NCIT currently skipped for performance reasons"
	
imports/npo_import.owl:
	echo "!!!!!NPO currently skipped!"
	
mirror/npo.owl:
	echo "!!!!!NPO currently skipped!"
	
imports/exo_import.owl:
	echo "!!!!!EXO mirror currently skipped, see: https://github.com/CTDbase/exposure-ontology/issues/11"
	
mirror/exo.owl:
	echo "!!!!!EXO currently skipped, see: https://github.com/CTDbase/exposure-ontology/issues/11"


$(ONT)-full.owl: $(SRC) $(OTHER_SRC)
	echo "!!!!!! FULL RELEASE IS OVERWRITTEN, REMOVING DISJOINTS - ecto.Makefile. See https://github.com/EnvironmentOntology/environmental-exposure-ontology/issues/79 !!!!!!"
	$(ROBOT) merge --input $< \
		remove --axioms disjoint --preserve-structure false \
		reason --reasoner ELK --equivalent-classes-allowed all --exclude-tautologies structural \
		relax \
		reduce -r ELK \
		annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@

test: odkversion sparql_test all_reports
	echo "!!!!!! FULL TEST RUN IS OVERWRITTEN, REMOVING DISJOINTS - ecto.Makefile. See https://github.com/EnvironmentOntology/environmental-exposure-ontology/issues/79 !!!!!!"
	$(ROBOT) merge --input $(SRC) \
		remove --axioms disjoint --preserve-structure false \
		reason --reasoner ELK  --equivalent-classes-allowed all --exclude-tautologies structural --output test.owl && rm test.owl && echo "Success"
