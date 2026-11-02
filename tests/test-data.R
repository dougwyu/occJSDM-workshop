source(testthat::test_path("..", "R", "data.R"))

test_that("the mammal input has 108 species and 101 sites", {
  m <- load_mammal()
  expect_equal(ncol(m$OTU), 108)
  expect_equal(length(unique(m$info$Site)), 101)
  expect_equal(nrow(m$info), nrow(m$OTU))
  expect_equal(m$K, 6)
})

test_that("species_status has one row per species, with order and family", {
  m <- load_mammal()
  s <- species_status()
  expect_equal(nrow(s), 108)
  expect_setequal(s$otu_id, colnames(m$OTU))
  expect_false(anyNA(s$order))
  expect_false(anyNA(s$family))
  message("species with no IUCN status: ", sum(is.na(s$iucn) | s$iucn %in% c("", "NA")))
  message("species with no China Red List status: ", sum(is.na(s$china_red_list) | s$china_red_list %in% c("", "NA")))
})

test_that("the dhole is present and listed as Endangered", {
  s <- species_status()
  expect_equal(s$iucn[s$species == "Cuon alpinus"], "EN")
})

test_that("site covariates do not depend on the row order of the input", {
  m <- load_mammal()
  set.seed(1)
  shuffled <- m$info[sample(nrow(m$info)), ]
  a <- site_covariates_from(m$info, m$occCovariates)
  b <- site_covariates_from(shuffled, m$occCovariates)
  expect_equal(a, b)
  expect_equal(nrow(a), 101)
  expect_true("Human_modification_1km" %in% names(a))
  expect_false(anyNA(a$Human_modification_1km))
})

test_that("dhole_input is the mammal data reduced to the dhole's column", {
  m <- load_mammal()
  d <- dhole_input(m)
  expect_equal(dim(d$OTU), c(1818, 1))
  expect_equal(nrow(d$info), 1818)
  expect_equal(sum(d$OTU), sum(m$OTU[, grep("Cuon_alpinus", colnames(m$OTU))]))
  expect_true(file.exists(derived_path("dhole_input.rds")))
  expect_identical(readRDS(derived_path("dhole_input.rds")), d)
})

test_that("site_presence is a 0/1 site by species matrix named by site and species", {
  m <- load_mammal()
  y <- site_presence(m)
  expect_equal(dim(y), c(101, 108))
  expect_true(all(y %in% c(0L, 1L)))
  expect_setequal(rownames(y), unique(m$info$Site))
  expect_equal(colnames(y), colnames(m$OTU))
})

test_that("the CSV files the sessions read hold exactly the prepared data", {
  m <- load_mammal()
  info <- read.csv(derived_path("info.csv"))
  OTU <- as.matrix(read.csv(derived_path("OTU.csv")))
  expect_equal(info, m$info, ignore_attr = TRUE)
  expect_type(info$Primer, "character")
  expect_identical(OTU, m$OTU)
  expect_equal(read.csv(derived_path("species.csv")), as.data.frame(species_status()), ignore_attr = TRUE)
  d <- list(info = info, OTU = OTU[, grep("Cuon_alpinus", colnames(OTU), value = TRUE), drop = FALSE])
  # Session 2's input matches the MCP's file (read.csv makes whole-number columns integer; values agree)
  expect_equal(d, readRDS(derived_path("dhole_input.rds")), ignore_attr = TRUE)
})
