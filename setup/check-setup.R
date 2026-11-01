# check_setup() prints each requirement and returns TRUE only if all pass.
check_setup <- function(quiet = FALSE) {
  pins <- file.path(dirname(sys.frame(1)$ofile %||% "setup/check-setup.R"), "pins.R")
  if (!exists("PIN_OCCJSDM")) source(if (file.exists(pins)) pins else "setup/pins.R")
  say <- function(ok, what) {
    if (!quiet) cat(if (ok) "[ok]   " else "[FAIL] ", what, "\n", sep = "")
    ok
  }
  have <- function(p) requireNamespace(p, quietly = TRUE)
  pkgs <- setdiff(CRAN_PACKAGES, "tidyverse")
  results <- vapply(c(pkgs, "tidyverse", "occJSDM"), function(p) say(have(p), paste("package", p)), logical(1))
  sha <- installed_sha()
  pinned <- say(identical(sha, PIN_OCCJSDM), "occJSDM is at the pinned commit")
  solver <- say(have("highs") && have("prioritizr"), "an SCP solver is available")
  all(results, pinned, solver)
}
`%||%` <- function(a, b) if (is.null(a)) b else a

# Read the commit from the library path, not from a namespace that may already be loaded.
installed_sha <- function() {
  d <- suppressWarnings(utils::packageDescription("occJSDM", lib.loc = .libPaths()))
  if (is.list(d) && !is.null(d$RemoteSha)) d$RemoteSha else NA_character_
}
