# Beaked-redfish SPiCT example

This config demonstrates how a SPiCT project can drive a presentation from the
annual compact summary RDS written by `1 assessment model.qmd`.

From the root of `presentation-template`, run:

```bash
/usr/local/bin/Rscript render_presentation.R \
  --config examples/reb-spict/presentation.yml \
  --project-root "/path/to/reb-spict"
```

The config contains no machine-specific absolute paths. In a SPiCT project,
copy the presentation starter into the chosen presentation folder and keep the
summary path relative to the project root.
