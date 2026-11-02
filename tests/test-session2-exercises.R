# Session 2's exercise chunks are not run when the page is built, so run them here in the
# session's own objects and check that they produce what the questions ask students to find.
# Three refits, so this takes a minute or two.
.libPaths(c(file.path(normalizePath(testthat::test_path("..")), "Rlib"), .libPaths()))
root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
rmd <- readLines(file.path(root, "02-dhole.Rmd"))
code <- withr::local_tempfile(fileext = ".R")
knitr::purl(file.path(root, "02-dhole.Rmd"), output = code, quiet = TRUE)

chunk <- function(label) {   # the code of one chunk, whether or not it is evaluated
  start <- grep(paste0("^```\\{r ", label, "[,}]"), rmd)
  end <- start + which(rmd[(start + 1):length(rmd)] == "```")[1]
  rmd[(start + 1):(end - 1)]
}

s2 <- new.env()
withr::with_dir(root, withr::with_envvar(c(WORKSHOP_NO_MCP = "1", WORKSHOP_LIVE_FIT = "0"), {
  grDevices::pdf(NULL)
  suppressMessages(sys.source(code, envir = s2))
  for (label in c("exercise-takin", "exercise-two-samples", "exercise-no-rain")) {
    invisible(capture.output(suppressMessages(eval(parse(text = chunk(label)), envir = s2))))
  }
  grDevices::dev.off()
}))

test_that("Exercise 1: the takin's weak southern detections are judged false positives", {
  south <- s2$takin[s2$takin$positive_pcrs > 0 & s2$takin$Xs.2 < 27, ]
  expect_gte(nrow(south), 3)
  expect_true(all(south$probability < 0.05))
  north_strong <- s2$takin[s2$takin$positive_pcrs >= 13, ]
  expect_true(all(north_strong$probability > 0.99))
})

test_that("Exercise 2: dropping a sample moves some sites a lot", {
  moved <- s2$compare_two[abs(s2$compare_two$three_samples - s2$compare_two$two_samples) > 0.2, ]
  expect_gte(nrow(moved), 5)
  expect_true("GLG39" %in% moved$Site)                  # its strong third sample is gone
})

test_that("Exercise 3: without rain, blank samples after heavy rain read as absences", {
  moved <- s2$compare_rain[abs(s2$compare_rain$with_rain - s2$compare_rain$without_rain) > 0.1, ]
  dropped_blank <- moved[moved$pattern == "0, 0, 0" & moved$without_rain < moved$with_rain, ]
  expect_gte(nrow(dropped_blank), 2)
  expect_true(all(dropped_blank$rain_mm >= 19))
})
