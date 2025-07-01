calculate_missingness <- function(config, gwas_info, pruned_variants) {
  print("Searching for variants in trait GWAS...")
  gwas_variants <- pruned_variants$VAR_ID
  trait_ss_files <- gwas_info$trait_ss_files
  df_Ns <- count_traits_per_variant(gwas_variants,
                                    trait_ss_files)
  
  # fix column names
  df_Ns_rev <- df_Ns %>%
    column_to_rownames("VAR_ID") %>%
    set_colnames(names(trait_ss_files))
  
  print("Calculating variant missingess in traits...")
  variant_counts_df <- data.frame(VAR_ID=rownames(df_Ns_rev),
                                  frac=rowSums(!is.na(df_Ns_rev[,names(trait_ss_files)]))/length(trait_ss_files))
  var_nonmissingness <- ifelse(
    gwas_variants %in% variant_counts_df$VAR_ID,
    # if in counts data frame, take the non-missing fraction:
    variant_counts_df$frac[match(gwas_variants, variant_counts_df$VAR_ID)],
    # else not in data frame, so non-missing fraction is 0:
    0
  )
  var_nonmissingness <- setNames(var_nonmissingness, gwas_variants)  
  return(var_nonmissingness)
}
