# The numbers hard-coded in the prose of Session 3, checked against the session's own code.
# The chunks are run in the session's own objects, so if one of these fails, the sentence
# that quotes the number needs rewriting, not just the test.
root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
.libPaths(c(file.path(root, "Rlib"), .libPaths()))
suppressPackageStartupMessages(library(tidyverse))

rmd <- readLines(file.path(root, "03-many-species.Rmd"))
chunk <- function(label) {   # the code of one chunk, as in test-session2-exercises.R
  start <- grep(paste0("^```\\{r ", label, "[,}]"), rmd)
  end <- start + which(rmd[(start + 1):length(rmd)] == "```")[1]
  rmd[(start + 1):(end - 1)]
}

# Session 3 builds its tables from the full mammal fit, which is not in git.
skip_if_not(file.exists(file.path(root, "fits", "fit_Mammal_d4_community_1b4a2cd_10k.rds")),
            "put the full mammal fit in fits/")
suppressPackageStartupMessages(library(occJSDM))

s3 <- new.env()
withr::with_dir(root, {
  for (label in c("load", "fit-tables", "convergence", "detection-rates", "occupancy", "takin", "richness",
                  "reserve-effects", "reserve-credible", "reserve-maps", "hidden-covariates", "associations")) {
    invisible(capture.output(eval(parse(text = chunk(label)), envir = s3)))
  }
})

test_that("Session 3: the number of species", {
  expect_equal(nrow(s3$fit$params), 108)               # "108 separate models", "108 mammals"
  expect_equal(ncol(s3$OTU), 108)
  expect_equal(nrow(s3$fit$diagnostics), 108)          # "With 108 species"
})

test_that("Session 3: the takin's two probabilities", {
  t <- s3$takin
  strong <- filter(t, positive_pcrs >= 13)
  weak <- filter(t, positive_pcrs >= 1, positive_pcrs <= 4)
  expect_equal(nrow(strong), 6)                                       # "the six sites ... 13 to 18 of 18"
  expect_true(all(strong$positive_pcrs <= 18) & !any(t$positive_pcrs %in% 5:12))
  expect_true(all(round(strong$cond_mean, 2) == 1))                   # "cond_mean is 1"
  expect_true(all(strong$psi_mean > 0.5 & strong$psi_mean < 0.9))     # "only 0.5 to 0.9"
  expect_equal(nrow(weak), 16)                                        # "all 16 sites with only 1 to 4"
  expect_lte(round(max(weak$cond_mean), 2), 0.15)                     # "cond_mean is <= 0.15"
  # the three areas: the south (below 25.5 N), the north (above 27.5 N), and the eastern strip between
  south <- filter(weak, Xs.2 < 25.5)
  north <- filter(weak, Xs.2 > 27.5)
  east <- filter(weak, Xs.2 >= 25.5, Xs.2 <= 27.5)
  expect_equal(c(nrow(south), nrow(east), nrow(north)), c(4, 3, 9))   # "Four ... three ... nine"
  expect_true(all(east$Xs.1 > 98.7))                                  # "the eastern strip"
  expect_lte(round(max(south$psi_mean), 2), 0.03)                     # "at most 0.03 in the south"
  expect_lte(round(max(east$psi_mean), 2), 0.08)                      # "at most 0.08 in the east"
  all_south <- filter(t, Xs.2 < 25.5)
  expect_equal(nrow(all_south), 61)                                   # "all 61 southern sites"
  expect_lte(round(max(all_south$psi_mean), 2), 0.05)                 # "never exceeds 0.05"
  expect_true(round(min(north$psi_mean), 2) >= 0.05 & round(max(north$psi_mean), 1) == 0.3)   # "between 0.05 and 0.3"
  expect_lte(round(max(north$cond_mean), 2), 0.15)                    # "between 0 and 0.15"
  expect_lt(max(weak$psi_mean), 0.5)                                  # "no weakly detected site reaches a high psi_mean"
  expect_equal(sum(north$psi_mean > 0.1), 6)                          # "6 of them are above 0.1"
  expect_lte(round(max(c(south$psi_mean, east$psi_mean)), 2), 0.08)  # the other seven are all at or below 0.08
  expect_equal(sum(weak$cond_mean > 0.1), 1)                          # "apart from one purple site at 0.15"
  expect_equal(round(max(weak$cond_mean), 2), 0.15)
})

test_that("Session 3: the convergence bullets", {
  conv <- s3$conv
  expect_equal(sum(!conv$detection_settled), 1)        # "all but 1 species"
  expect_equal(sum(!conv$effects_settled), 5)          # "for 5 species"
  expect_equal(sum(!conv$settled), 5)                  # "5 species fail one check or the other"
  expect_equal(sum(!conv$settled & conv$sites_detected <= 6), 3)   # "3 of them ... six sites or fewer"
  expect_true(all(conv$sites_detected[!conv$settled] <= 11))       # "all were detected at 11 sites or fewer"
  expect_true(filter(conv, species == "Rattus tanezumi")$settled)   # common species now settle
  expect_true(filter(conv, species == "Cuon alpinus")$settled)   # "The dhole passes both checks"
})

test_that("Session 3: the plain detection plot", {
  p <- s3$profile
  expect_equal(round(min(p$p_mean), 2), 0.17)          # "from about 0.17"
  expect_equal(round(max(p$p_mean), 2), 0.95)          # "to 0.95"
  expect_equal(sum(p$q_mean < 0.05), 95)               # "Most species (95 of 108) ... below 0.05" (unchanged at 10,000 + 10,000)
  expect_equal(nrow(p), 108)
})

test_that("Session 3: occupancy and richness", {
  expect_equal(nrow(s3$occ), 10908)                    # "It has 10,908 rows"
  expect_equal(nrow(s3$occ), nrow(s3$sites) * 108)     # 101 sites x 108 species
  expect_equal(nrow(s3$sites), 101)
  expect_equal(round(mean(s3$richness$detected), 1), 22.5)   # "22.5 species detected"
  expect_equal(round(mean(s3$richness$expected), 1), 11.4)   # "the model expects only 11.4"
})

test_that("Session 3: the reserve bullets", {
  r <- s3$reserve_effects
  reserve <- filter(r, covariate == "Stream rises inside a reserve")
  modification <- filter(r, covariate == "More human modification")
  wild <- filter(reserve, local_status == "wild")
  expect_equal(nrow(wild), 91)                         # "the 91 wild species"
  expect_equal(sum(wild$lower > 0), 9)                 # "for only 9 of the 91"
  expect_equal(sum(reserve$upper < 0), 1)              # one species (Nectogale elegans) is credibly less likely
  expect_equal(filter(reserve, upper < 0)$species, "Nectogale elegans")
  expect_equal(round(cor(reserve$estimate, log10(reserve$body_mass)), 2), 0)       # no link with body mass
  expect_equal(nrow(modification), 103)                # "of the 103 species"
  expect_equal(sum(modification$lower > 0 | modification$upper < 0), 5)   # "only 5 of the 103"
  dom <- filter(reserve, local_status != "wild")
  expect_equal(sum(dom$lower > 0), 0)                  # "no credible reserve effect" for domestic animals
  nine <- filter(wild, lower > 0)
  expect_setequal(nine$species, c("Paradoxurus hermaphroditus", "Callosciurus quinquestriatus", "Callosciurus phayrei",
                                  "Atherurus macrourus", "Cynopterus brachyotis", "Eonycteris spelaea",
                                  "Nycticebus bengalensis", "Macaca assamensis", "Petaurista yunanensis"))   # the nine, named
  expect_equal(round(exp(range(nine$estimate))), c(5, 25))           # "about 5 (the flying squirrel) to 25 (the civet)"
  expect_equal(nine$species[which.min(nine$estimate)], "Petaurista yunanensis")
  expect_equal(nine$species[which.max(nine$estimate)], "Paradoxurus hermaphroditus")
  expect_true(all(nine$lower < 1.6))                                 # "their lower ends are close to zero"
  expect_equal(sum(wild$lower <= 0 & wild$upper >= 0), 81)           # "the other 81 wild species"
  ranked <- mutate(reserve, rank = rank(-estimate))                  # 1 = top of the figure
  bottom_half <- ranked$rank > nrow(ranked) / 2
  expect_equal(sum(bottom_half & ranked$local_status == "dom"), 8)          # "8 of the 9 domestic species"
  expect_equal(sum(ranked$local_status == "dom"), 9)
  expect_true(all(bottom_half[ranked$local_status == "wild_or_dom"]))       # "all 3 that can be wild or domestic"
  expect_equal(sum(ranked$local_status == "wild_or_dom"), 3)
  credible_mod <- filter(modification, lower > 0 | upper < 0)
  expect_equal(sum(credible_mod$upper < 0), 4)                       # "Four are less likely"
  expect_setequal(intersect(filter(credible_mod, upper < 0)$species, nine$species),
                  c("Paradoxurus hermaphroditus", "Callosciurus quinquestriatus", "Macaca assamensis"))   # "three of those four"
  expect_equal(filter(credible_mod, lower > 0)$species, "Capra hircus")   # "the goat ... is more likely"
})

test_that("Session 3: where the nine reserve species live", {
  corner <- s3$site_reserve |>
    left_join(s3$sites, by = "Site") |>
    mutate(sw_corner = Xs.1 < 97.9 & Xs.2 < 25)                      # "the far southwest corner"
  expect_equal(sum(corner$sw_corner), 18)                             # "18 of the 101 sites"
  expect_equal(nrow(corner), 101)
  expect_equal(sum(corner$sw_corner & corner$reserve == "inside a reserve"), 12)   # "12 of them inside a reserve"
  likely <- s3$occ |>
    filter(species %in% s3$nine, cond_mean > 0.5) |>
    left_join(corner, by = "Site")
  by_species <- likely |>
    group_by(species) |>
    summarise(n = n(), in_corner = sum(sw_corner), corner_inside = sum(sw_corner & reserve == "inside a reserve"))
  mostly_corner <- filter(by_species, in_corner > n / 2)
  expect_equal(nrow(mostly_corner), 7)                                # "For seven of the nine"
  expect_setequal(setdiff(s3$nine, mostly_corner$species), c("Macaca assamensis", "Petaurista yunanensis"))
  expect_equal(c(sum(mostly_corner$corner_inside), sum(mostly_corner$in_corner)), c(61, 62))   # "61 of those 62 sites"
  others <- filter(by_species, !species %in% mostly_corner$species)
  expect_true(all(others$n - others$in_corner >= 10))                 # "likely present at many reserve sites elsewhere"
})

test_that("Session 3: the hidden covariates' site scores", {
  sc <- s3$scores
  expect_lte(mean(sc["2.5%", , ] > 0 | sc["97.5%", , ] < 0), 0.02)   # "At almost every site, the 95% interval ... crosses zero"
  h <- s3$hidden |> mutate(sw = Xs.1 < 97.9 & Xs.2 < 25)
  by_cov <- h |>
    group_by(hidden) |>
    summarise(corner = mean(score[sw]), other = mean(score[!sw]),
              inside = mean(score[reserve == "inside a reserve"]), outside = mean(score[reserve == "outside"]),
              spread = sd(score))
  one <- filter(by_cov, hidden == "hidden covariate 1")
  expect_gt(one$corner, one$other)                                        # "1 is higher in the far southwest corner"
  three <- filter(by_cov, hidden == "hidden covariate 3")
  four <- filter(by_cov, hidden == "hidden covariate 4")
  expect_gt(three$inside, three$outside)                              # "3 is higher at reserve sites"
  expect_lt(four$inside, four$outside)                                # "4 ... is lower"
  expect_equal(by_cov$hidden[which.min(by_cov$spread)], "hidden covariate 4")   # "which varies least of the four"
})

test_that("Session 3: the associations", {
  a <- s3$assoc
  expect_equal(nrow(a), 235)                           # "235 pairs"
  expect_equal(sum(a$median < 0), 0)                   # "none of them is negative"
  top <- slice_max(a, median, n = 1)
  expect_setequal(c(top$species_a, top$species_b), c("Rattus nitidus", "Rattus tanezumi"))   # the strongest
  top3 <- slice_max(a, median, n = 3)
  pairs3 <- paste(pmin(top3$species_a, top3$species_b), pmax(top3$species_a, top3$species_b))
  expect_true("Episoriculus caudatus Episoriculus leucops" %in% pairs3)   # the shrews
  expect_true("Canis lupus Cuon alpinus" %in% pairs3)                     # the dhole and Canis lupus
  dhole <- filter(a, species_a == "Cuon alpinus" | species_b == "Cuon alpinus")
  expect_gt(nrow(dhole), 0)                            # the closing question has an answer
})
