library("DESeq2")
library(readr)
library("pheatmap")
library("vsn")
library(ggfortify)
library(gridExtra)
library(ggplot2)

#Load data from output of nf-core rnaseq:
load("deseq2.dds.RData")

#get sample names
sample_names<- dds$sample
write.csv(sample_names, "samples.csv", row.names = FALSE, quote=F)
coldata<- read.csv("coldata_cnt_exposed.csv", row.names=1, sep="\t")

#Run DESeq2
dds <- DESeqDataSetFromMatrix(countData = counts(dds),
colData = coldata,
design= ~ condition)
dds <- DESeq(dds)

resultsNames(dds) # lists the coefficients
res <- results(dds, name="condition_Exposed_vs_Control")

#Print out volcano type plot. Not saved. 
resLFC <- lfcShrink(dds, coef="condition_Exposed_vs_Control", type="apeglm")
plotMA(resLFC, ylim=c(-2,2))

# Create heat maps of top genes
select <- order(rowMeans(counts(dds,normalized=TRUE)),decreasing=TRUE)[1:20]
df <- as.data.frame(colData(dds)[,c("condition")])
pheatmap(assay(ntd)[select,], cluster_rows=FALSE, show_rownames=FALSE,
cluster_cols=FALSE, annotation_col=df)

select <- order(rowMeans(counts(dds,normalized=TRUE)),decreasing=TRUE)[1:20]
df <- as.data.frame(colData(dds)[,c("condition")])
pheatmap(dds[select,], cluster_rows=FALSE, show_rownames=FALSE,
cluster_cols=FALSE, annotation_col=df)

meanSdPlot(assay(ntd))
select <- order(rowMeans(counts(dds,normalized=TRUE)),decreasing=TRUE)[1:20]
ntd <- normTransform(dds)
df <- as.data.frame(colData(dds)[,c("condition")])
pheatmap(assay(ntd)[select,])


vsd <- vst(dds, blind=FALSE)

# Extract PCA data for PC1 and PC2
pca_data <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
percentVar <- round(100 * attr(pca_data, "percentVar"))

# Perform PCA analysis manually to extract PC3 and PC4
pca_results <- prcomp(t(assay(vsd)))
pc3 <- pca_results$x[, 3]
pc4 <- pca_results$x[, 4]
pca_data$PC3 <- pc3
pca_data$PC4 <- pc4

# Calculate explained variances correctly
var_explained <- pca_results$sdev^2 / sum(pca_results$sdev^2) * 100

# Function to create PCA plots with optional labels
create_pca_plot <- function(data, x, y, xlab, ylab, labels = FALSE) {
  p <- ggplot(data, aes_string(x = x, y = y, color = "condition")) +
    geom_point(size = 3) +
    stat_ellipse(aes_string(group = "condition"), level = 0.95) +
    xlab(xlab) +
    ylab(ylab) +
    theme_bw() +
    theme(legend.title = element_blank())
  
  if (labels) {
    p <- p + geom_text(aes(label = rownames(data)), vjust = 2, hjust = 0.5, size = 3)
  }
  
  return(p)
}

# Create PCA plots
p1 <- create_pca_plot(pca_data, "PC1", "PC2", 
                      paste0("PC1: ", percentVar[1], "% variance"), 
                      paste0("PC2: ", percentVar[2], "% variance"),
                      labels = FALSE)  # Set labels = TRUE to add labels

p2 <- create_pca_plot(pca_data, "PC3", "PC4", 
                      paste0("PC3: ", round(var_explained[3], 2), "% variance"), 
                      paste0("PC4: ", round(var_explained[4], 2), "% variance"),
                      labels = FALSE)  # Set labels = TRUE to add labels

# Arrange the plots side by side
grid.arrange(p1, p2, ncol = 2)

# If you want to plot individual gene expression levels (from DESeq2 manual):

#d <- plotCounts(dds, gene="BimpGene_00005995", intgroup="condition", returnData=TRUE)
#ggplot(d, aes(x=condition, y=count)) +
#geom_point(position=position_jitter(w=0.1,h=0)) +
#scale_y_log10(breaks=c(25,100,400))

savehistory("History.fatbody.txt")
