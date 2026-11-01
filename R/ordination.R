# Model-based ordination of raw detections with ecoCopula, and a ggplot2 biplot.
# Needs ecoCopula and ggplot2 loaded by the caller.

# y: site by species 0/1 matrix with names. Species detected at fewer than `min_sites`
# sites are dropped first, because a stacked binomial fit is unstable for them.
fit_ordination <- function(y, min_sites = 5L, nlv = 2L) {
  loadNamespace("ecoCopula")
  n_sites <- colSums(y)
  dropped <- colnames(y)[n_sites < min_sites]
  y <- y[, n_sites >= min_sites, drop = FALSE]
  fit <- ecoCopula::stackedsdm(as.data.frame(y), ~1, data = data.frame(x = rep(1, nrow(y))),
                               family = "binomial", ncores = 1)
  ord <- ecoCopula::cord(fit, nlv = nlv)
  lv <- paste0("LV", seq_len(nlv))
  site_scores <- data.frame(Site = rownames(y), unname(as.matrix(ord$scores)), stringsAsFactors = FALSE)
  species_scores <- data.frame(otu_id = colnames(y), unname(as.matrix(ord$loadings)), stringsAsFactors = FALSE)
  names(site_scores)[-1] <- lv
  names(species_scores)[-1] <- lv
  list(site_scores = tibble::as_tibble(site_scores),
       species_scores = tibble::as_tibble(species_scores),
       dropped = dropped, n_kept = ncol(y))
}

# Sites as points coloured by `site_var` (a column of `site_data`, joined by Site).
# Species as arrows coloured by `species_var` (a column of `species_data`, joined by otu_id).
plot_biplot <- function(ord, site_data = NULL, site_var = NULL, species_data = NULL, species_var = NULL) {
  sites <- ord$site_scores
  species <- ord$species_scores
  if (!is.null(site_var)) sites <- merge(sites, site_data[, c("Site", site_var)], by = "Site", sort = FALSE)
  if (!is.null(species_var)) species <- merge(species, species_data[, c("otu_id", species_var)], by = "otu_id", sort = FALSE)
  # Put the species arrows on the same scale as the sites so both show.
  k <- 0.9 * max(abs(c(sites$LV1, sites$LV2))) / max(abs(c(species$LV1, species$LV2)))
  species$x <- species$LV1 * k
  species$y <- species$LV2 * k
  # Sites are filled circles and species are coloured arrows, so each has its own scale.
  p <- ggplot2::ggplot()
  p <- p + if (is.null(site_var)) {
    ggplot2::geom_point(data = sites, ggplot2::aes(LV1, LV2), shape = 21, fill = "grey70", colour = "white", size = 3)
  } else {
    ggplot2::geom_point(data = sites, ggplot2::aes(LV1, LV2, fill = .data[[site_var]]), shape = 21, colour = "white", size = 3)
  }
  if (!is.null(site_var) && is.numeric(sites[[site_var]])) {
    p <- p + ggplot2::scale_fill_viridis_c(name = site_var, option = "C")
  }
  p <- p + if (is.null(species_var)) {
    ggplot2::geom_segment(data = species, ggplot2::aes(x = 0, y = 0, xend = x, yend = y),
                          colour = "grey50", alpha = 0.6, arrow = grid::arrow(length = grid::unit(0.12, "cm")))
  } else {
    list(
      ggplot2::geom_segment(data = species, ggplot2::aes(x = 0, y = 0, xend = x, yend = y, colour = .data[[species_var]]),
                            alpha = 0.8, arrow = grid::arrow(length = grid::unit(0.12, "cm"))),
      ggplot2::labs(colour = species_var)
    )
  }
  p + ggplot2::coord_equal() + ggplot2::theme_minimal() +
    ggplot2::labs(x = "Latent variable 1", y = "Latent variable 2")
}
