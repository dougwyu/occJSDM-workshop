# Memory check

Measured on the build laptop (macOS, R 4.6.1) on 1 November 2026, with `/usr/bin/time -l`.

- Loading the full cached mammal fit (`fit_Mammal_d4_fixed.rds`, 236 MB on disk) peaks at about 0.37 GB resident memory. The loaded object is about 0.3 GB.
- The slimmed `data-derived/fit_summary.rds` is 138 KB.

Route chosen: sessions read the slim summary, which is committed to git. The full fit is optional, for anyone who wants to run the occJSDM output functions on it themselves, and would be offered as a GitHub release download. It would fit in 4 GB with room to spare.

Not yet measured: the same load inside a 4 GB Posit Cloud session, and the disk cost of copying the template project for 15 students. Doug to confirm during the dry run (Task 12).
