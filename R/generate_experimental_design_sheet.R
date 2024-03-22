library(yaml)
library(here)
library(stringr)
library(dplyr)

config <- yaml.load_file(here("config/Mmul10_QC_config.yml"))
data_dir <- config$alignmentDir
files <- dir(data_dir, recursive = FALSE,
               include.dirs = TRUE, pattern = 'p[0-9]+.*')
samples <- str_extract(files, 's[0-9]+')
individual <- str_extract(files, 'Z[0-9]+')
individual[individual=='Z15229'] <- 'Z15228'
date <- str_extract(files, '[0-9]{2}-[0-9]{2}-[0-9]{2}')
tissue <- ifelse(grepl('Rectal-Biopsy', files, fixed=TRUE), 'rectal-biopsy', 'PBMC')



exp_des <- data.frame(FileID = files, SampleID = samples, Individual=individual, Tissue=tissue, Date=date)

exp_des <- exp_des %>%
  group_by(Individual, Tissue) %>%
  arrange(Date) %>%
  mutate(Timepoint = row_number()) %>%
  ungroup() %>% 
  arrange(SampleID)

write.table(exp_des, file = here('config/exp_design.txt'),
            sep = '\t', quote = FALSE,
            col.names = TRUE, row.names = FALSE)
