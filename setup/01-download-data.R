# Fetch the Gaoligongshan archive (Zenodo) into data-raw/.
# Without internet, set WORKSHOP_DATA_COPY to a folder holding the unpacked archive.
fetch_data <- function(dest = "data-raw", copy_from = Sys.getenv("WORKSHOP_DATA_COPY", unset = "")) {
  dir.create(dest, showWarnings = FALSE, recursive = TRUE)
  if (nzchar(copy_from)) {
    ok <- file.copy(list.files(copy_from, full.names = TRUE), dest, recursive = TRUE)
    stopifnot(all(ok))
    return(invisible(dest))
  }
  if (!exists("ZENODO_RECORD")) source("setup/pins.R")
  rec <- jsonlite::fromJSON(paste0("https://zenodo.org/api/records/", ZENODO_RECORD))
  link <- rec$files$links$self[1]
  zip <- file.path(dest, "archive.zip")
  options(timeout = 1800)
  utils::download.file(link, zip, mode = "wb")
  utils::unzip(zip, exdir = dest)
  unlink(zip)
  invisible(dest)
}

# Run with `Rscript setup/01-download-data.R`. Sourcing the file only defines fetch_data().
if (sys.nframe() == 0) fetch_data() else message("fetch_data() is defined. Call it to download the archive.")
