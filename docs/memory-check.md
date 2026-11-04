# Memory check

Measured on the build laptop (macOS, R 4.6.1) on 1 November 2026, with `/usr/bin/time -l`.

- Loading the full cached mammal fit (`fit_Mammal_d4_fixed.rds`, 236 MB on disk) peaks at about 0.37 GB resident memory. The loaded object is about 0.3 GB.
- The slimmed `data-derived/fit_summary.rds` is 138 KB.

Route chosen: sessions read the slim summary, which is committed to git. The full fit is optional, for anyone who wants to run the occJSDM output functions on it themselves, and would be offered as a GitHub release download. It would fit in 4 GB with room to spare.

Not yet measured: the same load inside a 4 GB Posit Cloud session, and the disk cost of copying the template project for 15 students. Doug to confirm during the dry run (Task 12).

## 4 November 2026: Session 3 builds its tables from the full fit

Doug decided that Session 3 loads the full fit and runs the occJSDM output functions live, with 4.5 GB per student. Measured on the build laptop (macOS, R 4.6.1, Accelerate BLAS, on mains power) with `/usr/bin/time -l` on `fit_Mammal_d4_community_1b4a2cd_10k.rds` (235 MB on disk, 287 MB loaded):

- Loading the fit, then `computeConditionalOccupancyProbs()`, `computePredictiveOccupancyProbs()` and `returnConvergenceDiagnostics()`: peak 0.75 GB resident, 9 seconds.
- Adding `returnResidualCorrelationMatrix()`: peak 3.2 GB resident (3.07 GB footprint), 14 seconds in all. The function builds every correlation for every draw (10,000 x 108 x 108, about 0.9 GB) and `apply()` copies it while taking the quantiles. The memory is released afterwards.

Not yet measured: the same on Posit Cloud (Linux, reference BLAS), in a session that already holds objects from earlier sessions. Taking the quantiles one species at a time in occJSDM would cut the peak below 1 GB with identical output, but would move the workshop pin; deferred until after the workshop unless the Posit Cloud test runs out of memory.
