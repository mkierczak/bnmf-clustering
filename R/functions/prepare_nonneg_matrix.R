prepare_nonneg_matrix <- function(config, zscore_filled) {
  # Generate non-negative z-score matrix
  initial_zscore_matrices_final <- zscore_filled
  prep_z_output <- prep_z_matrix(z_mat = initial_zscore_matrices_final$z_mat,
    N_mat = initial_zscore_matrices_final$N_mat,
    corr_cutoff = config$cor_cutoff)

  # prep_z_output has two outputs:

  #   1.) The scaled, non-negative z-score matrix
  final_zscore_matrix <- prep_z_output$final_z_mat

  #   2.) Results from the trait filtering
  df_traits_filtered <- prep_z_output$df_traits
    write_csv(x = df_traits_filtered,
    file = here(config$project_dir, "df_traits.csv"))

  # prep_z_matrix also save trait correlation matrix to working dir, so move to project dir
  system(sprintf("mv trait_cor_mat.txt %s", here(config$project_dir)))

  print(sprintf("Final matrix: %i SNPs x %i traits",
  nrow(final_zscore_matrix),
  ncol(final_zscore_matrix)/2))

  result <- list(
    final_zscore_matrix = final_zscore_matrix,
    df_traits_filtered = df_traits_filtered
  )
  return(result)
}