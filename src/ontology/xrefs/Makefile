XREFS = mre ncit wikidata

fixed-xrefs-mre.obo: ecto-xrefs-mre.obo
	cp $< $@
fixed-xrefs-wikidata.obo: ecto-xrefs-mre.obo
	perl -npe 's@Wikidata:@http://www.wikidata.org/entity/@' $< > $@
fixed-xrefs-ncit.obo: ecto-xrefs-ncit.obo
	perl -npe 's@NCIT:@http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#@' $< > $@

ecto-xrefs.owl: $(patsubst %,fixed-xrefs-%.obo,$(XREFS))
	owltools $^ --merge-support-ontologies --remove-annotation-assertions -p http://www.geneontology.org/formats/oboInOwl#hasDbXref -o $@ && perl -pi -ne 's@#string">http@#anyURI">http@' $@
