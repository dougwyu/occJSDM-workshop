# The numbers hard-coded in the prose of Session 3, checked against the session's own code.
# The chunks are run in the session's own objects, so if one of these fails, the sentence
# that quotes the number needs rewriting, not just the test.
root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
.libPaths(c(file.path(root, "Rlib"), .libPaths()))
suppressPackageStartupMessages(library(tidyverse))

rmd <- readLines(file.path(root, "03-many-species.Rmd"))
chunk <- function(label) {   # the code of one chunk, as in test-session2-exercises.R
  start <- grep(paste0("^```\\{r ", label, "[,}]"), rmd)
  end <- start + which(rmd[(start + 1):length(rmd)] == "```")[1]
  rmd[(start + 1):(end - 1)]
}

s3 <- new.env()
withr::with_dir(root, {
  sys.source(file.path(root, "R", "data.R"), envir = s3)
  sys.source(file.path(root, "R", "fit.R"), envir = s3)
  for (label in c("load", "convergence", "detection-rates", "occupancy", "richness",
                  "reserve-effects", "reserve-summary", "associations")) {
    invisible(capture.output(eval(parse(text = chunk(label)), envir = s3)))
  }
})

test_that("Session 3: the number of species", {
  expect_equal(nrow(s3$fit$params), 108)               # "108 separate models", "108 mammals"
  expect_equal(ncol(s3$OTU), 108)
  expect_equal(nrow(s3$fit$diagnostics), 108)          # "With 108 species"
})

test_that("Session 3: the convergence bullets", {
  conv <- s3$conv
  expect_equal(sum(!conv$detection_settled), 4)        # "all but 4 species"
  expect_equal(sum(!conv$effects_settled), 29)         # "for 29 species"
  expect_equal(sum(!conv$settled), 30)                 # "30 species fail one check or the other"
  expect_equal(sum(!conv$settled & conv$sites_detected <= 6), 15)   # "Half of them (15) ... six sites or fewer"
  rattus <- filter(conv, species == "Rattus tanezumi")
  expect_false(rattus$settled)                         # "the list also includes ... Rattus tanezumi"
  expect_equal(rattus$sites_detected, 84)              # "detected at 84 sites"
  expect_true(filter(conv, species == "Cuon alpinus")$settled)   # "The dhole passes both checks"
})

test_that("Session 3: the plain detection plot", {
  p <- s3$profile
  expect_equal(round(min(p$p_mean), 2), 0.15)          # "from about 0.15"
  expect_equal(round(max(p$p_mean), 2), 0.95)          # "to 0.95"
  expect_equal(sum(p$q_mean < 0.05), 96)               # "Most species (96 of 108) ... below 0.05"
  expect_equal(nrow(p), 108)
})

test_that("Session 3: occupancy and richness", {
  expect_equal(nrow(s3$occ), 10908)                    # "It has 10,908 rows"
  expect_equal(nrow(s3$occ), nrow(s3$sites) * 108)     # 101 sites x 108 species
  expect_equal(nrow(s3$sites), 101)
  expect_equal(round(mean(s3$richness$detected), 1), 22.5)   # "22.5 species detected"
  expect_equal(round(mean(s3$richness$expected), 1), 12.8)   # "the model expects only 12.8"
})

test_that("Session 3: the reserve bullets", {
  r <- s3$reserve_effects
  reserve <- filter(r, covariate == "Stream rises inside a reserve")
  modification <- filter(r, covariate == "More human modification")
  wild <- filter(reserve, local_status == "wild")
  expect_equal(nrow(wild), 68)                         # "the 68 wild species"
  expect_equal(sum(wild$lower > 0), 51)                # "for 51 of the 68"
  expect_equal(sum(reserve$upper < 0), 0)              # "No species is credibly less likely"
  expect_equal(round(cor(reserve$estimate, log10(reserve$body_mass)), 2), -0.37)   # "-0.37"
  expect_equal(nrow(modification), 78)                 # "of the 78 species"
  expect_equal(sum(modification$lower > 0 | modification$upper < 0), 1)   # "only 1 of the 78"
  dom <- filter(reserve, local_status != "wild")
  expect_equal(sum(dom$lower > 0), 0)                  # "little or no reserve effect" for domestic animals
})

test_that("Session 3: the associations", {
  a <- s3$assoc
  expect_equal(nrow(a), 225)                           # "225 pairs"
  expect_equal(sum(a$median < 0), 0)                   # "none of them is negative"
  top <- slice_max(a, median, n = 1)
  expect_setequal(c(top$species_a, top$species_b), c("Rattus nitidus", "Rattus tanezumi"))   # the strongest
  dhole <- filter(a, species_a == "Cuon alpinus" | species_b == "Cuon alpinus")
  expect_gt(nrow(dhole), 0)                            # the closing question has an answer
})
