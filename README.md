# occJSDM workshop

Four hands-on sessions that take a real eDNA survey (Ji et al. 2025, Gaoligongshan, [doi:10.1111/ele.70302](https://doi.org/10.1111/ele.70302)) from raw summaries to occupancy models to a simple systematic conservation plan. They run on Posit Cloud, with the occJSDM MCP agent available through Posit Assistant.

The design is in `docs/design.md` and the build plan in `docs/plan.md`. Student setup is in `docs/student-start.md` and teaching notes are in `docs/instructor-notes.md`.

## Installing the occJSDM MCP agent

The MCP agent lets Posit Assistant check a data file, fit a model and read its diagnostics through four occJSDM tools: `validate_data`, `fit_model`, `diagnostics` and `summarise_fit`. It is optional: every session also runs without it, and rendering with `WORKSHOP_NO_MCP=1` leaves out the MCP steps. Its source is in the occJSDM repository under [`mcp/paper2agent`](https://github.com/AlexDiana/occJSDM/tree/main/mcp/paper2agent). For Posit Cloud, use the ready-made bundle, which also carries the occJSDM source it needs.

1.  Download `occJSDM-cloud-pilot-v0.3.0.zip` from the occJSDM [v0.3.0-beta release](https://github.com/AlexDiana/occJSDM/releases/tag/v0.3.0-beta), and upload it to the root of the Posit Cloud project with the Files pane. Posit Cloud unpacks it into a folder called `occJSDM-mcp`. Delete the zip afterwards, so that it is not copied into every student's project.

2.  In the Terminal tab, move the folder into place:

    ``` bash
    cd /cloud/project && mkdir -p mcp && mv occJSDM-mcp mcp/paper2agent
    ```

3.  Install the Python packages and restore the MCP's own R runtime. The restore compiles occJSDM and took about 13 minutes on Posit Cloud.

    ``` bash
    cd /cloud/project/mcp/paper2agent && python3 -m venv occJSDM-env && ./occJSDM-env/bin/python -m pip install -r src/requirements.txt
    ```

    ``` bash
    cd /cloud/project/mcp/paper2agent && Rscript --vanilla r-runtime/restore-runtime.R "$PWD/cloud-r-runtime" 2>&1 | tee restore.log
    ```

    The last line should say that the restore and its checks passed.

4.  Register the server with Posit Assistant. If the project has no `.posit/assistant/settings.json` yet, copy the template; otherwise add the template's `occJSDM` entry to the file's `mcpServers` section.

    ``` bash
    mkdir -p /cloud/project/.posit/assistant && cp /cloud/project/mcp/paper2agent/class/posit-assistant-settings.template.json /cloud/project/.posit/assistant/settings.json
    ```

5.  In Posit Assistant, trust the workspace, choose a model, and enter the model provider's key in Assistant's own credential settings, never in the project. Send `/mcp`: the Session information panel should list occJSDM as Connected. Then ask the model which occJSDM tools it has. It should name the four tools above, as `mcp__occJSDM__validate_data` and so on.

The workshop uses Claude Haiku 5.5 through OpenRouter. On 5 November 2026 a full run of Session 2's MCP steps cost under 1 US cent. `docs/mcp-feasibility.md` records what was tested on Posit Cloud.

The files in `data-derived/` are committed, so the sessions need neither the raw archive nor the full fit. To rebuild them, run these from the project root, in order:

- `analysis/build-derived.R`, with `WORKSHOP_RAW` set to the unpacked Zenodo archive (`setup/01-download-data.R` fetches it). It writes `mammal_input.rds` and `species_status.rds`.
- `analysis/fit-mammal.R`, with `WORKSHOP_FIT` set to a new path outside the repo. It fits the 108 mammals at the pinned occJSDM (about 8 minutes on two cores) and saves the full fit, `fit_Mammal_d4_community_1b4a2cd_10k.rds`.
- `analysis/build-fit-summary.R`, with `WORKSHOP_FIT` set to that fit. It writes `fit_summary.rds`.
- `analysis/build-session-data.R`. It writes `dhole_input.rds`, `occupancy_long.csv` and `dhole_fit.rds`.
- `analysis/build-simulated-fit.R`. It writes `simulated_fit.rds`.
- `analysis/dhole-check.R`, with `WORKSHOP_FIT` set as above. It writes `dhole_check.rds`.
