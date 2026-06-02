# presentation-template

A reusable, AI-friendly Quarto presentation starter for scientific projects.
The source is human-readable, the results are rerenderable, and the workflow is
shared by Codex, Claude Code, and human collaborators.

## Recommendation

Use a Quarto `revealjs` presentation as the canonical deck:

- Edit `presentation.qmd` and `slide-plan.md`, not the generated HTML.
- Read result objects produced by the analysis project. Do not copy numeric
  results into slide text by hand.
- Render normal HTML with external assets while iterating.
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
`AGENTS.md` or `CLAUDE.md`.

1. Familiarize yourself with the analysis project and its compact result
   objects.
2. Discuss the audience, purpose, duration, meeting context, main claim, and
   desired HTML output filename with the analyst.
3. Draft `slide-plan.md`. Each slide gets one claim, one proof object, a layout,
   draft slide text, and speaker notes.
4. Present the proposed slide overview to the analyst and wait for explicit
   approval.
5. Update `presentation.qmd`, keeping computations in source code or a compact
   result object.
6. Render from the presentation folder:

   ```bash
   /usr/local/bin/Rscript render_presentation.R
   ```

   The ordinary working HTML is written beside `presentation.qmd`.

7. Capture QA screenshots and a contact sheet:

   ```bash
   /usr/local/bin/Rscript capture_slides.R
   ```

8. Inspect the rendered presentation visually. Iterate with the analyst,
   rerender, capture screenshots again, and review the affected slides.

## SPiCT example

The beaked-redfish SPiCT project already writes a compact summary object:

```text
data/model_output/spict_summaries/sum_beaked_redfish_spict_2026.rds
```

This template consumes that stable result boundary. The example config is
[`examples/reb-spict/presentation.yml`](examples/reb-spict/presentation.yml).
Render it from this repository by passing the local SPiCT project root:

```bash
/usr/local/bin/Rscript render_presentation.R \
  --config examples/reb-spict/presentation.yml \
  --project-root "/path/to/reb-spict"
```

The example config writes its working preview under
`examples/reb-spict/preview/`, keeping its generated assets separate from the
generic template preview.

The same pattern should be copied into `spict-template`: create a presentation
folder, point its config at the current annual summary RDS, and render the deck
after `run_assessment()`.

## Files

```text
.
├── presentation.qmd                  # canonical slide source
├── presentation.yml                  # project-specific metadata and result path
├── slide-plan.md                     # discussion-first slide overview
├── render_presentation.R             # normal rendering and optional preview output
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
- Give every slide one claim and one dominant visual or table.
- Use short titles that state the finding.
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
