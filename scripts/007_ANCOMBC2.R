source("./01_scripts/import_biom.R")



## Tumor vs Normal comparison ANCOMBC2 -same code applies to both sites
library(TreeSummarizedExperiment)
library(lme4)
library(sdamr)
library(afex)
library(broom.mixed)
library(data.table)
library(DT)
library(webshot)
library(mia)


counts <- matrix_file_4

tax <- tax_file_red_2

rownames(tax) <- tax$.otu

tax <- tax[rownames(tax)%in%rownames(counts),]

counts <- counts[rownames(counts)%in%rownames(tax),]

meta_2 <- meta_2[meta_2$.sample%in%colnames(counts),]

read_counts <- read.csv("./00_raw_data/ReadCounts.csv",header = TRUE)

read_counts <- read_counts[grep("Site1",read_counts$site),grep("sample|non",colnames(read_counts))]

meta_2 <- merge(meta_2,read_counts,by.x=".sample",by.y="samples",all.x=TRUE)

rownames(meta_2) <- meta_2$.sample

colnames(meta_2)[grep("nonh",colnames(meta_2))] <- "Counts"

samples <- meta_2

rownames(samples) <- meta_2$.sample



counts <- counts[order(match(rownames(counts),rownames(tax))), order(match(colnames(counts),rownames(samples)))]

all.equal(rownames(counts),rownames(tax))

all.equal(colnames(counts),rownames(samples))

# Let's ensure that the data is in correct (numeric matrix) format:
counts <- as.matrix(counts)


tse <- TreeSummarizedExperiment(
  assays =  SimpleList(counts = counts),
  colData = DataFrame(samples),
  rowData = DataFrame(tax))



## ANCOMBC2
library(ANCOMBC)
set.seed(123)
# It should be noted that we have set the number of bootstrap samples (B) equal 
# to 10 in the 'trend_control' function for computational expediency. 
# However, it is recommended that users utilize the default value of B, 
# which is 100, or larger values for optimal performance.
output = ancombc2(data = tse, tax_level = "Species",
                  fix_formula = "Group + Counts",
                  rand_formula = "(1 | Pt_ID)",
                  p_adj_method = "holm", 
                  prv_cut = 0.10, 
                  group = "Group", neg_lb = TRUE,
                  alpha = 0.1,  verbose = TRUE)

res_prim = output$res %>%
  mutate_if(is.numeric, function(x) round(x, 2))

res_prim <- res_prim[!is.na(res_prim$lfc_GroupT),]

res_prim <- res_prim[,grep("taxon|GroupT",colnames(res_prim))]

res_primary <- res_prim


write.csv(res_prim,"./02_tidy_data/tables/Ancombc_res.csv")


library(ggplot2)
library(RColorBrewer)

res_prim$direction <- ifelse(res_prim$lfc_GroupT>0,"Increased in tumors","Decreased in tumors")

res_prim$taxon <- gsub("g__","",res_prim$taxon)

res_prim$taxon <- gsub("_", " ",res_prim$taxon)


# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Save the results 
# ────────────────────────────────────────────────────────────────────────────────────────────────────

pdf("./03_plots/Aug/Maaslin/Ancombc_TN.pdf")

plot <- ggplot(res_prim , aes( y=lfc_GroupT, x=reorder(taxon,lfc_GroupT),fill=direction)) + 
  geom_bar(position="dodge", stat="identity")+xlab("Taxa")+ylab("Effect size")

plot <- plot+theme_classic()+theme(axis.text.x = element_text(size=14,angle=90,face="bold"),axis.text.y = element_text(size=14,face="bold.italic"))+coord_flip()

plot+scale_fill_brewer(palette = "Set2")

dev.off()

