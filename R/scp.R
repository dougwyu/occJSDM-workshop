# A deliberately simple systematic conservation plan on the survey sites.
# Planning units are the sites. Each species is a feature whose amount at a site is its
# probability of presence there (a posterior mean; no uncertainty is carried through).

# weights: tibble(species, weight). scheme "equal" gives 1 to every species. "redlist" uses
# the IUCN category, falling back to the China Red List, and gives species with neither a
# default weight of 1 (with a warning).
species_weights <- function(status, scheme = c("equal", "redlist")) {
  scheme <- match.arg(scheme)
  if (scheme == "equal") return(tibble::tibble(species = status$species, weight = 1))
  w_cat <- c(CR = 5, EN = 4, VU = 3, NT = 2, LC = 1, DD = 1)
  cat_used <- ifelse(!is.na(status$iucn), status$iucn, status$china_red_list)
  weight <- unname(w_cat[cat_used])
  missing <- is.na(weight)
  if (any(missing)) {
    warning(sum(missing), " species have no Red List status and get weight 1.", call. = FALSE)
    weight[missing] <- 1
  }
  tibble::tibble(species = status$species, weight = weight)
}

# occ: Site, species, cond_mean. cost: Site, cost. budget: total cost allowed.
# Minimises the weighted shortfall from each species' target (`target` of its total summed
# probability) within the budget. Species with weight 0 are left out.
build_scp <- function(occ, weights, cost, budget, target = 0.5) {
  library(prioritizr)                            # solve() is prioritizr's method for problems
  weights <- weights[weights$weight > 0, ]
  wide <- tidyr::pivot_wider(occ[occ$species %in% weights$species, ],
                             id_cols = Site, names_from = species, values_from = cond_mean)
  wide <- merge(cost, wide, by = "Site", sort = TRUE)
  wide$id <- seq_len(nrow(wide))                 # prioritizr needs a planning-unit id
  features <- weights$species
  p <- prioritizr::problem(wide, features = features, cost_column = "cost") |>
    prioritizr::add_min_shortfall_objective(budget) |>
    prioritizr::add_relative_targets(target) |>
    prioritizr::add_feature_weights(weights$weight) |>
    prioritizr::add_binary_decisions() |>
    prioritizr::add_highs_solver(gap = 0.01, time_limit = 30, verbose = FALSE)   # a near-optimal answer is enough here
  sol <- solve(p, run_checks = FALSE)
  out <- tibble::tibble(Site = sol$Site, selected = as.logical(sol$solution_1))
  attr(out, "features") <- features
  out
}

# Share of each species' total probability of presence that falls in the selected sites.
scp_coverage <- function(solution, occ) {
  occ$selected <- solution$selected[match(occ$Site, solution$Site)]
  occ |>
    dplyr::group_by(species) |>
    dplyr::summarise(held = sum(cond_mean[selected]) / sum(cond_mean), .groups = "drop")
}
