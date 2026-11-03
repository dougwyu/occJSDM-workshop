# The numbers Session 2's text states, computed by running the session's own chunks.
# The fits are the saved copies (see helper-saved-fits.R), which are identical to the live fits
# with the session's seed when the chunks run in a plain R session. If one of these fails, the sentence that quotes it needs
# rewriting, not just the test.
.libPaths(c(file.path(normalizePath(testthat::test_path("..")), "Rlib"), .libPaths()))
root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
code <- withr::local_tempfile(fileext = ".R")
knitr::purl(file.path(root, "02-dhole.Rmd"), output = code, quiet = TRUE)

s2 <- new.env()
s2$runOccJSDM <- saved_fits_runOccJSDM(root)   # found before the package's own
withr::with_dir(root, withr::with_envvar(c(WORKSHOP_NO_MCP = "1"), {
  grDevices::pdf(NULL)
  invisible(capture.output(suppressMessages(sys.source(code, envir = s2))))
  grDevices::dev.off()
}))

test_that("the data layout: 1,818 rows, one dhole column, 101 sites of 18 PCRs, 108 mammals", {
  expect_equal(nrow(s2$d$info), 1818)
  expect_equal(dim(s2$d$OTU), c(1818, 1))
  expect_equal(nrow(s2$sites), 101)                                   # "101 sites"
  expect_true(all(table(s2$info$Site) == 18))                         # "18 PCRs at each site"
  expect_equal(ncol(s2$OTU), 108)                                     # "all 108 mammals"
})

test_that("the simulated species: the model's counts, averages and ranges", {
  s <- s2$sim_check
  means <- tapply(s$probability, s$status, mean)
  lo <- tapply(s$probability, s$status, min)
  hi <- tapply(s$probability, s$status, max)
  expect_equal(as.vector(table(s$status)[c("absent", "present, detected", "present, missed")]),
               c(55, 37, 9))                                         # "these 55 / 37 / 9 sites"
  expect_equal(round(means[["absent"]], 2), 0.14)                    # "0.14 (from 0.01 to 0.48)"
  expect_equal(round(c(lo[["absent"]], hi[["absent"]]), 2), c(0.01, 0.48))
  expect_equal(round(means[["present, detected"]], 2), 0.98)         # "0.98 (from 0.85 to 1.00)"
  expect_equal(round(c(lo[["present, detected"]], hi[["present, detected"]]), 2), c(0.85, 1))
  expect_equal(round(means[["present, missed"]], 2), 0.40)           # "0.40 (from 0.20 to 0.49)"
  expect_equal(round(c(lo[["present, missed"]], hi[["present, missed"]]), 2), c(0.20, 0.49))
  absent <- s$probability[s$status == "absent"]
  expect_gte(sum(absent > 0.4 & absent < 0.5), 3)                    # "grey dots between 0.4 and 0.5"
  expect_lt(max(absent), 0.5)
  # "about 47 or 48 sites": 47.4 with the saved fit; a fit run inside rmarkdown::render() gives
  # 47.8 (the dhole fit is identical either way), so allow both
  expect_true(sum(s$probability) > 47 & sum(s$probability) < 48)
  expect_equal(sum(s$present), 46)                                   # "The truth is 46"
  expect_equal(sum(s$positive > 0), 37)                              # "only 37"
})

test_that("the dhole: false negatives and the expected number of sites", {
  m <- s2$map_data
  expect_equal(sum(m$raw == 0), 60)                                  # "the 60 empty circles"
  expect_equal(round(sum(m$model[m$raw == 0]), 1), 1.7)              # "about 1.7 sites"
  expect_equal(round(sum(m$model)), 17)                              # "about 17 sites"
  expect_equal(sum(m$raw > 0), 41)                                   # "the 41 where it was detected"
})

test_that("the dhole: baseline occupancy", {
  b <- s2$baseline$draw
  expect_equal(round(mean(b), 2), 0.20)                              # "about one in five (0.20)"
  expect_equal(round(quantile(b, 0.025)[[1]], 2), 0.08)              # "from 0.08"
  expect_equal(round(quantile(b, 0.975)[[1]], 2), 0.37)              # "to 0.37"
})

test_that("the dhole: false-positive rates and survey design", {
  r <- s2$rates
  expect_true(all(r$mean[grepl("false-positive", r$rate)] < 0.05))   # "a few percent"
  det <- function(M, K) mean(s2$detect_site(M, K))
  expect_equal(round(det(3, 6), 2), 0.96)                            # "about 96%"
  expect_lt(det(3, 12) - det(3, 6), 0.01)                            # "beyond 6 PCRs adds almost nothing"
  expect_gt(det(6, 6) - det(3, 6), 3 * (det(3, 12) - det(3, 6)))     # "more field samples would help more"
})

test_that("the dhole: covariate effects and diagnostics", {
  e <- s2$effects
  expect_equal(nrow(e), 9)                                           # "All 9 intervals"
  expect_true(all(e$lower < 0 & e$upper > 0))                        # "cross the line"
  expect_equal(round(s2$flagged$rhat, 2), c(1.03, 1.03))             # "rhat of 1.03"
})

test_that("the maps: single positives drop out, several positives get darker", {
  m <- s2$map_data
  single <- m[round(m$raw * 18) == 1, ]
  expect_gte(mean(single$model < 0.1), 0.9)                           # "almost every site with a single positive PCR is gone"
  several <- m[round(m$raw * 18) >= 3 & m$raw < 1, ]
  expect_gt(mean(several$model > several$raw), 0.5)                   # "sites with several positive PCRs mostly get darker"
})
