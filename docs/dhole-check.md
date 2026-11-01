# Dhole acceptance check (Task 6)

Run on 1 November 2026 from the cached fit (`analysis/dhole-check.R`, draws from `fit_Mammal_d4_fixed.rds`). **Verdict: pass, with a caution about what to teach.**

## What the fit says about the dhole (*Cuon alpinus*)

- The dhole's chains have settled: the largest R-hat is 1.002 for its detection parameters and 1.03 for its occupancy effects (occJSDM's `returnConvergenceDiagnostics()`). That is not true of every species in this fit; see `docs/instructor-notes.md`. True-positive rate 0.55 (95% interval 0.46 to 0.64), false-positive rate 0.023 (0.013 to 0.034).
- 41 of the 101 sites have at least one positive PCR. The model puts the probability of presence given the detections above 0.9 at 13 sites, between 0.5 and 0.9 at 2, between 0.1 and 0.5 at 13, and at or below 0.1 at 73. So it is confident about most sites: 13 are near-certainly occupied and 73 near-certainly empty, and the other 15 sites are uncertain (13 between 0.1 and 0.5, and 2 between 0.5 and 0.9). Most single detections are explained as false positives or chance. This is the "certainty about the right thing" the workshop wants to show.
- The occupancy probability psi at each site (from the covariates plus the hidden site effects, before the dhole's own detections there are weighed) is much less certain. The median 95% interval is 0.46 wide, against a 10th to 90th percentile spread of 0.58 in the site means. Sites can be ranked only coarsely.
- Covariate effects (logit scale, 95% interval): the Southwest region is clearly negative (-4.4, -7.5 to -1.7), annual precipitation is positive but only just clear of zero (0.86, 0.02 to 1.9), and the other seven effects include zero.

## What to teach

Teach the dhole through the detections and the probability of presence at each site, plus the regional pattern from this fit. Do not teach it as a clean covariate-response example: the covariate effects are mostly uncertain, and that is a fair thing to say aloud.

Per-site intervals for the probability of presence given detections are not available, because the stored fit keeps only their posterior means. The intervals above are for psi, which includes the hidden site effects estimated from the survey, so it is not a covariate-only prediction.

Leads if you want an alternative: Gongshan muntjac, gaur, leopard cat. They have not been run through this check.
