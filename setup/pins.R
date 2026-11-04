# One place for the versions the workshop depends on.
PIN_OCCJSDM <- "1b4a2cdfb1a25330e9b3da24aef2ebb210776352"
ZENODO_RECORD <- "17113196"
CRAN_PACKAGES <- c(
  "tidyverse", "vegan", "ecoCopula", "prioritizr", "highs", "rmarkdown",
  "testthat", "remotes", "jsonlite", "FastGP", "treemapify", "ggrepel", "kableExtra", "patchwork"
)

# Optional private library (set WORKSHOP_LIB), used to test without touching the default one.
use_workshop_lib <- function() {
  lib <- Sys.getenv("WORKSHOP_LIB", unset = "")
  if (nzchar(lib)) {
    dir.create(lib, showWarnings = FALSE, recursive = TRUE)
    .libPaths(c(normalizePath(lib), .libPaths()))
  }
  invisible(.libPaths())
}
