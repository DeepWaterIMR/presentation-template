# Exercise the installer contract in isolated temporary projects.

repo_root <- normalizePath(".", mustWork = TRUE)
rscript <- file.path(R.home("bin"), "Rscript")
installer <- file.path(repo_root, "install_into_project.R")

run_installer <- function(arguments, expected_status = 0L) {
  output_file <- tempfile("installer-output-")
  status <- system2(
    rscript,
    args = c(shQuote(installer), vapply(arguments, shQuote, character(1))),
    stdout = output_file,
    stderr = output_file
  )
  if (is.null(status)) status <- 0L
  output <- paste(readLines(output_file, warn = FALSE), collapse = "\n")
  unlink(output_file)
  if (!identical(as.integer(status), as.integer(expected_status))) {
    stop("Installer returned ", status, " instead of ", expected_status, ".\n", output)
  }
  output
}

make_project <- function(name) {
  path <- file.path(tempdir(), paste0("presentation-installer-", name, "-", Sys.getpid()))
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  normalizePath(path, mustWork = TRUE)
}

project_default <- make_project("default")
run_installer(c("--target", project_default))
required_default <- c(
  file.path(project_default, "docs", "presentation", "presentation.qmd"),
  file.path(project_default, ".agents", "skills", "make-presentation", "SKILL.md"),
  file.path(project_default, ".agents", "skills", "review-presentation", "SKILL.md")
)
if (!all(file.exists(required_default))) stop("Default installation is incomplete.")
if (dir.exists(file.path(project_default, ".agents", "skills", "maintain-presentation-template"))) {
  stop("Repository maintenance skill must not be installed downstream.")
}

overwrite <- run_installer(c("--target", project_default), expected_status = 1L)
if (!grepl("Refusing to overwrite", overwrite, fixed = TRUE)) {
  stop("Overwrite refusal did not explain the failure.")
}

project_optional <- make_project("optional")
blocked_skill <- file.path(project_optional, ".agents", "skills", "make-presentation", "SKILL.md")
dir.create(dirname(blocked_skill), recursive = TRUE, showWarnings = FALSE)
writeLines("keep existing skill", blocked_skill)
optional <- run_installer(c("--target", project_optional))
if (!grepl("Could not install optional agent workflow file", optional, fixed = TRUE)) {
  stop("Optional skill-shim failure did not warn and continue.")
}
if (!file.exists(file.path(project_optional, "docs", "presentation", "presentation.qmd"))) {
  stop("Optional skill-shim failure interrupted the required deck installation.")
}

project_custom <- make_project("custom")
run_installer(c("--target", project_custom, "--presentation-dir", "presentation"))
if (!file.exists(file.path(project_custom, "presentation", "presentation.yml"))) {
  stop("Custom destination was not respected.")
}

traversal <- run_installer(
  c("--target", project_custom, "--presentation-dir", "../outside"),
  expected_status = 1L
)
if (!grepl("must be a relative folder", traversal, fixed = TRUE)) {
  stop("Traversal rejection did not explain the failure.")
}

project_ignored <- make_project("ignored")
system2("git", c("-C", shQuote(project_ignored), "init", "--quiet"))
writeLines(c("/*", "!/.gitignore"), file.path(project_ignored, ".gitignore"))
ignored <- run_installer(c("--target", project_ignored))
if (!grepl("ignored by the target repository", ignored, fixed = TRUE)) {
  stop("Allowlist-style .gitignore warning was not emitted.")
}

message("Installer contract passed: default, custom, overwrite, traversal, optional shim, skill scope, and ignored-file warning.")
