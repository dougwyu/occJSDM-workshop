# MCP on Posit Cloud: what is known and what is left to check

## Already shown (Doug, 5 October 2026)

The occJSDM MCP server, Posit Assistant and an OpenRouter model have already worked together on Posit Cloud. The record is `mcp/paper2agent/reports/cloud-pilot.json` in the occJSDM repository: dependency installation, restoration of an isolated R runtime on R 4.6.1 and Python 3.12.11, Assistant showing the server as connected, and all four tools returning results. The evidence is user-reported. A model trial used DeepSeek through OpenRouter with a US$5 cap and spent about US$2.65 in total.

So the question is no longer whether this route can work. It is whether it works inside the workshop's own Posit Cloud project, for 15 students, with the workshop data.

## What the MCP can and cannot do

The server offers exactly four operations: `validate_data`, `fit_model`, `diagnostics` and `summarise_fit`. It fits non-spatial models from an input RDS file, and `summarise_fit` reports baseline occupancy, not per-site occupancy. It cannot build an ordination, a map or an SCP. For those, students use Posit Assistant as an ordinary R coding helper, not through the MCP.

Its scientific source is pinned to occJSDM `b7b7001`, which predates the beta. The workshop pins `6256791` (the commit that made the cached fits). The two runtimes are separate, but the input data layout must be accepted by both.

## Checks still to run (Doug, on Posit Cloud)

1. Create the shared template project and restore the MCP runtime into it, following `mcp/paper2agent/USAGE.md` (Posit Cloud handoff). Record the install time and the project's disk use, since each student gets a copy.
2. Merge `class/posit-assistant-settings.template.json` into `.posit/assistant/settings.json`, trust the workspace, and confirm `/mcp` lists the four tools in a fresh copy of the template.
3. Run `validate_data` on `data-derived/mammal_input.rds` (made in Task 4) and on a single-species dhole file. Record any complaint.
4. Run a real `fit_model` on the single-species dhole file at a workshop-length schedule, and record the wall time in a 4 GB session. A live one-species fit could be the Wednesday MCP step, if it is fast and stable (to be confirmed).
5. Pick the cheap OpenRouter model and set a spending cap for 15 students over four sessions. Record the cost of one full test conversation, and how keys are entered (Assistant's credential settings).

If step 2 fails in a fresh copy, the fallback is the non-AI route in `class/non-ai-workflow.R`, with the MCP as an instructor demonstration. Doug decides.
