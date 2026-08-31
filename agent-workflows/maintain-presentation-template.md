# Maintain the presentation template

Use this workflow only in the presentation-template repository.

## Preserve the public contracts

Treat `slide-patterns.yml` as the canonical catalogue. Pattern IDs are stable links shared by the Quarto slide, generated JSON, preview image, and learning-hub hash. Do not rename an ID without an explicit compatibility decision.

Keep `presentation.yml` backward compatible for downstream decks. Repository-only site and CI dependencies must not be copied into installed analysis projects.

## Add or revise a pattern

Update the marked example in `presentation.qmd`, its reusable style in `assets/theme.scss`, and its manifest record together. Give the slide one claim and one proof object, include concise notes, and reuse existing helpers before adding a new abstraction. Utilities and modifiers belong in an existing pattern entry unless they represent a distinct audience-facing layout.

Regenerate the catalogue, render the sampler, and capture every preview. Manifest order, rendered slide order, source markers, snippets, and previews must match exactly.

## Keep workflows focused

Stable scientific, data, writing, and privacy invariants belong in `AGENTS.md`. Creation, review, and maintenance procedures belong in their focused workflows. Install only the creation and review skills into downstream projects.

## Validate the repository

Run the catalogue contract check, sampler render, screenshot capture, installer smoke tests, skill validation, site lint/build, and desktop/mobile browser QA. Inspect the deck contact sheet and representative site states. Update the learning hub and contributor documentation when public behavior changes.

Do not commit generated HTML or QA images. Do not commit local paths, credentials, or unpublished project details.
