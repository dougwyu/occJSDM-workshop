# Every session must render with the MCP path skipped, so a failed key or server never blocks a student.
sessions <- c("01-why-model.Rmd", "02-dhole.Rmd", "03-many-species.Rmd", "04-scp.Rmd")

for (rmd in sessions) {
  test_that(paste(rmd, "renders with WORKSHOP_NO_MCP=1"), {
    skip_if(Sys.getenv("WORKSHOP_SKIP_RENDER") == "1", "render tests skipped")
    root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
    out <- withr::local_tempdir()
    withr::local_envvar(WORKSHOP_NO_MCP = "1", WORKSHOP_LIVE_FIT = "0")
    expect_no_error(rmarkdown::render(file.path(root, rmd), output_dir = out, intermediates_dir = out,
                                      knit_root_dir = root, quiet = TRUE))
    expect_true(file.exists(file.path(out, sub("Rmd$", "html", rmd))))
  })
}
