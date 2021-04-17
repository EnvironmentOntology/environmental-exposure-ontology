This folder serves two purposes

 * as a test of the kboom ontology merging process
 * To explore strategies the merging of multiple exposure ontologies

The ontology [merged-exposure.obo](merged-exposure.obo) contains the ontologies merged by kboom

See [rpt.md](rpt.md) for the kboom report

Example:

![img](target/img-EO_0007154.png)

Instructions:

1. To download the source ontologies for the alignment, run:

```
make all_exposure
```

Note: If you want to include SNOMED in the alignmnet process, you can only do that with an appropriate license. The pipeline expects the snomed.obo file in the src/ontology directory.