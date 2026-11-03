# The numbers the session text and docs state, checked against the data and the fits.
# If one of these fails, the sentence that quotes it needs rewriting, not just the test.
source(testthat::test_path("..", "R", "data.R"))
source(testthat::test_path("..", "R", "fit.R"))
.libPaths(c(file.path(workshop_root(), "Rlib"), .libPaths()))
suppressPackageStartupMessages(library(dplyr))

m <- load_mammal()
status <- species_status()
f <- read_fit_summary()
sites_detected <- colSums(site_presence(m))
by_name <- function(x, sp) unname(x[status$otu_id[match(sp, status$species)]])

test_that("Session 1: the dhole figure supports the text", {
  expect_equal(by_name(sites_detected, "Cuon alpinus"), 41)
  expect_equal(nrow(site_presence(m)) - by_name(sites_detected, "Cuon alpinus"), 60)   # "60 empty circles"
  dhole <- status$otu_id[status$species == "Cuon alpinus"]
  per_sample <- tapply(m$OTU[, dhole], m$info$Sample, sum)
  glg39 <- per_sample[sort(unique(m$info$Sample[m$info$Site == "GLG39"]))]
  expect_equal(as.vector(glg39), c(0, 2, 3))            # "samples 2 and 3 had 2 and 3 ... sample 1 had none"
  pcr <- tapply(m$OTU[, dhole], m$info$Site, sum)
  expect_gte(sum(pcr == 1), 4)                       # the four arrowed sites have 1 positive PCR of 18
})

test_that("Session 1: taxonomic orders use current names", {
  expect_false("Soricomorpha" %in% status$order)
})

test_that("Sessions 1 and 2: the simulated species supports the text", {
  suppressPackageStartupMessages({ library(occJSDM); library(tidyverse) })
  chunk <- function(file, label) {   # the code of one chunk, as in test-session2-exercises.R
    rmd <- readLines(file.path(workshop_root(), file))
    start <- grep(paste0("^```\\{r ", label, "[,}]"), rmd)
    end <- start + which(rmd[(start + 1):length(rmd)] == "```")[1]
    rmd[(start + 1):(end - 1)]
  }
  # "the same code"; trailing spaces are ignored, since RStudio strips them on save
  expect_identical(trimws(chunk("01-why-model.Rmd", "simulate-survey"), "right"),
                   trimws(chunk("02-dhole.Rmd", "simulate-survey"), "right"))

  sim <- new.env()
  sim$info <- read.csv(derived_path("info.csv"))
  sim$sim_fit <- readRDS(derived_path("simulated_fit.rds"))
  eval(parse(text = chunk("02-dhole.Rmd", "simulate-survey")), envir = sim)
  for (label in c("simulated-check", "simulated-classify")) {
    invisible(capture.output(eval(parse(text = chunk("02-dhole.Rmd", label)), envir = sim)))
  }
  s <- sim$sim_check

  expect_true(all(s$positive[s$present == 0] == 0))              # "no false positives"
  expect_equal(sum(s$present), 46)                              # "present in 46 sites"
  expect_equal(sum(s$positive > 0), 37)                         # "only detected it in 37 sites"
  expect_equal(sum(s$present == 1 & s$positive == 0), 9)        # "9 false-negative sites"
  expect_gte(sum(s$present == 1 & s$positive == 0), 5)          # enough orange sites to see
  means <- tapply(s$probability, s$status, mean)
  expect_gt(means[["present, detected"]], 0.95)                  # "nearly sure"
  expect_gt(means[["present, missed"]], 2 * means[["absent"]])   # missed sites get clearly more
  expect_gte(sum(s$present == 0 & s$probability > min(s$probability[s$status == "present, missed"])), 3)   # "some ... absent get as high"
  expect_lt(abs(sum(s$probability) - sum(s$present)), 3)        # "about the right amount"
  expect_gt(sum(s$present) - sum(s$positive > 0), 5)            # raw count is clearly short
  expect_equal(mean(sim$sim_fit$results_output$theta_output), 0.4, tolerance = 0.1)   # "recovers the rates"
  expect_equal(mean(sim$sim_fit$results_output$p_output), 0.6, tolerance = 0.1)
})

test_that("Session 2: the results sections support the text", {
  suppressPackageStartupMessages(library(occJSDM))
  fit <- readRDS(derived_path("dhole_fit.rds"))
  cond <- computeConditionalOccupancyProbs(fit)[, 1]
  expect_true(all(cond[c("GLG23055", "GLG23052", "GLG23053", "GLG23064")] < 0.05))   # "a few percent at most"
  expect_gt(cond[["GLG39"]], 0.7)                    # "gets a high probability"
  expect_gt(cond[["GLG28"]], 0.99)                   # "is certain"
  bt <- returnPosteriorDraws(fit, "beta_theta")
  expect_equal(round(10 * mean(plogis(bt["(Intercept)", 1, , ]))), 7)   # "about seven times in ten"
  expect_equal(round(10 * mean(returnPosteriorDraws(fit, "p")[1, 1, , ])), 6)   # "about six times in ten"
  expect_lt(quantile(bt["PrevDayRain", 1, , ], 0.975), 0)               # rain clearly lowers collection
  expect_lt(quantile(bt["Filter_vol", 1, , ], 0.025), 0)                # water volume crosses zero
  c_draws <- plogis(bt["(Intercept)", 1, , ]); p_draws <- returnPosteriorDraws(fit, "p")[1, 1, , ]
  expect_equal(round(mean(1 - (1 - c_draws * (1 - (1 - p_draws)^6))^3), 2), 0.96)   # "about 96%"
  dg <- returnConvergenceDiagnostics(fit)
  flagged <- dg[dg$rhat > 1.01 | dg$ess < 400, ]
  expect_setequal(flagged$param, c("p", "q"))        # "the flagged parameters ... p and q"
  expect_true(all(flagged$rhat < 1.05))              # "rhat of 1.03"
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
