# Spinal deformity workflow: simulate, fit, and diagnose a binomial GLMM
#
# Study description (plain language)
# ----------------------------------
# Fish embryos were exposed to two perfluoroalkyl substances, PFOA and PFOS,
# at three concentrations each: 0 (control), 5, and 20. Every combination of
# PFOA and PFOS was tested, so the design is fully crossed. Fish came from
# several rivers, and river of origin is a random effect because the rivers
# are a sample from a larger population of rivers, not levels we care about
# individually.
#
# For each fish we recorded whether it showed spinal deformity (yes or no).
# The question is whether the probability of deformity rises with PFOA and
# PFOS, and whether the two chemicals interact.
#
# Model: a logistic mixed model. The log-odds of deformity is a linear
# function of PFOA, PFOS, and their interaction, plus a random intercept
# for river:
#
#   deformed ~ PFOA * PFOS + (1 | river), binomial family
#
# Example requests a student could make to get this analysis:
#   "Simulate a dataset for a binary outcome (spinal deformity) from fish in
#    several rivers, exposed to PFOA and PFOS at 0, 5, and 20. Include a
#    river random intercept and an interaction between the two chemicals."
#   "Fit a binomial GLMM with a river random intercept and check the
#    residuals with DHARMa."
#   "Check whether the river variance is estimable and what the singular-fit
#    warning means for the results."
#
# Simulated design: rivers x PFOA x PFOS x replicate fish, with river random intercept

library(lme4)
library(DHARMa)

# ---- Settings ----
seed        <- 4817
n_rivers    <- 10
doses       <- c(0, 5, 20)   # PFOA and PFOS levels; 0 is the control
n_reps      <- 2             # fish per river x PFOA x PFOS combination
sd_river    <- 0.5
b0          <- -2.5
b_pfoa      <- 0.04
b_pfos      <- 0.05
n_sim       <- 1000          # DHARMa simulations

# ---- Simulate data ----
set.seed(seed)

design <- expand.grid(PFOA = doses, PFOS = doses, rep = seq_len(n_reps))

spine_dat <- do.call(rbind, lapply(seq_len(n_rivers), function(j) {
  d <- design
  d$river <- factor(sprintf("R%02d", j))
  d
}))
spine_dat$fish <- factor(seq_len(nrow(spine_dat)))

u_river <- setNames(rnorm(n_rivers, 0, sd_river), levels(spine_dat$river))

eta <- b0 + b_pfoa * spine_dat$PFOA + b_pfos * spine_dat$PFOS +
  u_river[as.character(spine_dat$river)]
spine_dat$deformed <- rbinom(nrow(spine_dat), 1, plogis(eta))

# Observed deformity rate by dose combination
with(spine_dat, tapply(deformed, list(PFOA, PFOS), mean))

# ---- Fit model ----
fit <- glmer(
  deformed ~ PFOA * PFOS + (1 | river),
  family = binomial,
  data = spine_dat,
  control = glmerControl(optimizer = "bobyqa")
)

summary(fit)
isSingular(fit)
exp(fixef(fit))

# ---- Diagnostics ----
sim_res <- simulateResiduals(fit, n = n_sim, plot = FALSE)

plot(sim_res)
testUniformity(sim_res)
testDispersion(sim_res)
testZeroInflation(sim_res)
plotResiduals(sim_res, form = spine_dat$PFOA)
plotResiduals(sim_res, form = spine_dat$PFOS)
testCategorical(sim_res, catPred = spine_dat$river)
