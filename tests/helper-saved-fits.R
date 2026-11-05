# Session 2 fits the simulated species and the dhole live. The text tests run the session
# with this stand-in for runOccJSDM() instead, which returns the saved copies of those two fits
# (identical to the live fits on Posit Cloud with the session's seed) and passes any later call, such as an
# exercise refit, to the real function. The fits are told apart by the OTU column, so the
# order of the two in the session does not matter.
saved_fits_runOccJSDM <- function(root) {
  saved <- c(simulated = "simulated_fit.rds", dhole = "dhole_fit.rds")
  used <- character()
  function(data, ...) {
    kind <- if (identical(colnames(data$OTU), "simulated")) "simulated" else "dhole"
    if (kind %in% used) return(occJSDM::runOccJSDM(data = data, ...))
    used <<- c(used, kind)
    readRDS(file.path(root, "data-derived", saved[[kind]]))
  }
}
