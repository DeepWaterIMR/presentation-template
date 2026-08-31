# Capture one screenshot per RevealJS slide for visual QA.
#
# Examples:
#   Rscript capture_slides.R
#   Rscript capture_slides.R --html presentation.html
#   Rscript capture_slides.R --browser "/path/to/background/chromium"
#
# This script is for background QA. It does not auto-launch the user's
# interactive desktop browser. Pass --browser or PRESENTATION_QA_BROWSER to use
# a known headless/QA browser executable, or install Chromium/Playwright's
# browser cache so the script can find a non-interactive browser.

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

if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("Install the R package 'yaml' before capturing slides.")
}

config_file <- normalizePath(
  arg_value("--config", "presentation.yml"),
  mustWork = TRUE
)
render_config <- yaml::read_yaml(config_file)
configured_output <- render_config$render$output_file
if (is.null(configured_output) || !nzchar(configured_output)) {
  configured_output <- "presentation.html"
}

html_file <- normalizePath(
  arg_value("--html", configured_output),
  mustWork = TRUE
)
output_dir <- arg_value("--output-dir", "qa")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

existing <- function(paths) {
  paths <- paths[!is.na(paths) & nzchar(paths)]
  paths[file.exists(paths)]
}

playwright_browser_candidates <- function() {
  roots <- existing(c(
    Sys.getenv("PLAYWRIGHT_BROWSERS_PATH", unset = ""),
    file.path(Sys.getenv("HOME", unset = ""), ".cache", "ms-playwright"),
    file.path(Sys.getenv("HOME", unset = ""), "Library", "Caches", "ms-playwright")
  ))
  if (!length(roots)) {
    return(character())
  }

  patterns <- c(
    file.path("chromium_headless_shell-*", "chrome-headless-shell-mac*", "chrome-headless-shell"),
    file.path("chromium_headless_shell-*", "chrome-headless-shell-linux*", "chrome-headless-shell"),
    file.path("chromium_headless_shell-*", "chrome-mac", "headless_shell"),
    file.path("chromium_headless_shell-*", "chrome-linux", "headless_shell"),
    file.path("chromium_headless_shell-*", "chrome-win", "headless_shell.exe"),
    file.path("chromium-*", "chrome-mac-*", "Google Chrome for Testing.app", "Contents", "MacOS", "Google Chrome for Testing"),
    file.path("chromium-*", "chrome-mac", "Chromium.app", "Contents", "MacOS", "Chromium"),
    file.path("chromium-*", "chrome-linux*", "chrome"),
    file.path("chromium-*", "chrome-linux", "chrome"),
    file.path("chromium-*", "chrome-win", "chrome.exe")
  )
  unique(unlist(
    lapply(
      roots,
      function(root) {
        unlist(lapply(patterns, function(pattern) Sys.glob(file.path(root, pattern))))
      }
    )
  ))
}

browser_candidates <- c(
  arg_value("--browser"),
  Sys.getenv("PRESENTATION_QA_BROWSER", unset = ""),
  Sys.which("chromium"),
  Sys.which("chromium-browser"),
  Sys.which("google-chrome"),
  Sys.which("google-chrome-stable"),
  playwright_browser_candidates()
)
browser_candidates <- browser_candidates[
  !is.na(browser_candidates) &
    nzchar(browser_candidates) &
    file.exists(browser_candidates)
]
if (!length(browser_candidates)) {
  stop(
    "Could not find a background Chromium-compatible QA browser. ",
    "Install Chromium or Playwright's browser cache, or pass an explicit ",
    "QA browser executable with --browser or PRESENTATION_QA_BROWSER. ",
    "The script does not auto-launch the user's desktop browser."
  )
}
browser <- browser_candidates[[1]]
message("Using background QA browser: ", browser)

html <- paste(readLines(html_file, warn = FALSE), collapse = "\n")
section_tags <- regmatches(
  html,
  gregexpr("<section\\b[^>]*>", html, perl = TRUE)
)[[1]]
section_tags <- section_tags[
  grepl('\\bclass="[^"]*\\bslide[[:space:]]+level2\\b[^"]*"', section_tags, perl = TRUE) &
    grepl('\\bid="[^"]+"', section_tags, perl = TRUE)
]
slide_ids <- unique(sub('.*\\bid="([^"]+)".*', "\\1", section_tags, perl = TRUE))
if (!length(slide_ids)) {
  stop("Could not find RevealJS slide IDs in ", html_file)
}

manifest_arg <- arg_value("--manifest")
if (!is.null(manifest_arg)) {
  manifest_file <- normalizePath(manifest_arg, mustWork = TRUE)
  manifest <- yaml::read_yaml(manifest_file)
  expected_ids <- vapply(
    manifest$patterns,
    function(pattern) pattern$id,
    character(1)
  )
  if (!identical(slide_ids, expected_ids)) {
    stop(
      "Rendered slides do not match the requested manifest. Rendered: ",
      paste(slide_ids, collapse = ", "),
      "; expected: ",
      paste(expected_ids, collapse = ", ")
    )
  }
}

old_screenshots <- setdiff(
  list.files(output_dir, pattern = "^[a-z0-9-]+[.]png$", full.names = TRUE),
  file.path(output_dir, "contact-sheet.png")
)
if (length(old_screenshots)) {
  unlink(old_screenshots)
}

fragment_state <- arg_value("--fragment-state", "initial")
if (!fragment_state %in% c("initial", "last")) {
  stop("--fragment-state must be either 'initial' or 'last'.")
}
query <- if (identical(fragment_state, "last")) "?qa-fragments=last" else ""
html_url <- paste0("file://", URLencode(html_file), query)
screenshot_files <- character(length(slide_ids))
for (index in seq_along(slide_ids)) {
  slide_id <- slide_ids[[index]]
  safe_id <- gsub("[^[:alnum:]-]+", "-", slide_id)
  screenshot_file <- normalizePath(
    file.path(output_dir, paste0(safe_id, ".png")),
    mustWork = FALSE
  )
  screenshot_files[[index]] <- screenshot_file
  profile_dir <- tempfile("presentation-qa-chrome-")
  dir.create(profile_dir)

  chrome_args <- c(
    "--headless",
    "--disable-background-networking",
    "--disable-component-update",
    "--disable-gpu",
    "--disable-sync",
    "--hide-scrollbars",
    "--metrics-recording-only",
    "--no-sandbox",
    "--run-all-compositor-stages-before-draw",
    "--virtual-time-budget=1500",
    "--window-size=1600,900",
    paste0("--user-data-dir=", profile_dir),
    paste0("--screenshot=", screenshot_file),
    paste0(html_url, "#/", slide_id)
  )

  suppressWarnings(
    system2(
      browser,
      args = vapply(chrome_args, shQuote, character(1)),
      stdout = FALSE,
      stderr = FALSE,
      wait = FALSE
    )
  )
  deadline <- Sys.time() + 15
  while (!file.exists(screenshot_file) && Sys.time() < deadline) {
    Sys.sleep(0.2)
  }
  pkill <- Sys.which("pkill")
  if (nzchar(pkill)) {
    suppressWarnings(
      system2(
        pkill,
        args = c("-f", shQuote(profile_dir)),
        stdout = FALSE,
        stderr = FALSE
      )
    )
  }
  unlink(profile_dir, recursive = TRUE)
  if (!file.exists(screenshot_file)) {
    stop("Browser did not create ", screenshot_file, " within 15 seconds.")
  }
  message("  captured: ", screenshot_file)
}

contact_sheet <- file.path(output_dir, "contact-sheet.png")
if (requireNamespace("png", quietly = TRUE)) {
  columns <- min(3, length(screenshot_files))
  rows <- ceiling(length(screenshot_files) / columns)
  grDevices::png(
    contact_sheet,
    width = columns * 480,
    height = rows * 300,
    bg = "white"
  )
  graphics::par(mar = rep(0, 4))
  graphics::plot.new()
  graphics::plot.window(xlim = c(0, columns), ylim = c(0, rows))

  for (index in seq_along(screenshot_files)) {
    column <- (index - 1) %% columns
    row <- (index - 1) %/% columns
    top <- rows - row
    image <- png::readPNG(screenshot_files[[index]])
    graphics::rasterImage(
      image,
      xleft = column,
      ybottom = top - 0.9,
      xright = column + 1,
      ytop = top,
      interpolate = TRUE
    )
    graphics::text(
      x = column + 0.02,
      y = top - 0.94,
      labels = sprintf("%02d  %s", index, slide_ids[[index]]),
      adj = c(0, 1),
      cex = 0.9
    )
  }
  grDevices::dev.off()
  message("Contact sheet created: ", contact_sheet)
} else {
  message(
    "Screenshots created. Install the R package 'png' to also create a contact sheet."
  )
}
