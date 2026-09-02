# Presentation template contract

Shared rules for scientific presentation projects based on this template. Task procedures live in the focused skills and `agent-workflows/`.

## Skill routing

- Use `make-presentation` to plan or build a new presentation, make substantive slide revisions, or reconnect slides to changed analysis outputs.
- Use `review-presentation` when an approved or existing presentation needs rendering, screenshots, visual correction, or delivery checks.
- In this template repository only, use `maintain-presentation-template` when changing supported layouts or features, the catalogue, learning hub, installer, or validation workflow.

## Writing and approval

- Do not hard-wrap prose. Keep each paragraph or list item on one source line and use line breaks only for real Markdown structure.
- Keep visible slide text concise, professional, factual, and free of filler or promotional language.
- Give each content slide a complete declarative sentence title that states its main message. Title and section slides are exceptions.
- Do not invent text, results, or examples merely to fill space in a project presentation.
- Before editing a presentation, read `README.md`, `slide-plan.md`, and `presentation.yml`, then learn the surrounding analysis project.
- For a new presentation, discuss audience, duration, purpose, meeting context, one-sentence story, and output filename; use `presentation.html` by default.
- Draft and show `slide-plan.md`, then wait for explicit approval before expanding `presentation.qmd` or rendering.

## Scientific and data rules

- Give every content slide one clear message supported by a primary figure, image, table, or explanation.
- Generate presentation inputs through the analysis workflow. Treat `data.summary_file`, named `data.inputs`, or a declared project data-loading script as the stable boundary.
- Never transcribe numeric results from another presentation when a rerenderable source exists.
- Stop clearly when a required input is missing; do not invent values or silently use stale files.
- Keep analysis logic in the analysis project or small helpers. Reuse a helper when one figure appears on multiple slides.
- Keep project inputs relative. Do not commit local absolute paths, credentials, access tokens, private URLs, or unpublished personal details.
- Author names, affiliations, and contact details may be included when they are intended presentation metadata.

## Visual rules

- Prefer the named layouts demonstrated in the learning hub and implemented in `assets/theme.scss`.
- When a figure or image is shown, it should normally occupy most of the slide's content area.
- Concepts should be paired with a photograph, schematic, map, or representative scientific figure that contributes to the explanation.
- Keep all visible text at least 16 pt, including captions, legends, tables, section labels, and slide numbers.
- Keep detailed explanation in speaker notes.
- Use captions only when requested. Otherwise avoid `fig-` and `tbl-` chunk-label prefixes and placeholder captions.
- Use transparent plot, panel, legend, and legend-key backgrounds.
- Render inline figures at screen resolution and optimize large external images before embedding them in self-contained HTML.
- Reserve arbitrary absolute positioning for genuine full-bleed images or small accents; use the supported figure layouts for scientific figures.
- Keep fragment slides legible in their resting state and ensure transparent intermediate figures fade out before the next one appears.
- Bundle custom fonts under `assets/fonts/`, register them with `systemfonts`, and render those figures with `ragg`.

## Render and delivery rules

- Edit source files, not generated HTML.
- Render through `render_presentation.R` and visually review the result after substantive changes.
- Use the integrated background browser or `capture_slides.R`; do not take over the user's desktop browser for QA.
- Check every slide for overflow, tiny labels, weak hierarchy, awkward spacing, crowded tables, and an unclear relationship between title and supporting evidence or explanation.
- Rerender and reinspect affected slides after layout, theme, figure-size, or rendering changes.
- Deliver self-contained HTML beside the Quarto source. Add PDF or PowerPoint only when the project requires it.
- Keep generated HTML, screenshots, contact sheets, and generated presentation assets out of version control.

## Installation rules

- Presentation-level files are required; project-root skill shims are useful but optional and must warn rather than abort when they cannot be installed.
- Never overwrite an existing project-level `AGENTS.md` or `CLAUDE.md`.
- After installation into an allowlist-style repository, report required copied files that Git ignores.
