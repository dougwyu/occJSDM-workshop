# Rebuild the two data files that come straight from the Gaoligongshan archive
# (Zenodo 10.5281/zenodo.17113196): data-derived/mammal_input.rds and species_status.rds.
# Set WORKSHOP_RAW to the folder that holds `data/` (default data-raw). Run from the project root.
# The other derived files are built from these, in order, by build-fit-summary.R,
# build-session-data.R and dhole-check.R.
raw <- Sys.getenv("WORKSHOP_RAW", unset = "data-raw")
find_raw <- function(pattern) {
  hit <- list.files(raw, pattern = pattern, recursive = TRUE, full.names = TRUE)[1]
  if (is.na(hit)) stop("No file matching ", pattern, " under ", raw)
  hit
}

# The mammal input. Ported from occJSDM_Ecoletts/R/prep_mammal.R. The archive has one row per
# field sample with the number of positive PCRs out of K. Each count y becomes y ones and K - y
# zeros, one row per PCR replicate, which keeps the two-stage likelihood exact because no
# covariate varies between the replicates of a sample.
e <- new.env()
load(find_raw("^gaoligongshan_Mammal_data_.*[.]rda$"), envir = e)
info_s <- e$data$info
otu_s <- e$data$OTU
K <- e$data$K
stopifnot(nrow(info_s) == nrow(otu_s), all(otu_s >= 0), all(otu_s <= K), all(otu_s == round(otu_s)))
occ_cov <- c("annual_precipitation", "mean_temperature", "Human_modification_1km",
             "Percent_of_forest_cover_1km", "Patch_density_1km", "Edge_density_1km",
             "streamOrigin", "Regional_Division")
coll_cov <- c("Filter_vol", "PrevDayRain")
rep_idx <- rep(seq_len(nrow(info_s)), each = K)
info <- data.frame(Site = as.character(info_s$Site[rep_idx]),
                   Sample = as.character(info_s$SampleID[rep_idx]),
                   Primer = "12S", stringsAsFactors = FALSE)
for (v in c(occ_cov, coll_cov)) info[[v]] <- info_s[[v]][rep_idx]
info$Xs.1 <- info_s$longitude[rep_idx]
info$Xs.2 <- info_s$latitude[rep_idx]
within_rep <- rep(seq_len(K), times = nrow(info_s))
OTU <- matrix(0L, nrow = nrow(info), ncol = ncol(otu_s), dimnames = list(NULL, colnames(otu_s)))
for (j in seq_len(ncol(otu_s))) OTU[, j] <- as.integer(within_rep <= otu_s[rep_idx, j])
back <- rowsum(OTU, group = rep_idx, reorder = FALSE)
stopifnot(identical(as.vector(back), as.vector(otu_s * 1L)))   # the expansion loses nothing
saveRDS(list(data = list(info = info, OTU = OTU), occCovariates = occ_cov, collCovariates = coll_cov,
             K = K, n_sites = length(unique(info$Site)), n_species = ncol(OTU)),
        "data-derived/mammal_input.rds")

# The species table, with taxonomy read from the OTU label and the status fields.
sp <- read.delim(find_raw("^SP_withBODYSIZE.txt$"), stringsAsFactors = FALSE, na.strings = c("", "NA"))
sp <- sp[match(colnames(OTU), sp$otuID), ]
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
# The labels put the moles (Talpidae) in Soricomorpha, an older name, and the shrews in
# Eulipotyphla. Both are Eulipotyphla today, so one order would otherwise show as two.
status$order[status$order == "Soricomorpha"] <- "Eulipotyphla"
saveRDS(status, "data-derived/species_status.rds")
