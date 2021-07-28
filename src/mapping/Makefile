#all: all_exposure ecto.sssom.tsv  rpt.html merged-exposure.obo axioms-r.obo  hier all_ecto unmapped.tsv
all: all_exposure ecto.sssom.tsv rpt.html merged-exposure.obo axioms-r.obo  hier all_ecto unmapped.tsv

OBO = http://purl.obolibrary.org/obo

# eo, the plant environment ontology, was previously used here but is now obsoleted
#MOD = wikidata
MOD = xco zeco exo peco ecto ncit go snomed mre eo

## define variables for ontologies
XCO_OBO = "http://purl.obolibrary.org/obo/xco.obo"
NCIT_OBO = "http://purl.obolibrary.org/obo/ncit.obo"
ZECO_OBO = "http://purl.obolibrary.org/obo/zeco.obo"
PECO_OBO = "http://purl.obolibrary.org/obo/peco.obo"
EO_OBO = "http://purl.obolibrary.org/obo/eo.obo"
GO_OBO = "http://purl.obolibrary.org/obo/go.obo"
EXO_OBO = 'http://purl.obolibrary.org/obo/exo.obo'
MRE_OWL = "https://github.com/monarch-initiative/Medically-Relevant-Exposome/blob/master/src/ontology/mre-edit.owl"


all_exposure: $(patsubst %, exposure-%.obo,$(MOD))

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


## XCO in OBO copy all ontology
exposure-xco.obo:
	wget --no-check-certificate $(XCO_OBO) -O $@


## ZECO in OBO copy all ontology
exposure-zeco.obo:
	wget --no-check-certificate $(ZECO_OBO) -O $@


## just strings matching name
exposure-mesh.obo:
	ogr -t obo -r mesh-obo.json %xposure% > $@


## now called pheco <----  CAN'T FIND PHECO, SO I'LL USE PECO
exposure-peco.obo:
	wget --no-check-certificate $(PECO_OBO) -O $@


## currently no content in MRE ((Medically-Relevant-Exposome) to transform
exposure-mre.obo:
	git clone https://github.com/monarch-initiative/Medically-Relevant-Exposome.git
	robot convert -i Medically-Relevant-Exposome/src/ontology/mre-edit.owl -o mre.obo
	mv mre.obo $@


## extract subclasses of 'Exposureure to potentially harmful entity'; note: snomed.obo must be in proper form before running
#SNOMED_PREFIX=http://purl.obolibrary.org/obo/SNOMED_
SNOMED_PREFIX=http://snomed.info/id/
exposure-snomed.obo:
	export ROBOT_JAVA_ARGS=-Xmx16G && robot extract --method top -i ../ontology/snomed.obo -t "$(SNOMED_PREFIX)418715001" -o tmp-snomed.obo
	mv tmp-snomed.obo $@


## extact classes containg 'xposure'; note: using obo-grep for performance reasons
exposure-ncit.obo:
	wget --no-check-certificate $(NCIT_OBO) -O tmp-in.obo
	perl obo-grep.pl -r ".*xposure.*" tmp-in.obo > tmp-xposure.obo # find obo stanzas containing *xposure*
	rm tmp-in.obo
	mv tmp-xposure.obo $@


## extract subclasses of 'response to stimulus'
exposure-go.obo:
	wget --no-check-certificate $(GO_OBO) -O tmp-in.obo
	export ROBOT_JAVA_ARGS=-Xmx16G && robot extract --method top -i tmp-in.obo -t GO:0050896 -o tmp-out.obo # get subclasses of 'response to stimulus'
	perl obo-grep.pl -r 'name: .*response to.*' tmp-out.obo > tmp-go.obo # filter

	rm tmp-in.obo
	rm tmp-out.obo
	mv tmp-go.obo $@


## EXO in OBO copy ontology
exposure-exo.obo:
	wget --no-check-certificate $(EXO_OBO) -O $@


exposure-ecto.obo: ../../ecto-base.obo
	cp $< $@


# MERGE ALL SUB ONTOLOGIES TOGETHER
#combined-exposure.obo:
# combined-exposure.obo: all_exposure
# 	perl obo-cat.pl exposure-*.obo | grep -v ^namespace: | grep -v ^property_value: | ./add-syns.pl > $@
# .PRECIOUS: combined-exposure.obo

EXPOSURE_ONTS=$(patsubst %, exposure-%.obo,$(MOD))

slim-exposure.obo: $(EXPOSURE_ONTS)
	perl obo-cat.pl $(EXPOSURE_ONTS) | grep -v ^namespace: | grep -v ^property_value: | ./add-syns.pl > $@
.PRECIOUS: slim-exposure.obo


slim-exposure.owl: slim-exposure.obo
	robot convert -i slim-exposure.obo -o slim-exposure.owl

RDFMATCHDEBUG=
RDFMATCH = swipl -p library=/tools/rdf_matcher/prolog /tools/rdf_matcher/bin/rdfmatch $(RDFMATCHDEBUG)


slim-exposure.ttl: slim-exposure.obo shacl-declarations.ttl
	robot convert -i $< --check false -o $@
	## prepend SHACL declarations
	cat shacl-declarations.ttl $@ > slim-exposure.tmp && mv slim-exposure.tmp $@

ecto.sssom.tsv: slim-exposure.ttl
	## run rdfmatch to generate match info
	# -G match-graph.ttl -f tsv 
	$(RDFMATCH) -i slim-exposure.ttl --predicate skos:exactMatch match > full_$@
	sssom dedupe -i full_$@ -o $@
	# The following is needed because the SSSOM dedupe command does not handle sssom annotations
	grep "^[^#]" $@ > $@.tmp && mv $@.tmp $@ # This is removing all metadata in case the command gets fixed
	grep "^[#]" full_ecto.sssom.tsv > meta_full_ecto.sssom.tsv
	cat meta_full_ecto.sssom.tsv $@ > tmp.ecto.sssom.tsv
	mv tmp.ecto.sssom.tsv $@
	
	# We could use the sssom file coming out of rdfmatcher and call this done
	# (obo weights) file added
	# Take sssom.py to generate the ptables
	# sssom command to collaps to highest probablity one
	# ptable + ontologies go into boomer
	# many different voc (say mod)
	# merge then put them tohether - 
	# How many unmatched MRE terms?
	# Make MRE table

.PHONY: release_mappings
release_mappings:
	cp ecto.sssom.tsv ../../mappings/ecto.sssom.tsv

old_commands:
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

MAX_E=8
axioms.owl: slim-exposure.owl ecto.sssom.tsv 
	kboom --experimental  --splitSize 50 --max $(MAX_E) -m rpt.md -j rpt.json -n -o $@ -t ecto.sssom.tsv $<

axioms-boomer.owl: slim-exposure.owl ecto.sssom.tsv prefixes.yaml output.ofn
	robot convert -i output.ofn -o output.owl
	mv output.owl $@

output.ofn:
	boomer --ptable ecto.sssom.tsv --ontology slim-exposure.owl --window-count 10 --runs 20 --prefixes prefixes.yaml

########################################
# These don't work. For some reason,
# it keeps throwing an "Error 1". E.g.:
#   Reaping losing child 0x7fcbf1410430 PID 96143 
#   make: *** [axioms-boomer.owl] Error 1
#   Removing child 0x7fcbf1410430 PID 96143 from chain.
# I think it is keeping a lock on the
# output file *(output.ofn).
# So, using output.ofn target
########################################
#axioms-boomer.owl: slim-exposure.owl ecto.sssom.tsv prefixes.yaml
#	boomer --ptable ecto.sssom.tsv --ontology slim-exposure.owl --window-count 10 --runs 20 --prefixes prefixes.yaml
#	robot convert -i output.ofn -o output.owl
#	mv output.owl $@
#boomer-output.ofn:
#	boomer --ptable ecto.sssom.tsv --ontology slim-exposure.owl --window-count 10 --runs 20 --prefixes prefixes.yaml
#	mv output.ofn $@

rpt.html: axioms.owl
	pandoc rpt.md -o rpt.html


clean-axioms:
	rm $(patsubst %, exposure-%.obo,$(MOD))
	rm slim-exposure.owl
	rm axioms.owl
	rm ecto.sssom.tsv
