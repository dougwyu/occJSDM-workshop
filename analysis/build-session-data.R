# Rebuild the smaller files the sessions read: data-derived/dhole_input.rds,
# occupancy_long.csv and dhole_fit.rds. Run from the project root after build-fit-summary.R.
source("setup/pins.R")
use_workshop_lib()
source("R/data.R")
source("R/fit.R")
suppressPackageStartupMessages(library(occJSDM))

# The one-species file Session 2 gives to the MCP's validate_data and fit_model.
d <- dhole_input()
saveRDS(d, "data-derived/dhole_input.rds")

# One row per site and species, for Session 4.
utils::write.csv(occupancy_long(), "data-derived/occupancy_long.csv", row.names = FALSE)

# Session 2's cached fit: the same call, settings and seed as its live fit.
set.seed(2026)
fit <- runOccJSDM(
  data = d,
  listParams = list(n_factors = 0),
  threshold = 1,
  occCovariates = c("annual_precipitation", "mean_temperature", "Human_modification_1km",
                    "Percent_of_forest_cover_1km", "Patch_density_1km", "Edge_density_1km",
                    "streamOrigin", "Regional_Division"),
  collCovariates = c("Filter_vol", "PrevDayRain"),
  spatCovariates = character(),
  MCMCparams = list(nchain = 2, nburn = 5000, niter = 5000, nthin = 1),
  summarisedLatentPresences = TRUE
)
saveRDS(fit, "data-derived/dhole_fit.rds")
