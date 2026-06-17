# Render the working RevealJS presentation as a self-contained HTML file beside
# its source or in an optional preview folder.
#
# Examples:
#   Rscript render_presentation.R
#   Rscript render_presentation.R \
#     --config examples/reb-spict/presentation.yml \
#     --project-root /path/to/reb-spict \
#     --output-file reb-spict-example.html

this_file <- function() {
  cmd_args <- commandArgs(trailingOnly = FALSE)
  file_arg <- sub("^--file=", "", grep("^--file=", cmd_args, value = TRUE))
  if (length(file_arg)) {
    return(file_arg[[1]])
  }
  for (frame in rev(sys.frames())) {
    if (!is.null(frame$ofile)) {
      return(frame$ofile)
    }
  }
  NULL
}

original_wd <- getwd()
on.exit(setwd(original_wd), add = TRUE)
setwd(dirname(normalizePath(this_file())))

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
metadata <- list(
  pagetitle = tools::file_path_sans_ext(basename(output_file)),
  format = list(
    revealjs = list(
      "embed-resources" = TRUE
    )
  )
)

message("Rendering presentation")
message("  config:       ", config_file)
message("  project root: ", project_root)
if (!is.null(output_dir)) {
  message("  output dir:   ", output_dir)
}

report_output_size <- function(path) {
  if (!file.exists(path)) {
    return(invisible(NULL))
  }
  size_mb <- file.info(path)$size / 1024^2
  message(sprintf("Rendered HTML size: %.1f MB", size_mb))
  if (is.finite(size_mb) && size_mb > 25) {
    warning(
      sprintf(
        "Rendered HTML is %.1f MB. Optimize or resize embedded images before sharing.",
        size_mb
      ),
      call. = FALSE
    )
  }
  invisible(size_mb)
}

render_once <- function() {
  quarto::quarto_render(
    input = "presentation.qmd",
    output_file = output_file,
    execute_params = list(
      config_file = config_file,
      project_root = project_root
    ),
    metadata = metadata,
    quiet = FALSE
  )
}

if (is.null(output_dir)) {
  render_once()
  report_output_size(output_file)
  local_assets <- file.path(
    dirname(normalizePath(output_file, mustWork = FALSE)),
    paste0(tools::file_path_sans_ext(basename(output_file)), "_files")
  )
  if (dir.exists(local_assets)) {
    unlink(local_assets, recursive = TRUE)
  }
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

  unlink(build_dir, recursive = TRUE)
  message("Isolated preview created: ", final_output)
  report_output_size(final_output)
}
