# occJSDM workshop

Four hands-on sessions that take a real eDNA survey (Ji et al. 2025, Gaoligongshan, [doi:10.1111/ele.70302](https://doi.org/10.1111/ele.70302)) from raw summaries to occupancy models to a simple systematic conservation plan. They run on Posit Cloud, with the occJSDM MCP agent available through Posit Assistant.

The design is in `docs/design.md` and the build plan in `docs/plan.md`. Student setup is in `docs/student-start.md` and teaching notes are in `docs/instructor-notes.md`.

## Installing the occJSDM MCP agent

The MCP agent lets Posit Assistant check a data file, fit a model and read its diagnostics through four occJSDM tools: `validate_data`, `fit_model`, `diagnostics` and `summarise_fit`. It is optional: every session runs without it, and each session's assistant section is plain text that students can skip. Its source is in the occJSDM repository under [`mcp/paper2agent`](https://github.com/AlexDiana/occJSDM/tree/main/mcp/paper2agent). Both routes use the same ready-made bundle, which also carries the occJSDM source it needs. It is the same occJSDM version (v0.3.0-beta) as the workshop's own pin.

### On Posit Cloud

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

### On your own Mac

Install the agent once, in its own folder outside this repository. This repository ignores `mcp/`, `.posit/assistant/settings.json` and `artifacts/`, so nothing here is added to Git. The restore installs 60 R packages and took about 7 minutes on an Apple silicon Mac, so allow 10 to 30 minutes. It follows the restore recorded on macOS 27 (arm64) with R 4.6.1, so you need R 4.6.1, Python 3.11 or later, the Xcode command line tools, a Fortran compiler for R and Homebrew's `gettext`. Keep using the same Terminal tab.

1.  Download the bundle and unpack it. The unpacked folder is called `occJSDM-mcp`, and must not exist already.

    ``` bash
    cd ~/Downloads
    curl -fL -O https://github.com/AlexDiana/occJSDM/releases/download/v0.3.0-beta/occJSDM-cloud-pilot-v0.3.0.zip
    unzip -q occJSDM-cloud-pilot-v0.3.0.zip -d ~
    cd ~/occJSDM-mcp
    ```

2.  Create the Python environment.

    ``` bash
    python3 -m venv occJSDM-env && ./occJSDM-env/bin/python -m pip install -r src/requirements.txt
    ```

3.  Restore the R runtime into a new folder. The two exports are the macOS workarounds, and the throwaway Makevars file replaces your own `~/.R/Makevars` for this Terminal session only. After a failed attempt, delete `local-r-runtime` before retrying.

    ``` bash
    export MACOSX_DEPLOYMENT_TARGET=15.0
    export R_MAKEVARS_USER="$(mktemp)"
    echo 'CPPFLAGS += -I/opt/homebrew/opt/gettext/include' > "$R_MAKEVARS_USER"
    Rscript --vanilla r-runtime/restore-runtime.R "$PWD/local-r-runtime" 2>&1 | tee restore.log
    ```

    The last line should say that the restore and its checks passed.

4.  Print the settings entry for this project. Set `PROJECT` to where you cloned the workshop, then run the block from `~/occJSDM-mcp`.

    ``` bash
    PROJECT="$HOME/src/occJSDM-workshop"
    cat <<EOF
    {
      "mcpServers": {
        "occJSDM": {
          "type": "local",
          "command": ["$PWD/occJSDM-env/bin/python", "$PWD/src/occJSDM_mcp.py"],
          "environment": {
            "P2A_PROJECT_ROOT": "$PROJECT",
            "P2A_R_PROJECT": "$PWD/local-r-runtime",
            "P2A_RSCRIPT": "$(which Rscript)",
            "P2A_TIMEOUT_SECONDS": "600"
          },
          "timeout": 30000
        }
      }
    }
    EOF
    ```

5.  Merge the printed `occJSDM` entry into `.posit/assistant/settings.json` in the workshop folder, creating the file if needed and keeping any keys already there. Then restart Posit Assistant, trust the workspace, and check with `/mcp` as in step 5 of the Posit Cloud route. The server can only read data files under the workshop folder, and it writes its results to `artifacts/` there. If the `/mcp` panel has no MCP Servers section, the entry is missing from that file or the workspace is not trusted.

The same installation can serve any other project: print a new entry with a different `PROJECT` and merge it into that project's settings file.

The workshop uses Claude Haiku 5.5 through OpenRouter. On 5 November 2026 a full run of Session 2's MCP steps cost under 1 US cent. `docs/mcp-feasibility.md` records what was tested on Posit Cloud.

The files in `data-derived/` are committed, so the sessions need neither the raw archive nor the full fit. To rebuild them, run these from the project root, in order:

- `analysis/build-derived.R`, with `WORKSHOP_RAW` set to the unpacked Zenodo archive (`setup/01-download-data.R` fetches it). It writes `mammal_input.rds` and `species_status.rds`.
- `analysis/fit-mammal.R`, with `WORKSHOP_FIT` set to a new path outside the repo. It fits the 108 mammals at the pinned occJSDM (about 8 minutes on two cores) and saves the full fit, `fit_Mammal_d4_community_1b4a2cd_10k.rds`.
- `analysis/build-fit-summary.R`, with `WORKSHOP_FIT` set to that fit. It writes `fit_summary.rds`.
- `analysis/build-session-data.R`. It writes `dhole_input.rds`, `occupancy_long.csv` and `dhole_fit.rds`.
- `analysis/build-simulated-fit.R`. It writes `simulated_fit.rds`.
- `analysis/dhole-check.R`, with `WORKSHOP_FIT` set as above. It writes `dhole_check.rds`.
