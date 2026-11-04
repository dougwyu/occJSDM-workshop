# Refit at occJSDM 1b4a2cd: what changes in the session text

Made on 4 Nov 2026 on branch `claude/adoring-haslett-482c8c`. The workshop now pins occJSDM 1b4a2cd, where `b0_prior` defaults to "community" for multi-species data. Every derived file the sessions read has been rebuilt, and the tests now pin the new numbers. The four session Rmd files were not edited. This file lists every sentence in them that the new numbers make wrong, with the line number at the time of writing (commit 34e55ef), the old text and the new value. Chunk outputs (tables, plots) update themselves; only prose and plot titles are listed.

## What changed most

- **The reserve story in Session 3 does not survive.** With the fixed prior, 51 of 68 settled wild species were credibly more likely present where the stream rises inside a reserve. With the community prior, 5 of 81 are, and one species (*Nectogale elegans*) is credibly less likely. The mean reserve effect fell from about 2.2 to 0.2 on the log-odds scale. This is the prior, not chance: the 18 Oct PR 36 community fit gives the same answer (9 of 108 credibly positive against 73 of 108 for the fixed fit). Under the fixed prior every species' intercept was pulled towards 50% occupancy, and the reserve covariate absorbed much of the difference for rare species.
- **The dhole's Southwest effect no longer excludes zero** in the mammal-wide fit (now -1.18, 95% interval -4.20 to 1.72; it was -4.45, -7.54 to -1.68). All 9 of its mammal-wide intervals now cross zero, as in the one-species fit.
- **Convergence is much better.** 17 species fail a check, not 30. The community mean `mu_b0` itself has R-hat 1.04 and ESS 104 (mean -5.72, 95% interval -6.32 to -5.06). No species' occupancy intercept has R-hat above 1.1.
- **Session 4's plans put about two in three of their sites inside a reserve**, not four in five.
- **Session 2's one-species fit changes a little**, because the new pin seeds each chain separately (the prior is unchanged; see "Fits" below).

## Session 2 (`02-dhole.Rmd`)

- Line 426: "The model's answer is about 1.7 sites". New: about 1.8 sites (1.78).
- Line 427: "the model expects the dhole at about 17 sites, against the 41 where it was detected". New: about 18 sites (17.6); 41 is unchanged.
- Line 451: "An average, reference site has about a 20% chance of holding the dhole, but the 95% interval is wide: 0.08 to 0.37." New: about 21% (0.21), interval 0.08 to 0.38.
- Line 656: "Only 2 parameters out of 16 in this model fit break the `rhat` or `ess` rule." New: 3 parameters out of 16.
- Line 667 (question, no change needed): "Which of the two rules does each one break?" The answer is now different: `p` and `q` break only the `ess` rule (`rhat` 1.00 for both, `ess` 215 and 203).
- Line 669: "The flagged parameters here are the lab detection and false-positive rates, `p` and `q`." New flagged set: the effect of rain on collection (`beta_theta`, `PrevDayRain`: `rhat` 1.03, `ess` 1055) and `p` and `q` (`rhat` 1.00, `ess` 215 and 203). The traceplot of `p` still shows a flagged parameter, for its low `ess`.
- Line 678 (code comment): "flagged: rhat above 1.01 and ess below 400". New: `p` is flagged for `ess` below 400 only.
- Line 691: "Chain 1 also makes more high excursions than chain 2. That small disagreement between the chains is what nudges `rhat` above 1.01." No longer true for `p` (`rhat` 1.00). Suggest dropping it, or moving the `rhat` point to the rain effect, which is the one parameter whose chains disagree a little.
- Line 695: "The flags here are small (`rhat` of 1.03, not 1.3)". Still true, but the 1.03 is now the rain effect, not `p` and `q`.
- Unchanged and still true: the simulated species (all of lines 205 to 215; the saved simulated fit is identical to the old one), lines 405 to 407 (the four possible false positives are all below 0.03, GLG39 is 0.80, GLG28 is 1.00), line 493 (collection 0.71, PCR detection 0.59: "seven times in ten", "six times in ten"), line 513 (rain's interval is still below zero: -3.38 to -0.19), line 569 (96%), and all 9 occupancy intervals crossing zero.

## Session 3 (`03-many-species.Rmd`)

- Line 40: "your instructor can provide it (`fit_Mammal_d4_fixed.rds`, 236 MB)". New file: `fit_Mammal_d4_community_1b4a2cd.rds`, 235 MB. You may also want a sentence here saying that the fit uses the package's default community-mean prior on the species' baseline occupancies.
- Line 80 (from-a-fit chunk): `readRDS("fit_Mammal_d4_fixed.rds")`. New: `readRDS("fit_Mammal_d4_community_1b4a2cd.rds")`. `tests/test-from-a-fit.R` now matches any `fit_Mammal_d4_*.rds` name here.
- Lines 95 to 103 (from-a-fit chunk): `returnConvergenceDiagnostics()` now also returns one row for `mu_b0`, with `label1` and `label2` both "1". The chunk's `if_else(label2 %in% species_ids, label2, label1)` gives it the `otu_id` "1", so `diagnostics` gets a 109th row. Suggest adding `filter(param != "mu_b0")` before the `mutate()` on line 98. (`analysis/build-fit-summary.R` does this, and keeps the `mu_b0` row as `fit_summary.rds$mu_b0`.)
- Line 167: "Detection has settled for all but 4 species." New: all but 2 species.
- Line 168: "for 29 species at least one effect has not settled." New: 16 species.
- Line 169: "Together, 30 species fail one check or the other. Half of them (15) were detected at six sites or fewer, where there is little information. But the list also includes common species such as *Rattus tanezumi*, detected at 84 sites." New: 17 species; 7 of them were detected at six sites or fewer (fewer than half, so "Half of them" needs rewording, e.g. "7 of them"); *Rattus tanezumi* now passes both checks. Common species still on the list: *Bos taurus* (97 sites), *Capra hircus* (64), *Niviventer huang* (58). The tests now pin *Bos taurus* at 97 sites.
- Line 170: "The dhole passes both checks." Still true.
- Line 172: "do not read the covariate effects of these 30 species". New: 17.
- Line 204: "True-positive rates spread widely, from about 0.15 to 0.95." New: from about 0.17 to 0.95.
- Line 205: "Most species (96 of 108) sit at the far left". New: 95 of 108.
- Line 258: still true (the ten highest false-positive rates include the pig and cattle, and several common small mammals).
- Line 313: "On average a site had 22.5 species detected, but the model expects only 12.8." New: 22.5 detected (unchanged), 11.5 expected.
- Line 346: "set aside the 30 species whose chains have not settled". New: 17.
- Line 408 (plot title): "Most species are more likely present inside the reserves". No longer true. Suggest something like "Few species respond clearly to the reserves or to human modification".
- Line 441: "Most wild species are more likely to be present where the stream rises inside a reserve: for 51 of the 68 wild species the interval excludes zero. No species is credibly less likely to be there." New: 81 settled wild species; for only 5 of them is the interval above zero (*Macaca assamensis*, *Callosciurus phayrei*, *Suncus murinus*, *Cynopterus brachyotis*, *Petaurista yunanensis*), and 1 (*Nectogale elegans*, a water shrew) is credibly less likely to be there. The wild species' mean effect is 0.15, and 54% of them have a positive estimate.
- Line 442: "Threatened species are no different from common ones in this. The reserves seem to go with most of the mammal community, not with the threatened species in particular." The second sentence is no longer true. Threatened species (10 settled): 0 credibly positive, mean effect 0.10; not threatened (64): 4 positive, 1 negative, mean 0.08; not assessed (17): 1 positive, mean 0.16.
- Line 443: "Larger species show weaker reserve effects, not stronger ones (the correlation with body mass is -0.37)." New correlation: 0.04, so no link with body mass. Suggest dropping this bullet.
- Line 444: "Domestic animals show little or no reserve effect". Still true (7 settled domestic species, none credibly positive, mean effect -0.09), but it no longer contrasts with the wild species.
- Line 445: "human modification has a credible effect for only 1 of the 78 species." New: 2 of the 91 species (*Macaca assamensis*, less likely with more modification; *Sus scrofa*, more likely).
- Line 447: "So the pattern that Session 1's ordination could not untangle is, in this model, mostly about the reserves." No longer supported. With both covariates in the model, neither has a credible effect for most species.
- Lines 451 to 453 and 455 (cautions and the Discuss question) assume a reserve effect to be careful about. They need reframing around a weak or absent effect.
- Line 459: "The mammal-wide fit does put one of the dhole's effects clearly away from zero." No longer true: all 9 mammal-wide intervals cross zero, as in the one-species fit.
- Line 470: "Its Southwest effect is clearly below zero." New: -1.18, interval -4.20 to 1.72.
- Line 471: "the intervals are mostly wider, not narrower". Still true.
- Line 493 (plot title "Both fits agree about where the dhole is"): still true; correlation 0.96.
- Line 526: "225 pairs have an interval that excludes zero, and none of them is negative". New: 236 pairs; still none negative.
- Line 527: "The strongest are between close relatives (the *Rattus* species), between livestock (cattle and buffalo), and between the dhole and *Canis lupus*". Cattle and buffalo (0.69) now rank 144th of 236, out of the top ten. The top three are *Rattus nitidus* with *R. tanezumi* (0.95), the shrews *Episoriculus leucops* with *E. caudatus* (0.93), and the dhole with *Canis lupus* (0.92). The rest of the top ten are rodents and small mammals.
- Line 549 (take-away): "With human modification held fixed, most species are more likely present at reserve sites, threatened or not." No longer true.

## Session 4 (`04-scp.Rmd`)

- Line 270: "Only 38 of the 108 species meet their target." New: 32.
- Line 346: "The two plans share 18 of their 20 sites. Swapping just 2 sites raises the number of threatened species that meet their target from 3 to 5, out of 12." New: share 16 of their 20 sites; swapping 4 sites; from 4 to 5, out of 12.
- Line 381: "it can afford 31 sites instead of 20." Still 31.
- Line 424: "changes 6 sites from Plan 3." New: 4 sites. 99 species are still left in.
- Line 430: "Session 3 found that most species are more likely to be present where the stream rises inside a reserve. So we might expect the plans to pick reserve sites." The premise no longer holds (see Session 3, line 441).
- Line 456: "Only 51 of the 101 sites are inside a reserve, but every plan puts about four in five of its sites there." New: every plan puts about two in three there (13 of 20 for Plans 1 and 2, 20 of 31 for Plans 3 and 4). This is still more than the 51 of 101 by chance.
- Not tested but worth knowing: Plan 3 (cost by human modification) meets the target for 77 species, including all 12 threatened ones; Plan 4 meets it for 77 species, including 11 of the 12 threatened.

## Session 1 (`01-why-model.Rmd`)

No changes: Session 1 reads only the data and the simulated species, and the saved simulated fit is identical to the old one.

## Fits

- **Mammal fit.** `analysis/fit-mammal.R`, saved outside the repo as `/Users/douglasyu/src/occJSDM_Ecoletts/fit_Mammal_d4_community_1b4a2cd.rds` (235 MB), next to the untouched `fit_Mammal_d4_fixed.rds` and the 18 Oct PR 36 fit `fit_Mammal_d4_community.rds`. Settings: the same call and seed (20261018) as `occJSDM_Ecoletts/R/fit_mammal.R`, with n_factors = 4, 5,000 burn-in + 5,000 kept iterations, two chains, `b0_prior` left at its default and `ncores = 2`. It took 3.7 minutes (2 workers of 1 thread; each chain took about 200 s) under R 4.6.1 with Apple Accelerate (vecLib) BLAS, on AC power with low power mode off (`pmset -g`: `lowpowermode 0`). The old fit used conda R 4.5.3 with OpenBLAS. The shift step accepted 47% and 45% of proposals over the kept iterations.
- **The community mean.** `mu_b0` has mean -5.72 (95% interval -6.32 to -5.06), R-hat 1.04 (Gelman-Rubin upper limit 1.37) and ESS 104. Note that this is the centre of the species' intercepts at the reference levels, with the hidden site effects at zero, so plogis(-5.72) = 0.3% is not the community's average occupancy. Across all 1,729 parameters in `returnConvergenceDiagnostics()`, 24 have R-hat above 1.1.
- **Dhole fit (Session 2).** Refitted with `analysis/build-session-data.R`, which now passes `ncores = 2` like the session's own call. With one species the default falls back to the fixed prior: `infos$intercept_prior` is `list(mean = 0, sd = 1)`, the same as before. The result still changed, because 1b4a2cd seeds each chain separately (the parallel-chains work, PR 31), whereas 6256791 ignored `ncores` and ran the chains one after the other from one stream. Probabilities of presence moved by at most 0.07 at any site. The package documents that draws do not depend on `ncores` when the BLAS is single-threaded.
- **Simulated fit (Session 2).** Rebuilt with `analysis/build-simulated-fit.R`. Its probabilities of presence are identical to the old saved fit's.
- **`dhole_check.rds`.** Rebuilt with `analysis/dhole-check.R` from the new mammal fit. The verdict in `docs/dhole-check.md` (Southwest excludes zero) is now out of date.

## Test changes

Every change below follows a change in the fits; no test was loosened beyond the new value.

- `tests/test-claims.R`, Session 2 results: flagged parameters were `p`, `q`; now `beta_theta`, `p`, `q`.
- `tests/test-claims.R`, saved dhole fit: `p` and `q` had R-hat above 1.01 and ESS below 400; now R-hat at most 1.01 and ESS below 400, plus a new check that the rain effect has R-hat between 1.01 and 1.05 and ESS of at least 400. Flagged count 2 -\> 3 (of 16).
- `tests/test-claims.R`, Session 3 dhole: "Southwest effect excludes zero" (`sw$hi < 0`) is now "all 9 mammal-wide intervals cross zero". The "mostly wider" check is unchanged.
- `tests/test-claims.R`, Session 3 convergence: 4 -\> 2 (detection), 29 -\> 16 (effects), 30 -\> 17 (either), 15 -\> 7 (at six sites or fewer). The common unsettled species is now *Bos taurus* (97 sites) instead of *Rattus tanezumi* (84), and a new check says *Rattus tanezumi* passes.
- `tests/test-claims.R`, associations: 225 -\> 236 credible pairs.
- `tests/test-session2-text.R`: expected sites at undetected sites 1.7 -\> 1.8; expected sites in total 17 -\> 18; baseline mean 0.20 -\> 0.21; baseline upper 0.37 -\> 0.38; flagged R-hat `c(1.03, 1.03)` -\> `c(1.03, 1.00, 1.00)` for `beta_theta`, `p`, `q`, plus ESS below 400 for `p` and `q`.
- `tests/test-session3-text.R`, convergence: 4 -\> 2, 29 -\> 16, 30 -\> 17, 15 -\> 7; *Rattus tanezumi* (84 sites) -\> *Bos taurus* (97 sites).
- `tests/test-session3-text.R`, detection: lowest true-positive rate 0.15 -\> 0.17; species with false-positive rate below 0.05: 96 -\> 95.
- `tests/test-session3-text.R`, richness: expected 12.8 -\> 11.5.
- `tests/test-session3-text.R`, reserve: settled wild species 68 -\> 81; credibly positive 51 -\> 5; credibly negative 0 -\> 1 (*Nectogale elegans*, now named in the test); body-mass correlation -0.37 -\> 0.04; species in the modification panel 78 -\> 91; credible modification effects 1 -\> 2.
- `tests/test-session3-text.R`, associations: 225 -\> 236.
- `tests/test-session4-text.R`: Plan 1 targets met 38 -\> 32; shared sites 18 -\> 16; swapped sites 2 -\> 4; threatened targets met by Plan 1 3 -\> 4 (Plan 2 still 5); sites changed by Plan 4 6 -\> 4; share of each plan's sites inside a reserve 0.75 to 0.85 -\> 0.6 to 0.7.
- `tests/test-from-a-fit.R`: the chunk's file name is now matched as any `fit_Mammal_d4_*.rds`, and the test fails if the chunk does not read the fit under test.

## Other files now out of date (not changed)

- `docs/dhole-check.md`: its verdict rests on the Southwest effect excluding zero.
- `docs/design.md` (line 92), `docs/plan.md` (line 20) and `docs/mcp-feasibility.md` (line 13) still name 6256791 as the pin.
- `docs/memory-check.md` measured `fit_Mammal_d4_fixed.rds`. The new fit is the same size (235 MB), so the numbers should carry over.
