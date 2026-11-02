# The numbers the session text and docs state, checked against the data and the fits.
# If one of these fails, the sentence that quotes it needs rewriting, not just the test.
source(testthat::test_path("..", "R", "data.R"))
source(testthat::test_path("..", "R", "fit.R"))
source(testthat::test_path("..", "R", "scp.R"))
.libPaths(c(file.path(workshop_root(), "Rlib"), .libPaths()))
suppressPackageStartupMessages(library(dplyr))

m <- load_mammal()
status <- species_status()
f <- read_fit_summary()
sites_detected <- colSums(site_presence(m))
by_name <- function(x, sp) unname(x[status$otu_id[match(sp, status$species)]])

test_that("Session 1: dhole detections and naive against model occupancy", {
  expect_equal(by_name(sites_detected, "Cuon alpinus"), 41)
  dhole <- status$otu_id[status$species == "Cuon alpinus"]
  pcr <- tapply(m$OTU[, dhole], m$info$Site, sum)
  expect_gte(sum(pcr %in% 1:2), 15)                 # "many have only one or two positive PCRs"
  model <- tapply(f$occ$cond_mean, f$occ$otu_id, mean)
  for (sp in c("Sus scrofa", "Bos taurus")) {       # "detected at almost every site ... about half"
    expect_gt(by_name(sites_detected, sp) / 101, 0.95)
    expect_gt(by_name(model, sp), 0.4)
    expect_lt(by_name(model, sp), 0.6)
  }
  expect_lt(by_name(model, "Cuon alpinus"), 0.25)   # "far fewer" than 41 of 101
})

test_that("Session 1: order explains about a fifth of axis 1, with borderline evidence", {
  presence <- site_presence(m)                      # the same steps as the session's chunks
  y <- as.data.frame(presence[, colSums(presence) >= 5])
  set.seed(2026)
  sdm <- ecoCopula::stackedsdm(y, formula_X = ~ 1, data = data.frame(site = rownames(y)), family = "binomial", ncores = 1)
  ord <- ecoCopula::cord(sdm, nlv = 2)
  loadings <- data.frame(otu_id = colnames(y), LV1 = ord$loadings[, 1]) |>
    left_join(status[, c("otu_id", "order")], by = "otu_id")
  a <- anova(lm(LV1 ~ order, data = loadings))
  expect_equal(a$`Sum Sq`[1] / sum(a$`Sum Sq`), 0.2, tolerance = 0.05 / 0.2)
  expect_gt(a$`Pr(>F)`[1], 0.02)
  expect_lt(a$`Pr(>F)`[1], 0.1)
  expect_false("Soricomorpha" %in% status$order)
})

test_that("Session 2: the saved dhole fit supports the text", {
  suppressPackageStartupMessages(library(occJSDM))
  fit <- readRDS(derived_path("dhole_fit.rds"))     # identical to the live fit with the session's seed
  invisible(capture.output(diag <- returnConvergenceDiagnostics(fit)))
  expect_equal(mean(fit$results_output$p_output), 0.6, tolerance = 0.05 / 0.6)   # "six times in ten"
  pq <- diag[diag$param %in% c("p", "q"), ]
  expect_true(all(pq$rhat > 1.01 & pq$ess < 400))   # "R-hat a little above 1.01 and ESS below 400"
  expect_true(all(pq$rhat < 1.1))
  b <- diag[diag$param == "beta_psi", ]
  expect_true(all(b$q2.5 < 0 & b$q97.5 > 0))        # "every interval here crosses it"
  cond <- computeConditionalOccupancyProbs(fit)[, 1]
  expect_gt(mean(cond < 0.1 | cond > 0.9), 0.5)     # "most sites are close to certain"
  joint <- f$occ[f$occ$species == "Cuon alpinus", ]
  expect_gt(cor(cond[joint$Site], joint$cond_mean), 0.9)   # "both fits agree"
})

test_that("Session 2: the mammal-wide Southwest effect excludes zero but is not more precise", {
  eff <- readRDS(derived_path("dhole_check.rds"))$effects
  sw <- eff[eff$covariate == "Regional_DivisionSouthwest", ]
  expect_lt(sw$hi, 0)
  fit <- readRDS(derived_path("dhole_fit.rds"))
  invisible(capture.output(diag <- occJSDM::returnConvergenceDiagnostics(fit)))
  single <- diag[diag$param == "beta_psi", ]
  width_joint <- (eff$hi - eff$lo)[match(single$label1, eff$covariate)]
  expect_gt(mean(width_joint > single$q97.5 - single$q2.5), 0.5)   # "mostly wider, not narrower"
})

test_that("Session 3: convergence counts quoted in the text", {
  d <- f$diagnostics
  bad_det <- d$rhat_detection > 1.1
  bad_eff <- d$rhat_effects > 1.1
  expect_equal(sum(bad_det), 4)
  expect_equal(sum(bad_eff), 29)
  expect_equal(sum(bad_det | bad_eff), 30)
  n <- sites_detected[d$otu_id[bad_det | bad_eff]]
  expect_equal(sum(n <= 6), 15)                      # "half of those 30 ... six sites or fewer"
  expect_true(d$rhat_effects[d$species == "Rattus tanezumi"] > 1.1)
  expect_equal(by_name(sites_detected, "Rattus tanezumi"), 84)
  expect_true(all(unlist(d[d$species == "Cuon alpinus", c("rhat_detection", "rhat_effects")]) <= 1.1))
})

test_that("Session 3: false positives, richness and associations", {
  top <- f$params |> arrange(desc(q_mean)) |> head(10)
  expect_true(all(sites_detected[top$otu_id] / 101 > 0.5))   # "detected at most sites"
  expect_true(all(c("Sus scrofa", "Bos taurus") %in% top$species))
  credible <- f$assoc |> filter(lo > 0 | hi < 0)
  expect_equal(nrow(credible), 225)
  expect_true(all(credible$median > 0))              # "every association that survives is positive"
  sp <- function(id) status$species[match(id, status$otu_id)]
  pairs <- paste(sp(credible$otu_a), sp(credible$otu_b))
  expect_true(any(pairs %in% c("Bos taurus Bubalus bubalis", "Bubalus bubalis Bos taurus")))
  expect_true(any(pairs %in% c("Cuon alpinus Canis lupus", "Canis lupus Cuon alpinus")))
})

test_that("Session 4: livestock and Red List coverage", {
  dom <- status$species[status$local_status == "dom"]
  expect_true(all(c("Bos taurus", "Bubalus bubalis", "Capra hircus") %in% dom))
  expect_equal(sum(is.na(status$iucn) & is.na(status$china_red_list)), 13)
})

test_that("Session 4: costing by human modification picks less modified sites, and more of them", {
  occ <- read.csv(derived_path("occupancy_long.csv"))[, c("Site", "species", "cond_mean")]
  sites <- site_covariates()
  w <- suppressWarnings(species_weights(status, "redlist"))
  equal <- build_scp(occ, w, data.frame(Site = sites$Site, cost = 1), budget = 0.2 * 101)
  human <- build_scp(occ, w, data.frame(Site = sites$Site, cost = sites$Human_modification_1km),
                     budget = 0.2 * sum(sites$Human_modification_1km))
  hm <- function(plan) sites$Human_modification_1km[match(plan$Site[plan$selected], sites$Site)]
  expect_lt(mean(hm(human)), mean(hm(equal)))
  expect_gt(sum(human$selected), sum(equal$selected))
})
