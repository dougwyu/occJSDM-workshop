# Session 3 builds its tables live from the full mammal fit (fits/, not in git), and shows,
# in a chunk not run in class, how Session 4's occupancy table was saved. Both must agree
# with the shipped files, which analysis/build-fit-summary.R and build-session-data.R made.
root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
fit_file <- file.path(root, "fits", "fit_Mammal_d4_community_1b4a2cd_10k.rds")

session3_tables <- function() {
  .libPaths(c(file.path(root, "Rlib"), .libPaths()))
  suppressPackageStartupMessages(library(tidyverse))
  suppressPackageStartupMessages(library(occJSDM))
  rmd <- readLines(file.path(root, "03-many-species.Rmd"))
  chunk <- function(label) {
    start <- grep(paste0("^```\\{r ", label, "[,}]"), rmd)
    end <- start + which(rmd[(start + 1):length(rmd)] == "```")[1]
    rmd[(start + 1):(end - 1)]
  }
  e <- new.env()
  withr::with_dir(root, for (label in c("load", "fit-tables")) {
    invisible(capture.output(eval(parse(text = chunk(label)), envir = e)))
  })
  e$save_code <- sub("^# ?", "", chunk("save-for-session-4"))   # the chunk is commented out so it cannot run by accident
  e
}

test_that("Session 3 reads the fit the build scripts used", {
  rmd <- readLines(file.path(root, "03-many-species.Rmd"))
  expect_true(any(grepl('readRDS("fits/fit_Mammal_d4_community_1b4a2cd_10k.rds")', rmd, fixed = TRUE)))
  expect_equal(readRDS(file.path(root, "data-derived", "fit_summary.rds"))$source$fit,
               basename(fit_file))
})

test_that("Session 3's live tables match the saved fit summary, and its save chunk remakes Session 4's table", {
  skip_if_not(file.exists(fit_file), "put the full mammal fit in fits/")
  e <- session3_tables()
  f <- readRDS(file.path(root, "data-derived", "fit_summary.rds"))
  expect_named(e$fit, c("occ", "params", "diagnostics", "effects", "assoc"))
  # the tables have the shipped columns, and the same rows
  for (t in names(e$fit)) {
    expect_setequal(names(e$fit[[t]]), names(f[[t]]))
    expect_equal(nrow(e$fit[[t]]), nrow(f[[t]]))
  }
  same <- function(a, b, by) {
    j <- dplyr::inner_join(a, b, by = by, suffix = c(".live", ".saved"))
    expect_equal(nrow(j), nrow(a))
    for (col in setdiff(names(a), by)) expect_equal(unname(j[[paste0(col, ".live")]]), unname(j[[paste0(col, ".saved")]]), info = col)
  }
  same(e$fit$occ, f$occ, c("Site", "otu_id"))
  same(e$fit$params, f$params, "otu_id")
  same(e$fit$diagnostics, f$diagnostics, "otu_id")
  same(e$fit$effects, f$effects, c("otu_id", "covariate"))
  same(e$fit$assoc, f$assoc, c("otu_a", "otu_b"))

  # the not-run chunk, writing to a temporary folder, remakes occupancy_long.csv
  out <- withr::local_tempdir()
  dir.create(file.path(out, "data-derived"))
  withr::with_dir(out, eval(parse(text = e$save_code), envir = e))
  remade <- read.csv(file.path(out, "data-derived", "occupancy_long.csv"))
  shipped <- read.csv(file.path(root, "data-derived", "occupancy_long.csv"))
  expect_equal(names(remade), names(shipped))
  same(remade, shipped, c("Site", "otu_id"))
})
