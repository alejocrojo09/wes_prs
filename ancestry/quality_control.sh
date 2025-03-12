#!/bin/bash

# Quality control UKB-WES (Data field: 23156)

for chr in {1..22}; do
    input=UKB_chr${chr}
    output=wes/UKB_chr${chr}
    
    plink --bfile ${input} --maf 0.10 --indep-pairwise 200 100 0.1 --out ${output}
    plink --bfile ${input} --extract ${output}.prune.in --make-bed --out ${output}
done

# Quality control UKB-Imputed array (Data field: 23156) - PLINK2 has support for BGEN 

for chr in {1..22}; do
    bgen=ukb22828_c${chr}_b0_v3.bgen
    sample=ukb22828_c${chr}_b0_v3.sample
    pfile=UKB_chr${chr}
    output=UKB_chr${chr}

    plink2 --bgen ${bgen} ref-first --sample ${sample} --make-pgen --memory 10000 --threads 12 --out ${pfile}

    plink2 --pfile ${pfile} --maf 0.10 --indep-pairwise 200 100 0.1 --out ${output}
    plink2 --pfile ${pfile} --extract ${output}.prune.in --make-bed --out ${output}
done

# Make a list of BED files to merge into a single one

find . -name "*.bim" > merge_chr.list   

plink --merge-list merge_chr.list --out ukb_wes # or array
