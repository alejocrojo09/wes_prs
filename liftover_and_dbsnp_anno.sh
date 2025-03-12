#!/bin/bash

# 1. Liftover

java -jar -Xmx240g picard.jar LiftoverVcf  \
    -I UKB_qc.vcf.gz \
    -R human_g1k_v37.fasta \
    -O UKB_qc_grch37.vcf.gz \
    -C GRCh38_to_GRCh37.chain \
    --REJECT UKB_qc_rejected.vcf \
    --RECOVER_SWAPPED_REF_ALT true \
    -WMC true

# 2. dbSNP 153

bcftools annotate -x ID UKB_qc_grch37.vcf.gz -o UKB_qc_grch37.vcf.gz --threads 10 -Oz # Remove SNPs ids
bcftools index UKB_qc_grch37.vcf.gz

java -jar -Xmx200g SnpSift.jar annotate dbsnp153_grch37.vcf.gz UKB_qc_grch37.vcf.gz > UKB_qc_grch37.vcf.gz

# Convert to BED format using PLINK --vcf for analyses

