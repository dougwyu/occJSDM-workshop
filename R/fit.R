# The mammal fit, reduced to the tables Session 3 builds live from the full fit
# (fits/fit_Mammal_d4_community_1b4a2cd_10k.rds, 235 MB, not in git; the session's
# fit-tables chunk peaks near 3.2 GB). The tests and occupancy_long() read this copy,
# so they do not need the full fit.
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
