# Install everything the workshop needs. Safe to re-run.
source("setup/pins.R")
use_workshop_lib()
options(repos = c(CRAN = "https://cloud.r-project.org"))

missing <- setdiff(CRAN_PACKAGES, rownames(installed.packages()))
if (length(missing)) install.packages(missing)

installed_sha <- if (requireNamespace("occJSDM", quietly = TRUE)) {
  utils::packageDescription("occJSDM")$RemoteSha
} else {
  NA_character_
}
if (!identical(installed_sha, PIN_OCCJSDM)) {
  remotes::install_github(paste0("AlexDiana/occJSDM@", PIN_OCCJSDM), upgrade = "never")
}
source("setup/check-setup.R")
stopifnot(check_setup())
