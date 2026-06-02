# Install this presentation starter into an existing analysis project.
#
# Example:
#   Rscript install_into_project.R --target /path/to/project
#   Rscript install_into_project.R \
#     --target /path/to/project \
#     --presentation-dir presentation
#   Rscript install_into_project.R --target /path/to/project --force
#
# The installer does not edit or overwrite the target project's AGENTS.md or
# CLAUDE.md. Those files often contain domain-specific guidance.

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

target <- arg_value("--target")
if (is.null(target)) {
  stop(
    "Usage: Rscript install_into_project.R --target /path/to/project ",
    "[--presentation-dir docs/presentation] [--force]"
  )
}

target <- normalizePath(target, mustWork = TRUE)
presentation_dir <- arg_value("--presentation-dir", file.path("docs", "presentation"))
if (
  grepl("^(/|~|[[:alpha:]]:[/\\\\])", presentation_dir) ||
    any(strsplit(presentation_dir, "[/\\\\]")[[1]] == "..")
) {
  stop("--presentation-dir must be a relative folder within the target project.")
}
deck_dir <- normalizePath(
  file.path(target, presentation_dir),
  mustWork = FALSE
)
if (identical(deck_dir, target)) {
  stop("--presentation-dir must name a folder within the target project.")
}
force <- "--force" %in% args

copy_one <- function(source, destination) {
  if (file.exists(destination) && !force) {
    stop(
      "Refusing to overwrite existing file: ",
      destination,
      "\nRerun with --force only after reviewing the existing presentation files."
    )
  }

  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  if (!file.copy(source, destination, overwrite = force)) {
    stop("Failed to copy ", source, " to ", destination)
  }
  message("  installed: ", destination)
}

deck_files <- c(
  "README.md",
  "AGENTS.md",
  "CLAUDE.md",
  "presentation.qmd",
  "presentation.yml",
  "slide-plan.md",
  "render_presentation.R",
  "capture_slides.R",
  file.path("R", "presentation_helpers.R"),
  file.path("assets", "theme.scss"),
  file.path("assets", "HI_logo_farger_engelsk.png")
)

root_files <- c(
  file.path("agent-workflows", "make-presentation.md"),
  file.path(".agents", "skills", "make-presentation", "SKILL.md"),
  file.path(".claude", "skills", "make-presentation", "SKILL.md")
)

message("Installing presentation starter into ", deck_dir)

for (source in deck_files) {
  copy_one(
    source,
    file.path(deck_dir, source)
  )
}

for (source in root_files) {
  copy_one(source, file.path(target, source))
}

message("")
message("Next steps:")
message("  1. Familiarize yourself with the analysis project.")
message("  2. Discuss the presentation, including the HTML output filename, and update ", presentation_dir, "/slide-plan.md.")
message("  3. Show the slide plan to the user and wait for approval.")
message("  4. Render from ", presentation_dir, "/:")
message("     /usr/local/bin/Rscript render_presentation.R --project-root ", target)
message("  5. Capture QA screenshots from ", presentation_dir, "/:")
message("     /usr/local/bin/Rscript capture_slides.R")
message("  6. Add a short presentation-workflow pointer to the project's AGENTS.md.")
