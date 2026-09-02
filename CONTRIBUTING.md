# Contributing

Contributions should address a real scientific presentation task while keeping downstream presentations reproducible and reviewable. Open an issue before a substantial visual-system, installer, or interface change.

## Add or change a slide layout

1. Give the content slide a declarative sentence title that states its main message.
2. Identify the primary figure, image, table, or explanation and give it sufficient space.
3. Add or update the marked example in `presentation.qmd`.
4. Reuse or update `assets/theme.scss`; avoid one-off styling when an existing class can express the composition.
5. Add or update the matching `slide-layouts.yml` record without changing an existing stable ID.
6. Run `Rscript scripts/generate_layout_catalog.R`.
7. Render the sampler and capture previews with manifest validation.
8. Build the learning hub and inspect desktop and mobile layouts.
9. Update documentation when public behavior or installation changes.

New layouts must include concise speaker notes, readable labels, a copyable source example, a rendered preview, and a clear consideration or limitation. Fragments, emphasis styles, backgrounds, fonts, spacing, and text-density modifiers normally belong under features rather than becoming layouts.

## Validate a change

Run the repository validation path described in [docs/architecture.md](docs/architecture.md). At minimum, check manifest/source equality, the sampler render, screenshot coverage, installer behavior, skill structure, site lint/build, and relevant browser states.

Do not commit generated HTML, QA screenshots, contact sheets, local absolute paths, credentials, private URLs, unpublished project details, or dependency caches.

## Report problems

Use the issue templates and include the smallest reproducible example. For visual problems, name the slide layout, canvas size, output format, and whether the problem appears in the source presentation, rendered HTML, PDF, or screenshot capture.
