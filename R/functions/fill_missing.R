fill_missing <- function(config, gwas_info, zscore_matrices, rsids) {
# Section 9: Fill missing data in z-score and N matrices
  df_input_snps <- zscore_matrices$df_input_snps
  df_rsIDs_final <- rsids$df_rsIDs_final
  df_snps <- df_input_snps %>%
  inner_join(df_rsIDs_final, by="VAR_ID") %>%
  data.frame()

print("Searching for cover proxies for missing z-scores...")
initial_zscore_matrices_final <- fill_missing_zscores(zscore_matrices$initial_zscore_matrices,
                                                      df_snps,
                                                      gwas_info$trait_ss_files,
                                                      gwas_info$trait_ss_size,
                                                      gwas_info$main_ss_filepath,
                                                      gwas_info$rsID_map_file,
                                                      method_fill = config$fill_missing_method,
                                                      population = config$ref_pop)
  return(initial_zscore_matrices_final)
}
