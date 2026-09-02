# Review a presentation

Use this workflow when an approved or existing presentation needs rendering, visual QA, correction, or delivery.

## Inspect before rendering

Read the slide source, configuration, theme, and recent analysis outputs. Confirm that displayed values are generated from current project inputs and that required files exist. Review source rather than generated HTML for semantics.

## Render

Run `Rscript render_presentation.R` from the presentation folder or call the script by path. The script sets its own working directory, derives the browser title from `presentation.yml`, embeds resources, and reports output size. Treat missing dependencies or inputs as blockers; do not substitute stale values.

## Capture and inspect

Run `Rscript capture_slides.R` or use an integrated background browser. The capture script uses an isolated profile and supports slides with background images. Do not take over the user's interactive desktop browser.

Inspect every slide for overflow, labels below 16 pt, clipped content, weak hierarchy, awkward whitespace, inconsistent spacing, crowded tables, fragment resting states, non-declarative content titles, figures that are too small, and an unclear relationship between the title and primary evidence or explanation. Inspect the contact sheet for presentation-level rhythm and the individual images for detail. Do not infer appearance from generated HTML text.

## Correct and repeat

Fix source files, rerender, and reinspect affected slides without asking for another approval when the presentation plan is already approved. Continue until the requested result works or a real blocker remains. Check that self-contained HTML has not grown to tens of megabytes; optimize embedded media when it has.

## Deliver

Keep source, configuration, helpers, and the approved slide plan under version control. Deliver self-contained HTML and any requested PDF. Add PowerPoint only when a separately validated export workflow is required. Report incomplete coverage or unresolved layout risks explicitly.
