# Where the workshop's fits come from

The sessions never fit the mammal model live. They read saved fits and derived files in `data-derived/`, plus the full mammal fit, which is too large for the repository. This file records how each was made, what must not be rebuilt on the laptop, and how the community-prior refit changed the story. It replaces `REFIT-NOTES.md` (deleted 7 Nov 2026), whose line-by-line list of text changes was all applied; that list and the matching test changes are in the git history (last at commit 5040c4e).

## Package version

`setup/pins.R` pins occJSDM `5cba0db` (`v0.3.0-beta`, 5 Nov 2026). The fits and derived files were made at `1b4a2cd`, where `b0_prior` defaults to "community" for multi-species data. The only package-code change between the two commits is the WAIC quadrature fix (4326682), which the sessions do not call. Rendering all four sessions at each pin with `WORKSHOP_NO_MCP=1` gave identical figures and text, apart from temporary file paths and chain timings in Session 2's live fit.

## Session 2's saved fits come from Posit Cloud

With the same seed, a fit on Posit Cloud (Linux, OpenBLAS) is not identical to one on the macOS laptop (Apple Accelerate), and students fit live on Cloud. So `data-derived/dhole_fit.rds` and `data-derived/simulated_fit.rds` come from a Cloud render of Session 2 at `5cba0db` (5 Nov 2026), and Session 2's text and tests follow the Cloud numbers: about 17 sites in total, a 20% baseline, absent sites up to just under 0.5 and detected sites from about 0.85, and 2 of 16 parameters flagged (`p` and `q`; the rain effect's `rhat` is 1.002 on Cloud, against 1.03 on the laptop).

**Do not rebuild these two files on the laptop** with `analysis/build-session-data.R` or `analysis/build-simulated-fit.R`. That would bring back the laptop fits, and the tests would fail. Rebuild them on Cloud instead.

Notes on the dhole fit:

- With one species the default prior falls back to the fixed prior: `infos$intercept_prior` is `list(mean = 0, sd = 1)`.
- Since `1b4a2cd` each chain is seeded separately (the parallel-chains work, PR 31), and `analysis/build-session-data.R` passes `ncores = 2` like the session's own call.
- The dhole fit does not depend on the mammal fit.

## The mammal fit

- **File.** Made by `analysis/fit-mammal.R` and saved outside the repo as `/Users/douglasyu/src/occJSDM_Ecoletts/fit_Mammal_d4_community_1b4a2cd_10k.rds` (235 MB). Session 3's from-a-fit chunk reads it, and the instructor provides it on request. Older fits next to it, kept untouched: `fit_Mammal_d4_fixed.rds` (fixed prior), `fit_Mammal_d4_community.rds` (the 18 Oct PR 36 fit) and `fit_Mammal_d4_community_1b4a2cd.rds` (5,000 + 5,000 at this pin).
- **Settings.** The same call and seed (20261018) as `occJSDM_Ecoletts/R/fit_mammal.R`: `n_factors = 4`, two chains, `b0_prior` left at its default, `ncores = 2`, `nburn = 10000`, `niter = 5000`, `nthin = 2`. In occJSDM `niter` counts kept draws, so each chain runs `nburn + niter * nthin` = 20,000 iterations and keeps 5,000.
- **Why thinned.** Keeping all 10,000 draws per chain would double the file (to about 470 MB) and the memory Session 3's from-a-fit chunk needs. `docs/memory-check.md` measured the fixed fit, which is the same size with the same number of kept draws, so its numbers carry over.
- **Why 10,000 + 10,000.** The first refit at this pin (5,000 + 5,000) had R-hat 1.04 and ESS 104 for the community mean `mu_b0`.
- **Run.** 5.9 minutes (2 workers of 1 thread; each chain about 335 s) under R 4.6.1 with Apple Accelerate BLAS, on AC power with low power mode off. The shift step accepted 45% and 44% of proposals over the kept iterations.
- **Convergence.** `mu_b0` has mean -5.70 (95% interval -6.36 to -5.09), R-hat 1.0002 (upper limit 1.0005) and ESS 197 on the package's basis (all kept draws, as `returnConvergenceDiagnostics()` computes it); with coda's default of dropping the first half of each chain, R-hat is 1.018 (upper 1.039). 8 of the 1,729 parameters have R-hat above 1.1, and no species' occupancy intercept is above 1.02. Only 5 species fail a session check, all detected at 11 sites or fewer.
- **Reading `mu_b0`.** It is the centre of the species' intercepts at the covariates' reference levels, with the hidden site effects at zero. So plogis(-5.70) = 0.3% is not the community's average occupancy.

Derived from the mammal fit, and rebuilt from it on 4 Nov 2026: `fit_summary.rds` (per-species summaries, with `mu_b0` kept as `fit_summary.rds$mu_b0`; `analysis/build-fit-summary.R`), the occupancy and species tables Session 4 reads, and `dhole_check.rds` (`analysis/dhole-check.R`).

## What the community prior changed

Against the old fixed-prior fit (`fit_Mammal_d4_fixed.rds`):

- **The reserve story in Session 3.** With the fixed prior, 51 of 68 settled wild species were credibly more likely present where the stream rises inside a reserve. With the community prior, 9 of 91 are, and one (*Nectogale elegans*) is credibly less likely. The wild species' mean reserve effect fell from about 2.2 to 0.3 on the log-odds scale. This is the prior, not chance or chain length: the PR 36 community fit and the 5,000 + 5,000 fit give the same picture. Under the fixed prior every species' intercept was pulled towards 50% occupancy, and the reserve covariate absorbed much of the difference for rare species.
- **The dhole's Southwest effect** no longer excludes zero in the mammal-wide fit: -1.09 (95% interval -3.77 to 1.65), was -4.45 (-7.54 to -1.68). All 9 of its mammal-wide intervals now cross zero, as in the one-species fit.
- **Convergence** is much better: 5 species fail a check, not 30.
- **Session 4's plans** put two in three to three in four of their sites inside a reserve, not four in five.

## Where the reserve effect comes from

The numbers come from `analysis/reserve-by-region.R`, which reads only the derived files. Its detection counts are raw (a site counts if any PCR of the species was positive), so they include false positives.

**The reserve boundary changes the habitat only in the Southwest.** Site means of human modification and forest cover, inside against outside a reserve:

- Northwest (13 inside, 4 outside): human modification 0.10 against 0.10, forest cover 0.96 against 0.94. Intact and lightly used on both sides.
- East (20 inside, 8 outside): human modification 0.37 against 0.40, forest cover 0.60 against 0.66. Moderately modified, but alike on both sides.
- Southwest (18 inside, 38 outside): human modification 0.27 against 0.48, forest cover 0.88 against 0.43. Most of the sites outside the reserves are here, and nearly all of the habitat difference.

The model has one reserve coefficient per species for all three regions, with no reserve-by-region interaction, so the estimate is driven by the Southwest. The 12 outside sites in the north and east add little, because they look like the inside sites there. Doug's reading: in the north and east the habitat is intact (or at least no worse) outside the reserves and human population density is low, so the reserves add little protection there.

**The 9 credibly positive species are forest mammals of the tropical Southwest.** Eight of the nine are Indo-Malayan tropical species: two fruit bats (*Cynopterus brachyotis*, *Eonycteris spelaea*), the Bengal slow loris (*Nycticebus bengalensis*, EN), the Assam macaque (*Macaca assamensis*, NT), two *Callosciurus* squirrels, the brush-tailed porcupine (*Atherurus macrourus*) and the common palm civet (*Paradoxurus hermaphroditus*), plus the Yunnan giant flying squirrel (*Petaurista yunanensis*). Compared with the 81 settled wild species with no credible effect:

- 70% of their detections are at Southwest sites, against 49%.
- They are detected at a median of 26 sites, against 9. This is probably why their intervals clear zero: they are detected often enough for the effect to be measured. Most of the 81 are rare, and "no credible effect" for them means the data cannot say, not that there is no effect.
- They are larger (median body mass 1.1 kg, against 100 g).
- Most are Least Concern, so this is not a story about threatened species.

**Raw detections within the Southwest show the effect plainly.** Share of Southwest sites with a detection, inside against outside a reserve:

- *Atherurus macrourus*: 0.83 against 0.16
- *Callosciurus quinquestriatus*: 0.78 against 0.26
- *Paradoxurus hermaphroditus*: 0.78 against 0.42
- *Petaurista yunanensis*: 0.67 against 0.37
- *Nycticebus bengalensis*: 0.56 against 0.13
- *Macaca assamensis*: 0.50 against 0.03
- *Callosciurus phayrei*: 0.44 against 0.00
- *Cynopterus brachyotis*: 0.39 against 0.03
- *Eonycteris spelaea*: 0.28 against 0.03
- *Nectogale elegans* (water shrew, credibly negative): 0.78 against 0.95. It is detected at 95 of the 101 sites and lives in streams, so it has no reason to track forest protection.

**Cautions.** The effect is estimated with human modification and forest cover held fixed, but in the Southwest the reserve, forest loss and human modification go together, so the model is partly splitting one contrast three ways. Several of the 9 species are hunted (loris, macaque, porcupine, civet), and less hunting inside the reserve is a plausible reason for the contrast that the 1 km human-modification index would not capture. That is a guess; the model does not test it. With 91 species and 95% intervals, about 2 or 3 would come out credibly positive by chance alone, so a few of the 9 may be false alarms. A reserve-by-region interaction would be the analysis for a paper, not for the workshop.

**Session 4 numbers not tested by the suite.** Plan 2 meets 26 targets in all. Since 7 Nov 2026 `cost_human` is human modification rescaled so the average site costs 1 (the 101 sites sum to 101, as in `cost_equal`), and every plan's budget is 20% of that, 20.2. This gives the same plans as the earlier 7.05 budget in raw units. Plan 3 picks 32 sites, keeps all 20 of Plan 2's, and meets 74 targets, including 11 of the 12 threatened species; Plan 4 picks 33 and meets 77. Two checks made while choosing this design: with at most 20 sites and Plan 2's real cost as the budget, the solver picks exactly Plan 2's sites, so cost only changes a plan through the budget; and a cost-blind plan given 27 sites meets 65 targets but costs about 46% more than Plan 3's 27 sites at Plan 2's money (54 targets). Which sites Plan 4 changes is fragile: the solver stops within 1% of the best plan, and across budgets Plan 4 differed from Plan 3 by 0 to 10 sites. The session counts targets met, but `prioritizr` minimises weighted shortfall; with 20 sites and less money than Plan 2's sites cost, plans met more targets (up to 39) while their weighted shortfall rose.
