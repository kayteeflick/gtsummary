#' @title Methods for tbl_regression
#'
#' @description Most regression models are handled by [tbl_regression.default()],
#' which uses [broom::tidy()] to perform initial tidying of results. There are,
#' however, some model types that have modified default printing behavior.
#' Those methods are listed below.
#'
#' @inheritSection tbl_regression Methods
#' @name tbl_regression_methods
#' @rdname tbl_regression_methods
#' @param ... arguments passed to `tbl_regression.default()`
#' @inheritParams tbl_regression
#' @inheritParams tbl_stack
NULL

#' @export
#' @rdname tbl_regression_methods
tbl_regression.survreg <- function(
  x, tidy_fun = function(x, ...) broom::tidy(x, ...) %>% dplyr::filter(.data$term != "Log(scale)"), ...) {
  tbl_regression.default(x = x, tidy_fun = tidy_fun, ...)
}

#' @export
#' @rdname tbl_regression_methods
tbl_regression.mira <- function(x, tidy_fun = pool_and_tidy_mice, ...) {
  tbl_regression.default(x = x, tidy_fun = tidy_fun, ...)
}

#' @export
#' @rdname tbl_regression_methods
tbl_regression.mipo <- function(x, ...) {
  paste("Please pass the 'mice' model to {.code tbl_regression()} before ",
        "models have been combined with {.code mice::pool()}.",
        "The default tidier, {.code pool_and_tidy_mice()}, ","
        will both pool and tidy the regression model.") %>%
    stringr::str_wrap() %>%
    cli_alert_danger()
  paste("\n\nmice::mice(trial, m = 2) %>%",
        "with(lm(age ~ marker + grade)) %>%",
        "tbl_regression()", sep = "\n  ") %>%
    cli_code()
}

#' @export
#' @rdname tbl_regression_methods
tbl_regression.lmerMod <- function(
  x, tidy_fun = function(x, ...) broom.mixed::tidy(x, ..., effects = "fixed"), ...) {
  assert_package("broom.mixed", "tbl_regression.lmerMod()")
  tbl_regression.default(x = x, tidy_fun = tidy_fun, ...)
}

#' @export
#' @rdname tbl_regression_methods
tbl_regression.glmerMod <- tbl_regression.lmerMod

#' @export
#' @rdname tbl_regression_methods
tbl_regression.glmmTMB <- tbl_regression.lmerMod

#' @export
#' @rdname tbl_regression_methods
tbl_regression.glmmadmb <- tbl_regression.lmerMod

#' @export
#' @rdname tbl_regression_methods
tbl_regression.stanreg <- tbl_regression.lmerMod

#' @export
#' @rdname tbl_regression_methods
tbl_regression.gam <- function(x, tidy_fun = tidy_gam, ...) {
  tbl_regression.default(x = x, tidy_fun = tidy_fun, ...)
}

#' @export
#' @rdname tbl_regression_methods
tbl_regression.multinom <- function(x, ...) {
  result <- tbl_regression.default(x = x, ...)

  # adding a grouped header for the outcome levels
  result$table_body <-
    result$table_body %>%
    mutate(groupname_col = .data$y.level) %>%
    select(.data$groupname_col, everything()) %>%
    group_by(.data$groupname_col)
  result <- .update_table_styling(result)

  # warning about multi-nomial models
  paste("Multinomial models have a different underlying structure than",
        "the models gtsummary was designed for.",
        "Other gtsummary functions designed to work with",
        "{.field tbl_regression} objects may yield unexpected",
        "results.") %>%
    str_wrap() %>%
    cli_alert_info()

  result
}
