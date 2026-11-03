# Teaching prep for Session 1: a drawing of how occJSDM's info and OTU tables fit together.
# Made-up values: one site, 2 field samples, 2 primers per sample, 2 PCRs per primer.

data_schematic <- function() {
  schematic <- data.frame(
    PCR = c(1, 2, 1, 2, 1, 2, 1, 2),
    Site = "GLG01",
    Sample = rep(c("GLG01-1", "GLG01-2"), each = 4),
    Primer = rep(rep(c("12S", "16S"), each = 2), 2),
    annual_precipitation = 1775,
    Human_modification_1km = 0.33,
    Filter_vol = rep(c(5.2, 4.8), each = 4),
    OTU_1 = c(1523, 2210, 874, 0, 0, 1311, 2967, 1045),   # read counts
    OTU_2 = c(0, 0, 0, 0, 3, 0, 0, 0),                    # a single weak detection
    OTU_3 = 0,
    more = ""
  )
  schematic[] <- lapply(schematic, as.character)
  schematic <- rbind(schematic, c("", rep("⋮", 9), ""))   # the table goes on

  knitr::kable(schematic, align = "c", col.names = c(names(schematic)[-11], "…")) |>
    kableExtra::kable_styling(full_width = FALSE, font_size = 13) |>
    kableExtra::column_spec(1:11, extra_css = "white-space: nowrap;") |>
    kableExtra::column_spec(1, color = "grey55", italic = TRUE) |>
    kableExtra::column_spec(8, border_left = "2px solid #444") |>
    kableExtra::row_spec(5:8, background = "#f2f2f2") |>
    kableExtra::add_header_above(c("not a column" = 1, "where the row belongs" = 3, "site covariates" = 2,
                                   "collection covariate" = 1, "one column per species" = 4)) |>
    kableExtra::add_header_above(c(" " = 1, "info" = 6, "OTU" = 4), font_size = 15, bold = TRUE)
}

# The optional traits table: one row per species, named like the OTU columns.
traits_schematic <- function() {
  traits <- data.frame(
    species = c("OTU_1", "OTU_2", "OTU_3"),
    body_mass_kg = c(15.2, 0.4, 230),
    diet = c("carnivore", "omnivore", "herbivore"),
    nocturnal = c("no", "yes", "no")
  )
  traits <- rbind(traits, c("⋮", "⋮", "⋮", "⋮"))   # one row for every OTU column

  knitr::kable(traits, align = "c", col.names = c("", names(traits)[-1])) |>
    kableExtra::kable_styling(full_width = FALSE, font_size = 13) |>
    kableExtra::column_spec(1:4, extra_css = "white-space: nowrap;") |>
    kableExtra::column_spec(1, color = "grey55", italic = TRUE) |>
    kableExtra::column_spec(2, border_left = "2px solid #444") |>
    kableExtra::add_header_above(c("row names" = 1, "numeric" = 1, "categorical" = 2)) |>
    kableExtra::add_header_above(c(" " = 1, "traits" = 3), font_size = 15, bold = TRUE)
}
