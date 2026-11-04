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
  expect_equal(sum(!conv$detection_settled), 2)        # "all but 2 species"
  expect_equal(sum(!conv$effects_settled), 16)         # "for 16 species"
  expect_equal(sum(!conv$settled), 17)                 # "17 species fail one check or the other"
  expect_equal(sum(!conv$settled & conv$sites_detected <= 6), 7)   # "7 of them ... six sites or fewer"
  cattle <- filter(conv, species == "Bos taurus")
  expect_false(cattle$settled)                         # "the list also includes ... Bos taurus"
  expect_equal(cattle$sites_detected, 97)              # "detected at 97 sites"
  expect_true(filter(conv, species == "Cuon alpinus")$settled)   # "The dhole passes both checks"
})

test_that("Session 3: the plain detection plot", {
  p <- s3$profile
  expect_equal(round(min(p$p_mean), 2), 0.17)          # "from about 0.17"
  expect_equal(round(max(p$p_mean), 2), 0.95)          # "to 0.95"
  expect_equal(sum(p$q_mean < 0.05), 95)               # "Most species (95 of 108) ... below 0.05"
  expect_equal(nrow(p), 108)
})

test_that("Session 3: occupancy and richness", {
  expect_equal(nrow(s3$occ), 10908)                    # "It has 10,908 rows"
  expect_equal(nrow(s3$occ), nrow(s3$sites) * 108)     # 101 sites x 108 species
  expect_equal(nrow(s3$sites), 101)
  expect_equal(round(mean(s3$richness$detected), 1), 22.5)   # "22.5 species detected"
  expect_equal(round(mean(s3$richness$expected), 1), 11.5)   # "the model expects only 11.5"
})

test_that("Session 3: the reserve bullets", {
  r <- s3$reserve_effects
  reserve <- filter(r, covariate == "Stream rises inside a reserve")
  modification <- filter(r, covariate == "More human modification")
  wild <- filter(reserve, local_status == "wild")
  expect_equal(nrow(wild), 81)                         # "the 81 wild species"
  expect_equal(sum(wild$lower > 0), 5)                 # "for only 5 of the 81"
  expect_equal(sum(reserve$upper < 0), 1)              # one species (Nectogale elegans) is credibly less likely
  expect_equal(filter(reserve, upper < 0)$species, "Nectogale elegans")
  expect_equal(round(cor(reserve$estimate, log10(reserve$body_mass)), 2), 0.04)    # no link with body mass
  expect_equal(nrow(modification), 91)                 # "of the 91 species"
  expect_equal(sum(modification$lower > 0 | modification$upper < 0), 2)   # "only 2 of the 91"
  dom <- filter(reserve, local_status != "wild")
  expect_equal(sum(dom$lower > 0), 0)                  # "little or no reserve effect" for domestic animals
})

test_that("Session 3: the associations", {
  a <- s3$assoc
  expect_equal(nrow(a), 236)                           # "236 pairs"
  expect_equal(sum(a$median < 0), 0)                   # "none of them is negative"
  top <- slice_max(a, median, n = 1)
  expect_setequal(c(top$species_a, top$species_b), c("Rattus nitidus", "Rattus tanezumi"))   # the strongest
  dhole <- filter(a, species_a == "Cuon alpinus" | species_b == "Cuon alpinus")
  expect_gt(nrow(dhole), 0)                            # the closing question has an answer
})
