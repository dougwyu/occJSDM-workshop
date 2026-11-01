# Every session must render with the MCP path skipped, so a failed key or server never blocks a student.
sessions <- c("01-why-model.Rmd", "02-dhole.Rmd", "03-many-species.Rmd", "04-scp.Rmd")

for (rmd in sessions) {
  test_that(paste(rmd, "renders with WORKSHOP_NO_MCP=1"), {
    skip_if(Sys.getenv("WORKSHOP_SKIP_RENDER") == "1", "render tests skipped")
    root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
    out <- withr::local_tempdir()
    withr::local_envvar(WORKSHOP_NO_MCP = "1")   # Session 2 therefore runs its live fit
    expect_no_error(rmarkdown::render(file.path(root, rmd), output_dir = out, intermediates_dir = out,
                                      knit_root_dir = root, quiet = TRUE))
    expect_true(file.exists(file.path(out, sub("Rmd$", "html", rmd))))
  })
}

test_that("Session 2 falls back to the saved fit when the live fit fails", {
  skip_if(Sys.getenv("WORKSHOP_SKIP_RENDER") == "1", "render tests skipped")
  root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
  out <- withr::local_tempdir()
  withr::local_envvar(WORKSHOP_NO_MCP = "1")
  # Chunks run in this environment, so this runOccJSDM is found before the package's own.
  env <- new.env()
  env$runOccJSDM <- function(...) stop("simulated failure")
  expect_no_error(rmarkdown::render(file.path(root, "02-dhole.Rmd"), output_dir = out, intermediates_dir = out,
                                    knit_root_dir = root, envir = env, quiet = TRUE))
  html <- paste(readLines(file.path(out, "02-dhole.html"), warn = FALSE), collapse = "\n")
  expect_match(html, "simulated failure")
  expect_match(html, "Using the saved copy of the same fit instead")
})
