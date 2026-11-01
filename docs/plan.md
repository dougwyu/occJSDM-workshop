# occJSDM Workshop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build four hands-on R Markdown sessions, plus the setup around them, that run on Posit Cloud (about 4 GB RAM) from a real eDNA dataset to a simple systematic conservation plan, with the occJSDM MCP agent available through Posit Assistant.

**Architecture:** A new repository, `occJSDM-workshop`, holds one Rmd per half-day session, a small helper layer in `R/`, setup scripts, and small derived data files. Raw data come from Zenodo by script, and large cached fits are slimmed to the summaries the sessions need. Each session has an MCP-free path so a failed key or server never blocks a student.

**Tech Stack:** R, tidyverse and ggplot2, occJSDM pinned by commit, ecoCopula, vegan, prioritizr with the HiGHS solver (the solver is my choice, verify it installs), testthat, Posit Cloud, an OpenRouter key through Posit Assistant.

**Spec:** `WORKSHOP-DESIGN.md` (in this folder until Task 1 moves it to `docs/design.md` in the new repository).

## Global Constraints

- First teaching session is Tuesday 10 November 2026, 13.00. Teaching slots: Tue and Wed 13.00 to 17.00, Thu and Fri 08.30 to 12.00. About 14 hours.
- 15 students, in person, Posit Cloud sessions with about 4 GB RAM each.
- Students can read tidyverse and ggplot2 code and no more. All plots are ggplot2.
- Dataset: Ji et al. (2025) Gaoligongshan survey, Zenodo DOI 10.5281/zenodo.17113196. Mammals: 101 sites, 108 species.
- The 101 sites are the SCP planning units. No prediction over the landscape.
- Pin occJSDM to `6256791d4e16b20a5aa3cdc8252a11a8955fbb28` (main, fixed intercept prior), the commit that produced `fit_Mammal_d4_fixed.rds`. Move to `553e37c` (PR 36) only if the community-prior fit is shown instead.
- Live sessions use cached fits only. No live refits.
- Wednesday species: the dhole (*Cuon alpinus*). If it fails the acceptance check in Task 6, stop and report to Doug. Do not swap silently.
- SCP cost is `Human_modification_1km`. Weightings come from Red List status in `glgs/data/SP_withBODYSIZE.txt`. SCP uses posterior mean occupancy, and the sessions say so.
- Markdown rules (Doug edits in RStudio Visual mode): one line per paragraph, no hard wrapping, no pipe tables, escape `-\>` and `\~` in prose, short code spans, no em-dashes anywhere including commit messages.
- Commit messages end with: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`

## Review Focus

- Site order. occJSDM sorts rows by Site, the published CSVs do not. Every join to the published results or the covariates goes by site name, never by position. Test: shuffle the site rows and confirm the output tables do not change (Task 4).
- Species with no Red List match. The SCP gets a documented default weight and a printed warning, never a silent NA. Test in Task 10.
- Memory. One student loads a cached fit and builds the SCP inside 4 GB. Test in Task 5.
- MCP or key failure. Each session renders and finishes with the MCP path skipped. Test: render each Rmd with `WORKSHOP_NO_MCP=1` (Tasks 7 to 10).
- Sparse species in ecoCopula. Species detected at too few sites can break the fit. A documented filter keeps the ordination running. Test in Task 7.
- Zenodo unreachable at the venue. The setup script falls back to a copy in the shared Posit Cloud project. Test in Task 3.

---

## Schedule and cut line

Nine days remain. Work in this order, each gate reported to Doug: Tasks 1 and 2 by Wednesday 4 November, Tasks 3 to 6 by Friday 6 November, Task 7 by Sunday 8 November, Tasks 8 to 10 one per day after, Task 12 on the days before each session. If behind, cut in this order: Thursday's species-association section, then Friday's cost scenario, then the Wednesday MCP step. Never cut the Tuesday why-model session or the Friday SCP itself.

---

### Task 1: Repository skeleton

**Files:**
- Create: `~/src/occJSDM-workshop/` with `occJSDM-workshop.Rproj`, `CLAUDE.md`, `README.md`, `.gitignore`, `docs/design.md`, `docs/plan.md`
- Move: `WORKSHOP-DESIGN.md` and `WORKSHOP-PLAN.md` from `~/src/occJSDM` into `docs/`

**Interfaces:**
- Produces: the directory layout every later task writes into: `R/`, `tests/`, `setup/`, `data-derived/`, `docs/`.

- [ ] **Step 1:** Ask Doug for access to the new folder with the directory request tool, then `git init` it. `.gitignore` excludes `data-raw/`, `fits/` and `*.html`.
- [ ] **Step 2:** `.Rproj` sets `MarkdownWrap: None`. `CLAUDE.md` copies the markdown rules from the Global Constraints.
- [ ] **Step 3:** Move the two documents with `git mv`-style copies, leaving the occJSDM folder clean, and commit.

Verify: `git -C ~/src/occJSDM-workshop status --short` is empty and `git -C ~/src/occJSDM status --short | grep WORKSHOP` prints nothing.

### Task 2: MCP feasibility in the workshop project (Doug runs)

**Files:**
- Create: `docs/mcp-feasibility.md` (written)

**Interfaces:**
- Produces: a go or no-go on the MCP route inside the template project, and the exact client settings every later session quotes. The Posit Cloud check of 5 October 2026 shows the route can work, so this task confirms it in the workshop's own project.

- [x] **Step 1:** Write what is already known and the remaining checklist (done).
- [ ] **Step 2:** Doug runs the five checks in `docs/mcp-feasibility.md` and records the results. If the template copy fails, record the fallback.
- [ ] **Step 3:** Check that the pre-beta MCP runtime accepts the workshop's input data. Rebuilding that runtime on current main is a separate project and not in this plan.

The MCP has four operations only. Task 8 uses it for validate, a one-species fit and diagnostics. Tasks 9 and 10 use Posit Assistant as an ordinary R helper, not the MCP.

### Task 3: Environment and setup scripts

**Files:**
- Create: `setup/00-install.R`, `setup/01-download-data.R`, `setup/check-setup.R`, `tests/test-setup.R`

**Interfaces:**
- Produces: `check_setup(): logical`, which prints each requirement and returns TRUE only if all pass. Later tasks call it first.

- [ ] **Step 1:** Write `tests/test-setup.R` asserting that `check_setup()` is TRUE and that `packageDescription("occJSDM")$RemoteSha` equals the pinned SHA.
- [ ] **Step 2:** Implement `setup/00-install.R`: install occJSDM at the pinned SHA, plus FastGP, ecoCopula, vegan, prioritizr, the HiGHS solver package, and the tidyverse. Implement `01-download-data.R` to fetch and unpack the Zenodo archive into `data-raw/`, with a fallback to a path given by `WORKSHOP_DATA_COPY`.
- [ ] **Step 3:** Run both on a clean library on this laptop, then Doug runs them on Posit Cloud. Record install time.

Verify: `Rscript -e 'source("setup/check-setup.R"); stopifnot(check_setup())'` exits 0.

### Task 4: Data layer

**Files:**
- Create: `R/data.R`, `tests/test-data.R`, `data-derived/mammal_input.rds`, `data-derived/species_status.rds`
- Port from: `~/src/occJSDM_Ecoletts/R/prep_mammal.R`

**Interfaces:**
- Produces: `load_mammal(): list(info, OTU, K)` (the reshaped input), `species_status(): tibble(species, order, family, iucn, china_red_list, local_status, body_mass)` (order and family parsed from the OTU label such as `Mammalia_Eulipotyphla_Soricidae_...`), and `site_covariates(): tibble(Site, ...)` including `Human_modification_1km`.

- [ ] **Step 1:** Write tests: 108 species and 101 sites; `species_status()` has one row per species; a shuffled copy of the site rows gives identical joined output; the count of species with no Red List match is asserted and printed.
- [ ] **Step 2:** Implement the three functions, joining by name.
- [ ] **Step 3:** Run `Rscript -e 'testthat::test_dir("tests")'`. Expected: all pass.

### Task 5: Cached fits and memory

**Files:**
- Create: `R/fit.R`, `tests/test-fit.R`, `data-derived/fit_summary.rds`, `docs/memory-check.md`

**Interfaces:**
- Consumes: `load_mammal()`.
- Produces: `read_fit_summary(): list(occ, params, diagnostics)`, where `occ` is a tibble `(Site, species, psi_mean, cond_mean)` with one row per site and species, `params` holds detection and false-positive rates per species, and `diagnostics` holds R-hat per parameter.

- [ ] **Step 1:** Measure peak memory (resident set) of loading `fit_Mammal_d4_fixed.rds` and calling the package's output functions, on this laptop and on a 4 GB Posit Cloud session. Write the numbers in `docs/memory-check.md`.
- [ ] **Step 2:** If peak exceeds about 2 GB, build `fit_summary.rds` from the fit and have sessions use only that. Otherwise ship the full fit through a GitHub release and keep the summary for speed.
- [ ] **Step 3:** Test that `read_fit_summary()$occ` has 101 x 108 rows and values in [0, 1], and that site names match `load_mammal()`.

Verify: `docs/memory-check.md` states the 4 GB result and which route was chosen.

### Task 6: Dhole acceptance check (gate)

**Files:**
- Create: `analysis/dhole-check.R`, `docs/dhole-check.md`

**Interfaces:**
- Produces: a decision for Doug: pass or fail, with numbers.

- [ ] **Step 1:** From the stored fit, compute for *Cuon alpinus* the per-site occupancy with a 95% interval (from posterior draws, since the package returns means only) and the covariate effects with intervals.
- [ ] **Step 2:** Apply the criteria: interval narrow enough to rank sites, and at least one clear covariate effect with an interval excluding zero. Write the result and a figure to `docs/dhole-check.md`.
- [ ] **Step 3:** If it fails, stop and report with the other leads. Do not start Task 8.

### Task 7: Tuesday session, why model

**Files:**
- Create: `01-why-model.Rmd`, `R/ordination.R`, `tests/test-ordination.R`

**Interfaces:**
- Consumes: `load_mammal()`, `species_status()`, `read_fit_summary()`.
- Produces: `fit_ordination(y: matrix): list(site_scores, species_scores)` and `plot_biplot(ord, site_colour, species_colour): ggplot`.

- [ ] **Step 1:** Write tests: `fit_ordination()` returns scores for every kept species and site; species detected at fewer than the documented minimum number of sites are dropped and reported; `plot_biplot()` returns a ggplot.
- [ ] **Step 2:** Implement with ecoCopula (a stacked binomial fit on site presence, then `cord()`), using site presence from any positive PCR. Check the installed ecoCopula's function names.
- [ ] **Step 3:** Write the Rmd: composition summary, the biplot coloured by site covariate and by taxonomic order, a table of naive against model occupancy for the pig, cattle and dhole, and a closing page on why a detection is not a presence. Include an `MCP optional` box that is skipped when `WORKSHOP_NO_MCP=1`.
- [ ] **Step 4:** Check Doug's recollection that species loadings show a taxonomic pattern. If not, state it and colour by covariate only.

Verify: `WORKSHOP_NO_MCP=1 Rscript -e 'rmarkdown::render("01-why-model.Rmd", quiet = TRUE)'` exits 0 and the rendered HTML has the biplot.

### Task 8: Wednesday session, the dhole

**Files:**
- Create: `02-dhole.Rmd`

**Interfaces:**
- Consumes: `read_fit_summary()`, the Task 6 outputs.

- [ ] **Step 1:** Write the Rmd: the two-stage data layout, how to read a convergence table, the dhole's covariate effects, its detection and false-positive rates, and a map of occupancy at the 101 sites. Plots use ggplot2.
- [ ] **Step 2:** End with an MCP step that repeats the workflow through Posit Assistant, quoting the settings from Task 2, and an MCP-free path.

Verify: render with `WORKSHOP_NO_MCP=1`, exit 0.

### Task 9: Thursday session, many species

**Files:**
- Create: `03-many-species.Rmd`, `data-derived/occupancy_long.csv`

**Interfaces:**
- Produces: `occupancy_long.csv`, one row per site and species with `cond_mean`, the input to Task 10.

- [ ] **Step 1:** Write the Rmd: diagnostics across species, species associations (cut line item), richness per site and by taxonomic order computed by hand, and export of the long table.
- [ ] **Step 2:** Add MCP questions to the cached fit, with the skip path.

Verify: render, exit 0, and `nrow(read.csv("data-derived/occupancy_long.csv")) == 101 * 108`.

### Task 10: Friday session, the SCP

**Files:**
- Create: `04-scp.Rmd`, `R/scp.R`, `tests/test-scp.R`

**Interfaces:**
- Consumes: `occupancy_long.csv`, `species_status()`, `site_covariates()`.
- Produces: `build_scp(occ, weights, cost, budget): tibble(Site, selected)` and `species_weights(status, scheme): tibble(species, weight)`.

- [ ] **Step 1:** Write tests: selected cost is at or below budget; a species with no Red List match gets the default weight and a warning; a higher weight on one species never lowers its achieved coverage.
- [ ] **Step 2:** Implement with prioritizr's tabular input, `Human_modification_1km` as cost, and a maximum-coverage style objective, because weights do not apply to the minimum-set objective. Verify the objective in the installed version.
- [ ] **Step 3:** Write the Rmd: a baseline solution, a threatened-species weighting, a cost comparison, and a group exercise. Say that occupancy enters as posterior means. Add the MCP step and skip path.

Verify: tests pass and the Rmd renders with `WORKSHOP_NO_MCP=1`.

### Task 11: Student pack

**Files:**
- Create: `docs/student-start.md`, `docs/instructor-notes.md`

- [ ] **Step 1:** One page for students: open the Posit Cloud project, run `check_setup()`, enter the API key, open the first session.
- [ ] **Step 2:** Instructor notes: expected run times from Task 3 and Task 5, the cut line, known failure modes and fixes.

### Task 12: Dry run on Posit Cloud (Doug runs)

- [ ] **Step 1:** Doug creates the shared template project from the repository and runs all four Rmd files end to end in a fresh 4 GB session, with the real API key through Posit Assistant.
- [ ] **Step 2:** Record timings and failures in `docs/instructor-notes.md`. Fix and repeat for any failing session before it is taught.

Verify: each session renders in a fresh session within its time slot.
