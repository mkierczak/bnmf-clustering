# 00_setup.R
if (!requireNamespace("pacman", quietly = TRUE))  {
  install.packages("pacman")
}
  pacman::p_load(tidyverse, data.table, readxl, magrittr, yaml, GenomicRanges, strex, DT, kableExtra)

if (!require("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

if (!require('GenomicRanges')) {
BiocManager::install("GenomicRanges")
}

if (!require(Homo.sapiens)) {
  BiocManager::install("Homo.sapiens")
}
