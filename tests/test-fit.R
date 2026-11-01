source(testthat::test_path("..", "R", "data.R"))
source(testthat::test_path("..", "R", "fit.R"))

test_that("the fit summary has one occupancy row per site and species, matched by name", {
  f <- read_fit_summary()
  m <- load_mammal()
  expect_equal(nrow(f$occ), 101 * 108)
  expect_true(all(f$occ$psi_mean >= 0 & f$occ$psi_mean <= 1))
  expect_true(all(f$occ$cond_mean >= 0 & f$occ$cond_mean <= 1))
  expect_setequal(f$occ$Site, unique(m$info$Site))
  expect_setequal(f$occ$otu_id, colnames(m$OTU))
  expect_false(anyNA(f$occ$species))
})

test_that("the dhole's mean occupancy matches the stored comparison", {
  f <- read_fit_summary()
  d <- f$occ[f$occ$species == "Cuon alpinus", ]
  expect_equal(nrow(d), 101)
  expect_equal(mean(d$cond_mean), 0.18, tolerance = 0.03)
})

test_that("detection parameters and diagnostics cover every species", {
  f <- read_fit_summary()
  expect_equal(nrow(f$params), 108)
  expect_true(all(c("p_mean", "p_lo", "p_hi", "q_mean", "q_lo", "q_hi") %in% names(f$params)))
  expect_equal(nrow(f$diagnostics), 108)
  expect_equal(sum(f$diagnostics$converged), 104)
})

test_that("species associations cover every pair once, with ordered quantiles", {
  f <- read_fit_summary()
  expect_equal(nrow(f$assoc), 108 * 107 / 2)
  expect_true(all(f$assoc$lo <= f$assoc$median & f$assoc$median <= f$assoc$hi))
  expect_true(all(abs(c(f$assoc$lo, f$assoc$hi)) <= 1))
  expect_false(any(f$assoc$otu_a == f$assoc$otu_b))
})

test_that("occupancy_long joins status to occupancy and matches the saved CSV", {
  o <- occupancy_long()
  expect_equal(nrow(o), 101 * 108)
  expect_true(all(c("Site", "species", "order", "iucn", "cond_mean", "psi_mean") %in% names(o)))
  csv <- read.csv(derived_path("occupancy_long.csv"))
  expect_equal(nrow(csv), 101 * 108)
  expect_equal(csv$cond_mean, o$cond_mean, tolerance = 1e-9)
})
