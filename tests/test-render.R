# Every session must render without the assistant, so a failed key or server never blocks a student.
# The assistant sections are plain text, so nothing in a session depends on it.
sessions <- c("01-why-model.Rmd", "02-dhole.Rmd", "03-many-species.Rmd", "04-scp.Rmd",
              # the Bahasa Indonesia translations, with the same code
              "01-why-model-id.Rmd", "02-dhole-id.Rmd", "03-many-species-id.Rmd", "04-scp-id.Rmd")

for (rmd in sessions) {
  test_that(paste(rmd, "renders"), {
    skip_if(Sys.getenv("WORKSHOP_SKIP_RENDER") == "1", "render tests skipped")
    root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
    if (startsWith(rmd, "03-many-species"))   # Session 3 reads the full mammal fit, which is not in git
      skip_if_not(file.exists(file.path(root, "fits", "fit_Mammal_d4_community_1b4a2cd_10k.rds")),
                  "put the full mammal fit in fits/")
    out <- withr::local_tempdir()
    expect_no_error(rmarkdown::render(file.path(root, rmd), output_dir = out, intermediates_dir = out,
                                      knit_root_dir = root, quiet = TRUE))
    expect_true(file.exists(file.path(out, sub("Rmd$", "html", rmd))))
  })
}

test_that("Session 2's commented-out fallback lines load the saved fits", {
  root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
  rmd <- readLines(file.path(root, "02-dhole.Rmd"))
  fallback <- sub("^# ", "", grep("^# (sim_)?fit <- readRDS\\(", rmd, value = TRUE))
  expect_setequal(fallback, c('fit <- readRDS("data-derived/dhole_fit.rds")',
                              'sim_fit <- readRDS("data-derived/simulated_fit.rds")'))
  env <- new.env()
  withr::with_dir(root, for (line in fallback) eval(parse(text = line), envir = env))
  expect_false(is.null(env$fit$results_output))
  expect_false(is.null(env$sim_fit$results_output))
})
