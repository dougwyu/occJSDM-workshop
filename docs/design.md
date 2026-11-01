# occJSDM workshop: design

Draft of 1 November 2026, for Doug's approval. Nothing in it has been built. Items marked **Doug** were decided by Doug in the brainstorm. Items marked **My call** are mine and are open to being overruled.

## Intent and why

Most eDNA papers report taxonomic composition and ordinations. These are summaries of what was detected, so they cannot say where a species is or what to protect. The workshop teaches students to go from those summaries to two things a decision-maker can use: where a species is, and where the high conservation value areas are.

Students begin with a real dataset and a real decision, and meet each method as the answer to a problem they have just hit. They should leave knowing why a detection is not a presence, trusting a model result when the data support it, and able to run a simple systematic conservation plan (SCP) from their own fits.

## Audience

**Doug:** students who signed up to learn R and eDNA. They are motivated and know little about real ecological modelling. They have probably never done species distribution or occupancy modelling. Assume they can read tidyverse and ggplot2 code, and no more. The group size is not known.

## Format and timetable

**Doug:** 15 students, in person, on Posit Cloud sessions with about 4 GB of RAM each. The workshop runs 9 to 13 November 2026 and is shared with other presenters. Session titles in the wider timetable are to be ignored. Only the timings matter.

Doug's teaching slots are four half-days, about 14 hours in all:
- Tuesday 10 Nov, 13.00 to 15.00 and 15.15 to 17.00 (3 h 45 min).
- Wednesday 11 Nov, the same.
- Thursday 12 Nov, 08.30 to 10.00 and 10.15 to 12.00 (3 h 15 min).
- Friday 13 Nov, the same.

Doug also appears as a presenter on Monday 09.00 to 12.00 (a lecture and discussion). That is not counted as teaching time here. The Wednesday morning R session before Doug's slot is led by someone else and covers basic R visualisation.

**The first session is nine days after this draft.** The Quickstart expansion is unfinished, the MCP runtime needs rebuilding, and the workshop repository does not exist. The build must be sequenced so that a reduced version, using cached fits only, is teachable on 10 November (**My call**, see below).

## Goals

- Students run all code themselves, on Posit Cloud, with access to the occJSDM MCP agent (**Doug**).
- Open with a real dataset: the Ji et al. (2025) Gaoligongshan survey (**Doug**). The NWWT qPCR example is dropped (**Doug**).
- Include code for the usual eDNA summaries, composition and an ordination, then go beyond them (**Doug**).
- The ordination uses ecoCopula and is drawn as a ggplot2 biplot with sites and species coloured, so patterns show. Doug recalls taxonomic structure in the species loadings. Nobody has checked this yet (**Doug**).
- Answer two questions: where is a species (useful for good and bad species), and where are the high conservation value areas (**Doug**).
- Students run a very simple SCP, with different species weightings and with an example using different costs (**Doug**). The 101 survey sites are the planning units, because there is no time to predict over the whole landscape (**Doug**).
- Show that modelling can give certainty about the right things when the data support it, not only uncertainty (**Doug**).

## Non-goals

- No spatial submodel and no prediction over the whole reserve.
- No model comparison or JSDM package comparison (Lessons 5 and 6 stay out). Students are not taught the theory in Lesson 2.
- No uncertainty-aware SCP. The package currently returns per-site occupancy as posterior means only, so the SCP runs on means. The workshop says so openly (**My call**, following the Quickstart session's finding).

## Anti-goals

- A workshop that is a tour of functions with no decision at the end.
- A single-species example so uncertain that students conclude modelling only adds doubt. This is why the bullfrog is out (**Doug**).
- Live fits that fail or run too long on Posit Cloud in front of students.

## Proposed arc (My call throughout)

One theme per half-day, each ending in something students made. Each session is mostly hands-on, with a short framing talk (the split is left to the builder).

- **Tuesday afternoon, why model.** Introduce the survey. Run composition summaries and the ecoCopula biplot. End by showing that none of it says where a species is. Then show that a detection is not a presence: replicate PCRs, sites with mixed results, and naive occupancy beside model occupancy for species such as the pig and cattle, where false positives are large.
- **Wednesday afternoon, where is a species.** The dhole (*Cuon alpinus*, Endangered), chosen by Doug (**Doug**). The stored mammal results show naive occupancy 0.41 and model occupancy 0.18, with a true-positive rate of 0.55 and a false-positive rate of 0.03, and the fit converges. Interval width and covariate response have not been checked yet. Cover how the data are laid out for a two-stage model, a cached fit, convergence checks, the main results, and a map at the 101 sites. The MCP agent first appears at the end, after the steps have been done by hand, to repeat the workflow.
- **Thursday morning, many species at once.** The cached mammal fit. Cover diagnostics, species associations, and the per-site occupancy table for all species. Students use the MCP agent to ask questions of the fit.
- **Friday morning, where to protect.** A simple SCP on the 101 sites. Targets come from occupancy, weightings from Red List status, costs from human modification. Students compare solutions in a group exercise, and use the MCP agent to repeat or extend the analysis.

The MCP agent is mandatory (**Doug**). Students use it through Posit Cloud's Posit Assistant, connected with an API key that Doug issues, probably to OpenRouter and paid for by Doug (**Doug**). Doug tests on Posit Cloud himself before the workshop (**Doug**).

An optional short simulated-truth interlude, so students see the model recover a known answer, is out by default. Real data has no truth, and the only external check is the published occPlus results.

## Materials

- **Data.** The Gaoligongshan Zenodo archive, DOI 10.5281/zenodo.17113196, about 127 MB. A local working copy and the reshaped mammal input live in `~/src/occJSDM_Ecoletts` (`mammal_occjsdm_input.rds`: 1,818 samples, 108 species, 101 sites).
- **Species table**, `glgs/data/SP_withBODYSIZE.txt` in the archive, with IUCN and China Red List status, wild or domesticated or invasive flag, and mammal body mass. It is part of the published data, so no licensing work is needed. This supplies the SCP weightings. Some species may lack a Red List match, so the builder must check coverage and decide how to treat unmatched species.
- **SCP cost.** `Human_modification_1km` is one of the eight occupancy covariates and is a per-site value, so it can serve directly as the cost (**My call**).
- **Stored results** in that folder: per-species naive and model occupancy, detection parameters, and R-hat. Two cached mammal fits exist, 236 MB each, both with convergence flags. 104 of 108 species converge. They were run in conda R 4.5.3 with OpenBLAS.
- **Covariates.** Eight occupancy covariates and two collection covariates (filter volume, prior-day rain).

## Where the workshop should live

**My call: its own repository, `occJSDM-workshop`, beside this one, not inside occJSDM.** Reasons:
- The package repository is built, checked and released as an R package. Workshop files, data and cached fits do not belong in it, and a workshop folder inside it risks an `R CMD build` that copies large trees.
- Posit Cloud can create a project straight from a Git repository, so students get the whole workshop in one step.
- The workshop has its own timeline and audience, and should not be held up by package releases.
- Large files stay out of git: raw data are downloaded from Zenodo by a setup script, and cached fits go in a GitHub release or a shared Posit Cloud project.
- The repository pins one occJSDM commit, so the workshop never breaks when the package moves.

It would carry its own `.Rproj` with `MarkdownWrap: None`, and a short project instruction file copying the markdown rules used here, because Doug edits it in RStudio Visual mode too.

This design file sits in the occJSDM folder, untracked, only so Doug can read it. It would move into the new repository once Doug agrees.

Posit Cloud needs one shared template project, with the pinned occJSDM and all dependencies installed and a `readRDS()` fallback for every live fit.

## Dependencies and constraints

- **Quickstart expansion.** Doug is finishing it. If the workshop reuses its output tour on Gaoligongshan, chunks are written once. Not decided.
- **Package gaps.** Per-site occupancy has no intervals, richness by higher taxon is missing, and `returnLatentPresences` is broken. All are in TODO.md. The workshop works around them in plain R.
- **MCP.** The runtime is pinned to a pre-beta commit and needs rebuilding on current main before it matches the workshop's package version. Adoption gates are still open: a controlled model comparison, scientific and Indonesian review, a tested workshop MCMC preset, and a student credential plan.
- **Package version and cached fits.** The workshop pins the occJSDM commit that produced the fits it shows: `6256791` on main for the fixed intercept prior, or `553e37c` (PR 36) for the community-mean prior. This keeps the cached fits valid, so no refit is needed (**My call**). If Doug refits the lessons with the community prior once PRs 36 to 38 merge, the pin moves with them. A refit of the mammal model is a 5 to 8 minute job, not the tens of hours of the spatial studies.
- **Defaults.** Unless Doug says otherwise, Day 2 loads cached fits only, with no live refit, and there is no simulated-truth interlude (**My call**).
- **Not yet verified.** Whether `ecoCopula` and `prioritizr` (with a free solver) install and run on Posit Cloud. Fit times and memory limits on the plan Doug will use. The cached fits are 236 MB each.

## Open decisions for Doug

- Who helps with install problems in person. With 15 students, one presenter may be enough if the template project works first time (**My call**).
- Whether the MCP works inside the workshop's own template project for 15 students. It has already been shown to work with Posit Assistant and OpenRouter on Posit Cloud (Doug, 5 October 2026; see `docs/mcp-feasibility.md`). What is left is restoring the runtime in the template, the cost for 15 students, and whether the pre-beta runtime accepts the workshop data. The MCP offers only four operations (validate, fit, diagnostics, baseline summary) and cannot do per-site occupancy or the SCP, so students use Posit Assistant as an ordinary R helper for those.
- The OpenRouter key arrangement: a spending cap, a cheap model that handles the MCP tools reliably, and whether the key is shared or per student.
- The dhole is the Wednesday species (**Doug**). First task for the builder: check its per-site occupancy intervals and covariate effects in the stored fits against these criteria (**My call**): a 95% interval narrow enough to rank sites, and a clear covariate effect whose interval excludes zero. If it falls short, report back to Doug with the other leads (Gongshan muntjac, gaur, leopard cat) and do not swap silently. If the ecoCopula biplot shows no taxonomic pattern, the opening falls back to colouring by covariate only.
- Whether the workshop reuses the Quickstart tour. Default (**My call**): do not wait for it. The workshop writes its own chunks on Gaoligongshan and borrows from the Quickstart where it is ready.
- Whether to confirm the repository location above.

## Left to the builder

- Exact timetable, chunk wording and exercises.
- The ecoCopula transformation and model settings, and the colouring variables.
- SCP formulation: objective, targets, and the specific weighting and cost scenarios.
- How to present convergence flags in the cached fits, as a teaching moment or by refitting longer.
