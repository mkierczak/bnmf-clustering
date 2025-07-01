search_for_proxies <- function(config, secrets, gwas_info, pruned_variants, variant_nonmissingness) {
  
  print("Identifying variants needing proxies...")
  proxies_needed_df <- find_variants_needing_proxies(pruned_variants,
                                                  variant_nonmissingness,
                                                  gwas_info$rsID_map_file,
                                                  missing_cutoff = config$missing_cutoff)

  print("Searching for proxies with TopLD API...")
  proxy_search_results <- choose_proxies(need_proxies = proxies_needed_df,
                                    method = config$proxy_search_method,
                                    LDlink_token = secrets$user_token,
                                    topLD_path = api_path,
                                    rsID_map_file = gwas_info$rsID_map_file,
                                    trait_ss_files = gwas_info$trait_ss_files,
                                    pruned_variants = pruned_variants,
                                    population=config$ref_pop
)

  df_proxies <- proxy_search_results %>%
    dplyr::select(VAR_ID, proxy_VAR_ID) %>%
   dplyr::inner_join(pruned_variants[,c("VAR_ID","GWAS")], by="VAR_ID") %>%
   mutate(Risk_Allele=NA, PVALUE=NA)

  result <- list(
    proxies_needed = proxies_needed_df,
    proxy_search_results = proxy_search_results,
    proxies = df_proxies
  )
  return(result)
}