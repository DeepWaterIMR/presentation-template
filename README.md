# presentation-template

A Quarto RevealJS template for scientific presentations. It provides predefined slide layouts, project-relative data interfaces, and a render-and-review workflow.

**Learning hub:** <https://deepwaterimr.github.io/presentation-template/>

**Repository:** <https://github.com/DeepWaterIMR/presentation-template>

## What the template provides

- Content slides with a full-sentence title that states the main message.
- Layouts that give the primary figure, image, table, or explanation sufficient space.
- Project-relative interfaces for reading rerenderable analysis outputs.
- A self-contained HTML presentation that can be shared as one file.
- Focused skills for presentation creation, rendered-slide review, and template maintenance.
- Scripts for rendering slides and producing screenshots and contact sheets for review.

The slide-design guidance is informed by the assertion–evidence approach described by Michael Alley in *The Craft of Scientific Presentations*. The template adapts that approach to its existing Quarto visual system; it does not reproduce Alley's template.

## Start with an agent

Give the agent this repository URL, the analysis project, and the folder where the presentation should live:

```text
Use https://github.com/DeepWaterIMR/presentation-template to initiate a presentation in docs/presentation. Familiarize yourself with the analysis project first. Discuss the audience, purpose, duration, meeting context, one-sentence story, and HTML output filename with me. Prepare slide-plan.md, show me the overview, and wait for approval before building.
```

The `make-presentation` skill covers orientation, discussion, planning, and construction. The `review-presentation` skill covers rendering, screenshots, correction, and delivery checks.

## Install manually

From a clone of this repository:

```bash
Rscript install_into_project.R --target "/path/to/project"
```

The default destination is `docs/presentation/`. Use `--presentation-dir presentation` to choose another project-relative folder. The installer refuses to overwrite existing presentation files unless `--force` is supplied, never overwrites project-level agent guidance, and warns when required files are ignored by Git.

## Build and review a presentation

1. Learn the analysis and identify stable result objects or data-loading scripts.
2. Agree on the sequence of messages and the slide plan.
3. Connect project-relative inputs through `presentation.yml`.
4. Select layouts from the [learning hub](https://deepwaterimr.github.io/presentation-template/).
5. Build the presentation from the approved plan.
6. Run `Rscript render_presentation.R`.
7. Run `Rscript capture_slides.R` and inspect every slide plus the contact sheet.

Use `presentation.html` when no output filename is specified. PowerPoint export is not yet part of the supported workflow; it will be evaluated after the HTML layouts are settled.

## Stable interfaces

- `presentation.yml` is the downstream presentation configuration and data-input boundary.
- `slide-plan.md` records the approved message, supporting evidence or explanation, layout, visible text, notes, and status for each slide.
- `slide-layouts.yml` is the repository's public layout catalogue. Stable IDs connect sampler slides, source snippets, previews, and learning-hub links.
- `assets/theme.scss` contains the reusable visual system.
- `R/presentation_helpers.R` contains small adapters and plotting helpers.

## Development

Repository maintenance is documented in [docs/architecture.md](docs/architecture.md) and [CONTRIBUTING.md](CONTRIBUTING.md). The `maintain-presentation-template` skill applies only to this repository. Generated HTML, screenshots, contact sheets, and generated presentation assets are build artifacts and are not committed.

The repository-authored code and documentation are MIT licensed. The bundled IMR logo and font asset are excluded; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
