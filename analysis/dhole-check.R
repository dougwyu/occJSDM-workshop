# Acceptance check for the Wednesday species (Cuon alpinus): are per-site occupancy and
# covariate effects well enough determined to teach from? Uses draws from the cached fit.
fit_path <- Sys.getenv("WORKSHOP_FIT", unset = "fits/fit_Mammal_d4_fixed.rds")
f <- readRDS(fit_path)
j <- f$results_output$jsdm_output
sp <- grep("Cuon_alpinus", f$infos$speciesNames)
stopifnot(length(sp) == 1)
sites <- f$infos$siteNames
X <- as.matrix(f$X_psi)                       # 101 x 9 covariates (no intercept column)
nit <- dim(j$B0_output)[2]; nch <- dim(j$B0_output)[3]
n_draw <- nit * nch

# Rebuild site occupancy draws: link(B0 + X B + U L), then test the link against the stored psi.
b0 <- as.vector(j$B0_output[sp, , ])
B <- matrix(j$B_output[, sp, , ], nrow = ncol(X))           # 9 x draws
U <- matrix(aperm(j$U_output, c(1, 3, 2, 4)), nrow = nrow(X) * 1)  # placeholder, rebuilt below
eta <- matrix(0, nrow(X), n_draw)
for (k in seq_len(n_draw)) {
  it <- ((k - 1) %% nit) + 1; ch <- ((k - 1) %/% nit) + 1
  eta[, k] <- b0[k] + X %*% B[, k] + j$U_output[, , it, ch] %*% j$L_output[, sp, it, ch]
}
psi_draws <- plogis(eta)
psi_mean <- rowMeans(psi_draws)
stored <- f$results_output$psi_output[, sp]
cat("Link check: max |rebuilt - stored psi| =", signif(max(abs(psi_mean - stored)), 3), "\n")

lo <- apply(psi_draws, 1, quantile, 0.025); hi <- apply(psi_draws, 1, quantile, 0.975)
width <- hi - lo
spread <- unname(diff(quantile(psi_mean, c(0.1, 0.9))))
cat("Site occupancy: mean", round(mean(psi_mean), 3), "| median 95% width", round(median(width), 3),
    "| 10th-90th spread of site means", round(spread, 3), "\n")

eff <- data.frame(
  covariate = colnames(X),
  mean = rowMeans(B),
  lo = apply(B, 1, quantile, 0.025), hi = apply(B, 1, quantile, 0.975)
)
eff$excludes_zero <- eff$lo > 0 | eff$hi < 0
print(eff, digits = 3, row.names = FALSE)
cat("Verdict: spread >= median width:", spread >= median(width),
    "| covariate effects excluding zero:", sum(eff$excludes_zero), "\n")
saveRDS(list(sites = sites, psi = data.frame(Site = sites, mean = psi_mean, lo = lo, hi = hi), effects = eff),
        "data-derived/dhole_check.rds")
