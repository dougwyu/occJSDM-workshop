# Cached mammal fit, reduced to the summaries the sessions use.
# The full fit is 236 MB on disk (about 0.4 GB in memory), so students read this instead.
read_fit_summary <- function() {
  readRDS(derived_path("fit_summary.rds"))
}
