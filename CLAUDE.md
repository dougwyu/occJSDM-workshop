# Project instructions

## Markdown in this repo

Doug edits markdown here using RStudio's *Visual* mode, which rewrites the whole file to canonical form on every save. Anything written in a form Visual mode would reformat comes back on the next open as a diff nobody authored.

- **Do not hard-wrap.** Write each paragraph as a single line. Never add an `editor_options: markdown: wrap:` block to a file.
- **No pipe tables.** Use bullet lists instead.
- **Keep inline code spans short.**
- **Escape markdown-significant characters in prose.** Write `-\>` not `->`, and `\~` not `~`. Same for a literal `\<`, `\>` or `\|` in running text.
- **Do not escape inside code.** Backtick spans and fenced blocks are left verbatim.
- **Re-read a file immediately before and after editing it**, since it may be open in the RStudio editor.
- **No em-dashes** anywhere, including commit messages. Use a plain double hyphen (`--`).

## Workshop conventions

- All plots are ggplot2. Students can read tidyverse code and no more.
- Live sessions use cached fits only. Joins go by site name, never by row position.
- Every session must run and render without the assistant, so a failed key or server never blocks a student. The "Ask the assistant" sections are plain text, not code chunks, because students read the sessions in RStudio's Visual mode.
- Helper functions in `R/` may hide only teaching prep (library paths, reading the prepared data). Any code students would run in their own analysis (ordination, plotting, prioritizr, extracting results from a fit) is written out in the session. Test it by running the session's own chunks, not a copy in `R/`.
- Each session opens with a workshop-only setup chunk, then a separate chunk of `library()` calls.
- The design is in `docs/design.md` and the build plan in `docs/plan.md`.
