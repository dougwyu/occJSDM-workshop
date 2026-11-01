source(testthat::test_path("..", "setup", "pins.R"))
source(testthat::test_path("..", "setup", "check-setup.R"))
use_workshop_lib()

test_that("every required package is installed and occJSDM is at the pinned commit", {
  expect_true(check_setup(quiet = TRUE))
  expect_equal(installed_sha(), PIN_OCCJSDM)
})

test_that("the data fallback copies a local archive instead of downloading", {
  source(testthat::test_path("..", "setup", "01-download-data.R"))
  src <- withr::local_tempdir()
  dir.create(file.path(src, "data"))
  writeLines("x", file.path(src, "data", "marker.txt"))
  dest <- withr::local_tempdir()
  fetch_data(dest = dest, copy_from = src)
  expect_true(file.exists(file.path(dest, "data", "marker.txt")))
})
