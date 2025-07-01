library(targets)
library(tarchetypes)
library(here)

here::i_am("R/00_setup.R")

source(here("R","00_setup.R"))                         # loads libraries and config
source(here("R/functions_orig", "choose_variants.R"))  # ld_pruning, count_traits_per_variant, fina_variants_needing_proxies, & choose_potential_proxies
source(here("R/functions_orig","prep_bNMF.R"))         # fetch_summary_stats & prep_z_matrix
source(here("R/functions_orig","run_bNMF.R"))          # run_bNMF & summarize_bNMF

purrr::walk(list.files("R/functions", full.names = TRUE), source)

tar_option_set(
  packages = c("tidyverse", "data.table", "readxl", "yaml"),
  format = "rds"
)

list(
  tar_target(config, yaml::read_yaml('config.yml')),
  tar_target(secrets, yaml::read_yaml('secrets.yml')),
  tar_target(gwas_info, fetch_gwas_info(config)),
  tar_target(sig_variants, extract_significant_variants(config, gwas_info)),
  tar_target(pruned_variants, prune_variants_ld(config, secrets, sig_variants)),
  tar_target(non_missingness, calculate_missingness(config, gwas_info, pruned_variants)),
  tar_target(proxy_results, search_for_proxies(config, secrets, gwas_info, pruned_variants, non_missingness)),
  tar_target(zscore_matrices, prepare_z_matrices(config, gwas_info, pruned_variants, proxy_results)),
  tar_target(rsids, map_rsids(config, gwas_info, zscore_matrices)),
  tar_target(zscore_filled, fill_missing(config, gwas_info, zscore_matrices, rsids)),
  tar_target(nonneg_matrix, prepare_nonneg_matrix(config, zscore_filled)),
  tar_target(result, bNMF(config, nonneg_matrix))
)

### To test rule by rule comment out the list above and uncomment desired rules below ###
#config <- yaml::read_yaml('config.yml')
#secrets <- yaml::read_yaml('secrets.yml')
#gwas_info <- fetch_gwas_info(config)
#sig_variants <- extract_significant_variants(config, gwas_info)
#pruned_variants <- prune_variants_ld(config, secrets, sig_variants)
#non_missingness <- calculate_missingness(config, gwas_info, pruned_variants)
#proxy_results <- search_for_proxies(config, secrets, gwas_info, pruned_variants, non_missingness)
#zscore_matrices <- prepare_z_matrices(config, gwas_info, pruned_variants, proxy_results)
#rsids <- map_rsids(config, gwas_info, zscore_matrices)
#zscore_filled <- fill_missing(config, gwas_info, zscore_matrices, rsids)
#nonneg_matrix <- prepare_nonneg_matrix(config, zscore_filled)
#result <- bNMF(config, nonneg_matrix)
