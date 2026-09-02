# Maintain the presentation template

Use this workflow only in the presentation-template repository.

## Preserve the public contracts

Treat `slide-layouts.yml` as the canonical catalogue. Layout and feature IDs are stable links shared by the Quarto example, generated JSON, preview image, and learning-hub hash. Do not rename an ID without an explicit compatibility decision.

Keep `presentation.yml` backward compatible for downstream presentations. Repository-only site and CI dependencies must not be copied into installed analysis projects.

## Add or revise a layout

Update the marked example in `presentation.qmd`, its reusable style in `assets/theme.scss`, and its catalogue entry together. Give each content slide a declarative sentence title and one primary figure, image, table, or explanation. When a visual is present, give it most of the content area. Include concise notes and reuse existing helpers before adding a new abstraction.

Document fragments, emphasis, background images, fonts, spacing, and text-density modifiers as features unless they represent a distinct audience-facing composition.

Regenerate the catalogue, render the sampler, and capture every preview. Catalogue order, rendered slide order, source markers, snippets, and previews must match exactly.

## Keep workflows focused

Stable scientific, data, writing, privacy, and visual rules belong in `AGENTS.md`. Creation, review, and maintenance procedures belong in their focused workflows. Install only the creation and review skills into downstream projects.

## Validate the repository

Run the catalogue contract check, sampler render, screenshot capture, installer smoke tests, skill validation, site lint/build, and desktop/mobile browser QA. Inspect the presentation contact sheet and representative site states. Update the learning hub and contributor documentation when public behavior changes.

Do not commit generated HTML or QA images. Do not commit local paths, credentials, or unpublished project details.
