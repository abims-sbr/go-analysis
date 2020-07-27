# goslim-analysis

## Prerequisite
### Ontology files
http://geneontology.org/docs/download-ontology/

```
# Full
wget http://purl.obolibrary.org/obo/go/go-basic.obo
#get ftp://ftp.geneontology.org/go/ontology/gene_ontology.obo

# Subsets
wget http://current.geneontology.org/ontology/subsets/goslim_generic.obo
wget http://current.geneontology.org/ontology/subsets/goslim_pir.obo
# ...
```

### Dependencies

https://docs.conda.io/en/latest/miniconda.html
```
conda create -n goslim-analysis coreutils=8.31 perl-go-perl=0.15 r-ggplot2=3.1.1 r-rcolorbrewer=1.1_2 r-optparse
conda activate goslim-analysis
```

## Usage
### goslimWrapper.sh

#### Inputs
The mandatory column are: id (here col1), logFC (here col3) and GO numbers separated by space (here col4)
```
comp20180_c0_seq1       1.258866547     0.08025349      GO:0005634 GO:0003682 GO:0003677 GO:0005515 GO:0010468 GO:0006355 GO:0006351
comp2018_c0_seq1        -3.081078296    1.76E-06     GO:0005739 GO:0005634 GO:0043565 GO:0003700 GO:0008270 GO:0007517 GO:0006351
comp2706_c0_seq1        -7.408903924     8.79E-05        GO:0031225
comp27949_c0_seq1       -2.251179759    0.000217982  GO:0016021 GO:0005886 GO:0005509 GO:0005515 GO:0021987 GO:0007157 GO:0035329 GO:0007156 GO:0022008
```

#### Run
```
./goslimWrapper.sh table_with_GO_number.tab
```
Or something like that if you have plenty of files (here I'm filtering on the filename ended by `U.tab` or `A.tab`)
```
conda activate goslim-analysis
for file_i in *[UA].tab; do echo $file_i; srun "../../../script/goslim-analysis/goslimWrapper.sh $file_i" & echo "next"; done
```

#### Outputs

### goslimWrapper.sh
