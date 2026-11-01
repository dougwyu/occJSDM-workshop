# Reduce fit_Mammal_d4_fixed.rds (occJSDM 6256791, b0_prior = "fixed") to data-derived/fit_summary.rds.
# Set WORKSHOP_FIT to the fit. Run from the project root after build-derived.R.
source("R/data.R")
suppressPackageStartupMessages(library(occJSDM))
fit_path <- Sys.getenv("WORKSHOP_FIT", unset = "fits/fit_Mammal_d4_fixed.rds")
f <- readRDS(fit_path)
ro <- f$results_output
status <- species_status()
nm <- f$infos$speciesNames

occ <- expand.grid(Site = f$infos$siteNames, otu_id = nm, stringsAsFactors = FALSE)
occ$cond_mean <- as.vector(ro$z_output)
occ$psi_mean <- as.vector(ro$psi_output)
occ$species <- status$species[match(occ$otu_id, status$otu_id)]
occ <- occ[, c("Site", "otu_id", "species", "cond_mean", "psi_mean")]

draws <- function(a, s) as.vector(a[1, s, , ])
q <- function(x) stats::quantile(x, c(0.025, 0.975), names = FALSE)
params <- do.call(rbind, lapply(seq_along(nm), function(s) {
  p <- draws(ro$p_output, s); fp <- draws(ro$q_output, s); th <- as.vector(ro$theta0_output[s, , ])
  data.frame(
    otu_id = nm[s],
    p_mean = mean(p), p_lo = q(p)[1], p_hi = q(p)[2],
    q_mean = mean(fp), q_lo = q(fp)[1], q_hi = q(fp)[2],
    theta0_mean = mean(th), theta0_lo = q(th)[1], theta0_hi = q(th)[2]
  )
}))
params$species <- status$species[match(params$otu_id, status$otu_id)]

# Convergence per species: the largest R-hat in each of two groups, from occJSDM's own
# returnConvergenceDiagnostics() (coda's Gelman-Rubin), the function Session 2 uses.
#   rhat_detection: true- and false-positive rates, theta0 and the collection-covariate effects.
#   rhat_effects:   the occupancy intercept and covariate effects.
# An earlier summary judged convergence on detection alone, which hid the unsettled effects.
invisible(capture.output(dg <- returnConvergenceDiagnostics(f)))
dg$otu_id <- ifelse(dg$label2 %in% nm, dg$label2, dg$label1)   # the species label sits in either column
stopifnot(all(dg$otu_id %in% nm))
dg$group <- ifelse(dg$param %in% c("beta0_psi", "beta_psi"), "rhat_effects", "rhat_detection")
by_group <- tapply(dg$rhat, list(dg$otu_id, dg$group), max, na.rm = TRUE)
diagnostics <- data.frame(otu_id = nm, species = status$species[match(nm, status$otu_id)],
                          rhat_detection = by_group[nm, "rhat_detection"],
                          rhat_effects = by_group[nm, "rhat_effects"],
                          row.names = NULL, stringsAsFactors = FALSE)

# Residual species associations: quantiles of the correlation left after the covariates.
sig <- returnResidualCorrelationMatrix(f)               # 3 x species x species: lower, median, upper
up <- which(upper.tri(matrix(0, length(nm), length(nm))), arr.ind = TRUE)
assoc <- data.frame(otu_a = nm[up[, 1]], otu_b = nm[up[, 2]],
                    lo = sig[cbind(1, up[, 1], up[, 2])], median = sig[cbind(2, up[, 1], up[, 2])],
                    hi = sig[cbind(3, up[, 1], up[, 2])], stringsAsFactors = FALSE)

stopifnot(nrow(occ) == 101 * 108, nrow(params) == 108, nrow(diagnostics) == 108, !anyNA(diagnostics))
saveRDS(list(occ = tibble::as_tibble(occ), params = tibble::as_tibble(params),
             diagnostics = tibble::as_tibble(diagnostics), assoc = tibble::as_tibble(assoc),
             source = list(fit = basename(fit_path), occjsdm = "6256791", b0_prior = "fixed")),
        "data-derived/fit_summary.rds")
