source(testthat::test_path("..", "R", "data.R"))
source(testthat::test_path("..", "R", "ordination.R"))
.libPaths(c(file.path(workshop_root(), "Rlib"), .libPaths()))
suppressPackageStartupMessages(library(ggplot2))

m <- load_mammal()
y <- site_presence(m)

test_that("site_presence is a 0/1 site by species matrix named by site and species", {
  expect_equal(dim(y), c(101, 108))
  expect_true(all(y %in% c(0L, 1L)))
  expect_setequal(rownames(y), unique(m$info$Site))
  expect_equal(colnames(y), colnames(m$OTU))
})

test_that("fit_ordination drops sparse species and reports them", {
  ord <- fit_ordination(y, min_sites = 5L)
  expect_equal(nrow(ord$site_scores), 101)
  expect_equal(length(ord$dropped), 28)
  expect_equal(nrow(ord$species_scores), 108 - 28)
  expect_false(any(ord$dropped %in% ord$species_scores$otu_id))
})

test_that("an all-zero species column does not break the ordination", {
  y0 <- cbind(y, never_seen = 0L)
  ord <- fit_ordination(y0, min_sites = 5L)
  expect_true("never_seen" %in% ord$dropped)
  expect_equal(nrow(ord$site_scores), 101)
})

test_that("plot_biplot returns a ggplot that builds", {
  ord <- fit_ordination(y)
  s <- species_status()
  sites <- site_covariates()
  p <- plot_biplot(ord, site_data = sites, site_var = "Human_modification_1km",
                   species_data = s, species_var = "order")
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("the same seed gives the same ordination", {
  set.seed(2026); a <- fit_ordination(y)
  set.seed(2026); b <- fit_ordination(y)
  expect_equal(a$site_scores, b$site_scores)
})
