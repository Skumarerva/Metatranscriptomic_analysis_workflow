rm(list = ls())

##  Final Version 
## not rarefied

suppressMessages(library(dplyr))
suppressMessages(library(tidyr))
suppressMessages(library(ggplot2))
suppressMessages(library(rbiom))
suppressMessages(library(reshape2))
suppressMessages(library(stringr))
suppressMessages(library(RColorBrewer))
suppressMessages(library(readxl))
suppressMessages(library(ape))


## Import metadata file -same code applies to both sites

file = "./00_raw_data/Site1_Metadata.csv"

metadata <- read.csv(file, header = T)

metadata$.sample <- metadata$Sample

## Import biom files -same code applies to both sites

path_biom <-
  "/03_tidy_data/kraken2_results/Site1_02_filtered_version2/"

s_biom <-
  rbiom::read_biom(paste(path_biom, "/Site1_02_filtered_version2.biom", sep = ""))

tax_file = s_biom$taxonomy %>% as.data.frame()



## Function to convert simple triplet matrix to dense matrix

set.seed(123)
stm2dns <- function(x, memory = NULL) {
  if (!is.null(memory)) {
    if (utils::memory.limit() < memory) {
      message('You are going to increase the maximum amount of RAM that R can use.')
    }
    utils::memory.limit(memory) #200000
  }
  
  y <- matrix(as.integer(0), x[['nrow']], x[['ncol']])
  
  n <- list(1L)
  while (n[[1L]] <= length(x[['v']])) {
    y[[x[['i']][[n[[1L]]]], x[['j']][[n[[1L]]]]]] <- x[['v']][[n[[1L]]]]
    n[[1L]] <- n[[1L]] + 1L
  }
  
  rownames(y) <- x[['dimnames']][['Docs']]
  colnames(y) <- x[['dimnames']][['Terms']]
  
  if (!is.null(attr(x, 'weighting'))) {
    attr(y, 'weighting') <- attr(x, 'weighting')
    class(y) <- c(class(y), 'weighted')
  }
  y
}


#' @rdname stm2dns
#'
#' @param ... further arguments passed to the function
#'
#' @return \code{\link{as.data.frame.simple_triplet_matrix}}
#'          returns a \code{data.frame}
#' @export
as.data.frame.simple_triplet_matrix <-
  function(x, ...,  memory = NULL) {
    y <- as.data.frame.matrix(stm2dns(x = x, memory = memory))
    if (!is.null(attr(x, 'weighting'))) {
      attr(y, 'weighting') <- attr(x, 'weighting')
      class(y) <- c(class(y), 'weighted')
    }
    y
  }




## Check read depths with different adiversity measures
rare_corrplot(s_biombiom,
              adiv = "OTUs",
              layers = "tc",
              rline = TRUE)

rare_multiplot(s_biombiom,
               adiv = "Chao1",
               layers = "tc",
               rline = TRUE)
rare_multiplot(s_biom,
               adiv = "OTUs",
               layers = "tc",
               rline = TRUE)

## Convert simple triplet matrix to dense matrix


dtshow <- stm2dns(s_biom$counts) %>% as.matrix()

rownames(dtshow) <- s_biom$counts$dimnames[[1]]
colnames(dtshow) <- s_biom$counts$dimnames[[2]]

matrix_file <- as.matrix(dtshow)

meta <- s_biom$metadata %>% as.data.frame()

metadata$.sample <- metadata$Sample

## remove sample 138T as it is an outlier in alpha  diversity

matrix_file <- matrix_file[,-grep("138T",colnames(matrix_file))]

## Create a  new biom file after removing 138 T sample

biom <-
  as_rbiom(list(
    counts = matrix_file,
    metadata = metadata,
    taxonomy = tax_file
  ))





