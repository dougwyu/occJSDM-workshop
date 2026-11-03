# Rebuild data-derived/simulated_fit.rds, Session 2's saved copy of its fit to the imaginary
# species. It runs Session 2's own chunks, so the survey, call, settings and seed cannot drift
# from the live fit. Run from the project root.
source("setup/pins.R")
use_workshop_lib()
suppressPackageStartupMessages({
  library(tidyverse)
  library(occJSDM)
})

rmd <- readLines("02-dhole.Rmd")
chunk <- function(label) {   # the code of one chunk of 02-dhole.Rmd
  start <- grep(paste0("^```\\{r ", label, "[,}]"), rmd)
  end <- start + which(rmd[(start + 1):length(rmd)] == "```")[1]
  rmd[(start + 1):(end - 1)]
}

info <- read.csv("data-derived/info.csv")
live_fit <- TRUE
eval(parse(text = chunk("simulate")))
eval(parse(text = chunk("simulated-fit")))
saveRDS(sim_fit, "data-derived/simulated_fit.rds")
