prepare_z_matrices <- function(config, gwas_info, pruned_variants, proxy_results) {
  pruned_vars <- pruned_variants
  proxies_needed_df <- proxy_results$proxies_needed
  proxy_search_results <- proxy_results$proxy_search_results
  print("Prepping input for fetch_summary_stats...")

  # Remove SNPs from pruned_vars that needed proxies
  df_orig_snps <- pruned_vars %>%
    filter(!VAR_ID %in% proxies_needed_df$VAR_ID)

  # Join with pruned vars so we can get the original GWAS where the proxy came from 
  # and add the necessary columns (if you don't care about the original GWAS, can
  # ski the inner_join step and just set GWAS=NA)
  df_proxies <- proxy_search_results %>%
    dplyr::select(VAR_ID, proxy_VAR_ID) %>%
    dplyr::inner_join(pruned_vars[,c("VAR_ID","GWAS")], by="VAR_ID") %>%
    mutate(Risk_Allele=NA, PVALUE=NA) %>% dplyr::rename(P_VALUE = PVALUE)

  # combine original SNPs with proxy SNP
  # MAKE SURE assign proxy_VAR_ID to VAR_ID in df_proxies!!!
  df_input_snps <- rbind(df_orig_snps %>% dplyr::select(VAR_ID, P_VALUE, Risk_Allele,GWAS),
                        df_proxies %>% dplyr::select(VAR_ID=proxy_VAR_ID, P_VALUE, Risk_Allele,GWAS)) %>%
    arrange(P_VALUE) %>% 
    filter(!duplicated(VAR_ID))

  cat(sprintf("\n%i original SNPs...\n", nrow(df_orig_snps)))
  cat(sprintf("\n%i proxy SNPs...\n", nrow(df_proxies)))
  cat(sprintf("\n%i total unique SNPs!\n", nrow(df_input_snps)))

  initial_zscore_matrices <- fetch_summary_stats(
    df_input_snps,
    gwas_info$main_ss_filepath,
    gwas_info$trait_ss_files,
    gwas_info$trait_ss_size,
    pval_cutoff = config$pval_cutoff2
  )
  system(sprintf("mv alignment_GWAS_summStats.csv %s", config$project_dir))
  result <- list(
    initial_zscore_matrices = initial_zscore_matrices,
    df_input_snps = df_input_snps
  )
  return(result)
}
