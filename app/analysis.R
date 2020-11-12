# ### analysis.R ###

library(trackViewer)
library(ggplot2)
library(vroom)

File_location <- "http://storage.googleapis.com/gbsc-gcp-lab-jgoronzy_group/Rohit"

# vstNormalizedCounts_t_cell_activation <- read.table(paste0(File_location,"/WebInputFiles/t_cell_activation/","vstNormalizedCounts_t_cell_activation_filt.txt"),header = T)
specification <- cols(
  SampleNames = col_character(),
  Diagnosis = col_character(),
  Batch = col_character(),
  Sample = col_character(),
  Lineage = col_character(),
  Peaks = col_character(),
  vstNormalizedCounts = col_double(),
  Group = col_character(),
  .delim = "\t"
)
vstNormalizedCounts_RA <- vroom(paste0(File_location,"/WebInputFiles/RA/","vstNormalizedCounts_RA_filt.txt"),
                                               col_types = specification)
UCSC.hg19.genes<- read.table(paste0(File_location,"/WebInputFiles/commonFiles/","Gene_Symbols.txt"),header = F)

`%notin%` <- Negate(`%in%`)