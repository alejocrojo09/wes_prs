library(flashpcaR)

# PCA analysis with FlashPCA2

path.bed = "/ukb_wes" # Path to BED files (WES or array

pca = flashpca(path.bed, ndim = 40)

# Create a data frame with the generated eigenvectors and individuals IDs as row names

pca.vectors = as.data.frame(pca$vectors)
id = rownames(pca.vectors)
rownames(pca.vectors) = NULL
FID = id
IID = FID
pca = data.frame(FID, IID, pca.vectors)
pca$FID = gsub('.*:', '', pca$FID)
pca$IID = gsub('.*:', '', pca$IID)

# Save results 
path.pca = "wes.pca"
saveRDS(pca, "wes.rds")
write.table(pca, path.pca, row.names = FALSE, col.names = TRUE, quote = FALSE)
