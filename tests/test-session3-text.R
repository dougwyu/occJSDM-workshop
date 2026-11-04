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

# Session 3 builds its tables from the full mammal fit, which is not in git.
skip_if_not(file.exists(file.path(root, "fits", "fit_Mammal_d4_community_1b4a2cd_10k.rds")),
            "put the full mammal fit in fits/")
suppressPackageStartupMessages(library(occJSDM))

s3 <- new.env()
withr::with_dir(root, {
  for (label in c("load", "fit-tables", "convergence", "detection-rates", "occupancy", "richness",
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
  expect_equal(sum(!conv$detection_settled), 1)        # "all but 1 species"
  expect_equal(sum(!conv$effects_settled), 5)          # "for 5 species"
  expect_equal(sum(!conv$settled), 5)                  # "5 species fail one check or the other"
  expect_equal(sum(!conv$settled & conv$sites_detected <= 6), 3)   # "3 of them ... six sites or fewer"
  expect_true(all(conv$sites_detected[!conv$settled] <= 11))       # "all were detected at 11 sites or fewer"
  expect_true(filter(conv, species == "Rattus tanezumi")$settled)   # common species now settle
  expect_true(filter(conv, species == "Cuon alpinus")$settled)   # "The dhole passes both checks"
})

test_that("Session 3: the plain detection plot", {
  p <- s3$profile
  expect_equal(round(min(p$p_mean), 2), 0.17)          # "from about 0.17"
  expect_equal(round(max(p$p_mean), 2), 0.95)          # "to 0.95"
  expect_equal(sum(p$q_mean < 0.05), 95)               # "Most species (95 of 108) ... below 0.05" (unchanged at 10,000 + 10,000)
  expect_equal(nrow(p), 108)
})

test_that("Session 3: occupancy and richness", {
  expect_equal(nrow(s3$occ), 10908)                    # "It has 10,908 rows"
  expect_equal(nrow(s3$occ), nrow(s3$sites) * 108)     # 101 sites x 108 species
  expect_equal(nrow(s3$sites), 101)
  expect_equal(round(mean(s3$richness$detected), 1), 22.5)   # "22.5 species detected"
  expect_equal(round(mean(s3$richness$expected), 1), 11.4)   # "the model expects only 11.4"
})

test_that("Session 3: the reserve bullets", {
  r <- s3$reserve_effects
  reserve <- filter(r, covariate == "Stream rises inside a reserve")
  modification <- filter(r, covariate == "More human modification")
  wild <- filter(reserve, local_status == "wild")
  expect_equal(nrow(wild), 91)                         # "the 91 wild species"
  expect_equal(sum(wild$lower > 0), 9)                 # "for only 9 of the 91"
  expect_equal(sum(reserve$upper < 0), 1)              # one species (Nectogale elegans) is credibly less likely
  expect_equal(filter(reserve, upper < 0)$species, "Nectogale elegans")
  expect_equal(round(cor(reserve$estimate, log10(reserve$body_mass)), 2), 0)       # no link with body mass
  expect_equal(nrow(modification), 103)                # "of the 103 species"
  expect_equal(sum(modification$lower > 0 | modification$upper < 0), 5)   # "only 5 of the 103"
  dom <- filter(reserve, local_status != "wild")
  expect_equal(sum(dom$lower > 0), 0)                  # "little or no reserve effect" for domestic animals
})

test_that("Session 3: the associations", {
  a <- s3$assoc
  expect_equal(nrow(a), 235)                           # "235 pairs"
  expect_equal(sum(a$median < 0), 0)                   # "none of them is negative"
  top <- slice_max(a, median, n = 1)
  expect_setequal(c(top$species_a, top$species_b), c("Rattus nitidus", "Rattus tanezumi"))   # the strongest
  dhole <- filter(a, species_a == "Cuon alpinus" | species_b == "Cuon alpinus")
  expect_gt(nrow(dhole), 0)                            # the closing question has an answer
})
