# Architecture and maintenance

The repository has four connected surfaces: the downstream deck scaffold, the sampler, focused agent workflows, and the public learning hub.

## Public contracts

`presentation.yml` is the downstream configuration boundary. Keep existing project, data, and render fields backward compatible.

`slide-patterns.yml` is the canonical catalogue for this repository. Each record supplies a stable ID, category, proof object, use case, classes, caveat, source marker, and preview filename. The stable ID is shared by the Quarto heading, source markers, generated JSON, screenshot filename, and website hash.

`presentation.qmd` is both the installable starter and the complete sampler. Pattern markers surround each catalogue slide so `scripts/generate_pattern_catalog.R` can extract the real source rather than maintaining handwritten website snippets.

## Build flow

1. The catalogue generator validates manifest fields, IDs, source markers, and slide anchors, then writes `website/public/patterns.json`.
2. `render_presentation.R` renders a self-contained sampler and copies the complete helper and asset trees for isolated output builds.
3. `capture_slides.R --manifest slide-patterns.yml` discovers Reveal slide tags regardless of attribute order, checks exact manifest order, writes one PNG per stable ID, and creates a contact sheet.
4. The website reads the generated JSON and preview directory, builds the client bundle, and publishes it under the `/presentation-template/` GitHub Pages base path.
5. Pull requests run the complete contract, render, installer, skill, and website checks. Pushes to `main` additionally deploy the Pages artifact.

## Skill boundaries

`make-presentation` covers scientific orientation, the approval gate, and data-backed construction. `review-presentation` covers rendering, screenshots, correction, and delivery. Both are installed downstream.

`maintain-presentation-template` covers this repository's catalogue, sampler, site, installer, and validation contracts. It remains repository-local.

Stable writing, scientific, data, privacy, visual, and installation invariants remain in `AGENTS.md`.

## Generated and pinned dependencies

The repository pins website dependencies in `website/package-lock.json` and CI R dependencies in the workflow. Those repository-only dependencies are not copied by `install_into_project.R`. Generated HTML, QA images, `assets/generated/`, website preview images, and deployment output remain ignored.
