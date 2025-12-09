rm(list=ls())

## retain species level only

## retain Coverage >10

## cut off for distinct minimzer=10

## Create bash scripts to generate kraken2 reports (filtered)

## K reports

files_list <- list.files(path = "/mount/ictr1/Users/tsavachi/dataForShwetha/athrift/BCM/version2/BCM_02/fixed/filtered/",pattern = ".tsv")

# Complete file paths

files_list0 <- paste( "/mount/ictr1/Users/tsavachi/dataForShwetha/athrift/BCM/version2/BCM_02/fixed/filtered/",files_list,sep="")


## File names only

filter_1 <- gsub("^.*/$|.tsvfiltered.*$","",files_list)



## Import kraken2


files_list1 = list.files(path='/mount/ictr1/Users/tsavachi/dataForShwetha/Analysis/kraken2_results/BCM_02/fixed',pattern = ".kraken2")


#Complete file paths

files_list10 = paste('/mount/ictr1/Users/tsavachi/dataForShwetha/Analysis/kraken2_results/BCM_02/fixed/',files_list1,sep="")

## File names only

filter_2 <- gsub("^.*/$|.kraken2*$","",files_list1)

## Files are in the same order

all.equal(filter_1,filter_2)

## read data
list_Data <- lapply(files_list0[1:length(files_list0)],
                    function(x){df=read.table(x,quote="\"",header=TRUE)
                    return(df)})

names(list_Data) <- gsub(".tsvfiltered.tsv","",files_list[1:length(files_list)])

list_Data2 <- lapply(files_list10[1:length(files_list10)],
                     function(x){df=read.table(x,sep="\t",header=FALSE)
                     return(df)})

names(list_Data2) <- gsub(".kraken2","",files_list1[1:length(files_list1)])

list_Data2 <- list_Data2[order(match(names(list_Data2),names(list_Data)))]

all.equal(names(list_Data2),names(list_Data))

for (i in 1:length(list_Data)){
  
  df <- list_Data[[i]]
  
  df_r <- list_Data2[[i]]
  
  df <- df[df$R%in%"S",]
  
  df <- df[df$Number_fragments_covered>10,]
  
  df <- df[df$Estimate_minimizer>10,]
  
  I = match(df_r[,3],df[,7])
  
  I = which(!is.na(I))
  
  df_r = df_r[I,]
  
  out_path=paste("./02_tidy_data/Minimizer_filtered/",names(list_Data)[i],".kraken2",sep="")
  
  write.table(df_r, out_path,sep="\t",row.names=FALSE,quote=FALSE,col.names = FALSE)
}


## Create new report files

command = '/../../../../d../kraken2-report /../../../t../Microbiome_231030/k2_standard_20210517/taxo.k2d  IN/sample.kraken2 OUT/sample.kreport2'

s = '#!/bin/bash'


samples <- gsub(".tsvfiltered.tsv","",files_list[1:length(files_list)])

outputfolder = "./02_tidy_data/Minimizer_filtered"

outputfolder1 = "./02_tidy_data/Minimizer2"

for (k in 1:length(samples)){
  
  stmp = gsub('IN',outputfolder,command)
  stmp = gsub('OUT',outputfolder1,stmp)
  
  stmp = gsub('sample',samples[k],stmp)
  
  s = c(s,stmp)
}

writeLines(s,'./01_scripts/createFixedReports.sh')
