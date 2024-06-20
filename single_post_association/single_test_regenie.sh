#!/bin/bash

# 1. Perform single-variant association testing with regenie

inputBed=base_grch37
inputPheno=panel_norm.tab
inputCovar=panel.cov

declare -a traits=("BMI" "SBP" "DBP" "LDL" "HBA1C" "VITD" "ALT" "ALB" "ALP" "APOA" "APOB" "AST" "CAL" "CHO" "CREA" "CRP" "GGT" "GLUC" "HDL" "IGF1" "PHOS" "SHBG" "TBIL" "TPROT" "TRIG" "URA" "URT")

for i in "${traits[@]}"; do
    regenie \
        --step 1 \
        --bed ${inputBed} \
        --phenoFile ${inputPheno} \
        --phenoCol ${i} \
        --covarFile ${inputCovar} \
        --catCovarList sex \
        --qt \
        --threads 20 \
        --bsize 100 \
        --out step_1/${i}

    regenie \
        --step 2 \
        --bed ${inputBed} \
        --phenoFile ${inputPheno} \
        --phenoCol ${i} \
        --covarFile ${inputCovar} \
        --catCovarList sex \
        --pred step_1/${i}_pred.list \
        --firth \
        --approx \
        --pThresh 0.01 \
        --bsize 100 \
        --qt \
        --out step_2/base
done