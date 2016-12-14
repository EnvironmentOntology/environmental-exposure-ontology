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

# ----------------------------------------
# Mapping
# ----------------------------------------

# requires biomake
align-$(O1)-with-$(O2).tsv: $(O1).obo $(O2).obo ignore.pro
	blip-findall  -i ignore.pro -i $(O1).obo -i $(O2).obo -debug index -goal nlp_index_all  -u metadata_nlp entity_pair_label_reciprocal_best_intermatch/2 -no_pred -label -use_tabs > $@.tmp && sort -u $@.tmp > $@

%.pro: %.tsv
	tbl2p -p m $< > $@

nomapping-$(O1)-with-$(O2).tsv: align-$(O1)-with-$(O2).pro
	blip-findall -i $< -i $(O1).obo "class(X),\+m(X,_,_,_),\+m(_,_,X,_)" -select X -label > $@.tmp && mv $@.tmp $@

nomapping-$(O1)-with-$(O2).obo: align-$(O1)-with-$(O2).pro
	blip ontol-query -i $< -i $(O1).obo -query "class(X),\+m(X,_,_,_),\+m(_,_,X,_),ID=X" -to obo > $@.tmp && mv $@.tmp $@
