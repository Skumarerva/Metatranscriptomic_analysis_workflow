setwd('Y:/LC_shwetha/Analysis')

#Need to run kraken with confidence=0.2,0.3,0.4,0.5
#Made new folders
#kraken2_results\Site1_02
#kraken2_results\Site1_03
#kraken2_results\Site1_04
#kraken2_results\Site1_05
#kraken2_results\Site2_02
#kraken2_results\Site2_03
#kraken2_results\Site2_04
#kraken2_results\Site2_05
#Within each one of these folders, we put a 'fixed' subfolder with the filtered
#kraken2 files, updated kreport2 files, and final biom files



#Fastq non human reads in fastqNonHuman
#Run kraken2 just as in the protocol, output folders = 
#kraken2_Site1 and kraken2_Site2


#######################################
#Ready to run kraken2
d11 = dir(pattern='R1.fastq.gz',path='fastq_Site1/')
d12 = dir(pattern='R1.fastq.gz',path='fastq_Site2/')

confidence = c(0,0.2,0.5)
foldersuffix = c('00','02','05')

d1 = c(d11,d12)
d2 = gsub('R1.fastq.gz','R2.fastq.gz',d1)

samples = gsub('.R1.fastq.gz','',d1)
#table(file.exists(paste0('./fastqNonHuman/',d1)))
#table(file.exists(paste0('./fastqNonHuman/',d2)))

for (iii in 1:length(confidence)){
outputfolder = c(rep(paste0('kraken2_results/Site1_',foldersuffix[iii]),length(d11)),rep(paste0('kraken2_results/Site2_',foldersuffix[iii]),length(d12)))



command = './code/kraken2folder/kraken2 --db ../../Microbiome_231030/k2_standard_20210517  --confidence CCC --report-minimizer-data --minimum-hit-groups 3 --threads 2 --report ./output/MYSAMPLE.kreport2 --paired ./fastqNonHuman/MYSAMPLE_1 ./fastqNonHuman/MYSAMPLE_2 > ./output/MYSAMPLE.kraken2'
s = "#!/bin/bash"
for (i in 1:length(samples)){
  s1 = gsub('MYSAMPLE_1',d1[i],command)
  s1 = gsub('MYSAMPLE_2',d2[i],s1)
  s1 = gsub('MYSAMPLE',samples[i],s1)
  s1 = gsub('CCC',confidence[iii],s1)
  s1 = gsub('output',outputfolder[i],s1)
  s = c(s,s1)
}
writeLines(s,paste0('runKraken_conf_',iii,'.sh'))

} #For iii, difference confidence values

###################################################
#Need to fix kraken2 files and re-create the kreport2 files
for (iii in 1:length(confidence)){
  outputfolder = c(rep(paste0('kraken2_results/Site1_',foldersuffix[iii]),length(d11)),rep(paste0('kraken2_results/Site2_',foldersuffix[iii]),length(d12)))
  files = paste0(outputfolder,'/',samples,'.kraken2')
  outfiles = paste0(outputfolder,'/fixed/',samples,'.kraken2')
  
  for (i in 1:length(samples)){
    s = readLines(files[i])
    I = grep(s,pattern='\t9606\t')
    writeLines(s[-I],outfiles[i])
  }
  
}
  

#d = dir(pattern='kraken2',path='kraken2_Site1')
#counts = matrix(0,nrow=length(d),ncol=2)
#colnames(counts) = c('Human','NonHuman')
#for (i in 1:length(d)){
#  s = readLines(paste0('./kraken2_Site1/',d[i]))
#  I = grep(s,pattern='\t9606\t')
#  counts[i,1] = length(I)
#  counts[i,2] = length(s)-length(I)
#  s = s[-I]
#  writeLines(s,paste0('./kraken2_Site1/fixed/',d[i]))
#  print(i)
#}
#countsBCM = cbind(counts,d)


#d = dir(pattern='kraken2',path='kraken2_Site2')
#counts = matrix(0,nrow=length(d),ncol=2)
#colnames(counts) = c('Human','NonHuman')
#for (i in 1:length(d)){
#  s = readLines(paste0('./kraken2_Site2/',d[i]))
#  I = grep(s,pattern='\t9606\t')
#  counts[i,1] = length(I)
#  counts[i,2] = length(s)-length(I)
#  s = s[-I]
#  writeLines(s,paste0('./kraken2_Site2/fixed/',d[i]))
#  print(i)
#}
#countsHarvard = cbind(counts,d)

#save.image('counts_BCM_Harvard.RData')
############################################
#create files kreport2 files

command = '../../Microbiome_231030/kraken2-report ../../Microbiome_231030/k2_standard_20210517/taxo.k2d ./FOLDER/fixed/sample.kraken2 ./FOLDER/fixed/sample.kreport2'

s = '#!/bin/bash'


for (iii in 1:length(confidence)){
  outputfolder = c(rep(paste0('kraken2_results/Site1_',foldersuffix[iii]),length(d11)),rep(paste0('kraken2_results/Site2_',foldersuffix[iii]),length(d12)))
  for (k in 1:length(samples)){
  stmp = gsub('FOLDER',outputfolder[k],command)
  stmp = gsub('sample',samples[k],stmp)
  s = c(s,stmp)
  
  }
}

writeLines(s,'createFixedReports_conf.sh')

#within fixed
#conda activate py38
#kraken-biom *.kreport2 --fmt json -o Site1_00_fixed.biom
#kraken-biom *.kreport2 --fmt json -o Site1_02_fixed.biom
#kraken-biom *.kreport2 --fmt json -o Site1_05_fixed.biom
#within Site1_00, etc, not fixed. This does not work!
#kraken-biom *.kreport2 --fmt json -o Site1_00_notfixed.biom
#kraken-biom *.kreport2 --fmt json -o Site1_02_notfixed.biom
#kraken-biom *.kreport2 --fmt json -o Site1_05_notfixed.biom

############################################
#Create biom files for Site2 and Site1
#Run these command within kraken2_Site1/fixed and kraken2_Site2/fixed
#kraken-biom *.kreport2 --fmt json -o Site1_RNAseq_Nov24.biom
#kraken-biom *.kreport2 --fmt json -o Site2_RNAseq_Nov24.biom



