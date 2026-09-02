# Generate website JSON from the layout manifest and marked Quarto source.

args <- commandArgs(trailingOnly = TRUE)

command_args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", grep("^--file=", command_args, value = TRUE))
script_file <- if (length(file_arg)) normalizePath(file_arg[[1]], mustWork = TRUE) else normalizePath("scripts/generate_layout_catalog.R", mustWork = TRUE)
repo_root <- dirname(dirname(script_file))

arg_value <- function(flag, default = NULL) {
  position <- match(flag, args)
  if (is.na(position)) return(default)
  if (position == length(args)) stop("Missing value after ", flag)
  args[[position + 1]]
}

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("Install the R package yaml before generating the layout catalogue.")
}
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("Install the R package jsonlite before generating the layout catalogue.")
}

manifest_file <- normalizePath(arg_value("--manifest", file.path(repo_root, "slide-layouts.yml")), mustWork = TRUE)
source_file <- normalizePath(arg_value("--source", file.path(repo_root, "presentation.qmd")), mustWork = TRUE)
output_file <- normalizePath(
  arg_value("--output", file.path(repo_root, "website", "public", "layouts.json")),
  mustWork = FALSE
)
preview_dir <- normalizePath(
  arg_value("--preview-dir", file.path(repo_root, "website", "public", "previews")),
  mustWork = FALSE
)
require_previews <- "--require-previews" %in% args

manifest <- yaml::read_yaml(manifest_file)
entries <- manifest$entries
if (!is.list(entries) || !length(entries)) {
  stop("slide-layouts.yml must contain a non-empty entries list.")
}

required <- c(
  "id", "kind", "name", "category", "evidence", "use", "code", "classes",
  "caveat", "source_marker", "preview"
)
missing_fields <- lapply(entries, function(entry) setdiff(required, names(entry)))
if (any(lengths(missing_fields))) {
  index <- which(lengths(missing_fields) > 0)[[1]]
  stop(
    "Catalogue entry ", index, " is missing fields: ",
    paste(missing_fields[[index]], collapse = ", ")
  )
}

ids <- vapply(entries, function(entry) entry$id, character(1))
if (any(!nzchar(ids)) || anyDuplicated(ids)) {
  stop("Catalogue IDs must be non-empty and unique.")
}
if (any(!grepl("^[a-z0-9]+(?:-[a-z0-9]+)*$", ids))) {
  stop("Catalogue IDs must use lowercase kebab-case.")
}
kinds <- vapply(entries, function(entry) entry$kind, character(1))
if (any(!kinds %in% c("layout", "feature"))) {
  stop("Each catalogue entry kind must be layout or feature.")
}

source_lines <- readLines(source_file, warn = FALSE)
extract_snippet <- function(marker) {
  start_token <- paste("<!-- catalogue:start", marker, "-->")
  end_token <- paste("<!-- catalogue:end", marker, "-->")
  start <- which(trimws(source_lines) == start_token)
  end <- which(trimws(source_lines) == end_token)
  if (length(start) != 1 || length(end) != 1 || end <= start) {
    stop("Expected exactly one ordered marker pair for catalogue entry: ", marker)
  }
  paste(source_lines[seq.int(start + 1, end - 1)], collapse = "\n")
}

records <- lapply(entries, function(entry) {
  marker <- entry$source_marker
  snippet <- extract_snippet(marker)
  if (!grepl(paste0("#", entry$id, "(?:[ }])"), snippet)) {
    stop("Catalogue snippet does not declare its stable slide ID: ", entry$id)
  }
  preview_path <- file.path(preview_dir, entry$preview)
  if (require_previews && !file.exists(preview_path)) {
    stop("Missing preview for catalogue entry ", entry$id, ": ", preview_path)
  }
  list(
    id = entry$id,
    kind = entry$kind,
    name = entry$name,
    category = entry$category,
    evidence = entry$evidence,
    use = entry$use,
    code = entry$code,
    classes = I(unname(unlist(entry$classes, use.names = FALSE))),
    caveat = entry$caveat,
    preview = file.path("previews", entry$preview),
    snippet = snippet
  )
})

extra_starts <- grep("^<!-- catalogue:start ", trimws(source_lines), value = TRUE)
marker_ids <- sub("^<!-- catalogue:start ([a-z0-9-]+) -->$", "\\1", extra_starts)
if (!setequal(ids, marker_ids)) {
  stop(
    "Manifest/source catalogue mismatch. Missing from manifest: ",
    paste(setdiff(marker_ids, ids), collapse = ", "),
    "; missing from source: ",
    paste(setdiff(ids, marker_ids), collapse = ", ")
  )
}

dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
jsonlite::write_json(
  list(entries = records),
  output_file,
  auto_unbox = TRUE,
  pretty = TRUE,
  null = "null"
)
message("Layout catalogue created: ", output_file)
message("Layouts: ", sum(kinds == "layout"), "; features: ", sum(kinds == "feature"))
