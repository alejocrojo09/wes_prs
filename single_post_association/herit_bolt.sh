#!/bin/bash

# 2. Estimate heritability measurements with BOLT-LMM (values in stdout)

inputMap=BOLT-LMM_v2.4/tables/genetic_map_hg38_withX.txt.gz
inputLd=BOLT-LMM_v2.4/tables/LDSCORE.1000G_EUR.tab.gz


for i in "${traits[@]}"; do
    bolt \
        --reml \
        --bfile ${inputBed} \
        --geneticMapFile ${inputMap} \
        --LDscoresFile ${inputLd} \
        --phenoFile ${inputPheno} \
        --covarFile ${inputCovar} \
        --phenoCol ${i} \
        --covarCol sex \
        --qCovarCol age \
        --qCovarCol PC{1:40} \
        --numThreads 10 
done 