all: all_exposure probs.tsv m.tsv  rpt.html merged-exposure.obo axioms-r.obo  hier all_ecto unmapped.tsv

OBO = http://purl.obolibrary.org/obo

MOD = peco xco zeco exo ecto go ncit snomed

## define variables for ontologies
OBO=http://purl.obolibrary.org/obo
EO_OBO = "http://purl.obolibrary.org/obo/peco.obo"
XCO_OBO = "http://purl.obolibrary.org/obo/xco.obo"
NCIT_OBO = "http://purl.obolibrary.org/obo/ncit.obo"
THESAURUS = "https://evs.nci.nih.gov/ftp1/rdf/Thesaurus.owl" # direct from NCI
NCIT_OWL = "http://purl.obolibrary.org/obo/ncit.owl"
ZECO_OBO = "http://purl.obolibrary.org/obo/zeco.obo"
PECO_OBO = "http://purl.obolibrary.org/obo/peco.obo"
GO_OBO = "http://purl.obolibrary.org/obo/go.obo"
EXO_OBO = 'http://purl.obolibrary.org/obo/exo.obo'
MRE_OBO = ""

.PHONY: all clean all_exposure 

all_exposure: $(patsubst %, exposure-%.obo,$(MOD))

clean:
	rm $(patsubst %, exposure-%.obo,$(MOD))
	rm axioms.owl
	rm probs.tsv

# ----------------------------------------
# creation of source ontology subsets
# ----------------------------------------
#
# we create a set of ontology subsets that feed into the alignment pipeline.
#
# in some cases these are the entire ontology. In some cases it is a subset of
# an existing ontology (ie those matching a string match or subclasses of a root
# of a branch)
#
# these are all named exposure-X, where X is the source ontology

TEST_MOD = peco xco zeco
test-robot: exposure-peco.obo  exposure-xco.obo  exposure-zeco.obo
	robot convert -i exposure-peco.obo -o exposure-peco-tmp.obo
	robot convert -i exposure-xco.obo -o exposure-xco-tmp.obo
	robot convert -i exposure-zeco.obo -o exposure-zeco-tmp.obo


	mv exposure-peco-tmp.obo exposure-peco.obo
	mv exposure-xco-tmp.obo exposure-xco.obo
	mv exposure-zeco-tmp.obo exposure-zeco.obo

	#robot merge $(patsubst %,-i %, $^) -o merge-test.obo
	robot merge -i exposure-peco.obo -i exposure-xco.obo -i exposure-zeco.obo -o merge-test.obo

# XCO in OBO copy all ontology
exposure-xco.obo:
	wget --no-check-certificate $(XCO_OBO) -O $@

# copy all ontology
exposure-zeco.obo:
	wget --no-check-certificate $(ZECO_OBO) -O $@

# now called pheco <----  CAN'T FIND PHECO, SO I'LL USE PECO
exposure-peco.obo:
	#robot merge -i $(PECO_OBO) > $@
	wget --no-check-certificate $(PECO_OBO) -O $@

exposure-ncit.obo:
	wget --no-check-certificate $(NCIT_OBO) -O tmp-in.obo
	#wget --no-check-certificate $(NCIT_OWL) -O tmp-in.owl
	#wget --no-check-certificate $(THESAURUS) -O tmp-in.owl
  
	## WORKS BUT IS QUITE SLOW
	#export ROBOT_JAVA_ARGS=-Xmx16G && robot \
	#  convert -f owl -i tmp-in.obo -o tmp-out.owl \
	#  query -i tmp-out.owl --tdb true --keep-tdb-mappings true -q xposure.sparql tmp-out.tsv

  # THIS RUN BETTER B/C IT DOES NOT HAVE TO CONVERT FROM OBO TO OWL
	#export ROBOT_JAVA_ARGS=-Xmx16G && robot \
	#  query -i tmp-in.owl --tdb true -q xposure-construct.sparql tmp-out.obo
	
	## MUCH FASTER
	obo-grep.pl -r ".*xposure.*" tmp-in.obo > tmp-xposure.obo # find obo stanzas containing *xposure*
	
	## steps in this pipeline ## NOT NEEDED IT DOESN'T MAKE A DIFFERENCE IN OUTPUT
	## obo-strip: keep only the id lines from the obo stanzas
	## grep: return only the id lines
	## cut: return only the NCIT identifier in the line
	## sed: replace "NCIT:" with full IRI
	# obo-strip.pl -t id tmp-xposure.obo | grep id: | cut -f2 -d' ' | sed 's/NCIT:/http:\/\/purl\.obolibrary\.org\/obo\/NCIT_/g' > tmp-ids
	
	## run robot filter to get any subclasses of the NCIT classes
	#robot filter -i tmp-xposure.obo --term-file tmp-ids --trim false --select "self children" -o tmp-out.obo
	
	rm tmp-in.obo
	#rm tmp-ids
	#rm tmp-xposure.obo
	# mv tmp-out.obo $@

exposure-go.obo:
	#blip ontol-query -r go -query "class(R,'response to stimulus'),subclassRT(ID,R)" -to obo | obo-grep.pl -r 'name: response to' - > $@
	wget --no-check-certificate $(GO_OBO) -O tmp-in.obo
	robot extract --method top -i tmp-in.obo -t GO:0050896 -o tmp-out.obo # get subclasses of 'response to stimulus'
	obo-grep.pl -r 'name: .*response to.*' tmp-out.obo > tmp-go.obo # filter
	
	rm tmp-in.obo
	rm tmp-out.obo
	mv tmp-go.obo $@

exposure-exo.obo:
	wget --no-check-certificate $(EXO_OBO) -O $@

exposure-ecto.obo: ../../subsets/ecto-basic.obo
	cp $< $@

exposure-snomed.obo:
	export ROBOT_JAVA_ARGS=-Xmx16G && robot extract --method top -i ../ontology/snomed.obo -t "http://snomed.info/id/418715001" > tmp-snomed.obo
	mv tmp-snomed.obo > $@
  
# MOD = peco xco zeco exo ecto go ncit snomed
slim-exposure.obo: $(patsubst %, exposure-%.obo,$(MOD))
	obo-cat.pl $^ | grep -v ^namespace: | grep -v ^property_value: | ./add-syns.pl > $@
	
  #############################
  # The robot merge command below throws error:
  # OBO STRUCTURE ERROR Ontology does not conform to OBO structure rules:
  # multiple def tags not allowed. in frame:Frame(ENVO:00010483 id( ENVO:00010483)synonym( portion of environmental material EXACT)name( environmental material)namespace( plant_experimental_conditions_ontology)def( A portion of environmental material is a fiat object part which forms the medium or part of the medium of an environmental system.[DOI:10.1186/2041-1480-4-43 MA:ma ORCID:0000-0002-4366-3088 URL:http://ontology.buffalo.edu/smith/articles/niches.html ])def( A portion of environmental material is a fiat object which forms the medium or part of the medium of an environmental system.[DOI:10.1186/2041-1480-4-43 MA:ma ORCID:0000-0002-4366-3088 URL:http://ontology.buffalo.edu/smith/articles/niches.html ])is_a( BFO:0000040)is_a( BFO:0000024))
  # 
  # So, using obo-cat.
  #############################
	
	#robot merge \
	#  -i exposure-zeco.obo \
	#  -i exposure-peco.obo \
	#  -i exposure-exo.obo \
	#  -i exposure-xco.obo \
	#  -i exposure-ecto.obo \
	#  -o tmp.obo
	#grep -v ^namespace: tmp.obo | grep -v ^property_value: | ./add-syns.pl > $@
	  
.PRECIOUS: slim-exposure.obo

MAX_E=8
axioms.owl: slim-exposure.owl probs.tsv
	kboom --experimental  --splitSize 50 --max $(MAX_E) -m rpt.md -j rpt.json -n -o $@ -t probs.tsv $<

probs.tsv: slim-exposure.obo
	## convert slim-exposure.obo to ttl
	robot convert -i slim-exposure.obo --check false -o slim-exposure.ttl
	
	## prepend schacl declarations
	cat shacl-declarations.ttl slim-exposure.ttl > slim-exposure.tmp && mv slim-exposure.tmp slim-exposure.ttl
	
	## run rdfmatch to generate match info
	rdfmatch -G match-graph.ttl -f tsv -i slim-exposure.ttl match > match-output.txt
	
	## find exact label matches; the cut command returns the first two columns of output
	egrep 'info\((label|exact)-(label|exact)' match-output.txt | cut -f1,2 | uniq > exact-matches.txt
	
	## find other matches not in the exact matches file; note the removal of the null line
	cut -f1,2 match-output.txt | fgrep -v -x -f exact-matches.txt | uniq | grep -v null > non-exact-matches.txt

	## append probs of "0.1 0.1 0.85 0.1" to exact label matches
	awk '{print $$0 "\t0.1\t0.1\t0.85\t0.1"}' exact-matches.txt > exact-matches.tmp && mv exact-matches.tmp exact-matches.txt
	
	## append probs of "0.1 0.1 0.7 0.1" for other matches
	awk '{print $$0 "\t0.1\t0.1\t0.7\t0.1"}' non-exact-matches.txt > non-exact-matches.tmp && mv non-exact-matches.tmp non-exact-matches.txt
	
	## create probs file
	cat exact-matches.txt non-exact-matches.txt > $@
	
	## clean up
	rm exact-matches.txt
	rm non-exact-matches.txt

	
