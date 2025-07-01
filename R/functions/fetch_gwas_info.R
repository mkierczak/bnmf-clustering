# R/functions/fetch_gwas_info.R

fetch_gwas_info <- function(config) {
  data_dir <- here::here(config$data_dir)

  # File paths
  rsID_map_file <- here::here(config$rsID_map_file)
  gwas_file <- here::here(config$main_gwas_file)

  # Read main GWAS metadata
  gwas <- readxl::read_excel(gwas_file, sheet = "main_gwas") %>%
    as.data.frame()

  # Read clustering trait metadata
  gwas_traits <- readxl::read_excel(gwas_file, sheet = "trait_gwas")

  # Determine alignment file
  main_ss_filepath <- gwas %>%
    dplyr::filter(largest == "Yes") %>%
    dplyr::pull(full_path)

  # Create named lists
  gwas_ss_files <- setNames(gwas$full_path, gwas$study)
  trait_ss_files <- setNames(gwas_traits$full_path, gwas_traits$trait)
  trait_ss_size  <- setNames(gwas_traits$sample_size, gwas_traits$trait)

  # Return all values as a list
  result <- list(
    gwas = gwas,
    traits = gwas_traits,
    rsID_map_file = rsID_map_file,
    main_ss_filepath = main_ss_filepath,
    gwas_ss_files = gwas_ss_files,
    trait_ss_files = trait_ss_files,
    trait_ss_size = trait_ss_size
  )
  return(result)
}
