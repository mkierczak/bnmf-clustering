generate_report <- function(config, k) {
  k <- NULL
  if (is.null(k)){
    html_filename <- "results_for_maxK.html"
  } else {
    html_filename <- sprintf("results_for_K_%i.html", k)
  }

  rmarkdown::render(
    './format_bNMF_results.Rmd',
    output_file = html_filename,
    params = list(main_dir = here(config$project_dir),
                k = k,
                loci_file="query",
                GTEx=F,
                my_traits=gwas_traits)
  )
}