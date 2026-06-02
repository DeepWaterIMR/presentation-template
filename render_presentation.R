# Render the working RevealJS presentation beside its source or in an optional
# preview folder.
#
# Examples:
#   Rscript render_presentation.R
#   Rscript render_presentation.R \
#     --config examples/reb-spict/presentation.yml \
#     --project-root /path/to/reb-spict \
#     --output-file reb-spict-example.html

args <- commandArgs(trailingOnly = TRUE)

arg_value <- function(flag, default = NULL) {
  position <- match(flag, args)
  if (is.na(position)) {
    return(default)
  }
  if (position == length(args)) {
    stop("Missing value after ", flag)
  }
  args[[position + 1]]
}

if (!requireNamespace("quarto", quietly = TRUE)) {
  stop("Install the R package 'quarto' before rendering.")
}
if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("Install the R package 'yaml' before rendering.")
}

if (identical(Sys.getenv("QUARTO_PATH", unset = ""), "")) {
  quarto_candidates <- c(
    Sys.which("quarto"),
    "/Applications/quarto/bin/quarto"
  )
  quarto_candidates <- quarto_candidates[
    nzchar(quarto_candidates) & file.exists(quarto_candidates)
  ]
  if (length(quarto_candidates)) {
    Sys.setenv(QUARTO_PATH = quarto_candidates[[1]])
  }
}

config_file <- normalizePath(
  arg_value("--config", "presentation.yml"),
  mustWork = TRUE
)
render_config <- yaml::read_yaml(config_file)
project_root <- normalizePath(
  arg_value("--project-root", "."),
  mustWork = TRUE
)
configured_output <- render_config$render$output_file
if (is.null(configured_output) || !nzchar(configured_output)) {
  configured_output <- NULL
}
output_file <- arg_value("--output-file", configured_output)
if (is.null(output_file)) {
  output_file <- "presentation.html"
}
configured_output_dir <- render_config$render$output_dir
if (is.null(configured_output_dir) || !nzchar(configured_output_dir)) {
  configured_output_dir <- NULL
}
output_dir <- arg_value("--output-dir", configured_output_dir)

message("Rendering presentation")
message("  config:       ", config_file)
message("  project root: ", project_root)
if (!is.null(output_dir)) {
  message("  output dir:   ", output_dir)
}

render_once <- function() {
  quarto::quarto_render(
    input = "presentation.qmd",
    output_file = output_file,
    execute_params = list(
      config_file = config_file,
      project_root = project_root
    ),
    quiet = FALSE
  )
}

if (is.null(output_dir)) {
  render_once()
} else {
  final_dir <- normalizePath(output_dir, mustWork = FALSE)
  build_name <- ".preview-build"
  build_dir <- file.path(final_dir, build_name)

  if (dir.exists(build_dir)) {
    unlink(build_dir, recursive = TRUE)
  }
  dir.create(file.path(build_dir, "R"), recursive = TRUE)
  dir.create(file.path(build_dir, "assets"), recursive = TRUE)

  file.copy("presentation.qmd", build_dir, overwrite = TRUE)
  file.copy("R/presentation_helpers.R", file.path(build_dir, "R"), overwrite = TRUE)
  file.copy("assets/theme.scss", file.path(build_dir, "assets"), overwrite = TRUE)
  file.copy("assets/HI_logo_farger_engelsk.png", file.path(build_dir, "assets"), overwrite = TRUE)

  old_wd <- setwd(build_dir)
  on.exit(setwd(old_wd), add = TRUE)
  render_once()
  setwd(old_wd)

  dir.create(final_dir, recursive = TRUE, showWarnings = FALSE)
  final_output <- file.path(final_dir, basename(output_file))
  file.copy(
    file.path(build_dir, basename(output_file)),
    final_output,
    overwrite = TRUE
  )

  final_assets <- file.path(final_dir, "presentation_files")
  if (dir.exists(final_assets)) {
    unlink(final_assets, recursive = TRUE)
  }
  file.copy(
    file.path(build_dir, "presentation_files"),
    final_dir,
    recursive = TRUE
  )

  unlink(build_dir, recursive = TRUE)
  message("Isolated preview created: ", final_output)
}
