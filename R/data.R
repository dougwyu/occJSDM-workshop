# Data layer: the mammal input, species status, and site covariates.
# Everything is joined by name, never by row position.

workshop_root <- function(start = getwd()) {
  d <- normalizePath(start)
  while (!file.exists(file.path(d, "occJSDM-workshop.Rproj"))) {
    parent <- dirname(d)
    if (parent == d) stop("Run this from inside the occJSDM-workshop project.")
    d <- parent
  }
  d
}

derived_path <- function(...) file.path(workshop_root(), "data-derived", ...)

# The reshaped mammal input: one row per PCR replicate in `info`, a 0/1 matrix `OTU`.
load_mammal <- function() {
  x <- readRDS(derived_path("mammal_input.rds"))
  list(
    info = x$data$info,
    OTU = x$data$OTU,
    K = x$K,
    occCovariates = x$occCovariates,
    collCovariates = x$collCovariates
  )
}

# One row per species, with the taxonomy read from the OTU label and the status fields.
species_status <- function() {
  tibble::as_tibble(readRDS(derived_path("species_status.rds")))
}

# One row per site, ordered by site name, from the site-level occupancy covariates.
site_covariates_from <- function(info, covariates) {
  keep <- unique(c("Site", covariates, "Xs.1", "Xs.2"))
  site <- info[!duplicated(info$Site), keep, drop = FALSE]
  site <- site[order(site$Site), , drop = FALSE]
  rownames(site) <- NULL
  tibble::as_tibble(site)
}

site_covariates <- function() {
  m <- load_mammal()
  site_covariates_from(m$info, m$occCovariates)
}

# Site by species presence: 1 if any PCR replicate at the site was positive.
site_presence <- function(m = load_mammal()) {
  y <- rowsum(m$OTU, m$info$Site) > 0
  storage.mode(y) <- "integer"
  y
}

# The mammal data reduced to the dhole alone, in the layout runOccJSDM and the MCP accept.
dhole_input <- function(m = load_mammal()) {
  col <- grep("Cuon_alpinus", colnames(m$OTU), value = TRUE)
  stopifnot(length(col) == 1)
  list(info = m$info, OTU = m$OTU[, col, drop = FALSE])
}
