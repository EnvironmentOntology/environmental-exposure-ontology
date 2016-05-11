all: all_exposure probs.tsv m.tsv unmapped.tsv rpt.html merged-exposure.obo axioms-r.obo 

MOD = eo xco zeco snomed ncit go exo

all_exposure: $(patsubst %, exposure-%.obo,$(MOD))

exposure-eo.obo:
	blip ontol-query -r eo -query "class(ID)" -to obo > $@

exposure-xco.obo:
	blip ontol-query -r obo/xco -query "class(ID)" -to obo > $@

exposure-zeco.obo:
	blip ontol-query -r zeco -query "class(ID)" -to obo > $@

exposure-snomed.obo:
	blip ontol-query -r snomed_tidy -query "class(R,'Exposureure to potentially harmful entity'),subclassRT(ID,R)" -to obo | perl -npe 's@SCTID_@SCTID:@g' > $@

exposure-ncit.obo:
	blip ontol-query -r ncit -n %xposure% -to obo > $@

exposure-go.obo:
	blip ontol-query -r go -query "class(R,'response to stimulus'),subclassRT(ID,R)" -to obo | obo-grep.pl -r 'name: response to' - > $@

exposure-exo.obo:
	blip ontol-query -r exo -query "class(ID)" -to obo  > $@



combined-exposure.obo: all_exposure
	obo-cat.pl exposure-*.obo | grep -v ^namespace: | grep -v ^property_value: | ./add-syns.pl > $@

probs.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -u metadata_nlp entity_pair_mprobs/6 -no_pred > $@

m.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -u metadata_nlp entity_pair_label_match/6 -label -no_pred > $@

unmapped.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -u metadata_nlp "entity_nomatch/1" -label -no_pred > $@

OBO=http://purl.obolibrary.org/obo
combined-exposure.owl: combined-exposure.obo
	owltools $< --set-ontology-id $(OBO)/rad.owl -o $@

MAX_E=8
axioms.owl: combined-exposure.owl probs.tsv
	kboom --experimental  --splitSize 50 --max $(MAX_E) -m rpt.md -j rpt.json -n -o $@ -t probs.tsv $<

rpt.html: axioms.owl
	pandoc rpt.md -o rpt.html

axioms.obo: axioms.owl
	owltools $< combined-exposure.owl --set-ontology-id $(OBO)/rad/axioms -o -f obo $@

axioms-r.obo: combined-exposure.obo  axioms.obo
	obo-add-comments.pl -r -t id -t equivalent_to -t is_a $^ > $@

ORD = xx NCIT 10 xx EO 8 xx ZECO 6 xx XCO 4
ORD_C =  $(patsubst xx,-c,$(ORD))
ORD_D =  $(patsubst xx,-d,$(ORD))
ORD_L =  $(patsubst xx,-l,$(ORD))
#PRIORITIES := -l NCIT 10 -l EO 8 -l ZECO 5  -s NCIT 10 -s EO 8 -s ZECO 5 

merged-exposure.owl: combined-exposure.owl axioms.owl
	owltools $^ --merge-support-ontologies --reasoner elk --merge-equivalence-sets $(ORD_C) $(ORD_D) $(ORD_L) --set-ontology-id $(OBO)/rad.owl -o $@
.PRECIOUS: merged-exposure.owl

merged-exposure.obo: merged-exposure.owl
	owltools $< -o -f obo --no-check $@

merged-exposure.hier: merged-exposure.obo
	blip ontol-subset -i $< -n % > $@

merged-exposure.png: merged-exposure.obo
	blip ontol-subset -i $< -n $< -to png -u ontol_config_rad  -n % > $@
