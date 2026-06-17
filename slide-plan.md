# Slide plan

Agree on this overview before expanding `presentation.qmd`. Add, remove, and
reorder slides freely. Keep one row per slide. Keep the plan free of local
absolute paths, credentials, and unpublished personal details. Do not build or
render a new deck until the user has explicitly approved the proposed overview.

## Claim Spine

Write the one-sentence story before building slides. The story should say what
the audience should understand, discuss, or decide.

## Main Deck

| ID | Time | Claim | Proof object | Layout | Draft slide text | Speaker notes | Status |
|---|---:|---|---|---|---|---|---|
| 01 | 0:30 | The title states the decision or question clearly. | Minimal title slide | `title-slide` | Project title, subtitle, authors, meeting, date | Explain the purpose in one sentence. | draft |
| 02 | 1:00 | The audience should know the story before seeing details. | Three-step flow | `process-flow` | Question, evidence, implication | State what the audience should listen for. | draft |
| 03 | 1:00 | Results come from a rerenderable analysis boundary. | Data provenance diagram | `two-column` | Analysis project -> compact result object or stable model outputs -> deck | Name each source object and its update cadence. | draft |
| 04 | 2:00 | Replace this with the main empirical finding. | Chart or table | `chart-slide` | One sentence takeaway | Explain uncertainty and caveats. | draft |
| 05 | 0:30 | The starter deck shows available layout classes before project slides are finalised. | Optional style sampler | `grid-3`, `diagnostic-grid`, `takeaway-grid`, `scenario-figure` | Reusable slide-style examples | Delete sampler slides from project decks after choosing the needed patterns. | optional |
| 06 | 1:30 | Replace this with the decision-facing implication. | Scenario comparison | `table-slide` | One sentence takeaway | Explain which scenarios matter and why. | draft |
| 07 | 0:45 | End with a small number of memorable points. | Three takeaway cards | `takeaway-grid` | Three concise conclusions | State the requested discussion or next action. | draft |

## Reproducible Figure Sources

List every figure, table, or derived value that appears in the deck. Use
project-relative paths or named workflow outputs, not local absolute paths.

| Output | Primary source | Refresh step |
|---|---|---|
| Main result metrics | `data.summary_file` in `presentation.yml` | Rerun the analysis workflow |
| Annual or historic comparison | Add named entries under `data.inputs` | Run a small helper in `R/` if extraction is needed |

## Open questions

- Who is the primary audience?
- How many minutes are available?
- Is the presentation for information, discussion, or a decision?
- What should the HTML output file be called? Use `presentation.html` if no
  preference is given.
- Which result object should drive the rerender?
- Does the deck need one compact summary object, or a project-specific adapter
  that reads several stable model outputs?
- Are any comparisons needed between model-result folders from different
  assessment years?
- Is a manually rearrangeable PowerPoint file required, or is editable Quarto
  source plus HTML/PDF sufficient?

## Template-test notes

Record workflow issues discovered while using the template, especially
installer problems, missing input boundaries, ignored required files, rendering
quirks, and visual QA findings. Keep these notes generic enough that they can
be copied back into the template without exposing local paths or sensitive
project details.

- Verticality: content-light / card decks often leave a wide empty band below
  the content with the default `center: false`. Setting `center: true` balances
  each slide and reads much better. Caveats: the grey data-section watermark then
  sits just under the centred content rather than the slide edge, and `.absolute`
  bleed-figure slides / `.fit-narrow` assume top-aligned slides — re-render and
  check those after flipping it.
- Multi-figure walkthrough: a text-left / figure-right slide that reveals one
  figure per click (sync each `.fragment` bullet and its figure on a shared
  `fragment-index`, first figure `.fade-out`, middle `.fade-in-then-out`, last
  `.fade-in`) is an effective way to pace an argument. With transparent figure
  backgrounds the earlier figure bleeds through the next unless it fades out. See
  the "Pace a multi-figure argument" sampler slide.
