library(data.table)
library(umap)
library(dplyr)

# Read PCA data frame from FlashPCA2

pca = read.table('wes.pca', header = TRUE) # Or array

# Read metadata and map self-identified ethnicity

ukb.groups = read.table("ukb_fields_metadata.tab", header = TRUE) 
ethnGroup = data.frame(ukb.groups$eid, ukb_groups$ethnicBatch1)
colnames(ethnGroup) = c('eid', 'ethnicCode')

pcaGroup = ethnGroup[ethnGroup$eid %in% eids,]

# Translate the codes into ethnic background
for (i in 1:nrow(pcaGroup)){
    ethnvalue = pcaGroup$ethnicCode[i]
    if (ethnvalue == 1001) {
        pcaGroup$ethnicCode[i] <- 'British'
    } else if (ethnvalue == 2001) {
        pcaGroup$ethnicCode[i] <- 'White and Black Caribbean'
    } else if (ethnvalue == 3001) {
        pcaGroup$ethnicCode[i] <- 'Indian'
    } else if (ethnvalue == 4001) {
        pcaGroup$ethnicCode[i] <- 'Caribbean' 
    } else if (ethnvalue == 1002) {
        pcaGroup$ethnicCode[i] <- 'Irish'
    } else if (ethnvalue == 2002) {
        pcaGroup$ethnicCode[i] <- 'White and Black African'
    } else if (ethnvalue == 3002) {
        pcaGroup$ethnicCode[i] <- 'Pakistani'
    } else if (ethnvalue == 4002) {
        pcaGroup$ethnicCode[i] <- 'African'
    } else if (ethnvalue == 1003) {
        pcaGroup$ethnicCode[i] <- 'Any other white background'
    } else if (ethnvalue == 2003) {
        pcaGroup$ethnicCode[i] <- 'White and Asian'
    } else if (ethnvalue == 3003) {
        pcaGroup$ethnicCode[i] <- 'Bangladeshi'
    } else if (ethnvalue == 4003) {
        pcaGroup$ethnicCode[i] <- 'Any other Black background'
    } else if (ethnvalue == 2004) {
        pcaGroup$ethnicCode[i] <- 'Any other mixed background'
    } else if (ethnvalue == 3004) {
        pcaGroup$ethnicCode[i] <- 'Any other Asian background'c
    } else if (ethnvalue == 5) {
        pcaGroup$ethnicCode[i] <- 'Chinese'
    } else if (ethnvalue == 6) {
        pcaGroup$ethnicCode[i] <- 'Other ethnic group'
    } else {
        pcaGroup$ethnicCode[i] <- 'Unknown'
    }
}

colnames(pcaGroup) = c('FID','Population')
pca = merge(pca, pcaGroup, by = 'FID')

# UMAP analysis

pca.full = pca %>% select(V1:V40) # Use the 40 PCs for UMAP
ukb.pop = pca %>% select(Population)
umap.pca = umap(pca.full)

layout.umap = data.frame(umap.pca[['layout']])
UMAP1 = layout.umap$X1
UMAP2 = layout.umap$X2
Population = pca$Population
umap.ukb = data.frame(UMAP1, UMAP2, Population)
