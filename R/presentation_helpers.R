`%||%` <- function(x, fallback) {
  if (is.null(x) || length(x) == 0 || identical(x, "")) fallback else x
}

resolve_path <- function(path, base_dir = ".") {
  if (is.null(path) || length(path) == 0 || is.na(path) || identical(path, "")) {
    return(NULL)
  }
  if (grepl("^(/|[A-Za-z]:[/\\\\])", path)) {
    return(normalizePath(path, mustWork = FALSE))
  }
  normalizePath(file.path(base_dir, path), mustWork = FALSE)
}

read_presentation_config <- function(config_file = "presentation.yml",
                                     project_root = ".") {
  if (!requireNamespace("yaml", quietly = TRUE)) {
    stop("Install the R package 'yaml' before rendering the presentation.")
  }

  config_path <- resolve_path(config_file, getwd())
  if (!file.exists(config_path)) {
    stop("Presentation config does not exist: ", config_path)
  }

  cfg <- yaml::read_yaml(config_path)
  cfg$.config_path <- config_path
  cfg$.config_dir <- dirname(config_path)
  cfg$.project_root <- resolve_path(project_root, getwd())
  cfg
}

load_presentation_summary <- function(cfg) {
  env_path <- Sys.getenv("PRESENTATION_SUMMARY_FILE", unset = "")
  configured_path <- cfg$data$summary_file %||% ""
  summary_path <- env_path %||% configured_path

  if (identical(summary_path, "")) {
    return(NULL)
  }

  summary_path <- resolve_path(summary_path, cfg$.project_root)
  if (!file.exists(summary_path)) {
    stop(
      "Configured presentation summary does not exist: ",
      summary_path,
      "\nRerun the analysis or update data.summary_file in presentation.yml."
    )
  }

  readRDS(summary_path)
}

format_num <- function(x, digits = 2, suffix = "") {
  if (is.null(x) || length(x) == 0 || is.na(x)) {
    return("TBD")
  }
  paste0(format(round(x, digits), trim = TRUE, big.mark = ","), suffix)
}

extract_spict_context <- function(summary) {
  if (is.null(summary)) {
    return(NULL)
  }

  required <- c("summary", "refpoints", "state", "manTable", "assessment_year", "tac_year")
  missing <- setdiff(required, names(summary))
  if (length(missing)) {
    stop("SPiCT summary is missing fields: ", paste(missing, collapse = ", "))
  }

  state <- as.data.frame(summary$state)
  state$metric <- rownames(state)
  biomass_row <- grep("/Bmsy$", state$metric)
  fishing_row <- grep("/Fmsy$", state$metric)

  if (length(biomass_row) != 1 || length(fishing_row) != 1) {
    stop("Could not identify current B/Bmsy and F/Fmsy rows in the SPiCT state table.")
  }

  list(
    assessment_year = summary$assessment_year,
    advice_year = summary$tac_year,
    biomass_ratio = state$estimate[biomass_row],
    fishing_ratio = state$estimate[fishing_row],
    msy_tonnes = summary$refpoints["MSYd", "estimate"],
    scenarios = summary$manTable,
    raw = summary
  )
}

scenario_table <- function(spict) {
  if (is.null(spict)) {
    return(data.frame(
      Scenario = "Connect a result adapter to populate this table.",
      `Catch (t)` = "TBD",
      `B/Bmsy` = "TBD",
      `F/Fmsy` = "TBD",
      check.names = FALSE
    ))
  }

  x <- spict$scenarios
  data.frame(
    Scenario = gsub(" \\(@\\$\\)", "", x$Scenario),
    `Catch (t)` = format(round(x$C), big.mark = ",", scientific = FALSE),
    `B/Bmsy` = format(round(x$`B/Bmsy`, 2), nsmall = 2),
    `F/Fmsy` = format(round(x$`F/Fmsy`, 2), nsmall = 2),
    check.names = FALSE
  )
}

plot_spict_trajectories <- function(spict) {
  if (is.null(spict)) {
    plot.new()
    text(0.5, 0.5, "Connect a compact result object to draw project trajectories.")
    return(invisible(NULL))
  }

  x <- spict$raw$summary
  keep <- is.finite(x$year) & is.finite(x$BBmsy.est) & is.finite(x$FFmsy.est)
  x <- x[keep, , drop = FALSE]

  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par))
  par(mfrow = c(1, 2), mar = c(3.3, 3.7, 1.4, 0.8), mgp = c(2.1, 0.7, 0))

  plot(
    x$year,
    exp(x$BBmsy.est),
    type = "l",
    lwd = 3,
    col = "#056A89",
    xlab = "Year",
    ylab = "B / Bmsy"
  )
  abline(h = 1, col = "#6CA67A", lty = 2, lwd = 2)

  plot(
    x$year,
    exp(x$FFmsy.est),
    type = "l",
    lwd = 3,
    col = "#D44F56",
    xlab = "Year",
    ylab = "F / Fmsy"
  )
  abline(h = 1, col = "#6CA67A", lty = 2, lwd = 2)
}

