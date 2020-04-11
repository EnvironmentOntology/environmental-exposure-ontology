## This script takes the output of Nico's snomed.obo.zip file and creates a new 
## obo file with a new header and skips the OWL functional syntax at the 
## beginning of the file

#sed -n '1,3 p' snomed-mixed.obo > header.obo # print out lines 1-3

## easier to just build a new header
echo $'format-version: 1.2' > header.obo
echo $'ontology: snomed' >> header.obo

## output everyting from line 5 on
tail -n +5 snomed.obo > body.obo

## merger header and body
cat header.obo body.obo > tmp.obo

## use snomed CURI in obo file
sed 's/http:\/\/snomed.info\/id\//SNOMED:/g' tmp.obo > snomed.obo
rm header.obo body.obo tmp.obo
