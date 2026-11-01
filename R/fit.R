# Cached mammal fit, reduced to the summaries the sessions use.
# The full fit is 236 MB on disk (about 0.4 GB in memory), so students read this instead.
read_fit_summary <- function() {
  readRDS(derived_path("fit_summary.rds"))
}

# Occupancy for every site and species with the species' taxonomy and status attached.
# cond_mean is the probability of presence given the detections; psi_mean is the probability
# from the covariates plus the hidden site effects (estimated from the survey, so not a
# covariate-only prediction). Both are posterior means (the package returns no intervals).
occupancy_long <- function() {
  f <- read_fit_summary()
  status <- species_status()
  dplyr::left_join(f$occ[, c("Site", "otu_id", "cond_mean", "psi_mean")],
                   status[, c("otu_id", "species", "order", "family", "iucn", "china_red_list", "local_status")],
                   by = "otu_id")
}
