# presentation-template

A reusable, AI-friendly Quarto presentation starter for scientific projects.
The source is human-readable, the results are rerenderable, and the workflow is
shared by Codex, Claude Code, and human collaborators.

## Recommendation

Use a Quarto `revealjs` presentation as the canonical deck:

- Edit `presentation.qmd` and `slide-plan.md`, not the generated HTML.
- Read result objects produced by the analysis project. Do not copy numeric
  results into slide text by hand.
- Render a self-contained HTML file so the deck can be sent around as one file.
- Export or print a PDF for review and archiving.
- Treat PowerPoint as an optional secondary deliverable when colleagues need to
  rearrange slides in Microsoft Office. A Quarto `pptx` render can use a custom
  `reference-doc`, but it cannot reproduce every RevealJS layout, CSS rule, or
  interactive fragment.

Quarto RevealJS supports speaker notes, custom themes, columns, fragments, and
published HTML presentations. Quarto also supports PowerPoint output with
speaker notes and custom reference templates:

- <https://quarto.org/docs/presentations/revealjs/>
- <https://quarto.org/docs/presentations/powerpoint.html>

## Workflow

### Agent kickoff

Give the agent the GitHub URL for this template, the analysis project, and the
folder where the presentation should live. A useful opening request is:

```text
Use <template GitHub URL> to initiate a presentation in <project-relative
folder>. Familiarize yourself with this analysis project first. Then discuss
the presentation with me, including the HTML output filename. Use
presentation.html if I do not give one. Prepare slide-plan.md, show me the
proposed slide overview, and wait for my approval before building or rendering
slides.
```

The agent should keep working from the chosen presentation folder after
installation.

### Install manually

Install the starter into an existing analysis project. By default the deck is
created in `docs/presentation/`:

```bash
/usr/local/bin/Rscript install_into_project.R --target "/path/to/project"
```

Choose another folder within the project when that suits the project better:

```bash
/usr/local/bin/Rscript install_into_project.R \
  --target "/path/to/project" \
  --presentation-dir "presentation"
```

The installer copies the deck into the chosen folder and installs the
lightweight Codex and Claude Code skill shims at the target project root. It
also copies deck-level `README.md`, `AGENTS.md`, and `CLAUDE.md` files into the
presentation folder. It does not overwrite an existing project-level
`AGENTS.md` or `CLAUDE.md`. Root-level agent shims are useful but optional: if
they cannot be installed, the installer warns and continues with the deck
scaffold.

1. Familiarize yourself with the analysis project and its compact result
   objects.
2. Discuss the audience, purpose, duration, meeting context, main claim, and
   desired HTML output filename with the analyst.
3. Draft `slide-plan.md`. Each slide gets one claim, one proof object, a layout,
   draft slide text, and speaker notes.
4. Present the proposed slide overview to the analyst and wait for explicit
   approval. This is a hard gate for new decks: do not expand
   `presentation.qmd` or render slides until the analyst says to build the
   approved plan.
5. Update `presentation.qmd`, keeping computations in source code or a compact
   result object.
6. Render from the presentation folder:

   ```bash
   /usr/local/bin/Rscript render_presentation.R
   ```

   The ordinary working HTML is written beside `presentation.qmd` as a
   self-contained file. The render script anchors itself to its own location,
   so it can also be run by path or sourced from another working directory when
   an external workflow cannot set `wd` to the presentation folder first.

7. Capture QA screenshots and a contact sheet:

   ```bash
   /usr/local/bin/Rscript capture_slides.R
   ```

8. Inspect the rendered presentation visually. When modifying an already
   approved deck, rerender and inspect the affected slides without asking first.
   If the result does not match the request, correct it, rerender, and inspect
   again before delivering.

After installing into projects with allowlist-style `.gitignore` files, check
whether required copied files are ignored. The installer warns when Git reports
that copied files such as logo assets, `agent-workflows/`, or skill shims are
ignored. Add explicit allowlist exceptions when those files should be versioned.

For Codex visual QA, use the app's integrated browser or viewer when it can
inspect the rendered deck in the background without disturbing the analyst. Do
not launch or take over the analyst's desktop browser for agent QA. If an
integrated browser/viewer is unavailable or blocked, use `capture_slides.R` and
inspect its screenshots and contact sheet. The capture script is designed for a
background Chromium-compatible QA browser with an isolated temporary profile; it
does not auto-select the user's installed Chrome or Brave app.

## Projects without one compact result object

Some assessment projects do not yet expose a single presentation summary object.
Use a project-specific adapter rather than transcribing values by hand:

1. List stable, project-relative inputs in `presentation.yml`.

   ```yaml
   data:
     adapter: "project_adapter_name"
     summary_file: "path/to/current-model-output.rds"
     inputs:
       previous_model_data: "path/to/previous-model-data.rds"
       historic_retro: "path/to/historic-retrospective.csv"
   ```

2. Add adapter and plotting helpers in `R/`. For small extracts from nearby
   repositories, add a refresh helper in `R/` and store the compact extracted
   input with the deck.
3. Keep ordinary renders self-contained. A future rerender should not depend on
   local absolute paths or a neighbouring repository still being in the same
   place.

For comparisons between annual model folders, keep the comparison data-backed:
declare the model outputs in `data.inputs`, build figures from those inputs
during render, and record the source table or model object for each slide in
`slide-plan.md`.

### Reusing an existing data-loading script

A deck that presents a manuscript or analysis often does not need a new summary
object: the project already has a script that loads the figure inputs (indices,
fits, correlation tables, and so on). Sourcing that script from the setup chunk
is a valid alternative to a single `summary_file`, as long as figures are
regenerated at render time rather than transcribed. Point at the script with a
project-relative path, fail clearly when it is missing, and keep the compact
inputs the figures depend on with the deck so ordinary renders stay
self-contained.

## File size and figures

Self-contained HTML decks embed every figure and image, so they can balloon to
tens of megabytes — large embedded maps and photos, not code, are the usual
cause. Keep them light:

- Render inline figures at screen resolution (`fig.retina = 1`, set in the
  `presentation.qmd` setup chunk).
- Use a transparent graphics device for inline plots (`dev = "png"`,
  `dev.args = list(bg = "transparent")`) and make ggplot panel, plot, legend,
  and legend-key backgrounds transparent. The starter sets
  `ggplot2::theme_set(presentation_theme())` when ggplot2 is available.
- Pre-optimize external images (compress and resize) into an `optimized/` folder
  before embedding them. Keep the originals elsewhere.
- On a wide (~21:9) canvas, scale figure `base_size` and linewidths up so labels
  and lines stay legible; the default ggplot sizes look thin when stretched.
- Check the rendered HTML file size before delivery. If it has grown to tens of
  megabytes, optimize embedded images or lower inline figure dimensions before
  sharing.

## Files

```text
.
├── presentation.qmd                  # canonical slide source
├── presentation.yml                  # project-specific metadata and result path
├── slide-plan.md                     # discussion-first slide overview
├── render_presentation.R             # self-contained rendering and optional preview output
├── capture_slides.R                  # screenshots and contact sheet for QA
├── install_into_project.R            # overlay starter into an analysis repo
├── R/presentation_helpers.R          # result adapters and small plotting helpers
├── assets/theme.scss                 # shared visual system
├── assets/HI_logo_farger_engelsk.png # title-slide logo
├── agent-workflows/make-presentation.md
├── .agents/skills/make-presentation/SKILL.md
└── .claude/skills/make-presentation/SKILL.md
```

## Codex and Claude Code

Keep the repository contract in `AGENTS.md`. Codex reads `AGENTS.md`
automatically. Claude Code reads `CLAUDE.md`, which imports the same contract
with `@AGENTS.md`.

The repo-scoped `make-presentation` skill is intentionally thin. It points both
tools to one shared workflow file. This keeps the procedure discoverable
without loading a long set of instructions into every session.

## Visual quality rules

- Use a small set of layout classes instead of freehand absolute positioning.
- Use `.text-figure` for a two-column slide with concise text on the left and a
  dominant figure on the right.
- Add `data-section="Section name"` to slide headers when a quiet grey
  center-bottom section label improves navigation.
- Use `.figure-wide-right` or `.map-slide` as modifiers for `.text-figure` when
  the proof object needs more space.
- For figure-heavy science slides, pair RevealJS `.columns` with an `.absolute`
  figure in the wide column when one chart or map must dominate. This is a
  supported pattern; see the "text column beside a large figure" sampler slide.
  For the `ref-index` style, constrain the title width and place the figure with
  syntax like `![](...){.absolute top=-150 right=-100 height=1000}`.
- Pace arguments with fragments: `.fragment` reveals bullets in turn, and a
  `.r-stack` with paired `.fade-out` / `.fade-in` swaps figures in place (e.g.
  two species or two scenarios) without moving the audience's eye.
- Use `.alert-box`, `.deadline`, and `.closing` sparingly for decision-facing
  warnings, review deadlines, and closing text.
- Give every slide one claim and one dominant visual or table.
- Use short titles that state the finding.
- Keep all visible text at least 16 pt. The starter `.small-note` class is
  intentionally larger than a conventional document footnote so captions
  remain readable during a meeting.
- Most presentation figures and tables should not have captions. If captions
  are wanted, add them explicitly in the R chunk using `fig-cap` or `tbl-cap`.
  Otherwise avoid `fig-` and `tbl-` chunk labels and omit placeholder captions
  so Quarto does not render "Figure 1" or "Table 1" headers.
- Keep repeated metrics in consistent cards.
- Put details in speaker notes or the appendix.
- Review a contact sheet after every substantial change.

The generated HTML is the wrong input for an AI review. The efficient review
bundle is:

1. `slide-plan.md`
2. `presentation.qmd`
3. one screenshot per slide
4. one contact sheet
5. the compact result object or a small extracted table of metrics

When a presentation needs a small extract from a neighbouring repository,
write a refresh helper in the deck's `R/` folder and keep the compact extract
with the deck. The ordinary render should stay self-contained so that the
presentation remains reproducible after the surrounding projects move or
change.
