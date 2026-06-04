# Make a presentation

Use this workflow when starting or revising a Quarto presentation based on this
template.

Treat the presentation folder requested by the user as the deck root. Install
the starter there if needed, and run render and QA commands from that folder.

## 1. Orient

Read these files from the deck root:

- `README.md`
- `AGENTS.md`
- `presentation.yml`
- `slide-plan.md`
- any analysis-project guidance relevant to the result object

Familiarize yourself with the surrounding analysis project before proposing a
deck. Identify its purpose, workflow, existing documentation, compact result
objects, and candidate plots or tables.

Do not put local absolute paths, credentials, private URLs, or unpublished
personal details into committed presentation files. Intended author names,
emails, and affiliations are acceptable presentation metadata.

## 2. Plan before slides

Discuss the presentation with the analyst in a conversational style. Ask about
the audience, duration, meeting context, purpose, one-sentence story, and the
HTML output filename. Use `presentation.html` if the analyst does not provide
one. Update `slide-plan.md` as the discussion develops with:

- one claim per slide
- the proof object for that claim
- layout class
- draft slide text
- speaker notes
- open questions

Present the proposed overview from `slide-plan.md` to the analyst. Do not edit
`presentation.qmd` or render the deck until the analyst explicitly approves the
plan. Treat this as a hard gate: even if the analyst asks you to "make a
presentation", first ask the planning questions, write the plan, show the
overview, and wait for an explicit approval such as "approved", "go ahead", or
"build it".

## 3. Build

Edit `presentation.qmd` and reuse the layout classes in `assets/theme.scss`.
Prefer a small number of strong layout patterns:

- title slide
- two-column explanation
- chart with one takeaway
- text column beside a large figure (`.columns` + an `.absolute` figure) for
  figure-heavy science slides
- progressive reveal with `.fragment`, and figure-swap in a `.r-stack` with
  paired `.fade-out` / `.fade-in`
- narrow scenario table
- three-card conclusion

Read compact analysis outputs and regenerate values during render. Do not copy
numeric values from a previous deck.

If the project does not have one compact summary object, add named
project-relative paths under `data.inputs` in `presentation.yml` and write a
project-specific adapter or refresh helper in `R/`. When the project already has
a data-loading script that builds the figure inputs (common for manuscript
decks), sourcing it from the setup chunk is a valid alternative to a single
summary object, as long as figures are regenerated rather than transcribed. For
annual model-folder comparisons, keep the comparison data-backed and record each
figure source in `slide-plan.md`.

Keep the self-contained HTML small: render inline figures at screen resolution
(`fig.retina = 1`) and pre-optimize external images into an `optimized/` folder
before embedding them.

Most presentation figures and tables should not have visible captions. If the
analyst wants captions, add them with `fig-cap` or `tbl-cap` in the R chunk.
Otherwise avoid `fig-` and `tbl-` chunk labels and do not add placeholder
caption text.

## 4. Render and review

Render with:

```bash
/usr/local/bin/Rscript render_presentation.R
```

This writes the ordinary working HTML beside `presentation.qmd` as a
self-contained file that can be shared directly. Render through this script so
the browser tab title is derived from `presentation.yml` `render.output_file`
without the `.html` extension.

Capture screenshots and a contact sheet:

```bash
/usr/local/bin/Rscript capture_slides.R
```

Review the images. Check for overflow, small text, visual clutter, weak
hierarchy, awkward whitespace, inconsistent spacing, and slides without a
dominant proof object. Also check the rendered HTML file size: if it has grown
to tens of megabytes, optimize the embedded images before delivering.

If the app running the agent has an integrated browser or viewer, use that
surface for visual inspection in the background without disturbing the analyst.
Do not launch or take over the user's desktop browser for agent QA. Otherwise,
use `capture_slides.R`, which is designed to capture slides with a background
QA browser and an isolated temporary profile.

Avoid reading generated HTML as text to judge layout. Read the source `.qmd`
for semantics and use the in-app browser or rendered images for appearance.

After any requested slide, layout, theme, figure-size, or rendering change to an
already approved deck, rerender and visually inspect the affected slides without
asking first. If the result does not match the request, keep correcting,
rerendering, and inspecting until it does or until a real blocker remains.

## 5. Deliver

Keep the `.qmd`, config, helper functions, slide plan, and theme under version
control. Publish HTML and PDF artifacts according to the project convention.
Add a PowerPoint deliverable only if the audience requires manual rearrangement
in Microsoft Office.

After installing the starter into a project with an allowlist-style `.gitignore`,
check that required copied files such as logo assets, `agent-workflows/`, and
skill shims are not accidentally ignored.
