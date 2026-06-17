# AGENTS.md

Shared contract for AI agents and human collaborators working on presentation
projects based on this template.

## Read first

Read `README.md`, `slide-plan.md`, and `presentation.yml` before editing slides.
Then familiarize yourself with the surrounding analysis project: read its
guidance, identify the analysis workflow, and locate the compact result objects
or extracted tables that could drive the presentation.

## Working order

1. Familiarize yourself with the project before proposing slides.
2. Discuss the presentation with the user in a conversational style. Ask about
   audience, duration, purpose, meeting context, the one-sentence story, and
   the desired HTML output filename. Use `presentation.html` if the user does
   not provide one.
3. Update `slide-plan.md` as the discussion develops.
4. Present the proposed slide overview from `slide-plan.md` to the user.
5. Wait for explicit approval before expanding `presentation.qmd` or rendering
   the deck. This is a hard gate for new decks: ask the planning questions,
   write and show the plan, and wait for an explicit approval such as
   "approved", "go ahead", or "build it".
6. Read compact result objects or small extracted tables. Never transcribe
   model results manually when a rerenderable source exists.
7. Build and render the presentation in its working folder.
8. Review screenshots or a contact sheet and iterate layout problems with the
   user.

## Slide rules

- One claim per slide.
- One dominant proof object per slide: chart, table, diagram, image, or short
  set of bullets.
- Prefer the shared CSS layout classes in `assets/theme.scss`.
- Use `.text-figure` for concise text or bullets on the left and a dominant
  figure on the right.
- Add `data-section="Section name"` to ordinary slide headers when the deck
  benefits from a quiet grey section label at the bottom of each slide.
- Slides are top-aligned by default (`center: false`), which pins that grey
  data-section watermark to the slide bottom edge. For content-light / card
  decks that leave a lot of empty space below the content, set `center: true` in
  the `presentation.qmd` YAML to balance slides vertically and use the whole
  slide height. Two interactions: the watermark then sits just under the centred
  content instead of the edge, and `.absolute` bleed-figure slides / `.fit-narrow`
  assume top-aligned slides, so re-render and re-check those after flipping it.
- For figure-heavy science slides, pair RevealJS `.columns` with an `.absolute`
  figure in the wide column when one chart or map must dominate and a balanced
  grid would crowd it. This is a supported pattern, not a last resort; see the
  "text column beside a large figure" sampler slide in `presentation.qmd`.
- Reserve freehand absolute positioning (arbitrary offsets unrelated to the
  column pattern) for genuine hero images or small decorative accents.
- For a wide, edge-to-edge decorative graphic behind a content slide's text, use
  a slide `background-image` (e.g.
  `## Title {background-image="assets/x.png" background-size="contain" background-position="bottom"}`)
  rather than an `.absolute` chunk — it always sits behind the text and spans the
  full width. Make the figure full-bleed (`scale_x_continuous(expand = expansion(0))`,
  zero side/bottom `plot.margin`) and inset any edge labels so they are not
  clipped. Suppress the `data-section` watermark on that slide so the grey label
  does not land on the graphic
  (`section.slide[data-section="Name"]::after { content: none; }`).
- Hand-drawn / custom fonts: bundle the `.ttf` under `assets/fonts/`, register it
  with `register_xkcd_font()` (systemfonts), and render the figure with the
  **ragg** device (`device = ragg::agg_png` in `ggsave`, or `#| dev: ragg_png`
  for an inline chunk). The default `png`/quartz device ignores the registration.
  This is self-contained — no system font install. The `.ttf` is the one binary
  asset that must stay versioned (it cannot be regenerated like the PNGs).
- Use fragments to pace an argument: `.fragment` to reveal bullets in turn, and
  a `.r-stack` with paired `.fade-out` / `.fade-in` (or `.fade-in-then-out`) to
  swap figures in place. Keep the static slide legible if fragments are skipped.
- For a text-left / figure-right walkthrough, put the bullets in one `.column`
  and an `.r-stack` of figures in the other, and sync each bullet to its figure
  with a shared `fragment-index`. In the stack the first figure is `.fade-out`,
  middle figures `.fade-in-then-out`, and the last `.fade-in`. Because template
  figures use transparent backgrounds, an earlier figure shows through the next
  one unless it clears itself — so every step except the last must fade out. See
  the "Pace a multi-figure argument" sampler slide.
- On a wide (~21:9) canvas, scale figure `base_size` and linewidths up so labels
  and lines do not look thin.
- For the `ref-index` style, constrain the slide title width and place a
  dominant figure on the right with syntax like
  `![](...){.absolute top=-150 right=-100 height=1000}`, with bullets in a left
  column.
- Keep slide text concise. Move detailed explanation into `.notes`.
- Keep all visible text at least 16 pt, including captions, legends, table
  text, section labels, and slide numbers.
- Use figure and table captions only when the analyst wants them. In Quarto,
  add captions with `fig-cap` or `tbl-cap` in the R chunk. Otherwise avoid
  `fig-` and `tbl-` chunk labels and do not add placeholder captions, so the
  rendered deck does not show "Figure 1" or "Table 1" headers.
- Keep analysis logic in the analysis project or in small helper functions.

## Data rules

- Presentation inputs must be generated by the analysis workflow.
- Treat `data.summary_file` in `presentation.yml` as the stable result boundary.
- When one compact result object does not exist, add named project-relative
  entries under `data.inputs` and write a project-specific adapter or refresh
  helper in `R/`.
- When a deck presents a manuscript or analysis that already has a data-loading
  script building the objects the figures need, sourcing that script is a valid
  alternative to a single summary object. Point to it from `presentation.yml`
  and keep figures regenerated at render time. Still stop with a clear message
  if it is missing; never transcribe numbers by hand.
- If a required result object is missing, stop with a clear message. Do not
  invent numbers or silently use stale values.
- Keep the self-contained HTML small. Render inline figures at screen resolution
  (`fig.retina = 1`) and pre-optimize any external images (compress, resize)
  into an `optimized/` folder before embedding. Large embedded maps and photos,
  not code, are what make these decks balloon to tens of megabytes.
- Use transparent figure backgrounds. In setup chunks use
  `dev = "png", dev.args = list(bg = "transparent")`; for ggplot2 also set
  transparent `panel.background`, `plot.background`, `legend.background`,
  `legend.box.background`, and `legend.key`.
- When a figure needs a small extract from another repository, add a refresh
  helper in `R/` and keep the compact extracted input with the deck. Ordinary
  renders should remain self-contained years later.
- Rerender after model results change.
- Do not commit local absolute paths, credentials, access tokens, private URLs,
  or unpublished personal details. Author names, emails, and affiliations may
  be included when they are intended presentation metadata.

## Visual QA

- Review rendered slides visually after substantial changes.
- When working in an app with an integrated browser or viewer, inspect the
  rendered deck there in the background before considering slide edits complete.
- Do not launch or take over the user's desktop browser solely for agent QA.
- Use `capture_slides.R` to create screenshots and a contact sheet for AI
  review when an integrated browser/viewer is not available. The script should
  use a background QA browser with an isolated temporary profile, not the user's
  interactive browser.
- `capture_slides.R` **silently skips slides that use `background-image`**: its
  slide-detection regex expects `id"…" class=`, but Reveal injects
  `data-background-*` attributes between them, so such slides (and any title
  slide with a background image) are dropped without an error — the run just ends
  short. Screenshot those manually with headless Chrome pointed at the slide hash
  (`…/<output>.html#/<slide-id>`).
- Do not read a large generated HTML presentation as text to infer appearance.
- Check for overflow, tiny labels, inconsistent spacing, crowded tables, and
  slides without a clear visual hierarchy.
- After changing slide layout, theme, figure sizing, or rendering behavior in an
  already approved deck, rerender and inspect the affected slides without asking
  first. If the result does not work as intended, correct the slide, rerender,
  and inspect again before delivering the result.

## Generated files

- Edit source files, not generated HTML.
- Do not commit local absolute paths.
- Render the ordinary working HTML beside `presentation.qmd` as a self-contained
  single file with `embed-resources: true`.
- Render through `render_presentation.R` so the browser tab title is set from
  `render.output_file` without the `.html` extension. The script anchors itself
  to its own folder, so external workflows may call it by path or source it
  without first changing `wd` to the presentation folder.

## Installation lessons

- Optional root-level agent skill shims should warn and continue if they cannot
  be installed. Deck-level files are the required scaffold.
- After installing into projects with allowlist-style `.gitignore` files, check
  whether required copied files such as logo assets, `agent-workflows/`, or
  skill shims are ignored. Add explicit allowlist exceptions when those files
  should be versioned.
