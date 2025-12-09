## Figure 1
## Beta diversity by tumor vs normal samples

source("./01_scripts/import_biom.R")

## Tumor vs Normal comparison same codes applied to other comparisons and sites
library(lme4)
library(sdamr)
library(afex)
library(broom.mixed)
library(data.table)
library(DT)
library(webshot)



## Beta diversity
set.seed(123)


p1 <-
  bdiv_ord_plot(
    biom,
    bdiv = "Bray-Curtis",
    ord="UMAP",
    stat.by = "Group",
    colors = TRUE,
    shapes = FALSE,
    layers = c(p = "point", s = "spider"),
    weighted = TRUE,caption=FALSE
  )



p1 <- p1+labs(subtitle = NULL)




p1 <-
  p1 + theme_classic() + theme(
    axis.text.x = element_text(size = 15, face = "bold"),
    axis.text.y = element_text(size = 15, face = "bold")
  )



p1 <- p1 + scale_color_brewer(palette = "Dark2")

set.seed(123)

p1_1 <-
  bdiv_ord_plot(
    biom,
    bdiv = "Bray-Curtis",
    ord="UMAP",
    stat.by = "Group",
    colors = TRUE,
    shapes = FALSE,
    layers = c(p = "point", s = "spider"),
    weighted = FALSE,caption = FALSE
  )

p1_1 <- p1_1+labs(subtitle = NULL)

p1_1 <-
  p1_1 + theme_classic() + theme(
    axis.text.x = element_text(size = 15, face = "bold"),
    axis.text.y = element_text(size = 15, face = "bold")
  )


p1_1 <- p1_1 + scale_color_brewer(palette = "Dark2")



p <- list(p1_1, p1)

pdf("./03_plots/paper_plots/Beta/Beta_TN.pdf")

ggarrange(p[[1]], p[[2]], nrow = 2)

dev.off()

### PERMONOVA adjusting for reads but there is no way to adjusted for patient level similar to mixed effects analysis

dtshow2 <- stm2dns(biom$counts) %>% as.matrix()

rownames(dtshow2) <- biom$counts$dimnames[[1]]
colnames(dtshow2) <- biom$counts$dimnames[[2]]

dtshow2 <- t(dtshow2)

matrix_file <- as.matrix(dtshow2)

meta_data <- biom$metadata%>%as.data.frame()

rownames(meta_data) <- meta_data$.sample

read_counts <- read.csv("./00_raw_data/ReadCounts.csv",header = TRUE)

read_counts <- read_counts[grep("Site1",read_counts$site),grep("sample|non",colnames(read_counts))]

read_counts <- read_counts[which(read_counts$samples%in%meta_data$.sample),]

meta_data <- merge(meta_data,read_counts,by.x=".sample",by.y="samples",all.x=TRUE)

colnames(meta_data)[grep("counts",colnames(meta_data))] <- "Counts"

meta_data <- meta_data[order(match(meta_data$.sample,rownames(matrix_file))),]

rownames(meta_data) <- meta_data$.sample

all.equal(rownames(meta_data),rownames(matrix_file))

## unweighted

distunw <- bdiv_distmat(biom,weighted = FALSE)

library(vegan)

set.seed(36) #reproducible results


uwdiv<-adonis2(distunw~Group+Counts, data=meta_data, permutations=9999,by="margin")


## weighted

distw <- bdiv_distmat(biom,weighted = TRUE)

library(vegan)

set.seed(36) #reproducible results

wdiv<-adonis2(distw~Group+Counts, data=meta_data, permutations=9999,by="margin")