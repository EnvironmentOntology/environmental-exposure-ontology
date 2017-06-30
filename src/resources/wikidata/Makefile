OBO=http://purl.obolibrary.org/obo
BASE=$(OBO)/wikidata

# ----------------------------------------
# Extraction from WD
# ----------------------------------------

## CONSIDER:
## curl -i  --data-urlencode query@t2.sparql -H "Accept: text/turtle" https://query.wikidata.org/sparql
%.rdf: %.rq
	curl  --data-urlencode query@$< -H "Accept: text/turtle" https://query.wikidata.org/sparql > $@.tmp && mv $@.tmp $@
	#rsparql --query $< --service=https://query.wikidata.org/sparql > $@
.PRECIOUS: %.rdf


# ----------------------------------------
# Translation
# ----------------------------------------

%.owl: %.rdf
	owltools $< --set-ontology-id $(BASE)/$@ -o $@
.PRECIOUS: %.owl

%-tr.owl: %.owl
	perl -npe 's@http://www.wikidata.org/entity/@$(OBO)/Wikidata_@g' $< > $@

%.obo: %-tr.owl
	owltools $< -o -f obo --no-check $@.tmp && grep -v 'is_a: Error' $@.tmp > $@

%.json: %.owl
	owltools $< -o -f json $@

combined.obo: hazard-all.obo chebi-hazard.obo
	owltools $^ --merge-support-ontologies -o -f obo $@

%.csv: %-flat.rq
	rsparql --results=CSV --query $< --service=https://query.wikidata.org/sparql  > $@

# ----------------------------------------
# Assocs
# ----------------------------------------
exposure-all.owl: exposure-route-symptom-assocs.owl exposure-symptom-assocs.owl drug-exposure-assocs.owl
	owltools $^ --merge-support-ontologies -o $@

# TODO: PM2.5 e.g. https://www.wikidata.org/wiki/Q498957 different pattern

# ----------------------------------------
# Assocs
# ----------------------------------------
# cheat, use obo to avoid URI conversion
%-ecto.obo: %.obo
	owltools $< ../../mapping/axioms.obo --rename-entities-via-equivalent-classes -q http://purl.obolibrary.org/obo/ECTO_ -o -f obo --no-check $@

exposure-all-ecto.json: exposure-all-ecto.obo
	owltools $< -o -f json $@

RDIR = ../../..
merged.owl: $(RDIR)/ecto.owl exposure-all-ecto.obo
	owltools --catalog-xml $(RDIR)/catalog-v001.xml $^ --merge-support-ontologies --merge-imports-closure -o $@


# ----------------------------------------
# symptoms
# ----------------------------------------
wd-symptoms.obo: exposure-symptom-assocs.obo
	oq -i $< -query "parent(_,'RO:0002304',ID)" -to obo > $@

# ----------------------------------------
# ipython
# ----------------------------------------

nb:
	./init.sh && PYTHONPATH=. jupyter notebook
