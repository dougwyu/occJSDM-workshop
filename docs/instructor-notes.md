# Instructor notes

## Timetable

Doug's slots are Tuesday and Wednesday 13.00 to 17.00 (3 h 45 min each) and Thursday and Friday 08.30 to 12.00 (3 h 15 min each). One session per slot. Each is mostly hands-on, with a short framing talk.

## What each session needs

- Session 1: ecoCopula and ggplot2. The ordination fits in a few seconds.
- Session 2: a live one-species fit with occJSDM. It takes about 7 seconds on the build laptop (2 chains, 5000 burn-in, 5000 kept). Posit Cloud will be slower and is not yet timed. A cached copy, `data-derived/dhole_fit.rds`, is used when `WORKSHOP_LIVE_FIT=0`.
- Session 3: only the slim summary, `data-derived/fit_summary.rds`. The full mammal fit is not needed in class.
- Session 4: `prioritizr` with the HiGHS solver. The four plans solve in about 10 seconds in total on the build laptop.

## What is checked and what is not

Checked on the build laptop (macOS, R 4.6.1): all sessions render with the MCP steps skipped, and the tests pass. Not yet checked: any of this on Posit Cloud, the timings there, the memory use in a 4 GB session, the MCP restored in the template project, and the MCP accepting the one-species dhole file with `n_factors = 0`. See `docs/mcp-feasibility.md`.

## Things to say aloud

- The ecoCopula biplot shows only a weak taxonomic pattern. Order explains about a fifth of the spread on axis 1 (p about 0.075 with the seed set in the session; the ordination starts from random values, so another seed gives a slightly different p). The session teaches students to check an impression instead of trusting colour.
- The dhole is a case where the model is confident about where the animal is, but not about why. The covariate effects are mostly uncertain. See `docs/dhole-check.md`.
- Four species did not converge in the mammal-wide fit (Session 3). They were detected at only 3 to 16 sites.
- The SCP uses posterior means. The package does not yet return per-site intervals, so the plan cannot carry uncertainty through.
- 13 species have no Red List status at all. The SCP gives them weight 1 and says so.

## If you fall behind

Cut in this order: the species-association section of Session 3, the cost comparison in Session 4, then the MCP step in Session 2. Never cut Session 1 or the SCP itself.

## If the MCP fails

Every session works without it. Tell students to carry on with the code, and use Posit Assistant as an ordinary R helper if it connects at all.
