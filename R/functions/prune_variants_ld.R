prune_variants_ld <- function(config, secrets, sig_variants) {
  print(paste0("LD-pruning using ", config$ref_pop," panel in LDlinkR::SNPclip..."))
  ld_prune(df_snps = sig_variants,
                      pop = config$ref_pop,
                      output_dir = config$project_dir,
                      r2 = config$r2,
                      maf = config$maf,
                      my_token = secrets$user_token,
                      chr = as.numeric(str_split(config$chromosomes, ',')[[1]])
  )
  
  # combine LD-pruning results
  print("Combining SNP.clip results...")
  ld_files <- list.files(path = config$project_dir,
    pattern = "^snpClip_results",
    full.names = T)
  
  df_clipped_res = data.frame("RS_Number"=as.character(),
    "Position"=as.character(),
    "Alleles"= as.character(),
    "Details"=as.character())
  
  rename_cols_clipped <- c(RS_Number="RS Number", Position_grch37="Position")
  
  for (ld_file in ld_files){
    df <- fread(here(ld_file), stringsAsFactors = F, data.table = F) %>%
      dplyr::rename(any_of(rename_cols_clipped))
    df_clipped_res <- rbind(df_clipped_res, df)
  }
  
  df_clipped_kept <- df_clipped_res %>%
      filter(Details=="Variant kept.")
  
  pruned_vars <- sig_variants %>%
      separate(VAR_ID, into=c("CHR","POS","REF","ALT"), sep = "_",remove = F) %>%
      mutate(ChrPos = paste0("chr", CHR, ":", POS)) %>%
      filter(ChrPos %in% df_clipped_kept$Position)
  print(sprintf("T2D SNPs pruned from %i to %i...", nrow(sig_variants), nrow(pruned_vars)))  
  return(pruned_vars)
}
