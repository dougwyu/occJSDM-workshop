# Reduce the full mammal fit to data-derived/fit_summary.rds. The fit is made by fit-mammal.R:
# occJSDM 1b4a2cd, b0_prior left at its default, "community" (fit_Mammal_d4_community_1b4a2cd_10k.rds).
# Set WORKSHOP_FIT to the fit. Run from the project root after build-derived.R.
source("R/data.R")
suppressPackageStartupMessages(library(occJSDM))
fit_path <- Sys.getenv("WORKSHOP_FIT", unset = "fits/fit_Mammal_d4_community_1b4a2cd_10k.rds")
f <- readRDS(fit_path)
stopifnot(!is.null(f$results_output$jsdm_output$mu_b0_output))   # a community-prior fit
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
# The community mean of the occupancy intercepts is one parameter for all species: keep it apart.
mu_b0 <- dg[dg$param == "mu_b0", c("mean", "sd", "q2.5", "q97.5", "rhat", "ess")]
stopifnot(nrow(mu_b0) == 1)
dg <- dg[dg$param != "mu_b0", ]
dg$otu_id <- ifelse(dg$label2 %in% nm, dg$label2, dg$label1)   # the species label sits in either column
stopifnot(all(dg$otu_id %in% nm))
dg$group <- ifelse(dg$param %in% c("beta0_psi", "beta_psi"), "rhat_effects", "rhat_detection")
by_group <- tapply(dg$rhat, list(dg$otu_id, dg$group), max, na.rm = TRUE)
diagnostics <- data.frame(otu_id = nm, species = status$species[match(nm, status$otu_id)],
                          rhat_detection = by_group[nm, "rhat_detection"],
                          rhat_effects = by_group[nm, "rhat_effects"],
                          row.names = NULL, stringsAsFactors = FALSE)

# Occupancy covariate effects per species: posterior mean, 95% interval and R-hat, from the
# same diagnostics table. Factor levels carry the level in the name, e.g. streamOriginoutsideGLGS.
eff <- dg[dg$param == "beta_psi", ]
effects <- data.frame(otu_id = eff$otu_id, species = status$species[match(eff$otu_id, status$otu_id)],
                      covariate = eff$label1, mean = eff$mean, lo = eff$q2.5, hi = eff$q97.5,
                      rhat = eff$rhat, row.names = NULL, stringsAsFactors = FALSE)

# Residual species associations: quantiles of the correlation left after the covariates.
sig <- returnResidualCorrelationMatrix(f)               # 3 x species x species: lower, median, upper
up <- which(upper.tri(matrix(0, length(nm), length(nm))), arr.ind = TRUE)
assoc <- data.frame(otu_a = nm[up[, 1]], otu_b = nm[up[, 2]],
                    lo = sig[cbind(1, up[, 1], up[, 2])], median = sig[cbind(2, up[, 1], up[, 2])],
                    hi = sig[cbind(3, up[, 1], up[, 2])], stringsAsFactors = FALSE)

stopifnot(nrow(occ) == 101 * 108, nrow(params) == 108, nrow(diagnostics) == 108, !anyNA(diagnostics), nrow(effects) == 9 * 108)
saveRDS(list(occ = tibble::as_tibble(occ), params = tibble::as_tibble(params),
             diagnostics = tibble::as_tibble(diagnostics), effects = tibble::as_tibble(effects), assoc = tibble::as_tibble(assoc),
             mu_b0 = tibble::as_tibble(mu_b0),
             source = list(fit = basename(fit_path), occjsdm = "1b4a2cd", b0_prior = "community")),
        "data-derived/fit_summary.rds")
