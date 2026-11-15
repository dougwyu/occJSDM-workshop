# RCBD species richness analysis: 3 treatments, 9 blocks
#
# Study description (plain language)
# ----------------------------------
# A randomized complete block design (RCBD) compares species richness, the
# count of species in each plot, across three treatments: control, low, and
# high. The field is split into nine blocks (for example, areas that differ
# in soil or light), and each block contains one plot per treatment. Blocks
# are a source of nuisance variation, so block is treated as a random effect.
# We want to know whether richness differs among treatments and by how much.
#
# Model: richness is a count, so the primary model is a Poisson GLMM with a
# random intercept for block, using the log link:
#
#   richness ~ treatment + (1 | block), Poisson family
#
# Because count data often have more variation than a Poisson allows, a
# negative binomial GLMM is fit as a sensitivity check. Treatment contrasts
# are Tukey-adjusted and reported as rate ratios.
#
# Example requests a student could make to get this analysis:
#   "Simulate richness counts for a randomized complete block design with
#    3 treatments and 9 blocks, with a block random intercept."
#   "Fit a Poisson GLMM for richness with block as a random effect, check
#    for overdispersion, and compare with a negative binomial model."
#   "Compare treatments with Tukey-adjusted rate ratios and explain whether
#    the negative binomial fit changes the conclusions."

library(lme4)
library(emmeans)
library(DHARMa)
library(glmmTMB)

# Simulated data (replace with real data frame with columns block, treatment, richness)
set.seed(4817)
dat <- expand.grid(
  block = factor(1:9),
  treatment = factor(c("control", "low", "high"), levels = c("control", "low", "high"))
)
block_eff <- rnorm(9, 0, 0.25)
trt_eff <- c(control = 0, low = 0.3, high = 0.6)
mu <- exp(log(8) + trt_eff[as.character(dat$treatment)] + block_eff[as.integer(dat$block)])
dat$richness <- rpois(nrow(dat), mu)

# Primary model: Poisson GLMM with random intercept for block
m_pois <- glmer(richness ~ treatment + (1 | block), data = dat, family = poisson)
summary(m_pois)

# Overdispersion: Pearson dispersion ratio
pearson_chisq <- sum(residuals(m_pois, type = "pearson")^2)
rdf <- df.residual(m_pois)
disp_pearson <- pearson_chisq / rdf
c(pearson_chisq = pearson_chisq, df = rdf, dispersion = disp_pearson,
  p_lack_of_fit = pchisq(pearson_chisq, rdf, lower.tail = FALSE))

# Residual diagnostics (simulation-based)
sim_pois <- simulateResiduals(m_pois, n = 1000, seed = 2719)
plot(sim_pois)
testDispersion(sim_pois)
testZeroInflation(sim_pois)
testOutliers(sim_pois)

# Post-hoc comparisons, Tukey-adjusted, back-transformed to rate ratios
rr_pois <- pairs(emmeans(m_pois, ~ treatment), adjust = "tukey", type = "response")
confint(rr_pois)
rr_pois

# Sensitivity analysis: negative binomial GLMM (glmmTMB, nbinom2)
m_nb <- glmmTMB(richness ~ treatment + (1 | block), data = dat, family = nbinom2)
summary(m_nb)

# Convergence checks for the sensitivity model
c(convergence = m_nb$fit$convergence, pdHess = m_nb$sdr$pdHess)
c(dispersion_phi = sigma(m_nb))

rr_nb <- pairs(emmeans(m_nb, ~ treatment), adjust = "tukey", type = "response")
confint(rr_nb)
rr_nb

# Side-by-side comparison of primary and sensitivity results
rr_compare <- data.frame(
  contrast = summary(rr_pois)$contrast,
  poisson_RR = round(summary(rr_pois)$ratio, 3),
  nb_RR = round(summary(rr_nb)$ratio, 3),
  poisson_p_adj = round(summary(rr_pois)$p.value, 4),
  nb_p_adj = round(summary(rr_nb)$p.value, 4)
)
rr_compare

c(AIC_poisson = AIC(m_pois), AIC_nb = AIC(m_nb))
