# Architecture and maintenance

The repository has four connected surfaces: the downstream presentation scaffold, the sampler, focused agent workflows, and the public learning hub.

## Public contracts

`presentation.yml` is the downstream configuration boundary. Keep existing project, data, and render fields backward compatible.

`slide-layouts.yml` is the canonical catalogue. Each entry records whether it is a layout or feature, a stable ID, public name, category, evidence or explanation type, intended use, Quarto code, classes, caveat, source marker, and preview filename. The stable ID is shared by the Quarto heading, source markers, generated JSON, screenshot filename, and website hash.

`presentation.qmd` is both the installable starter and the complete sampler. Catalogue markers surround each example so `scripts/generate_layout_catalog.R` can extract the actual source rather than maintaining handwritten website snippets.

## Build flow

1. The catalogue generator validates fields, IDs, source markers, and slide anchors, then writes `website/public/layouts.json`.
2. `render_presentation.R` renders a self-contained sampler and copies the complete helper and asset trees for isolated output builds.
3. `capture_slides.R --manifest slide-layouts.yml` discovers Reveal slide tags regardless of attribute order, checks exact manifest order, writes one PNG per stable ID, and creates a contact sheet.
4. The website reads the generated JSON and preview directory, builds the client bundle, and publishes it under the `/presentation-template/` GitHub Pages base path.
5. Pull requests run the contract, render, installer, skill, and website checks. Pushes to `main` additionally deploy the Pages artifact.

## Layout and feature boundary

A layout is an audience-facing composition that a user can request by name and Quarto class, such as `Text + figure` / `.text-figure`. A feature modifies a layout or rendering method, such as fragments, a background image, custom figure fonts, or table density. This distinction keeps the layout selection concise without hiding supported authoring techniques.

## Skill boundaries

`make-presentation` covers scientific orientation, the approval gate, and data-backed construction. `review-presentation` covers rendering, screenshots, correction, and delivery. Both are installed downstream.

`maintain-presentation-template` covers this repository's catalogue, sampler, site, installer, and validation contracts. It remains repository-local.

Stable writing, scientific, data, privacy, visual, and installation rules remain in `AGENTS.md`.

## Generated and pinned dependencies

The repository pins website dependencies in `website/package-lock.json` and CI R dependencies in the workflow. Those repository-only dependencies are not copied by `install_into_project.R`. Generated HTML, QA images, `assets/generated/`, website preview images, and deployment output remain ignored.

## PowerPoint evaluation

The supported output is currently RevealJS HTML. A later evaluation should compare Quarto's native PowerPoint output, a dedicated PowerPoint reference template, and image-based export of the reviewed HTML slides. RevealJS classes and CSS do not translate directly to editable PowerPoint layouts, so any PowerPoint route needs an explicit mapping and separate visual validation.
