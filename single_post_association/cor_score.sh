#!/bin/bash

# 3. Estimate genetic correlation value with SCORE

geno=base_grch37
pheno=panel_norm.tab
cov=panel_adj_gender.cov

for i in "${traits[@]}"; do
    mkdir ${i}
    for j in "${traits[@]}"; do
        SCORE/build/SCORE -g ${geno} -p ${pheno} -c ${cov} -mpheno ${i},${j} -fill -b 10
        cp output /${i}/${j}.corr
    done
done
