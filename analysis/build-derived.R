# Rebuild data-derived/ from the Gaoligongshan archive (Zenodo 10.5281/zenodo.17113196).
# Set WORKSHOP_RAW to the folder that holds `data/` (default data-raw). The mammal input
# is the reshape in occJSDM_Ecoletts/R/prep_mammal.R (counts y out of K become y ones
# and K - y zeros, which keeps the two-stage likelihood exact).
raw <- Sys.getenv("WORKSHOP_RAW", unset = "data-raw")
tab <- list.files(raw, pattern = "^SP_withBODYSIZE.txt$", recursive = TRUE, full.names = TRUE)[1]
stopifnot(!is.na(tab))
sp <- read.delim(tab, stringsAsFactors = FALSE, na.strings = c("", "NA"))
m <- readRDS("data-derived/mammal_input.rds")
sp <- sp[match(colnames(m$data$OTU), sp$otuID), ]
stopifnot(!anyNA(sp$otuID))
parts <- strsplit(sp$otuID, "_", fixed = TRUE)
status <- data.frame(
  otu_id = sp$otuID,
  species = sp$species,
  class = vapply(parts, `[`, "", 1),
  order = vapply(parts, `[`, "", 2),
  family = vapply(parts, `[`, "", 3),
  iucn = sp$IUCN,
  china_red_list = sp$China_redlist,
  local_status = sp$status,
  body_mass = suppressWarnings(as.numeric(sp$AdultBodyMass)),
  stringsAsFactors = FALSE
)
saveRDS(status, "data-derived/species_status.rds")
