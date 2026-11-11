# Instructor notes

## Timetable

Doug's slots are Tuesday and Wednesday 13.00 to 17.00 (3 h 45 min each) and Thursday and Friday 08.30 to 12.00 (3 h 15 min each). One session per slot. Each is mostly hands-on, with a short framing talk.

## What each session needs

- Session 1: ecoCopula and ggplot2. The ordination fits in a few seconds.
- Session 2: a live one-species fit with occJSDM. It takes about 7 seconds on the build laptop (2 chains, 5000 burn-in, 5000 kept). Posit Cloud will be slower and is not yet timed. If the live fit fails, the chunk prints the error and loads `data-derived/dhole_fit.rds`, a saved copy of the same fit (same settings and seed). Setting `WORKSHOP_LIVE_FIT=0` before rendering skips the live fit altogether.
- Session 3: the full mammal fit, `fits/fit_Mammal_d4_community_1b4a2cd_10k.rds` (235 MB). It is not in git (GitHub refuses files over 100 MB), so put it in the `fits/` folder of the Posit Cloud template project before copying the template for students. The session's `fit-tables` chunk runs the occJSDM output functions on it in about 15 seconds on the build laptop and peaks at about 3.2 GB, so give each student 4.5 GB and have them restart R (Session \> Restart R) at the start of the session. Session 4 does not need the fit: it reads `data-derived/occupancy_long.csv`.
- Session 4: `prioritizr` with the HiGHS solver. The four plans solve in about 10 seconds in total on the build laptop.

## What is checked and what is not

Checked on the build laptop (macOS, R 4.6.1): all sessions render with the MCP steps skipped, and the tests pass. Not yet checked: any of this on Posit Cloud, the timings there, the memory use in a 4 GB session, the MCP restored in the template project, and the MCP accepting the one-species dhole file with `n_factors = 0`. See `docs/mcp-feasibility.md`.

## Things to say aloud

- The ecoCopula biplot shows only a weak taxonomic pattern. Order explains about a fifth of the spread on axis 1 (p about 0.047 with the seed set in the session; the ordination starts from random values, and other seeds give 0.043 to 0.049). Moles and shrews are one order here, Eulipotyphla, although the archive labels the moles Soricomorpha. The session teaches students to check an impression instead of trusting colour.
- The dhole is a case where the model is confident about where the animal is, but not about why. The covariate effects are mostly uncertain. See `docs/dhole-check.md`.
- In the mammal-wide fit, detection settled (largest R-hat at most 1.1) for all but four species, but the occupancy covariate effects did not settle for 29 species, 30 in all. Half of the 30 were detected at six sites or fewer; the rest include common species such as *Rattus tanezumi* (84 sites). An earlier version of the summary checked detection only and reported four. The dhole passes both checks. A longer run would be the fix; it is not possible in class.
- `psi_mean` includes the hidden site effects estimated from the survey, so it is not a covariate-only prediction for unsurveyed sites.
- The SCP uses posterior means. The package does not yet return per-site intervals, so the plan cannot carry uncertainty through.
- 13 species have no Red List status at all. The SCP gives them weight 1 and says so.

## Exercise answers

The exercise chunks are `eval = FALSE`, so the rendered pages do not show these. The numbers come from running the chunks on the build laptop against the full mammal fit and the session's own code.

- Session 3, Exercise 1, with `my_species <- "Cuon alpinus"`:
  - The dhole's chains settled: `rhat_detection` 1.00, `rhat_effects` 1.06, detected at 41 sites.
  - At the 12 sites with 5 to 18 positive PCRs, `cond_mean` is 0.96 to 1, except GLG23060 (7 positives, `cond_mean` 0.52, `psi_mean` 0.22).
  - All 13 sites with a single positive PCR have `cond_mean` of 0.12 or less, so the model treats them as false positives. A few still have a moderate `psi_mean`: GLG13 0.43, GLG35 0.29, GLG23041a 0.25. These are the ones worth surveying again.
  - Not every weak detection is dismissed. Of the sites with 4 positive PCRs, GLG68 (0.94), GLG08 (0.88) and GLG18 (0.51) keep a high `cond_mean`, while GLG37, GLG40 and GLG67 fall to 0.26 or less.
  - Nine sites with no positive PCR have `psi_mean` above 0.1 (GLG02, GLG07, GLG21, GLG23041b, GLG23066, GLG27, GLG31, GLG33, GLG64, highest 0.27). Their `cond_mean` is 0.18 or less, because 18 negative PCRs are evidence of absence.
  - Compared with Session 2's dhole-only fit (`data-derived/dhole_fit.rds`): both treat the single-PCR sites as false positives (Session 2 gives them 0.04 or less), and both give undetected sites at most about 0.2 (Session 2's highest is GLG17, 0.24). The joint model is more confident at the 4-positive sites: GLG68 0.94 against 0.63, GLG08 0.88 against 0.36, GLG18 0.51 against 0.47. GLG23060 is about the same (0.52 against 0.54).
- Session 3, Exercise 2:
  - Forest cover (`Percent_of_forest_cover_1km`): of the 103 settled species, none is credibly more likely and 3 are credibly less likely where forest cover is higher, all livestock or partly so: cattle (*Bos taurus*, odds multiplier 0.2), buffalo (*Bubalus bubalis*, 0.4) and pig (*Sus scrofa*, 0.4).
  - Mean temperature: 11 species credibly more likely, 1 less likely. It is the covariate the most species respond to.
  - For comparison, the counts (more likely, less likely) for the other covariates: `Regional_DivisionSouthwest` 9 and 2, `streamOriginoutsideGLGS` 1 and 9 (before the flip), `Regional_DivisionNorthwest` 5 and 0, `Human_modification_1km` 1 and 4, and none for precipitation, patch density or edge density.
- Session 4, group exercise starter (Plan 1 with `psi_mean`):
  - It shares 17 of its 20 sites with Plan 1. Three sites move each way.
  - Counted with `cond_mean`, it meets 34 targets against Plan 1's 32. Students may ask why the `psi_mean` plan does better on Plan 1's own measure. `prioritizr` minimises the total weighted shortfall, not the number of targets met, so a plan that is worse on shortfall can still push a couple more species just over 50%.

## If you fall behind

Cut in this order: the species-association section of Session 3, the cost comparison in Session 4, then the MCP step in Session 2. Never cut Session 1 or the SCP itself.

## If the MCP fails

Every session works without it. Tell students to carry on with the code, and use Posit Assistant as an ordinary R helper if it connects at all.
