# Session 1's dhole figure, redrawn in Session 2 so students need not rerun Session 1.
# It runs Session 1's own chunks, so the two figures cannot drift apart.

session1_dhole_map <- function() {
  rmd <- readLines("01-why-model.Rmd")
  chunk <- function(label) {   # the code of one chunk of 01-why-model.Rmd
    start <- grep(paste0("^```\\{r ", label, "[,}]"), rmd)
    end <- start + which(rmd[(start + 1):length(rmd)] == "```")[1]
    rmd[(start + 1):(end - 1)]
  }

  # a fresh environment, so Session 1's objects do not overwrite Session 2's
  env <- new.env(parent = globalenv())
  for (label in c("data", "sites", "dhole-samples")) {
    capture.output(eval(parse(text = chunk(label)), envir = env))
  }
  print(eval(parse(text = chunk("dhole-figure")), envir = env))
  invisible(NULL)
}
