## This script takes the output of Nico's snomed.obo.zip and removes the
## owl-axioms line that contains untranslatable axioms to produce the snomed.obo file.

grep -v ^owl-axioms snomed.obo > snomed.obo.tmp 

## use snomed CURI in obo file
sed 's/http:\/\/snomed.info\/id\//SNOMED:/g' snomed.obo.tmp > snomed.obo
rm snomed.obo.tmp
