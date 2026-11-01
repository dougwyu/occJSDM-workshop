source(testthat::test_path("..", "R", "data.R"))
source(testthat::test_path("..", "R", "fit.R"))
source(testthat::test_path("..", "R", "scp.R"))
.libPaths(c(file.path(workshop_root(), "Rlib"), .libPaths()))

occ <- occupancy_long()[, c("Site", "species", "cond_mean")]
status <- species_status()
cost <- site_covariates()[, c("Site", "Human_modification_1km")]
names(cost)[2] <- "cost"
budget <- 0.25 * sum(cost$cost)

test_that("species_weights gives unmatched species a default weight and warns", {
  expect_warning(w <- species_weights(status, "redlist"), "no Red List status")
  expect_equal(nrow(w), 108)
  expect_false(anyNA(w$weight))
  expect_equal(w$weight[w$species == "Cuon alpinus"], 4)      # Endangered
  expect_equal(unique(species_weights(status, "equal")$weight), 1)
})

test_that("the selection stays within budget and covers every site once", {
  sol <- build_scp(occ, species_weights(status, "equal"), cost, budget)
  expect_equal(nrow(sol), 101)
  expect_type(sol$selected, "logical")
  expect_gte(sum(sol$selected), 1)
  expect_lte(sum(cost$cost[match(sol$Site[sol$selected], cost$Site)]), budget + 1e-6)
})

test_that("raising a species' weight never lowers its coverage up to the target", {
  # Above the target the objective does not reward more coverage, so compare capped coverage,
  # and pick a species that starts below its target so the comparison means something.
  base <- species_weights(status, "equal")
  cv0 <- scp_coverage(build_scp(occ, base, cost, budget, target = 0.5), occ)
  sp <- cv0$species[which.min(cv0$held)]
  expect_lt(min(cv0$held), 0.5)
  boosted <- base
  boosted$weight[boosted$species == sp] <- 100
  cv1 <- scp_coverage(build_scp(occ, boosted, cost, budget, target = 0.5), occ)
  expect_gte(min(cv1$held[cv1$species == sp], 0.5), min(cv0$held[cv0$species == sp], 0.5) - 1e-9)
})

test_that("species with weight zero are left out of the objective", {
  w <- species_weights(status, "equal")
  w$weight[w$species %in% c("Sus scrofa", "Bos taurus")] <- 0
  sol <- build_scp(occ, w, cost, budget)
  expect_false(any(c("Sus scrofa", "Bos taurus") %in% attr(sol, "features")))
  expect_equal(length(attr(sol, "features")), 106)
})
