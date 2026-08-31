# Contributing

Contributions should improve a real presentation task while keeping downstream decks reproducible and easy to review. Open an issue before a large visual-system, installer, or interface change.

## Add or change a slide pattern

1. Give the pattern one claim and one dominant proof object.
2. Add or update the marked example in `presentation.qmd`.
3. Reuse or update `assets/theme.scss`; avoid one-off styling when an existing class can express the layout.
4. Add or update the matching `slide-patterns.yml` record without changing an existing stable ID.
5. Run `Rscript scripts/generate_pattern_catalog.R`.
6. Render the sampler and capture previews with manifest validation.
7. Build the learning hub and inspect desktop and mobile layouts.
8. Update documentation when public behavior or installation changes.

New patterns must include concise speaker notes, readable labels, a copyable source example, a rendered preview, and a clear caveat. Utilities such as spacing or text-size modifiers should normally remain part of an existing pattern rather than becoming catalogue entries.

## Validate a change

Run the repository validation path described in [docs/architecture.md](docs/architecture.md). At minimum, check manifest/source equality, the sampler render, screenshot coverage, installer behavior, skill structure, site lint/build, and relevant browser states.

Do not commit generated HTML, QA screenshots, contact sheets, local absolute paths, credentials, private URLs, unpublished project details, or dependency caches.

## Report problems

Use the issue templates and include the smallest reproducible example. For visual problems, name the slide pattern, canvas size, output format, and whether the problem appears in the source deck, rendered HTML, PDF, or screenshot capture.
