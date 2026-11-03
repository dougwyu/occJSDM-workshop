# Session 2 fits the dhole and then the simulated species live. The text tests run the session
# with this stand-in for runOccJSDM() instead, which returns the saved copies of those two fits
# (identical to the live fits with the session's seed) and passes any later call, such as an
# exercise refit, to the real function.
saved_fits_runOccJSDM <- function(root) {
  saved <- file.path(root, "data-derived", c("dhole_fit.rds", "simulated_fit.rds"))
  calls <- 0
  function(...) {
    calls <<- calls + 1
    if (calls <= 2) readRDS(saved[calls]) else occJSDM::runOccJSDM(...)
  }
}
