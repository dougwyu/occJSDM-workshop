# Install everything the workshop needs. Safe to re-run.
source("setup/pins.R")
use_workshop_lib()
# Keep a repository that is already set: Posit Cloud points at Posit Package Manager, which
# serves Linux binaries. Overriding it with CRAN would compile every package from source.
cran <- getOption("repos")["CRAN"]
if (is.na(cran) || !nzchar(cran) || cran == "@CRAN@") options(repos = c(CRAN = "https://cloud.r-project.org"))

missing <- setdiff(CRAN_PACKAGES, rownames(installed.packages()))
if (length(missing)) install.packages(missing)

source("setup/check-setup.R")
installed <- installed_sha()
if (!identical(installed, PIN_OCCJSDM)) {
  remotes::install_github(paste0("AlexDiana/occJSDM@", PIN_OCCJSDM), upgrade = "never")
}
stopifnot(check_setup())
