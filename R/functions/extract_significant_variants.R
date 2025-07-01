extract_significant_variants <- function(config, gwas_info) {
  gwas_ss_files <- gwas_info$gwas_ss_files
  gwas_meta <- gwas_info$gwas
  PVCUTOFF <- as.numeric(config$pval_cutoff)

  n_gwas <- length(gwas_ss_files)
  
  vars_sig = data.frame(VAR_ID = as.character(),
                        P_VALUE = as.numeric(),
                        Risk_Allele=as.character(),
                        GWAS=as.character())
  
  print(sprintf("Pulling significant SNPs w/ pval<%.1e from %i T2D GWAS...", PVCUTOFF, n_gwas))
  
  for(i in 1:n_gwas) {
    print(paste0("...Reading ", names(gwas_ss_files)[i], "..."))
  
    vars <- fread(here::here(gwas_ss_files[[i]]), data.table = FALSE)
  
    if (!"BETA" %in% colnames(vars)){
      print("Converting Odds Ratio to Log Odds Ratio...")
      vars <- vars %>%
        mutate(BETA = log(as.numeric(ODDS_RATIO)))
    }
    vars <- vars %>%
      filter(as.numeric(P_VALUE) <= PVCUTOFF) %>%
      subset(grepl("^[0-9]+_[0-9]+_[ACGT]+_[ACGT]", VAR_ID)) %>%
      separate(VAR_ID, into=c("CHR", "POS", "REF", "ALT"), sep="_", remove = F) %>%
      mutate(Risk_Allele = ifelse(BETA>=0, ALT, REF)) %>%
      mutate(GWAS = gwas_meta$study[i]) %>%
      dplyr::select(VAR_ID, P_VALUE, Risk_Allele, GWAS)
  
    print(nrow(vars))
    vars_sig = rbind(vars_sig, vars)
  }
  print(paste("No. total SNPs below pval cutoff:",nrow(vars_sig)))
  
  # remove duplicates
  vars_sig_uniq <- vars_sig %>%
    arrange(VAR_ID, P_VALUE) %>%
    filter(!duplicated(VAR_ID)) 
  print(paste("No. unique SNPs:",nrow(vars_sig_uniq)))
  
  # remove indels
  vars_sig_noIndels <- vars_sig_uniq %>%
    separate(VAR_ID, into=c("CHR","POS","REF","ALT"),sep="_",remove = F) %>%
    mutate(alleles = paste0(REF,ALT)) %>%
    subset(nchar(alleles)==2 | (nchar(alleles)<=4 & grepl(",",alleles))) %>%
    dplyr::select(VAR_ID, P_VALUE, Risk_Allele, GWAS)
  print(paste("No. SNPs excluding indels:",nrow(vars_sig_noIndels)))
  
  return(vars_sig_noIndels)
}

