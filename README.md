# occJSDM workshop

Four hands-on sessions that take a real eDNA survey (Ji et al. 2025, Gaoligongshan, [doi:10.1111/ele.70302](https://doi.org/10.1111/ele.70302)) from raw summaries to occupancy models to a simple systematic conservation plan. They run on Posit Cloud, with the occJSDM MCP agent available through Posit Assistant.

## Outline

Four afternoon or morning slots of about 3 to 4 hours, one session each. Every session is an R Markdown file that students run chunk by chunk, with hands-on exercises and an optional section for the occJSDM MCP agent. Each session also has a Bahasa Indonesia version (`01-why-model-id.Rmd` and so on), with the same code and Indonesian number formatting.

1.  **Why model? What eDNA summaries cannot tell you** (`01-why-model.Rmd`). The survey design, what was detected by taxonomic order, a model-based ordination with ecoCopula, and where the dhole was detected. A simulated survey shows how often a species that is present is missed.
2.  **Where is the dhole, really?** (`02-dhole.Rmd`). A first occupancy model, fitted live with occJSDM: first on the simulated survey, where the answer is known, then on the dhole. How widespread the dhole is, how well its DNA is collected and detected, which covariates explain where it lives, and whether the chains can be trusted.
3.  **Many species at once** (`03-many-species.Rmd`). A saved joint model of all 108 mammals: which species' fits can be trusted, how reliable each species' detection is, each species' probability of presence at each site, species richness per site, whether the reserves matter once human modification is accounted for, and which species occur together more often than the covariates explain.
4.  **Where should we protect?** (`04-scp.Rmd`). Turning occupancy probabilities into a systematic conservation plan with prioritizr: a toy plan first, then four plans for 101 sites, with equal weights, Red List weights, sites that cost different amounts, and domestic species left out. How much of each plan is already protected, and what a plan cannot tell us.

Each session ends with "What you take away" and a short Essay Coach question (`docs/essay-coach-questions.txt`).

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

You only need to do this once. These steps assume that you keep your code in a folder called `~/src`, so that the workshop and the agent sit side by side in it:

- `~/src/occJSDM-workshop`: your clone of this workshop repository;
- `~/src/occJSDM-mcp`: the agent, which step 1 creates.

The agent is installed in its own folder, **outside the `occJSDM-workshop` folder**. Nothing in the workshop folder changes except one small settings file, `.posit/assistant/settings.json`, which tells Posit Assistant where the agent is. So the agent never becomes part of the workshop repository or its Git history, and one installation can serve any number of projects. (The repository also ignores `mcp/`, `.posit/assistant/settings.json` and `artifacts/`, so none of these can be committed by accident.)

The agent has three parts, and the steps below set up one each:

- a small Python program that Posit Assistant talks to (steps 1 and 2);
- a private R library, holding occJSDM 0.3.0 and the 60 packages it needs. The agent uses it instead of your own R library, so nothing you install or update later can break the agent (step 3);
- the settings file in the workshop folder (step 4).

If you keep your code somewhere else, replace `~/src` in every step below. You need R 4.6.1, Python 3.11 or later, the Xcode command line tools, a Fortran compiler for R and Homebrew's `gettext`. Allow 10 to 30 minutes, most of it for step 3. Run every step in the same Terminal tab.

1.  **Get the agent.** Download the bundle and unzip it into `~/src`. This makes the folder `~/src/occJSDM-mcp`, which must not exist already.

    ``` bash
    cd ~/Downloads
    curl -fL -O https://github.com/AlexDiana/occJSDM/releases/download/v0.3.0-beta/occJSDM-cloud-pilot-v0.3.0.zip
    unzip -q occJSDM-cloud-pilot-v0.3.0.zip -d ~/src
    ```

2.  **Set up the Python program.** This makes a Python environment inside `~/src/occJSDM-mcp` and installs the packages the program needs.

    ``` bash
    cd ~/src/occJSDM-mcp
    python3 -m venv occJSDM-env && ./occJSDM-env/bin/python -m pip install -r src/requirements.txt
    ```

3.  **Build the private R library.** This installs occJSDM 0.3.0 and its packages into `~/src/occJSDM-mcp/local-r-runtime`, compiling some of them, which took about 7 minutes on an Apple silicon Mac. After the `cd`, the next three lines are settings that macOS needs for compiling. They last only for this Terminal tab and do not change your own R setup.

    ``` bash
    cd ~/src/occJSDM-mcp
    export MACOSX_DEPLOYMENT_TARGET=15.0
    export R_MAKEVARS_USER="$(mktemp)"
    echo 'CPPFLAGS += -I/opt/homebrew/opt/gettext/include' > "$R_MAKEVARS_USER"
    Rscript --vanilla r-runtime/restore-runtime.R "$PWD/local-r-runtime" 2>&1 | tee restore.log
    ```

    The last line should say that the restore and its checks passed. If it fails, delete `~/src/occJSDM-mcp/local-r-runtime` before trying again.

4.  **Tell Posit Assistant where the agent is.** This block writes the settings file into the workshop folder. It names two different folders: `AGENT` is the agent's folder from step 1 (`~/src/occJSDM-mcp`), and `WORKSHOP` is your clone of this workshop repository (`~/src/occJSDM-workshop`). Change either line if yours is somewhere else. As the block runs, the shell fills in `$AGENT`, `$WORKSHOP` and `$(which Rscript)` with your real paths. If the settings file already exists, the block leaves it alone and prints the entry instead, and you add its `occJSDM` part to the file's `mcpServers` section by hand.

    ``` bash
    AGENT="$HOME/src/occJSDM-mcp"
    WORKSHOP="$HOME/src/occJSDM-workshop"
    SETTINGS="$WORKSHOP/.posit/assistant/settings.json"
    if [ -e "$SETTINGS" ]; then
      echo "$SETTINGS already exists, so it was not changed. Add this occJSDM entry to its mcpServers section by hand:"
      OUT=/dev/stdout
    else
      mkdir -p "$WORKSHOP/.posit/assistant"
      OUT="$SETTINGS"
      echo "Wrote $SETTINGS"
    fi
    cat > "$OUT" <<EOF
    {
      "mcpServers": {
        "occJSDM": {
          "type": "local",
          "command": ["$AGENT/occJSDM-env/bin/python", "$AGENT/src/occJSDM_mcp.py"],
          "environment": {
            "P2A_PROJECT_ROOT": "$WORKSHOP",
            "P2A_R_PROJECT": "$AGENT/local-r-runtime",
            "P2A_RSCRIPT": "$(which Rscript)",
            "P2A_TIMEOUT_SECONDS": "600"
          },
          "timeout": 30000
        }
      }
    }
    EOF
    ```

5.  **Check that it works.** Open the workshop project in RStudio, open Posit Assistant, trust the workspace, and send `/mcp`: occJSDM should show as Connected. Then ask "Which occJSDM tools do you have?". It should name the four tools above. If the `/mcp` panel has no MCP Servers section, the settings file is missing or the workspace is not trusted.

The agent can only read data files inside the workshop folder, and it writes its results to `artifacts/` there. To use the same installation in another project, run step 4 again with `WORKSHOP` set to that project's folder.

The workshop uses Claude Haiku 5.5 through OpenRouter. On 5 November 2026 a full run of Session 2's MCP steps cost under 1 US cent. `docs/mcp-feasibility.md` records what was tested on Posit Cloud.

The files in `data-derived/` are committed, so the sessions need neither the raw archive nor the full fit. To rebuild them, run these from the project root, in order:

- `analysis/build-derived.R`, with `WORKSHOP_RAW` set to the unpacked Zenodo archive (`setup/01-download-data.R` fetches it). It writes `mammal_input.rds` and `species_status.rds`.
- `analysis/fit-mammal.R`, with `WORKSHOP_FIT` set to a new path outside the repo. It fits the 108 mammals at the pinned occJSDM (about 8 minutes on two cores) and saves the full fit, `fit_Mammal_d4_community_1b4a2cd_10k.rds`.
- `analysis/build-fit-summary.R`, with `WORKSHOP_FIT` set to that fit. It writes `fit_summary.rds`.
- `analysis/build-session-data.R`. It writes `dhole_input.rds`, `occupancy_long.csv` and `dhole_fit.rds`.
- `analysis/build-simulated-fit.R`. It writes `simulated_fit.rds`.
- `analysis/dhole-check.R`, with `WORKSHOP_FIT` set as above. It writes `dhole_check.rds`.
