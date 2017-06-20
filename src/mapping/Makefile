all: all_exposure probs.tsv m.tsv  rpt.html merged-exposure.obo axioms-r.obo  hier all_ecto unmapped.tsv

OBO = http://purl.obolibrary.org/obo

#wd causig loops?
#MOD = eo xco zeco snomed ncit go exo mre wikidata ecto
MOD = eo xco zeco snomed ncit go exo mre ecto

all_exposure: $(patsubst %, exposure-%.obo,$(MOD))


exposure-eo.obo:
	blip ontol-query -r eo -query "class(ID)" -to obo > $@

exposure-xco.obo:
	blip ontol-query -r obo/xco -query "class(ID)" -to obo > $@

exposure-zeco.obo:
	blip ontol-query -r zeco -query "class(ID)" -to obo > $@

exposure-peco.obo:
	wget --no-check-certificate https://raw.githubusercontent.com/pombase/fypo/master/peco.obo -O $@

exposure-snomed.obo:
	blip ontol-query -r snomed_tidy -query "class(R,'Exposureure to potentially harmful entity'),subclassRT(ID,R)" -to obo | perl -npe 's@SCTID_@SCTID:@g' > $@

exposure-ncit.obo:
	blip ontol-query -r ncit -n %xposure% -to obo > $@

exposure-go.obo:
	blip ontol-query -r go -query "class(R,'response to stimulus'),subclassRT(ID,R)" -to obo | obo-grep.pl -r 'name: response to' - > $@

exposure-exo.obo:
	blip ontol-query -r exo -query "class(ID)" -to obo  > $@

exposure-mre.obo:
	blip ontol-query -r mre -query "class(ID)" -to obo  > $@

access-ncit.obo:
	blip ontol-query -r ncit -n 'Access to%' -to obo > $@

exposure-wikidata.obo:
	cp ../resources/wikidata/combined.obo $@

exposure-ecto.obo: ../../subsets/ecto-basic.obo
	cp $< $@

#combined-exposure.obo:
combined-exposure.obo: all_exposure
	obo-cat.pl exposure-*.obo | grep -v ^namespace: | grep -v ^property_value: | ./add-syns.pl > $@
.PRECIOUS: combined-exposure.obo

slim-exposure.obo: exposure-ncit.obo exposure-snomed.obo exposure-mre.obo exposure-ecto.obo
	obo-cat.pl $^ | grep -v ^namespace: | grep -v ^property_value: | ./add-syns.pl > $@
.PRECIOUS: slim-exposure.obo

probs.tsv: slim-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -u metadata_nlp entity_pair_mprobs/6 -no_pred > $@.tmp && mv $@.tmp $@

m.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -u metadata_nlp entity_pair_label_match/6 -label -no_pred > $@
.PRECIOUS: m.tsv

mxrefs.obo: m.tsv
	cut -f1-2 $< | sort -u | tbl2obolinks.pl -k --rel xref > $@

unmapped.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -u metadata_nlp "entity_nomatch/1" -label -no_pred > $@

suggestions.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -consult suggester.pro -debug index -goal nlp_index_all -i $< -u metadata_nlp "" -label -no_pred > $@

unmapped-%.tsv: unmapped.tsv
	grep $*: $< > $@

# not really obol...
# use odputils to write suggestions based on parsing names using DPs
obol-%.obo: mxrefs.obo
	blip-findall -r $* -i ../ontology/ecto.obo -r envo -r chebi -u odputil -i $< -i ../patterns/ecto_patterns.pro "write_suggestion('MRE')" > $@.tmp && mv $@.tmp $@

OBO=http://purl.obolibrary.org/obo
%-exposure.owl: %-exposure.obo
	owltools $< --set-ontology-id $(OBO)/rad.owl -o $@

MAX_E=8
axioms.owl: slim-exposure.owl probs.tsv
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

aggregated-exposure.obo: combined-exposure.owl axioms.owl
	owltools $^ --merge-support-ontologies  --set-ontology-id $(OBO)/ecto/combined.owl -o -f obo --no-check $@
.PRECIOUS: aggregated-exposure.obo

new-inf-%.txt: exposure-%.obo
	owltools  exposure-$*.obo axioms.obo exposure-ecto.obo --spike-and-reason > $@.tmp && grep ^NEW $@.tmp > $@
missing-inf-%.txt: exposure-%.obo
	owltools  exposure-ecto.obo  axioms.obo exposure-$*.obo  --spike-and-reason > $@.tmp && grep ^NEW $@.tmp > $@

relgaps.tsv: aggregated-exposure.obo
	blip-findall -i $< -u ontol_gapfiller -goal ix relgap/7 -label -no_pred > $@.tmp && mv $@.tmp $@



#hier: merged-exposure.png merged-exposure.hier
hier:
	echo suppressed

merged-exposure.hier: merged-exposure.obo
	blip ontol-subset -i $< -n % -rel subclass > $@

merged-exposure.png: merged-exposure.obo
	blip ontol-subset -i $< -n $< -to png -rel subclass -u ontol_config_rad  -n % > $@


all_ecto: unmatched_ecto.tsv not_in_ecto.tsv

ECTO=../ontology/ecto.obo
combined2ecto.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -i $(ECTO) -u metadata_nlp entity_pair_mprobs/6 -no_pred -label > $@

unmatched_ecto.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -i $(ECTO) -u metadata_nlp entity_nomatch/1 -no_pred -label > $@.tmp && grep ^ECTO $@.tmp > $@

not_in_ecto.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -i $(ECTO) -u metadata_nlp "entity_nomatch_to(X,'ECTO')"  -label -select X > $@.tmp && mv $@.tmp $@

not_in_ecto_x.tsv: combined-exposure.obo ignore.pro
	blip-findall  -i ignore.pro -debug index -goal nlp_index_all -i $< -i $(ECTO) -u metadata_nlp "entity_nomatch_to(X,'ECTO'),entity_xref(X,Y)"  -label -select X-Y -no_pred > $@.tmp && mv $@.tmp $@


mirror-chebi.obo:
	wget $(OBO)/chebi.obo -O $@

chebihack.obo:
	blip ontol-query -r chebi -n % -to obo > $@.tmp && egrep -v '^(def|xref|namespace):' $@.tmp | egrep -v InChI | perl -npe 's@ EXACT @ RELATED @ if m@IUPAC@'  > $@

TAGS = chebi-simple chebi-diet
OBOL_ALL_E = $(patsubst %,obol-%-exact.obo,$(TAGS))
OBOL_ALL_S = $(patsubst %,obol-%-all.obo,$(TAGS))
OBOL_ALL = $(OBOL_ALL_E) $(OBOL_ALL_S)
obol: $(OBOL_ALL)
clean_obol:
	rm $(OBOL_ALL)

OBOL= obol -r ro  -i ../ontology/ecto.obo -i cme.obo -debug qobol -debug index qobol   -tag exposure
OBOL_MRE= $(OBO) -r exposure -idspace MRE

obol-chebi-%-exact.obo: 
	$(OBOL_MRE) -i chebihack.obo -tag $*  -undefined_only true -export obo > $@ 
.PRECIOUS: obol-chebi-%-exact.obo

obol-chebi-%-all.obo: obol-chebi-%-exact.obo
	$(OBOL_MRE) -i $< -i chebihack.obo -tag $*  -undefined_only true -export obo -scope all > $@
.PRECIOUS: obol-chebi-%-all.obo


obol.obo: $(OBOL_ALL)
	obo-cat.pl $^ > $@

obol-unparsed.txt: obol.obo
	blip ontol-query -i $< -r exposure -query "class(X),id_idspace(X,'MRE'),\+genus(X,_),ID=X" -showdefs -showrel subclass > $@

cme.obo:
	blip-findall -consult chebihack.pro -i chebihack.obo w > $@


epa-trichem.obo: tri_chemical_list_for_ry15_11_5_2015_1.txt
	./trichem2obo.pl $< > $@

epa-trichem-obol.obo: epa-trichem.obo
	$(OBOL) -i $< -idspace EPATRICHEM -i chebihack.obo -tag simple  -undefined_only true -export obo -scope all > $@

epa-trichem-unparsed.txt: epa-trichem.obo epa-trichem-obol.obo
	blip ontol-query -i epa-trichem.obo -i epa-trichem-obol.obo -query "class(X),id_idspace(X,'EPATRICHEM'),\+genus(X,_),ID=X" -showdefs > $@

