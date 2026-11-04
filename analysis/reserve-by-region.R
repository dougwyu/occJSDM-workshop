# Where does the mammal fit's reserve effect come from?
# Reads the derived files only; prints the numbers quoted in REFIT-NOTES.md
# ("Where the reserve effect comes from"). Run from the repository root.
# Detections here are raw: a site counts if any PCR of the species was positive,
# so false positives are included.

suppressMessages(library(dplyr))

fit_summary <- readRDS("data-derived/fit_summary.rds")
species <- read.csv("data-derived/species.csv")
info <- read.csv("data-derived/info.csv")
otu <- read.csv("data-derived/OTU.csv", check.names = FALSE)  # rows match info

sites <- info |>
  distinct(Site, streamOrigin, Regional_Division,
           Human_modification_1km, Percent_of_forest_cover_1km)

cat("Habitat by region and reserve (site means)\n")
sites |>
  group_by(Regional_Division, streamOrigin) |>
  summarise(n = n(),
            human_modification = round(mean(Human_modification_1km), 2),
            forest_cover = round(mean(Percent_of_forest_cover_1km), 2),
            .groups = "drop") |>
  print()

detected_sites <- function(otu_id) unique(info$Site[otu[[otu_id]] > 0])

# the model's coefficient is for "outside"; the reserve effect is its negative
reserve <- fit_summary$effects |>
  filter(covariate == "streamOriginoutsideGLGS") |>
  transmute(otu_id, effect = -mean, lower = -hi, upper = -lo) |>
  left_join(fit_summary$diagnostics, by = "otu_id") |>
  left_join(select(species, otu_id, order, body_mass, local_status), by = "otu_id") |>
  filter(local_status == "wild", rhat_detection < 1.1, rhat_effects < 1.1) |>
  mutate(call = case_when(lower > 0 ~ "positive",
                          upper < 0 ~ "negative",
                          TRUE ~ "neither"))

reserve$n_sites <- sapply(reserve$otu_id, \(o) length(detected_sites(o)))
reserve$n_southwest <- sapply(reserve$otu_id, \(o)
  sum(sites$Regional_Division[match(detected_sites(o), sites$Site)] == "Southwest"))

cat("\nSettled wild species by call\n")
reserve |>
  group_by(call) |>
  summarise(n = n(),
            median_sites = median(n_sites),
            southwest_share = round(sum(n_southwest) / sum(n_sites), 2),
            median_mass_g = round(median(body_mass, na.rm = TRUE))) |>
  print()

cat("\nWithin the Southwest: share of sites with a detection, inside and outside a reserve\n")
southwest <- filter(sites, Regional_Division == "Southwest")
reserve |>
  filter(call != "neither") |>
  arrange(desc(effect)) |>
  rowwise() |>
  mutate(inside = round(mean(southwest$Site[southwest$streamOrigin == "insideGLGS"] %in% detected_sites(otu_id)), 2),
         outside = round(mean(southwest$Site[southwest$streamOrigin == "outsideGLGS"] %in% detected_sites(otu_id)), 2)) |>
  ungroup() |>
  select(species, order, n_sites, effect, lower, upper, inside, outside) |>
  mutate(across(c(effect, lower, upper), \(x) round(x, 2))) |>
  print(width = 200)
