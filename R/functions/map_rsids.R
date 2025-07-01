map_rsids <- function(config, gwas_info, zscore_matrices) {
  # Section 8: get rsIDs for final variant set

  print("Getting rsIDs for final snps and saving to results...")
  z_mat <- zscore_matrices$initial_zscore_matrices$z_mat
  N_mat <- zscore_matrices$initial_zscore_matrices$N_mat
  df_input_snps <- zscore_matrices$df_input_snps
  rsID_map_file <- gwas_info$rsID_map_file
  project_dir <- config$project_dir

  df_var_ids <- df_input_snps %>%
    separate(VAR_ID, into=c("Chr","Pos","Ref","Alt"),sep="_",remove = F) %>%
    mutate(ChrPos=paste(Chr,Pos,sep = ":")) %>%
    subset(ChrPos %in% rownames(z_mat))
  write(df_var_ids$VAR_ID, here('my_snps.tmp'))

  system(sprintf("grep -wFf my_snps.tmp %s > %s",
              rsID_map_file, here(project_dir, "rsID_map.txt")))

  df_rsIDs <- fread(cmd=sprintf("grep -wFf my_snps.tmp %s",rsID_map_file),
                  header = F,
                  col.names = c("VAR_ID","rsID"))
  print(sprintf("rsIDs found for %i of %i SNPs...", nrow(df_rsIDs), nrow(df_var_ids)))

  df_rsIDs_final <- df_rsIDs %>%
  filter(VAR_ID %in% df_var_ids$VAR_ID)
  write_delim(x=df_rsIDs_final,
            file = here(project_dir, "rsID_map.txt"),
            col_names = T)

result <- list(
  df_var_ids = df_var_ids, 
  df_rsIDs = df_rsIDs, 
  df_rsIDs_final = df_rsIDs_final
)
return(result)
}
