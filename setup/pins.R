# One place for the versions the workshop depends on.
PIN_OCCJSDM <- "5cba0db2d78d23f2f7985fcf12d61cd6121ff05e"   # v0.3.0-beta; the fits were made at 1b4a2cd
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
