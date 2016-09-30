OBO=http://purl.obolibrary.org/obo
BASE=$(OBO)/wikidata

# ----------------------------------------
# Extraction from WD
# ----------------------------------------

%.rdf: %.rq
	rsparql --query $< --service=https://query.wikidata.org/sparql > $@
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
	owltools $< -o -f obo $@

combined.obo: hazard-all.obo chebi-hazard.obo
	owltools $^ --merge-support-ontologies -o -f obo $@

%.csv: %-flat.rq
	rsparql --results=CSV --query $< --service=https://query.wikidata.org/sparql  > $@
