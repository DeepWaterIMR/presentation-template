# presentation-template

An AI-friendly Quarto RevealJS starter for scientific presentations. It keeps the editable source, analysis inputs, rendered deck, and visual-review workflow connected.

**Learning hub:** <https://deepwaterimr.github.io/presentation-template/>

**Repository:** <https://github.com/DeepWaterIMR/presentation-template>

## What the template guarantees

- One claim and one dominant proof object per slide.
- Results read from rerenderable analysis outputs rather than copied values.
- A self-contained HTML deck that can be shared as one file.
- Reusable layouts for figures, maps, tables, concepts, fragments, and conclusions.
- Separate skills for deck creation, rendered-deck review, and template maintenance.
- Screenshot and contact-sheet review after substantive visual changes.

## Start with an agent

Give the agent this repository URL, the analysis project, and the folder where the deck should live:

```text
Use https://github.com/DeepWaterIMR/presentation-template to initiate a presentation in docs/presentation. Familiarize yourself with the analysis project first. Discuss the audience, purpose, duration, meeting context, one-sentence story, and HTML output filename with me. Prepare slide-plan.md, show me the overview, and wait for approval before building.
```

The `make-presentation` skill owns orientation, discussion, planning, and construction. The `review-presentation` skill owns rendering, screenshots, correction, and delivery checks.

## Install manually

From a clone of this repository:

```bash
Rscript install_into_project.R --target "/path/to/project"
```

The default destination is `docs/presentation/`. Use `--presentation-dir presentation` to choose another project-relative folder. The installer refuses to overwrite existing deck files unless `--force` is supplied, never overwrites project-level agent guidance, and warns when required files are ignored by Git.

## Build and review a deck

1. Learn the analysis and identify stable result objects or data-loading scripts.
2. Agree on the claim spine and slide plan.
3. Connect project-relative inputs through `presentation.yml`.
4. Build slides from the approved plan.
5. Run `Rscript render_presentation.R`.
6. Run `Rscript capture_slides.R` and inspect every slide plus the contact sheet.

Use `presentation.html` when no output filename is specified. Keep PowerPoint as an optional secondary deliverable when colleagues need to rearrange slides in Microsoft Office.

## Stable interfaces

- `presentation.yml` is the downstream deck configuration and data-input boundary.
- `slide-plan.md` records the approved claim, proof object, layout, visible text, notes, and status for each slide.
- `slide-patterns.yml` is the template repository's public pattern catalogue; stable IDs connect sampler slides, code snippets, previews, and learning-hub links.
- `assets/theme.scss` contains the reusable visual system.
- `R/presentation_helpers.R` contains small adapters and plotting helpers.

## Development

Repository maintenance is documented in [docs/architecture.md](docs/architecture.md) and [CONTRIBUTING.md](CONTRIBUTING.md). The `maintain-presentation-template` skill applies only to this repository. Generated HTML, screenshots, contact sheets, and generated background assets are build artifacts and are not committed.

The repository-authored code and documentation are MIT licensed. The bundled IMR logo and font asset are excluded; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
