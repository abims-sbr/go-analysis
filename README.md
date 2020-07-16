# goslim-analysis

## Prerequisite
### Ontology files
http://geneontology.org/docs/download-ontology/

```
# Full
wget http://purl.obolibrary.org/obo/go/go-basic.obo

# Subsets
wget http://current.geneontology.org/ontology/subsets/goslim_generic.obo
wget http://current.geneontology.org/ontology/subsets/goslim_pir.obo
# ...
```

### Dependencies

https://docs.conda.io/en/latest/miniconda.html
```
conda create -n goslim-analysis coreutils=8.31 perl-go-perl=0.15 r-ggplot2=3.1.1 r-rcolorbrewer=1.1_2
source activate goslim-analysis
```