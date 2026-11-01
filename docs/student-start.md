# Before Session 1: getting started

You will work in a Posit Cloud project that your instructor shares with you. Everything you need is already in it. You do not need to download any data.

1. Open the project link from your instructor. Posit Cloud makes you your own copy.
2. In the Console, run the check below. Every line should start with `[ok]`.

```r
source("setup/check-setup.R")
check_setup()
```

3. Connect the assistant. Your instructor will give you an API key. Enter it in Posit Assistant's credential settings, not in any file or script, and do not share it.
4. Open `01-why-model.Rmd`. Run the chunks one at a time with the green arrows, or press Knit to run them all.

If a line in step 2 says `[FAIL]`, tell your instructor. If the assistant does not respond, carry on with the code in the files. Everything in the sessions works without it.

The sessions are:

- Session 1, `01-why-model.Rmd`: why raw eDNA summaries cannot answer a management question.
- Session 2, `02-dhole.Rmd`: where is the dhole?
- Session 3, `03-many-species.Rmd`: all 108 mammals at once.
- Session 4, `04-scp.Rmd`: where should we protect?
