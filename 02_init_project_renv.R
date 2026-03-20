project_dir <- getwd()

options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  download.file.method = "libcurl",
  Ncpus = max(1L, parallel::detectCores(logical = TRUE) - 1L)
)

cat("==== INFO PROGETTO ====\n")
cat("Project dir:", project_dir, "\n")
cat("R version:", R.version.string, "\n\n")

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

# Inizializza renv con supporto Bioconductor.
# TRUE = release Bioconductor raccomandata per questa versione di R.
if (!file.exists(file.path(project_dir, "renv.lock"))) {
  renv::init(bioconductor = TRUE, bare = TRUE)
} else {
  renv::activate(project = project_dir)
}

# Congela esplicitamente la release Bioconductor del progetto
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  renv::install("BiocManager")
}
bioc_ver <- as.character(BiocManager::version())
renv::settings$bioconductor.version(bioc_ver)

cat("Bioconductor version fissata a:", bioc_ver, "\n\n")

cran_pkgs <- c(
  "stringr",
  "pheatmap",
  "ggplot2",
  "RColorBrewer",
  "enrichR",
  "ggrepel",
  "Seurat",
  "UpSetR"
)

bioc_pkgs <- c(
  "DESeq2",
  "biomaRt",
  "limma",
  "EnhancedVolcano",
  "edgeR"
)

github_pkgs <- c(
  "chris-mcginnis-ucsf/DoubletFinder"
)

cat("==== INSTALL CRAN ====\n")
renv::install(cran_pkgs)

cat("==== INSTALL BIOCONDUCTOR ====\n")
renv::install(paste0("bioc::", bioc_pkgs))

cat("==== INSTALL GITHUB ====\n")
renv::install(github_pkgs)

cat("==== TEST CARICAMENTO ====\n")
test_pkgs <- c(
  "tools",
  cran_pkgs,
  bioc_pkgs,
  "DoubletFinder"
)

failed <- character()

for (pkg in test_pkgs) {
  cat(sprintf("Test load: %s ... ", pkg))
  ok <- suppressPackageStartupMessages(
    require(pkg, character.only = TRUE, quietly = TRUE)
  )
  if (isTRUE(ok)) {
    cat("OK\n")
  } else {
    cat("FAIL\n")
    failed <- c(failed, pkg)
  }
}

cat("\n==== SNAPSHOT LOCKFILE ====\n")
renv::snapshot(prompt = FALSE)

cat("\n==== VERSIONI INSTALLATE ====\n")
for (pkg in test_pkgs) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("%-18s %s\n", pkg, as.character(packageVersion(pkg))))
  }
}

if (length(failed)) {
  cat("\nPACCHETTI NON CARICATI CORRETTAMENTE:\n")
  print(failed)
  quit(status = 1)
} else {
  cat("\nAMBIENTE renv CREATO E LOCKFILE SALVATO CORRETTAMENTE.\n")
}
