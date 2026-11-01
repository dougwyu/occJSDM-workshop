# Install everything the workshop needs. Safe to re-run.
source("setup/pins.R")
use_workshop_lib()
options(repos = c(CRAN = "https://cloud.r-project.org"))

missing <- setdiff(CRAN_PACKAGES, rownames(installed.packages()))
if (length(missing)) install.packages(missing)

source("setup/check-setup.R")
installed <- installed_sha()
if (!identical(installed, PIN_OCCJSDM)) {
  remotes::install_github(paste0("AlexDiana/occJSDM@", PIN_OCCJSDM), upgrade = "never")
}
stopifnot(check_setup())
