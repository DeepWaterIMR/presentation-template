# Make a presentation

Use this workflow to plan and build a scientific Quarto presentation from this template. Treat the requested presentation folder as the deck root.

## Orient

Read `README.md`, `AGENTS.md`, `presentation.yml`, and `slide-plan.md`, then learn the surrounding analysis project. Identify its purpose, workflow, compact result objects, data-loading scripts, and candidate proof objects. Keep local absolute paths, credentials, private URLs, and unpublished personal details out of committed files.

## Agree on the deck

Discuss the audience, duration, meeting context, purpose, one-sentence story, and HTML output filename. Use `presentation.html` when no name is provided. Update `slide-plan.md` with one claim, one proof object, one layout, draft visible text, notes, and status per slide.

Show the proposed overview and wait for explicit approval before expanding `presentation.qmd` or rendering a new deck. Approval of the plan is the hard gate.

## Build from stable inputs

Use the live learning hub when choosing a layout; in the template repository, `slide-patterns.yml` is the catalogue source. Keep analysis logic in the analysis project or small helpers. Read numbers and figures from `data.summary_file`, named `data.inputs`, or a project data-loading script; never transcribe model results from another deck.

When no compact summary exists, add project-relative inputs and a focused adapter or refresh helper. Fail clearly when required inputs are missing. Reuse plotting helpers when a figure appears more than once. Keep inline graphics at screen resolution and pre-optimize large external images.

Move detail into speaker notes, preserve scientific meaning and uncertainty, and keep visible text at least 16 pt. Add captions only when the analyst wants them.

## Review and deliver

After building, follow `agent-workflows/review-presentation.md`. The deck is not complete until the rendered path has been visually reviewed.
