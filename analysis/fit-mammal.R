# Fit the 108-mammal model that build-fit-summary.R reduces to data-derived/fit_summary.rds.
# The same call and seed as occJSDM_Ecoletts/R/fit_mammal.R (fit_Mammal_d4_fixed.rds), but at
# the workshop's pinned occJSDM, where b0_prior defaults to "community" for multi-species data,
# with the two chains on two cores, and with chains twice as long: 10,000 burn-in and 10,000
# iterations, keeping every second draw (niter = 5,000 kept draws per chain, nthin = 2), so the
# saved fit stays at 0.25 GB. Takes about 8 minutes on two cores.
# Set WORKSHOP_FIT to the output path (outside the repo). Run from the project root.
source("setup/pins.R")
use_workshop_lib()
suppressPackageStartupMessages(library(occJSDM))
out <- Sys.getenv("WORKSHOP_FIT", unset = "fits/fit_Mammal_d4_community_1b4a2cd_10k.rds")
stopifnot(!file.exists(out))   # never overwrite a fit

inp <- readRDS("data-derived/mammal_input.rds")
set.seed(20261018)
t0 <- Sys.time()
fit <- runOccJSDM(
  inp$data,
  listParams = list(n_factors = 4),
  threshold = 1,
  occCovariates = inp$occCovariates,
  collCovariates = inp$collCovariates,
  MCMCparams = list(nchain = 2, nburn = 10000, niter = 5000, nthin = 2, ncores = 2)
)
elapsed <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
saveRDS(fit, out)
cat("FIT DONE in", round(elapsed, 1), "minutes\n")
cat("occJSDM", utils::packageDescription("occJSDM")$RemoteSha, "\n")
str(fit$infos$intercept_prior)
