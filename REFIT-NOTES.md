# Refit at occJSDM 1b4a2cd: what changes in the session text

Made on 4 Nov 2026 on branch `claude/adoring-haslett-482c8c`. The workshop now pins occJSDM 1b4a2cd, where `b0_prior` defaults to "community" for multi-species data. The mammal fit has twice the chain length of the old one: 10,000 burn-in and 10,000 iterations per chain, keeping every second draw. Every derived file the sessions read has been rebuilt from it, and the tests now pin the new numbers. The four session Rmd files were not edited. This file lists every sentence in them that the new numbers make wrong, with the line number at commit 34e55ef, the old text and the new value. Chunk outputs (tables, plots) update themselves; only prose, code that names the fit file, and plot titles are listed.

**Re-pinned to v0.3.0 on 5 Nov 2026.** `setup/pins.R` now pins occJSDM `5cba0db` (`v0.3.0-beta`), so `packageVersion("occJSDM")` reports 0.3.0 rather than 0.2.0. The fits and derived files were made at 1b4a2cd and were not rebuilt: the only package-code change between the two commits is the WAIC quadrature fix (4326682), which the sessions do not call. Checked on the laptop by rendering all four sessions at each pin with `WORKSHOP_NO_MCP=1`: every figure and every line of text was identical, apart from temporary file paths and chain timings in Session 2's live fit. The workshop tests pass at the new pin (59 tests, 0 failures, the 4 render tests skipped because the renders were run separately). File names and notes below that say 1b4a2cd still describe where the fits were made.

**Session 2's saved fits now come from Posit Cloud (5 Nov 2026).** With the same seed, a fit on Posit Cloud (Linux, OpenBLAS) is not identical to one on the macOS laptop (Accelerate), and students fit live on Cloud. So `data-derived/dhole_fit.rds` and `data-derived/simulated_fit.rds` were replaced by the fits from a Cloud render of Session 2 at `5cba0db`, and the text and tests now follow the Cloud numbers: about 17 sites in total (was 18), a 20% baseline (was 21%), absent sites up to just under 0.5 and detected sites from about 0.85, and 2 of 16 parameters flagged (`p` and `q`; the rain effect's `rhat` is 1.002, against 1.03 on the laptop). Do not rebuild these two files on the laptop with `analysis/build-session-data.R` or `analysis/build-simulated-fit.R`: that would bring back the laptop fits and the tests would fail. Rebuild them on Cloud instead.

## What changed most

- **The reserve story in Session 3 does not survive.** With the fixed prior, 51 of 68 settled wild species were credibly more likely present where the stream rises inside a reserve. With the community prior, 9 of 91 are, and one species (*Nectogale elegans*) is credibly less likely. The wild species' mean reserve effect fell from about 2.2 to 0.3 on the log-odds scale. This is the prior, not chance or chain length: the 18 Oct PR 36 community fit and the 5,000 + 5,000 fit at this pin give the same picture (9 and 10 of 108 species credibly positive, against 73 of 108 for the fixed fit). Under the fixed prior every species' intercept was pulled towards 50% occupancy, and the reserve covariate absorbed much of the difference for rare species.
- **The dhole's Southwest effect no longer excludes zero** in the mammal-wide fit (now -1.09, 95% interval -3.77 to 1.65; it was -4.45, -7.54 to -1.68). All 9 of its mammal-wide intervals now cross zero, as in the one-species fit.
- **Convergence is much better.** Only 5 species fail a check, not 30, and all 5 were detected at 11 sites or fewer. The community mean `mu_b0` has R-hat 1.0002 (upper limit 1.0005) and ESS 197. 8 of the 1,729 parameters in `returnConvergenceDiagnostics()` have R-hat above 1.1.
- **Session 4's plans put two in three to three in four of their sites inside a reserve**, not four in five, and several plan counts change.
- **Session 2's one-species fit changes a little**, because the new pin seeds each chain separately (the prior is unchanged; see "Fits" below).

## Did the longer run change the findings of the 5,000 + 5,000 fit?

The first refit at this pin (5,000 burn-in + 5,000 kept, `fit_Mammal_d4_community_1b4a2cd.rds`) was replaced by this one because `mu_b0` had R-hat 1.04 and ESS 104. Compared with it:

- **Reserve effect:** the same conclusion, slightly stronger. 9 of 91 settled wild species are credibly positive (was 5 of 81); still one credibly negative (*Nectogale elegans*); wild mean effect 0.31 (was 0.15). More species are counted because more have settled chains.
- **Dhole's Southwest effect:** still crosses zero (-1.09, -3.77 to 1.65; was -1.18, -4.20 to 1.72).
- **Unconverged species:** 5, down from 17. *Bos taurus*, *Capra hircus* and *Niviventer huang*, the common species on the 17-species list, now pass. The 5 left are all rare.
- **Session 4:** Plan 1 still meets 32 targets. The rest moved: threatened species meeting their target go from 3 to 4 (was 4 to 5); the two plans share 17 sites (was 16); Plan 3 affords 32 sites (was 31); Plan 4 changes 7 sites (was 4); reserve shares are 0.65 to 0.73 (was 0.65 for all four).
- **Unchanged within rounding:** detection rates, richness (11.4, was 11.5), the strongest associations, and the dhole's agreement between the two fits (0.96).

## Session 2 (`02-dhole.Rmd`)

Session 2 does not read the mammal fit; these changes come from the new pin alone. Line numbers are those of the edited file on 5 Nov 2026, which added the rain-effect traceplot (8 lines after line 686); entries that moved also give their line at 34e55ef.

- ~~Line 426: "The model's answer is about 1.7 sites". New: about 1.8 sites (1.78).~~
- ~~Line 427: "the model expects the dhole at about 17 sites, against the 41 where it was detected". New: about 18 sites (17.6); 41 is unchanged.~~
- ~~Line 451: "An average, reference site has about a 20% chance of holding the dhole, but the 95% interval is wide: 0.08 to 0.37." New: about 21% (0.21), interval 0.08 to 0.38.~~
- ~~Line 656: "Only 2 parameters out of 16 in this model fit break the `rhat` or `ess` rule." New: 3 parameters out of 16.~~
- ~~Line 667 (question, no change needed): "Which of the two rules does each one break?" The answer is now different: `p` and `q` break only the `ess` rule (`rhat` 1.00 for both, `ess` 215 and 203).~~
- ~~Line 669: "The flagged parameters here are the lab detection and false-positive rates, `p` and `q`." New flagged set: the effect of rain on collection (`beta_theta`, `PrevDayRain`: `rhat` 1.03, `ess` 1055) and `p` and `q` (`rhat` 1.00, `ess` 215 and 203). The traceplot of `p` still shows a flagged parameter, for its low `ess`.~~
- ~~Line 678 (code comment): "flagged: rhat above 1.01 and ess below 400". New: `p` is flagged for `ess` below 400 only.~~
- ~~Line 699 (was 691): "Chain 1 also makes more high excursions than chain 2. That small disagreement between the chains is what nudges `rhat` above 1.01." No longer true for `p` (`rhat` 1.00). Suggest dropping it, or moving the `rhat` point to the rain effect, which is the one parameter whose chains disagree a little.~~
- ~~Line 703 (was 695): "The flags here are small (`rhat` of 1.03, not 1.3)". Still true, but the 1.03 is now the rain effect, not `p` and `q`.~~
- Unchanged and still true: the simulated species (lines 205 to 215; the saved simulated fit is identical to the old one), lines 405 to 407 (the four possible false positives are all below 0.03, GLG39 is 0.80, GLG28 is 1.00), line 493 (collection 0.71, PCR detection 0.59: "seven times in ten", "six times in ten"), line 513 (rain's interval is still below zero: -3.38 to -0.19), line 569 (96%), and all 9 occupancy intervals crossing zero.

## Session 3 (`03-many-species.Rmd`)

- Line 40: "so we use a saved fit that I prepared earlier (5,000 burn-in and 5,000 kept iterations, two chains). If you want to run the occJSDM output functions on the full model fit, your instructor can provide it (`fit_Mammal_d4_fixed.rds`, 236 MB)." New: 10,000 burn-in and 10,000 iterations per chain, two chains, keeping every second draw (5,000 kept per chain). New file: `fit_Mammal_d4_community_1b4a2cd_10k.rds`, 235 MB. You may also want a sentence here saying that the fit uses the package's default community-mean prior on the species' baseline occupancies.
- Line 80 (from-a-fit chunk): `readRDS("fit_Mammal_d4_fixed.rds")`. New: `readRDS("fit_Mammal_d4_community_1b4a2cd_10k.rds")`. `tests/test-from-a-fit.R` now matches any `fit_Mammal_d4_*.rds` name here.
- Lines 95 to 103 (from-a-fit chunk): `returnConvergenceDiagnostics()` now also returns one row for `mu_b0`, with `label1` and `label2` both "1". The chunk's `if_else(label2 %in% species_ids, label2, label1)` gives it the `otu_id` "1", so `diagnostics` gets a 109th row. Suggest adding `filter(param != "mu_b0")` before the `mutate()` on line 98. (`analysis/build-fit-summary.R` does this, and keeps the `mu_b0` row as `fit_summary.rds$mu_b0`.)
- Line 163 (plot title): "Detection has settled for almost every species; the covariate effects have not". The second half is now an overstatement: the covariate effects have not settled for 5 species. Suggest something like "Detection has settled for almost every species, and the covariate effects for most".
- Line 167: "Detection has settled for all but 4 species." New: all but 1 species (*Micromys erythrotis*).
- Line 168: "for 29 species at least one effect has not settled." New: 5 species.
- Line 169: "Together, 30 species fail one check or the other. Half of them (15) were detected at six sites or fewer, where there is little information. But the list also includes common species such as *Rattus tanezumi*, detected at 84 sites." New: 5 species fail (all 5 fail the effects check; *Micromys erythrotis* fails both). 3 of them were detected at six sites or fewer, and all 5 at 11 sites or fewer. No common species is on the list, so the last sentence should go: the unsettled species are all rare. They are *Apodemus ilex* (3 sites), *Priapomys leonardi* (4), *Suncus murinus* (5), *Micromys erythrotis* (9) and *Trogopterus xanthipes* (11).
- Line 170: "The dhole passes both checks." Still true.
- Line 172: "do not read the covariate effects of these 30 species". New: 5.
- Line 204: "True-positive rates spread widely, from about 0.15 to 0.95." New: from about 0.17 to 0.95.
- Line 205: "Most species (96 of 108) sit at the far left". New: 95 of 108.
- Line 258: still true (the ten highest false-positive rates include the pig and cattle, and several common small mammals).
- Line 313: "On average a site had 22.5 species detected, but the model expects only 12.8." New: 22.5 detected (unchanged), 11.4 expected.
- Line 346: "set aside the 30 species whose chains have not settled". New: 5.
- Line 408 (plot title): "Most species are more likely present inside the reserves". No longer true. Suggest something like "Few species respond clearly to the reserves or to human modification".
- Line 441: "Most wild species are more likely to be present where the stream rises inside a reserve: for 51 of the 68 wild species the interval excludes zero. No species is credibly less likely to be there." New: 91 settled wild species; for only 9 of them is the interval above zero (*Atherurus macrourus*, *Nycticebus bengalensis*, *Macaca assamensis*, *Callosciurus phayrei*, *Callosciurus quinquestriatus*, *Eonycteris spelaea*, *Cynopterus brachyotis*, *Petaurista yunanensis*, *Paradoxurus hermaphroditus*), and 1 (*Nectogale elegans*, a water shrew) is credibly less likely to be there. The wild species' mean effect is 0.31, and 66% of them have a positive estimate, so the lean is towards the reserves but mostly not credibly.
- Line 442: "Threatened species are no different from common ones in this. The reserves seem to go with most of the mammal community, not with the threatened species in particular." The first sentence still holds; the second is no longer true. Threatened species (12 settled): 1 credibly positive, mean effect 0.26; not threatened (73): 7 positive, 1 negative, mean 0.26; not assessed (18): 1 positive, mean 0.04.
- Line 443: "Larger species show weaker reserve effects, not stronger ones (the correlation with body mass is -0.37)." New correlation: 0.00, so there is no link with body mass. Suggest dropping this bullet.
- Line 444: "Domestic animals show little or no reserve effect". Still true (9 domestic species, none credibly positive, mean effect -0.28), and they now contrast only mildly with the wild species' mean of 0.31.
- Line 445: "human modification has a credible effect for only 1 of the 78 species." New: 5 of the 103 species. Four are less likely with more modification (*Dacnomys millardi*, *Macaca assamensis*, *Callosciurus quinquestriatus*, *Paradoxurus hermaphroditus*), and one is more likely (*Capra hircus*, the goat).
- Line 447: "So the pattern that Session 1's ordination could not untangle is, in this model, mostly about the reserves." No longer supported. With both covariates in the model, neither has a credible effect for most species, and each has one for a handful.
- Lines 451 to 453 and 455 (cautions and the Discuss question) assume a reserve effect to be careful about. They need reframing around a weak effect for a few species.
- Line 459: "The mammal-wide fit does put one of the dhole's effects clearly away from zero." No longer true: all 9 mammal-wide intervals cross zero, as in the one-species fit.
- Line 470: "Its Southwest effect is clearly below zero." New: -1.09, interval -3.77 to 1.65.
- Line 471: "the intervals are mostly wider, not narrower". Still true.
- Line 493 (plot title "Both fits agree about where the dhole is"): still true; correlation 0.96.
- Line 526: "225 pairs have an interval that excludes zero, and none of them is negative". New: 235 pairs; still none negative.
- Line 527: "The strongest are between close relatives (the *Rattus* species), between livestock (cattle and buffalo), and between the dhole and *Canis lupus*". Cattle and buffalo (0.67) now rank 152nd of 235, out of the top ten. The top three are *Rattus nitidus* with *R. tanezumi* (0.94), the shrews *Episoriculus leucops* with *E. caudatus* (0.93), and the dhole with *Canis lupus* (0.92). The rest of the top ten are rodents and small mammals.
- Line 549 (take-away): "With human modification held fixed, most species are more likely present at reserve sites, threatened or not." No longer true.

### Where the reserve effect comes from

Added on 4 Nov 2026 after the merge, to help reframe lines 408 to 455 and 549. The numbers come from `analysis/reserve-by-region.R`, which reads only the derived files. Its detection counts are raw (a site counts if any PCR of the species was positive), so they include false positives.

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

**A possible framing for Session 3.** In the tropical Southwest, where the land outside the reserve has been cleared, forest mammals such as the slow loris, Assam macaque, porcupine, palm civet and fruit bats are found mainly where the stream rises inside the reserve. In the Northwest the forest is intact on both sides of the boundary, and in the East the habitat is similar on both sides, so the reserve shows little effect there. For most small mammals the data cannot say. The fixed-prior fit's "51 of 68" came from the prior, not the data, which is itself a teaching point. A Discuss question could ask why the model can see a reserve effect only where there are unprotected sites to compare against, and only for species detected often enough to measure it.

**Cautions.** The effect is estimated with human modification and forest cover held fixed, but in the Southwest the reserve, forest loss and human modification go together, so the model is partly splitting one contrast three ways. Several of the 9 species are hunted (loris, macaque, porcupine, civet), and less hunting inside the reserve is a plausible reason for the contrast that the 1 km human-modification index would not capture. That is a guess; the model does not test it. With 91 species and 95% intervals, about 2 or 3 would come out credibly positive by chance alone, so a few of the 9 may be false alarms. A reserve-by-region interaction would be the analysis for a paper, not for the workshop.

## Session 4 (`04-scp.Rmd`)

- Line 270: "Only 38 of the 108 species meet their target." New: 32.
- Line 346: "The two plans share 18 of their 20 sites. Swapping just 2 sites raises the number of threatened species that meet their target from 3 to 5, out of 12." New: they share 17 of their 20 sites; swapping just 3 sites raises it from 3 to 4, out of 12.
- Line 381: "it can afford 31 sites instead of 20." New: 32 sites.
- Line 424: "Leaving out the 9 domestic species keeps 99 species in the plan and changes 6 sites from Plan 3." New: changes 7 sites. Plan 4 picks 33 sites to Plan 3's 32 at the same budget. 9 and 99 are unchanged.
- Line 430: "Session 3 found that most species are more likely to be present where the stream rises inside a reserve. So we might expect the plans to pick reserve sites." The premise no longer holds (see Session 3, line 441).
- Line 456: "Only 51 of the 101 sites are inside a reserve, but every plan puts about four in five of its sites there." New: 13 of 20 for Plans 1 and 2 (0.65), 21 of 32 for Plan 3 (0.66), 24 of 33 for Plan 4 (0.73). So every plan puts two in three to three in four of its sites inside a reserve, still more than the half you would expect by chance.
- Not tested but worth knowing: Plan 2 meets 26 targets in all; Plan 3 meets 74, including 11 of the 12 threatened species; Plan 4 meets 77, including 11 of the 12.

## Session 1 (`01-why-model.Rmd`)

No changes: Session 1 reads only the data and the simulated species, and the saved simulated fit is identical to the old one.

## Fits

- **Mammal fit.** Made by `analysis/fit-mammal.R` and saved outside the repo as `/Users/douglasyu/src/occJSDM_Ecoletts/fit_Mammal_d4_community_1b4a2cd_10k.rds` (235 MB). The untouched fits next to it are:
  - `fit_Mammal_d4_fixed.rds`;
  - `fit_Mammal_d4_community.rds` (the 18 Oct PR 36 fit);
  - `fit_Mammal_d4_community_1b4a2cd.rds` (the first refit at this pin, 5,000 + 5,000).
- **Settings.** The same call and seed (20261018) as `occJSDM_Ecoletts/R/fit_mammal.R`: n_factors = 4, two chains, `b0_prior` left at its default, `ncores = 2`. The chains are twice as long: `nburn = 10000`, `niter = 5000`, `nthin = 2`. In occJSDM `niter` counts kept draws, and each chain runs `nburn + niter * nthin` = 20,000 iterations.
- **Thinning.** Keeping all 10,000 draws per chain would double the saved fit (to about 470 MB) and the memory the from-a-fit chunk needs. The fit is thinned to 5,000 kept draws per chain, so it stays at 235 MB and loads like the old one. `fit_summary.rds` holds per-species summaries, not draws, so its size does not depend on this.
- **Run.** It took 5.9 minutes (2 workers of 1 thread; each chain about 335 s) under R 4.6.1 with Apple Accelerate (vecLib) BLAS, on AC power with low power mode off (`pmset -g`: `lowpowermode 0`). The 5,000 + 5,000 refit took 3.7 minutes under the same conditions. The old fixed-prior fit used conda R 4.5.3 with OpenBLAS. The shift step accepted 45% and 44% of proposals over the kept iterations.
- **The community mean.** `mu_b0` has mean -5.70 (95% interval -6.36 to -5.09).
  - On the package's basis (all kept draws, as `returnConvergenceDiagnostics()` computes it): R-hat 1.0002, Gelman-Rubin upper limit 1.0005, ESS 197.
  - With coda's default of dropping the first half of each chain: 1.018 (upper 1.039).
  - For the 5,000 + 5,000 fit the same figures were R-hat 1.042 (upper 1.18) and ESS 104, or 1.10 (upper 1.37) with coda's default.
  - This is the centre of the species' intercepts at the covariates' reference levels, with the hidden site effects at zero. So plogis(-5.70) = 0.3% is not the community's average occupancy.
- **Parameters above R-hat 1.1:** 8 of the 1,729 in `returnConvergenceDiagnostics()` (24 at 5,000 + 5,000). No species' occupancy intercept has R-hat above 1.02.
- **Dhole fit (Session 2).** Refitted with `analysis/build-session-data.R`, which now passes `ncores = 2` like the session's own call.
  - With one species the default falls back to the fixed prior: `infos$intercept_prior` is `list(mean = 0, sd = 1)`, the same as before.
  - The result still changed, because 1b4a2cd seeds each chain separately (the parallel-chains work, PR 31). 6256791 ignored `ncores` and ran the chains one after the other from one random stream.
  - Probabilities of presence moved by at most 0.07 at any site.
  - The fit does not depend on the mammal fit. Rebuilding it with the 10k mammal fit gave identical draws, so the committed copy was kept.
- **Simulated fit (Session 2).** Rebuilt with `analysis/build-simulated-fit.R`; every part of its results is identical to the old saved fit.
- **`dhole_check.rds`.** Rebuilt with `analysis/dhole-check.R` from the new mammal fit. The verdict in `docs/dhole-check.md` (Southwest excludes zero) is now out of date.

## Test changes (old -\> new)

Every change below follows a change in the fits; no test was loosened beyond the new value.

- `tests/test-claims.R`, Session 2 results: flagged parameters `p`, `q` -\> `beta_theta`, `p`, `q`.
- `tests/test-claims.R`, saved dhole fit: `p` and `q` had R-hat above 1.01 and ESS below 400; now R-hat at most 1.01 and ESS below 400. There is a new check that the rain effect has R-hat between 1.01 and 1.05 and ESS of at least 400. Flagged count 2 -\> 3 (of 16).
- `tests/test-claims.R`, Session 3 dhole: "Southwest effect excludes zero" (`sw$hi < 0`) -\> "all 9 mammal-wide intervals cross zero". The "mostly wider" check is unchanged.
- `tests/test-claims.R`, Session 3 convergence: 4 -\> 1 (detection), 29 -\> 5 (effects), 30 -\> 5 (either), 15 -\> 3 (at six sites or fewer).
  - The check that *Rattus tanezumi* (84 sites) is unsettled is now a check that it and *Bos taurus* pass.
  - New check: every unsettled species was detected at 11 sites or fewer.
- `tests/test-claims.R`, associations: 225 -\> 235 credible pairs.
- `tests/test-session2-text.R`:
  - expected sites at undetected sites 1.7 -\> 1.8;
  - expected sites in total 17 -\> 18;
  - baseline mean 0.20 -\> 0.21, baseline upper 0.37 -\> 0.38;
  - flagged R-hat `c(1.03, 1.03)` -\> `c(1.03, 1.00, 1.00)` for `beta_theta`, `p`, `q`, plus ESS below 400 for `p` and `q`.
- `tests/test-session3-text.R`, convergence: 4 -\> 1, 29 -\> 5, 30 -\> 5, 15 -\> 3. *Rattus tanezumi* unsettled at 84 sites -\> settled; new check that every unsettled species was detected at 11 sites or fewer.
- `tests/test-session3-text.R`, detection: lowest true-positive rate 0.15 -\> 0.17; species with a false-positive rate below 0.05: 96 -\> 95.
- `tests/test-session3-text.R`, richness: expected 12.8 -\> 11.4.
- `tests/test-session3-text.R`, reserve:
  - settled wild species 68 -\> 91;
  - credibly positive 51 -\> 9;
  - credibly negative 0 -\> 1 (*Nectogale elegans*, now named in the test);
  - body-mass correlation -0.37 -\> 0.00;
  - species in the modification panel 78 -\> 103;
  - credible modification effects 1 -\> 5.
- `tests/test-session3-text.R`, associations: 225 -\> 235.
- `tests/test-session4-text.R`:
  - Plan 1 targets met 38 -\> 32;
  - shared sites 18 -\> 17, swapped sites 2 -\> 3;
  - threatened targets met by Plans 1 and 2: 3 and 5 -\> 3 and 4;
  - Plan 3 sites 31 -\> 32;
  - sites changed by Plan 4: 6 -\> 7;
  - share of each plan's sites inside a reserve 0.75 to 0.85 -\> 0.6 to 0.75.
- `tests/test-from-a-fit.R`: the chunk's file name is now matched as any `fit_Mammal_d4_*.rds`, and the test fails if the chunk does not read the fit under test.

## Other files now out of date (not changed)

- `docs/dhole-check.md`: its verdict rests on the Southwest effect excluding zero.
- `docs/design.md` (line 92), `docs/plan.md` (line 20) and `docs/mcp-feasibility.md` (line 13) still name 6256791 as the pin.
- `docs/memory-check.md` measured `fit_Mammal_d4_fixed.rds`. The new fit is the same size (235 MB) and has the same number of kept draws, so the numbers should carry over.
