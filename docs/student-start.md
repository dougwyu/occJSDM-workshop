# Before Session 1: getting started

You will work in a Posit Cloud project that your instructor shares with you. Everything you need is already in it. You do not need to download any data.

1.  Open the project link from your instructor. Posit Cloud makes you your own copy.
2.  In the Console, run the check below. Every line should start with `[ok]`.

``` r
source("setup/check-setup.R")
check_setup()
```

3.  Connect the assistant, in the Posit Assistant pane.
    - When it asks whether to trust this project's workspace, say yes. Without that, it cannot use the occJSDM tools.
    - Your instructor will give you an API key. Enter it in Posit Assistant's credential settings, not in any file or script, and do not share it.
    - In the model menu under the chat box, choose **Claude Haiku 5.5**, not "Auto Router". It is cheap, and it is the model the sessions were tested with.
    - Check the connection: type `/mcp` in the chat box and press Enter. The panel that opens should list **occJSDM** as **Connected**.
    - When the assistant wants to run R code in your session, it asks you first. Read the code, and approve it only if you understand what it will do. The occJSDM tools run without asking.
    - The assistant replies in English. To have it reply in Bahasa Indonesia, start each conversation by typing: *Mulai sekarang, jawablah dalam Bahasa Indonesia. Biarkan kode R, nama fungsi, nama kolom dan nama file dalam bahasa Inggris.* ("From now on, answer in Bahasa Indonesia. Keep R code, function names, column names and file names in English.")
4.  Open `01-why-model.Rmd`. It opens in Visual mode. Run the chunks one at a time with the green arrows, or all of them with Run All (Ctrl+Alt+R). Tables appear in the Console and plots in the Plots pane.

If a line in step 2 says `[FAIL]`, tell your instructor. If the assistant does not respond, carry on with the code in the files. Everything in the sessions works without it.

The sessions are:

- Session 1, `01-why-model.Rmd`: why raw eDNA summaries cannot answer a management question.
- Session 2, `02-dhole.Rmd`: where is the dhole?
- Session 3, `03-many-species.Rmd`: all 108 mammals at once.
- Session 4, `04-scp.Rmd`: where should we protect?
