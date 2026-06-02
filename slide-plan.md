# Slide plan

Agree on this overview before expanding `presentation.qmd`. Add, remove, and
reorder slides freely. Keep one row per slide.

| ID | Claim | Proof object | Layout | Draft slide text | Speaker notes | Status |
|---|---|---|---|---|---|---|
| 01 | The title states the decision or question clearly. | Minimal title slide | `title-slide` | Project title, subtitle, authors, meeting, date | Explain the purpose in one sentence. | draft |
| 02 | The audience should know the story before seeing details. | Three-step flow | `process-flow` | Question, evidence, implication | State what the audience should listen for. | draft |
| 03 | Results come from a rerenderable analysis boundary. | Data provenance diagram | `two-column` | Analysis project -> compact result object -> deck | Name the source object and its update cadence. | draft |
| 04 | Replace this with the main empirical finding. | Chart or table | `chart-slide` | One sentence takeaway | Explain uncertainty and caveats. | draft |
| 05 | Replace this with the decision-facing implication. | Scenario comparison | `table-slide` | One sentence takeaway | Explain which scenarios matter and why. | draft |
| 06 | End with a small number of memorable points. | Three takeaway cards | `takeaway-grid` | Three concise conclusions | State the requested discussion or next action. | draft |

## Open questions

- Who is the primary audience?
- How many minutes are available?
- Is the presentation for information, discussion, or a decision?
- What should the HTML output file be called? Use `presentation.html` if no
  preference is given.
- Which result object should drive the rerender?
- Is a manually rearrangeable PowerPoint file required, or is editable Quarto
  source plus HTML/PDF sufficient?
