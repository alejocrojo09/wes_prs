#!/bin/bash

# Quality control of genotype data (WES or array) 

# 1. Keep SNPs and remove duplicate varaints

for chr in {1..22} X; do
    bfile=UKB_chr${chr}
    output=UKB_chr${chr}
    plink --bfile ${bfile} --snps-only --make-bed --out ${output} 
done

# 2. Split chromosome X PAR regions

bfile=UKB_chrX
output=UKB_chrX
plink --bfile ${bfile} --split-x hg38 --snps-only --make-bed --out ${output}

# 3. Remove duplicated variants (PLINK2)

for chr in {1..22} X; do
    bfile=UKB_chr${chr}
    output=UKB_chr${chr}
    plink2 --bfile ${bfile} --rm-dup force-first --make-bed --out ${output}
done

# 4. Keep individuals with matched ancestry with target cohort (IAF-EUR)

for chr in {1..22} X; do
    bfile=UKB_chr${chr}
    samples=ukb_eur.ids
    output=UKB_chr${chr}

    plink --bfile ${bfile} --keep ${samples} --make-bed --out ${output}
done

# 5. Remove sample and SNP-level missing data (Two-step filtering)

for chr in {1..22} X; do
    # Step 1: missing at 10%
    bfile=UKB_chr${chr}
    outputGeno1=UKB_chr${chr}
    plink --bfile ${bfile} --geno 0.1 --make-bed --out ${outputGeno1} 
    
    outputInd1=UKB_chr${chr}
    plink --bfile ${outputGeno1} --mind 0.1 --make-bed --out ${outputInd1}
    
    # Step 2: missing at 1%
    outputGeno2=UKB_chr${chr}
    plink --bfile ${outputInd1} --geno 0.01 --make-bed --out ${outputGeno2}
    
    outputInd2=UKB_chr${chr}
    plink --bfile ${outputGeno2} --mind 0.01 --make-bed --out ${outputInd2}
done

# 6. Filter MAF > 1%

for chr in {1..22} X; do
    bfile=UKB_chr${chr}
    output=UKB_chr${chr}
    plink --bfile ${inputFile} --maf 0.01 --make-bed --out ${output}
done

# 7. Filter for HWE (Two-step filtering)

for chr in {1..22} X; do
    # Step 1: HWE P-value < 1E-50
    bfile=UKB_chr${chr}
    outputHwe1=UKB_chr${chr}
    plink --bfile ${bfile} --hwe 1E-50 --make-bed --out ${outputHwe1}
    
    # # Step 2: HWE P-value < 1E-06
    outputHwe2=UKB_chr${chr}
    plink --bfile ${outputHwe1} --hwe 1E-06 --make-bed --out ${outputHwe2}
done

# 8. Filter for LD

for chr in {1..22} X; do
    bfile=UKB_chr${chr}
    output=UKB_chr${chr}
    plink --bfile ${bfile} --indep-pairwise 200 100 0.1 --out ${output}
    plink --bfile ${bfile} --extract ${output}.prune.in --make-bed --out ${output}
done

# 9. Merge files

find . -name "*.bim" > ukb_merge.list

plink --merge-list ukb_merge.list --out UKB_merge

# 10. Remove related individuals with KING (PLINK2)

bfile=UKB_merge
output=UKB_king

plink2 --bfile ${bfile} --king-cutoff 0.177 --make-bed --threads 10 --memory 10000 --out ${output} # Adjust memory usage if necessary

# 11. Remove individuals with sex discrepancies
# Check F values for diagnostics
bfile=UKB_king
outputFValues=UKB_sex
plink --bfile ${inputFile} --check-sex --out ${outputFValues}

# Impute
bfile=UKB_king
outputSex1=UKB_sex
plink --bfile ${inputFile} --impute-sex 0.2 0.8 --make-bed --out ${outputSex1}

# Remove remaining ambiguous individuals
outputSex2=UKB_sex
plink --bfile ${outputSex1} --check-sex --out ${outputSex2}
grep "PROBLEM" ${outputSex2}.sexcheck | awk '{print$1,$2}' > ${outputSex2}.fail.ids

outputSex3=UKB_sex
plink --bfile ${outputSex1} --remove ${outputSex2}.fail.ids --make-bed --out ${outputSex3}

# 12. Remove individuals with high heterozygosity

# Calculate homozygosity values to estimate heterozygosity rates and identify outliers (+/3 SD)
bfile=UKB_sex
output=UKB_het
plink --bfile ${inputFile} --het --out ${outputFile}

# Remove with the ids of outliers
bfile=UKB_sex
output=UKB_het
plink --bfile ${bfile} --remove ${output}.fail.ids --make-bed --out ${output}

# 13. Get autosomal chromosomes (PLINK2)

bfile=UKB_het
output=UKB_qc_chr
plink2 --bfile ${inputFile} --chr 1-22 --output-chr chrM --make-bed --out ${output}

# 14. Create VCF file

bfile=UKB_qc_chr
output=UKB_vcf
refGenome=GRCh38_full_analysis_set_plus_decoy_hla.fa

plink2 --bfile ${bfile} --fa ${refGenome} --export vcf bgz --out ${output}
