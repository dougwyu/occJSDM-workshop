# occJSDM workshop

Four hands-on sessions that take a real eDNA survey (Ji et al. 2025, Gaoligongshan) from raw summaries to occupancy models to a simple systematic conservation plan. They run on Posit Cloud, with the occJSDM MCP agent available through Posit Assistant.

The design is in `docs/design.md` and the build plan in `docs/plan.md`. Student setup is in `docs/student-start.md` and teaching notes are in `docs/instructor-notes.md`.

The files in `data-derived/` are committed, so the sessions need neither the raw archive nor the full fit. To rebuild them, run these from the project root, in order:

- `analysis/build-derived.R`, with `WORKSHOP_RAW` set to the unpacked Zenodo archive (`setup/01-download-data.R` fetches it). It writes `mammal_input.rds` and `species_status.rds`.
- `analysis/build-fit-summary.R`, with `WORKSHOP_FIT` set to `fit_Mammal_d4_fixed.rds`. It writes `fit_summary.rds`.
- `analysis/build-session-data.R`. It writes `dhole_input.rds`, `occupancy_long.csv` and `dhole_fit.rds`.
- `analysis/dhole-check.R`, with `WORKSHOP_FIT` set as above. It writes `dhole_check.rds`.
