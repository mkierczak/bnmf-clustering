bNMF <- function(config, nonneg_matrix) {
  bnmf_reps <- run_bNMF(nonneg_matrix$final_zscore_matrix,
    n_reps = config$n_bnmf_reps,
    tolerance = as.numeric(config$bnmf_tolerance))

  summary <- summarize_bNMF(bnmf_reps, dir_save=here(config$project_dir))

return(list(bnmf_reps=bnmf_reps, summary=summary))
}
