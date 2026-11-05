# MCP on Posit Cloud: what is known and what is left to check

## Already shown (Doug, 5 October 2026)

The occJSDM MCP server, Posit Assistant and an OpenRouter model have already worked together on Posit Cloud. The record is `mcp/paper2agent/reports/cloud-pilot.json` in the occJSDM repository: dependency installation, restoration of an isolated R runtime on R 4.6.1 and Python 3.12.11, Assistant showing the server as connected, and all four tools returning results. The evidence is user-reported. A model trial used DeepSeek through OpenRouter with a US\$5 cap and spent about US\$2.65 in total.

## What the MCP can and cannot do

The server offers exactly four operations: `validate_data`, `fit_model`, `diagnostics` and `summarise_fit`. It fits non-spatial models from an input RDS file, and `summarise_fit` reports baseline occupancy, not per-site occupancy. It cannot build an ordination, a map or an SCP. For those, students use Posit Assistant as an ordinary R coding helper, not through the MCP.

Since 5 November 2026 both the MCP and the workshop pin occJSDM 0.3.0 (`v0.3.0-beta`, commit `5cba0db`). The MCP's earlier pin, `b7b7001`, could not fit single-species two-stage data, so Session 2's `fit_model` step would have failed for every student. The two R runtimes are still separate: the MCP has its own in `mcp/paper2agent/cloud-r-runtime`.

## The workshop template on Posit Cloud (Doug, 5 November 2026)

Doug built the shared template project from the GitHub repository and installed the MCP from `occJSDM-cloud-pilot-v0.3.0.zip`.

- **Install.** The time for `source("setup/00-install.R")` has not been recorded yet. Posit Cloud unzipped the uploaded MCP zip by itself, into `occJSDM-mcp/`, which was then moved to `mcp/paper2agent`. The Python environment and `pip install` worked on Cloud's Python. The R runtime restore took 13 minutes 8 seconds (about 4 minutes on the laptop).
- **Disk.** About 950 MB per project: the MCP's R runtime 516 MB, its Python environment 118 MB, and everything else 317 MB, most of it the 235 MB mammal fit. Every student copy carries all of it. The runtime is self-contained: the restore turns off renv's shared cache, so nothing it needs lies outside `/cloud/project`.
- **Connection.** With `class/posit-assistant-settings.template.json` copied to `.posit/assistant/settings.json` and the workspace trusted, Assistant shows the occJSDM server as Connected. In this version of Assistant, `/mcp` opens the Session information panel, which names the server and its state but does not list tools. Asking the model "Which occJSDM tools do you have?" lists all four, as `mcp__occJSDM__validate_data` and so on. The setup text in the MCP bundle still says `/mcp` lists the tools and needs correcting.
- **Session 2's MCP steps.** All three worked with Claude Haiku 5.5 through OpenRouter. `validate_data` on `data-derived/dhole_input.rds` reported 101 sites, 303 samples and 1,818 PCRs, eligible, with no issues. `fit_model` (two chains, 5,000 burn-in and 5,000 kept, threshold 1, `n_factors` 0, seed 2026) took about 20 seconds (10 on the laptop). `diagnostics` flagged 2 of 16 parameters: `p` and `q`, for `ess` 218 and 239. The assistant read the table correctly and named the right rule for each.
- **Cost.** The whole test conversation (the tool-list question, then the three steps) used about 160,000 tokens: 3,414 output, 40,292 written to the prompt cache and 116,859 read from it. Assistant shows no cost for this model, so the cost was worked out from Haiku 5.5's list prices: about US\$0.008. Each request carries about 27,000 tokens of fixed context (Assistant's instructions and the tool definitions), so input dominates, and the cache matters. At this rate even ten times this use per student per session comes to about US\$6 for 15 students over four sessions. OpenRouter's Activity page gives the billed figure.
- **Cache warming.** Assistant's "Keep prompt cache warm by sending keepalive pings" was on, for 30 minutes. It was turned off in the template, because idle students would pay for pings. Whether this setting travels with a copied project is not yet known.
- **Git.** `.gitignore` now covers `mcp/`, `artifacts/` (where the MCP writes every call's output and its fit registry) and `.posit/assistant`. A commit from the Cloud project therefore cannot pick up the runtime or the Assistant settings.
- **Before sharing.** `artifacts/` held the test fits and was deleted, so student copies start without them. The MCP recreates it on its next call, so clear it again after any later test in the template. Assistant keeps no chat history in the project: `.posit/assistant` holds only `settings.json`.
- **Session 3 in 4.5 GB.** It runs. The `returnConvergenceDiagnostics(fit_full)` line in the `fit-tables` chunk takes about a minute (8 seconds on the laptop), and R's memory peaks at about 3.7 GB (3.2 GB on the laptop), which leaves about 0.8 GB. Students must restart R before Session 3. The minute is mostly coda's `gelman.diag()`, which builds full covariance matrices across each parameter block even for one R-hat per parameter: on the laptop the 972 occupancy effects alone take 5 seconds. It is single-threaded R code, so more CPUs would not help. Doug will tell students the line takes about a minute.
- **BLAS threads.** The container sees 16 cores but may use 2 (`nproc` 16; `cpu.max` 200000 100000). OpenBLAS starts a thread per visible core, so small matrix work in the main R session queued: the diagnostics line had used 3 minutes of CPU at 230% before it was stopped. `.Renviron` (commit 98da336) sets `OPENBLAS_NUM_THREADS=1` for every copy. It does not affect the occJSDM fits, which set their own threads, or the MCP, which runs R with `--vanilla`.

## Findings that change the session text

- **The same seed gives different fits on the laptop and on Cloud.** With seed 2026 the laptop flags 3 of 16 parameters (the rain effect on `rhat`, 1.03; `p` and `q` on `ess`, 215 and 203). On Cloud, both the MCP fit and Session 2's own live fit in R flag 2 (`p` and `q`, `ess` 218 and 239); the two Cloud fits match each other, and the Cloud live fit is not identical to the saved laptop fit (`data-derived/dhole_fit.rds`). The cause is floating-point differences between the platforms (Apple's Accelerate on the laptop, Linux on Cloud), which make the chains follow different paths. Students see the Cloud numbers, so Session 2's saved fallback fits now come from a Cloud render, and its prose and tests follow them (commit 85edb7c; see `REFIT-NOTES.md`).
- **Step 2 of the MCP section must give the detection threshold.** Asked to fit without one, the assistant asks for it, and students may not know the answer (1, as in the session's own fits). Giving the seed (2026) as well lets students compare the assistant's diagnostics with their own.
- **The assistant raised covariate scaling, which does not apply.** After `validate_data` it suggested checking the covariates' scales before fitting. `runOccJSDM()` rescales numeric covariates itself, so this is a dead end for students.
- **Haiku 5.5 made one stray tool call.** During `diagnostics` it called a shell tool as a "no-op placeholder", which did nothing. Worth watching for in class.

## Still to do

1. Record the time for `source("setup/00-install.R")` on Cloud.
2. Add a comment above the diagnostics line in `03-many-species.Rmd` saying it takes about a minute, and make sure Session 3 opens by telling students to restart R.
3. Check that `settings.json` holds no OpenRouter key, then make a fresh copy of the template from a second account. Confirm `check_setup()` is all `[ok]`, the server shows as Connected, one `validate_data` call works, and whether cache warming is still off.
4. Run `validate_data` on `data-derived/mammal_input.rds`.
5. Set the spending cap on the OpenRouter key.

If the MCP fails in a fresh copy, the fallback is the non-AI route in `class/non-ai-workflow.R`, with the MCP as an instructor demonstration. Doug decides.
