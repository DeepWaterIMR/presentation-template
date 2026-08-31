# Generate website JSON from the canonical manifest and marked Quarto source.

args <- commandArgs(trailingOnly = TRUE)

command_args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", grep("^--file=", command_args, value = TRUE))
script_file <- if (length(file_arg)) normalizePath(file_arg[[1]], mustWork = TRUE) else normalizePath("scripts/generate_pattern_catalog.R", mustWork = TRUE)
repo_root <- dirname(dirname(script_file))

arg_value <- function(flag, default = NULL) {
  position <- match(flag, args)
  if (is.na(position)) return(default)
  if (position == length(args)) stop("Missing value after ", flag)
  args[[position + 1]]
}

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("Install the R package 'yaml' before generating the pattern catalogue.")
}
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("Install the R package 'jsonlite' before generating the pattern catalogue.")
}

manifest_file <- normalizePath(arg_value("--manifest", file.path(repo_root, "slide-patterns.yml")), mustWork = TRUE)
source_file <- normalizePath(arg_value("--source", file.path(repo_root, "presentation.qmd")), mustWork = TRUE)
output_file <- normalizePath(
  arg_value("--output", file.path(repo_root, "website", "public", "patterns.json")),
  mustWork = FALSE
)
preview_dir <- normalizePath(
  arg_value("--preview-dir", file.path(repo_root, "website", "public", "previews")),
  mustWork = FALSE
)
require_previews <- "--require-previews" %in% args

manifest <- yaml::read_yaml(manifest_file)
patterns <- manifest$patterns
if (!is.list(patterns) || !length(patterns)) {
  stop("slide-patterns.yml must contain a non-empty patterns list.")
}

required <- c(
  "id", "title", "category", "proof_object", "use", "classes",
  "caveat", "source_marker", "preview"
)
missing_fields <- lapply(patterns, function(pattern) setdiff(required, names(pattern)))
if (any(lengths(missing_fields))) {
  index <- which(lengths(missing_fields) > 0)[[1]]
  stop(
    "Pattern ", index, " is missing fields: ",
    paste(missing_fields[[index]], collapse = ", ")
  )
}

ids <- vapply(patterns, function(pattern) pattern$id, character(1))
if (any(!nzchar(ids)) || anyDuplicated(ids)) {
  stop("Pattern IDs must be non-empty and unique.")
}
if (any(!grepl("^[a-z0-9]+(?:-[a-z0-9]+)*$", ids))) {
  stop("Pattern IDs must use lowercase kebab-case.")
}

source_lines <- readLines(source_file, warn = FALSE)
extract_snippet <- function(marker) {
  start_token <- paste("<!-- pattern:start", marker, "-->")
  end_token <- paste("<!-- pattern:end", marker, "-->")
  start <- which(trimws(source_lines) == start_token)
  end <- which(trimws(source_lines) == end_token)
  if (length(start) != 1 || length(end) != 1 || end <= start) {
    stop("Expected exactly one ordered marker pair for pattern: ", marker)
  }
  paste(source_lines[seq.int(start + 1, end - 1)], collapse = "\n")
}

records <- lapply(patterns, function(pattern) {
  marker <- pattern$source_marker
  snippet <- extract_snippet(marker)
  if (!grepl(paste0("#", pattern$id, "(?:[ }])"), snippet)) {
    stop("Pattern snippet does not declare its stable slide ID: ", pattern$id)
  }
  preview_path <- file.path(preview_dir, pattern$preview)
  if (require_previews && !file.exists(preview_path)) {
    stop("Missing preview for pattern ", pattern$id, ": ", preview_path)
  }
  list(
    id = pattern$id,
    title = pattern$title,
    category = pattern$category,
    proofObject = pattern$proof_object,
    use = pattern$use,
    classes = I(unname(unlist(pattern$classes, use.names = FALSE))),
    caveat = pattern$caveat,
    preview = file.path("previews", pattern$preview),
    snippet = snippet
  )
})

extra_starts <- grep("^<!-- pattern:start ", trimws(source_lines), value = TRUE)
marker_ids <- sub("^<!-- pattern:start ([a-z0-9-]+) -->$", "\\1", extra_starts)
if (!setequal(ids, marker_ids)) {
  stop(
    "Manifest/source pattern mismatch. Missing from manifest: ",
    paste(setdiff(marker_ids, ids), collapse = ", "),
    "; missing from source: ",
    paste(setdiff(ids, marker_ids), collapse = ", ")
  )
}

dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
jsonlite::write_json(
  list(patterns = records),
  output_file,
  auto_unbox = TRUE,
  pretty = TRUE,
  null = "null"
)
message("Pattern catalogue created: ", output_file)
message("Patterns: ", length(records))
