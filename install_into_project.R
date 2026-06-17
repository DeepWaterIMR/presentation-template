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

copy_optional <- function(source, destination) {
  tryCatch(
    copy_one(source, destination),
    error = function(error) {
      warning(
        "Could not install optional agent workflow file ",
        destination,
        ": ",
        conditionMessage(error),
        call. = FALSE
      )
    }
  )
}

warn_if_ignored <- function(target, paths) {
  git <- Sys.which("git")
  if (!nzchar(git) || !dir.exists(file.path(target, ".git"))) {
    return(invisible(NULL))
  }

  relative_paths <- vapply(
    paths,
    function(path) {
      path <- normalizePath(path, mustWork = FALSE)
      prefix <- paste0(normalizePath(target, mustWork = TRUE), .Platform$file.sep)
      if (startsWith(path, prefix)) {
        substring(path, nchar(prefix) + 1)
      } else {
        path
      }
    },
    character(1)
  )

  ignored <- system2(
    git,
    args = c("-C", shQuote(target), "check-ignore", "--", shQuote(relative_paths)),
    stdout = TRUE,
    stderr = FALSE
  )
  status <- attr(ignored, "status")
  if (is.null(status)) {
    status <- 0
  }
  if (status == 0 && length(ignored)) {
    warning(
      "Some installed presentation files are ignored by the target repository:\n  ",
      paste(ignored, collapse = "\n  "),
      "\nAdd explicit .gitignore allowlist exceptions if these files should be versioned.",
      call. = FALSE
    )
  }
  invisible(NULL)
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
  file.path("assets", "HI_logo_farger_engelsk.png"),
  file.path("assets", "fonts", "xkcd-script.ttf")
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
  copy_optional(source, file.path(target, source))
}

warn_if_ignored(
  target,
  c(
    file.path(deck_dir, deck_files),
    file.path(target, root_files)
  )
)

message("")
message("Next steps:")
message("  1. Familiarize yourself with the analysis project.")
message("  2. Discuss the presentation, including the HTML output filename, and update ", presentation_dir, "/slide-plan.md.")
message("  3. Show the slide plan to the user and wait for approval.")
message(
  "  4. Render from ",
  presentation_dir,
  "/, or call render_presentation.R by path from another working directory:"
)
message("     /usr/local/bin/Rscript render_presentation.R --project-root ", target)
message("  5. Capture QA screenshots from ", presentation_dir, "/:")
message("     /usr/local/bin/Rscript capture_slides.R")
message("  6. Add a short presentation-workflow pointer to the project's AGENTS.md.")
