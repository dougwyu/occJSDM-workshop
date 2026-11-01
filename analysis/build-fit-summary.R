# Reduce fit_Mammal_d4_fixed.rds (occJSDM 6256791, b0_prior = "fixed") to data-derived/fit_summary.rds.
# Set WORKSHOP_FIT to the fit and WORKSHOP_CONV to species_convergence.csv from occJSDM_Ecoletts.
source("R/data.R")
fit_path <- Sys.getenv("WORKSHOP_FIT", unset = "fits/fit_Mammal_d4_fixed.rds")
conv_path <- Sys.getenv("WORKSHOP_CONV", unset = "fits/species_convergence.csv")
f <- readRDS(fit_path)
ro <- f$results_output
status <- species_status()

occ <- expand.grid(Site = f$infos$siteNames, otu_id = f$infos$speciesNames, stringsAsFactors = FALSE)
occ$cond_mean <- as.vector(ro$z_output)
occ$psi_mean <- as.vector(ro$psi_output)
occ$species <- status$species[match(occ$otu_id, status$otu_id)]
occ <- occ[, c("Site", "otu_id", "species", "cond_mean", "psi_mean")]

draws <- function(a, s) as.vector(a[1, s, , ])
q <- function(x) stats::quantile(x, c(0.025, 0.975), names = FALSE)
params <- do.call(rbind, lapply(seq_along(f$infos$speciesNames), function(s) {
  p <- draws(ro$p_output, s); fp <- draws(ro$q_output, s); th <- as.vector(ro$theta0_output[s, , ])
  data.frame(
    otu_id = f$infos$speciesNames[s],
    p_mean = mean(p), p_lo = q(p)[1], p_hi = q(p)[2],
    q_mean = mean(fp), q_lo = q(fp)[1], q_hi = q(fp)[2],
    theta0_mean = mean(th), theta0_lo = q(th)[1], theta0_hi = q(th)[2]
  )
}))
params$species <- status$species[match(params$otu_id, status$otu_id)]

conv <- read.csv(conv_path, stringsAsFactors = FALSE)
diagnostics <- data.frame(otu_id = status$otu_id, species = status$species)
diagnostics <- merge(diagnostics, conv[, c("species", "rhat_p", "rhat_q", "rhat_theta0", "max_rhat", "converged")], by = "species")

# Residual species associations: quantiles of the correlation left after the covariates.
suppressPackageStartupMessages(library(occJSDM))
sig <- returnResidualCorrelationMatrix(f)               # 3 x species x species: lower, median, upper
nm <- f$infos$speciesNames
up <- which(upper.tri(matrix(0, length(nm), length(nm))), arr.ind = TRUE)
assoc <- data.frame(otu_a = nm[up[, 1]], otu_b = nm[up[, 2]],
                    lo = sig[cbind(1, up[, 1], up[, 2])], median = sig[cbind(2, up[, 1], up[, 2])],
                    hi = sig[cbind(3, up[, 1], up[, 2])], stringsAsFactors = FALSE)

stopifnot(nrow(occ) == 101 * 108, nrow(params) == 108, nrow(diagnostics) == 108)
saveRDS(list(occ = tibble::as_tibble(occ), params = tibble::as_tibble(params),
             diagnostics = tibble::as_tibble(diagnostics), assoc = tibble::as_tibble(assoc),
             source = list(fit = basename(fit_path), occjsdm = "6256791", b0_prior = "fixed")),
        "data-derived/fit_summary.rds")
