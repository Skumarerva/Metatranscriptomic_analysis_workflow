rm(list=ls())
library(dplyr)
library(ggplot2)
library(tidyr)
library(data.table)


## Data for Survival analysis only in tumor samples


meta_data <- meta_2[meta_2$Group%in%"T",]

meta_data$vital_status <- ifelse(meta_data$VS%in%"alive",0,1)


## Load ANCOMBC results


res_primary <- read.csv("./02_tidy_data/ANCOMBC_results.csv") 

results <- merge(res_primary,tax, by.y="Species",by.x="taxon",all.x=TRUE)

## filtere counts matrix for only significant OTUs

matfile1 <- counts[rownames(counts)%in%results$.otu,]

mat_long <- reshape2::melt(matfile1)

colnames(mat_long) <- c("Otu","Sample","Counts")

mat_long <- merge(mat_long,tax,by.x="Otu",by.y=".otu",all.x=TRUE)

mat_long1 <- mat_long%>%group_by(Otu)%>%mutate(pr_ab=if_else(Counts>0,1,0))

mat_long1$taxon <- gsub("^g__","",mat_long1$Species)

mat_long2 <- mat_long1[mat_long1$Sample%in%meta_data$.sample,]

mat_wide <- reshape2::dcast(mat_long2,Sample~taxon,value.var = "pr_ab")


## Survival analysis

library(survival)
library(ggsurvfit)
library(lubridate)
library(ggsurvfit)
library(gtsummary)
library(tidycmprsk)
library(survminer)

## select the taxa columns

tax_li <- colnames(mat_wide)[-grep("Sample",colnames(mat_wide))]

## HR adjusting for age, stage, and read coumts

covariates <- sapply(tax_li,function(x) {x <- paste(x,"+","Age","+","Stage","+","Counts",sep="")  })

names(covariates) <- NULL

univ_formulas <- sapply(covariates,
                        function(x) as.formula(paste('Surv(OSmonth,vital_status)~', x)))


data_all <- merge(meta_data,mat_wide,by.x=".sample",by.y="Sample",all.x=TRUE)

univ_models <- lapply( univ_formulas, function(x){coxph(x, data = data_all)})


CoxphToDF <- function(y) {
  stopifnot(class(y) == "summary.coxph")
  
  y <- 
    cbind(y[["coefficients"]], 
          `lower .95` = y[["conf.int"]][, "lower .95"], 
          `upper .95` = y[["conf.int"]][, "upper .95"]
    )
  
  cbind(Variable = rownames(y), as.data.frame(y))  
}
# Extract data 
univ_results <- lapply(univ_models,
                       function(x){ 
                        x_sum <- summary(x)
                        res <- CoxphToDF(x_sum)
                        res$HR <- paste(round(res$`exp(coef)`,2),"(",round(res$`lower .95`,2),"-",round(res$`upper .95`,2),")",sep="")
                        res <- res[,grep("HR|^Pr",colnames(res))]
                        colnames(res)[grep("Pr",colnames(res))] <- "pvalue"
                         return(res)
                         #return(exp(cbind(coef(x),confint(x))))
                       })

univ_results1 <- do.call(rbind,univ_results)



## prepare data for forestplot

univ_results1$Head <- rownames(univ_results1)

univ_results11 <- univ_results1[-grep(".Counts.Age$|.Counts.Counts$|.Counts.Stage",univ_results1$Head),]

univ_results11$l_CI <- as.numeric(gsub(".*\\(|-.*$|\\(","",univ_results11$HR))

univ_results11$u_CI <- as.numeric(gsub(".*-|-|\\)","",univ_results11$HR))

univ_results11$HR <- as.numeric(gsub("\\(.*$|\\(","",univ_results11$HR ))

univ_results11$Taxon <- gsub( "\\+.*$" ,"",univ_results11$Head)

univ_results11$Taxon <- gsub( "_|__" ," ",univ_results11$Taxon)


## Forestplot


library(forestplot)

# Example data

# Create the forest plot
forestplot( univ_results11$Taxon,
            mean = univ_results11$HR,
            lower = univ_results11$l_CI,
            upper = univ_results11$u_CI,
            zero = 1, # Example: set zero line at 0.5
            xlab = "Hazard ratio- for taxa adjusted by Age and  stage and Counts/Reads",
            col = fpColors(box = "royalblue",
                           line = "darkblue"),
            txt_gp=fpTxtGp(label = gpar(fontfamily = "Arial",fontface="italic"),ticks = gpar(fontfamily = "", cex = 1),xlab = gpar(fontfamily="Calibri",cex=1.5)))




