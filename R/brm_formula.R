#' @title Model formula
#' @export
#' @family models
#' @description Build a model formula for an MMRM.
#' @details [brm_formula()] builds an R formula for an MMRM based on
#'   the details in the data and your choice of parameterization.
#'   Customize your parameterization by toggling on or off
#'   the various `TRUE`/`FALSE` arguments of [brm_formula()],
#'   such as `intercept`, `baseline`, and `group_time`.
#'   All plausible additive effects, two-way interactions, and
#'   three-way interactions can be specified. The following interactions
#'   are not supported:
#'   * Any interactions with the concomitant covariates you specified in the
#'     `covariates` argument of [brm_data()].
#'   * Any interactions which include baseline response and treatment
#'     group together. Rationale: in a randomized controlled experiment,
#'     baseline and treatment group assignment should be uncorrelated.
#' @section Parameterization:
#'   The formula is not the only factor
#'   that determines the fixed effect parameterization.
#'   The ordering of the categorical variables in the data,
#'   as well as the `contrast` option in R, affect the
#'   construction of the model matrix. To see the model
#'   matrix that will ultimately be used in [brm_model()],
#'   run [brms::make_standata()] and examine the `X` element
#'   of the returned list. See the examples below for a
#'   demonstration.
#' @return An object of class `"brmsformula"` returned from
#'   `brms::brmsformula()`. It contains the fixed effect parameterization,
#'   correlation structure, and residual variance structure.
#' @param data A classed data frame from [brm_data()].
#' @param correlation Character of length 1, name of the correlation
#'   structure. The correlation matrix is a square `T x T` matrix, where
#'   `T` is the number of discrete time points in the data.
#'   This matrix describes the correlations between time points in the same
#'   patient, as modeled in the residuals. Different patients are modeled
#'   as independent. The `correlation` argument controls how this matrix
#'   is parameterized, and the choices given by `brms` are listed at
#'   <https://paul-buerkner.github.io/brms/reference/autocor-terms.html>,
#'   and the choice is ultimately encoded in the main body of the
#'   output formula through terms like `unstru()` and `arma()`, some
#'   of which are configurable through arguments
#'   `autoregressive_order`, `moving_average_order`, and
#'   `residual_covariance_arma_estimation` of [brm_formula()].
#'   Choices in `brms.mmrm`:
#'   * `"unstructured"`: the default/recommended option, a fully parameterized
#'     covariance matrix with a unique scalar parameter for each unique pair
#'     of discrete time points. C.f.
#'     <https://paul-buerkner.github.io/brms/reference/unstr.html>.
#'   * `"autoregressive_moving_average"`: autoregressive moving
#'     average (ARMA), c.f.
#'     <https://paul-buerkner.github.io/brms/reference/arma.html>.
#'   * `"autoregressive"`: autoregressive (AR), c.f.
#'     <https://paul-buerkner.github.io/brms/reference/ar.html>.
#'   * `"moving_average"`: moving average (MA), c.f.
#'     <https://paul-buerkner.github.io/brms/reference/ma.html>.
#'   * `"compound_symmetry`: compound symmetry, c.f.
#'     <https://paul-buerkner.github.io/brms/reference/cosy.html>.
#'   * `"diagonal"`: declare independent time points within patients.
#' @param autoregressive_order Nonnegative integer,
#'   autoregressive order for the `"autoregressive_moving_average"`
#'   and `"autoregressive"` correlation structures.
#' @param moving_average_order Nonnegative integer,
#'   moving average order for the `"autoregressive_moving_average"`
#'   and `"moving_average"` correlation structures.
#' @param residual_covariance_arma_estimation `TRUE` or `FALSE`,
#'   whether to estimate ARMA effects using residual covariance matrices.
#'   Directly supplied to the `cov` argument in `brms` for
#'   `"autoregressive_moving_average"`, `"autoregressive"`, and
#'   `"moving_average"` correlation structures. C.f.
#'   <https://paul-buerkner.github.io/brms/reference/arma.html>.
#' @param variance Character of length 1, variance structure for the
#'   residuals. `"heterogeneous"` declares a different variance component
#'   for each discrete time point, `"homogeneous"` declares a single
#'   scalar variance shared by all time points. In either case, the variance
#'   components are shared by all patients, and different patients are
#'   modeled as independent.
#'
#'   The variance components are encoded as parameters `b_sigma` in the model.
#'   Each `b_sigma` is a standard deviation of residuals on the natural
#'   log scale.
#'
#'   The variance structure is encoded in the
#'   `sigma ~ ...` part of the output formula. To see the variance
#'   parameterization for yourself, use `brms::make_standata()`
#'   on the formula and data, or `brms::prior_summary()` or
#'   `posterior::as_draws_df()` on the model.
#' @param intercept Logical of length 1.
#'   `TRUE` (default) to include an intercept, `FALSE` to omit.
#' @param baseline Logical of length 1.
#'   `TRUE` to include an additive effect for baseline
#'   response, `FALSE` to omit.
#'   Default is `TRUE` if [brm_data()] previously declared a baseline
#'   variable in the dataset.
#' @param baseline_subgroup Logical of length 1.
#'   `TRUE` to include baseline-by-subgroup interaction, `FALSE` to omit.
#'   Default is `TRUE` if [brm_data()] previously declared baseline
#'   and subgroup variables in the dataset.
#' @param baseline_subgroup_time Logical of length 1.
#'   `TRUE` to include baseline-by-subgroup-by-time interaction,
#'   `FALSE` to omit.
#'   Default is `TRUE` if [brm_data()] previously declared baseline
#'   and subgroup variables in the dataset.
#' @param baseline_time Logical of length 1.
#'   `TRUE` to include baseline-by-time interaction, `FALSE` to omit.
#'   Default is `TRUE` if [brm_data()] previously declared a baseline
#'   variable in the dataset.
#' @param group Logical of length 1.
#'   `TRUE` (default) to include additive effects for
#'   treatment groups, `FALSE` to omit.
#' @param group_subgroup Logical of length 1.
#'   `TRUE` to include group-by-subgroup interaction, `FALSE` to omit.
#'   Default is `TRUE` if [brm_data()] previously declared a subgroup
#'   variable in the dataset.
#' @param group_subgroup_time Logical of length 1.
#'   `TRUE` to include group-by-subgroup-by-time interaction, `FALSE` to omit.
#'   Default is `TRUE` if [brm_data()] previously declared a subgroup
#'   variable in the dataset.
#' @param group_time Logical of length 1.
#'   `TRUE` (default) to include group-by-time interaction, `FALSE` to omit.
#' @param subgroup Logical of length 1.
#'   `TRUE` to include additive fixed effects for subgroup levels,
#'   `FALSE` to omit.
#'   Default is `TRUE` if [brm_data()] previously declared a subgroup
#'   variable in the dataset.
#' @param subgroup_time Logical of length 1.
#'   `TRUE` to include subgroup-by-time interaction, `FALSE` to omit.
#'   Default is `TRUE` if [brm_data()] previously declared a subgroup
#'   variable in the dataset.
#' @param time Logical of length 1.
#'   `TRUE` (default) to include a additive effect for discrete time,
#'   `FALSE` to omit.
#' @param covariates Logical of length 1.
#'   `TRUE` (default) to include any additive covariates declared with
#'   the `covariates` argument of [brm_data()],
#'   `FALSE` to omit.
#' @param effect_baseline Deprecated on 2024-01-16 (version 0.0.2.9002).
#'   Use `baseline` instead.
#' @param effect_group Deprecated on 2024-01-16 (version 0.0.2.9002).
#'   Use `group` instead.
#' @param effect_time Deprecated on 2024-01-16 (version 0.0.2.9002).
#'   Use `time` instead.
#' @param interaction_baseline Deprecated on 2024-01-16 (version 0.0.2.9002).
#'   Use `baseline_time` instead.
#' @param interaction_group Deprecated on 2024-01-16 (version 0.0.2.9002).
#'   Use `group_time` instead.
#' @examples
#' set.seed(0)
#' data <- brm_data(
#'   data = brm_simulate_simple()$data,
#'   outcome = "response",
#'   role = "response",
#'   group = "group",
#'   time = "time",
#'   patient = "patient",
#'   reference_group = "group_1",
#'   reference_time = "time_1"
#' )
#' brm_formula(data)
#' brm_formula(data = data, intercept = FALSE, baseline = FALSE)
#' formula <- brm_formula(
#'   data = data,
#'   intercept = FALSE,
#'   baseline = FALSE,
#'   group = FALSE
#' )
#' formula
#' # Optional: set the contrast option, which determines the model matrix.
#' options(contrasts = c(unordered = "contr.SAS", ordered = "contr.poly"))
#' # See the fixed effect parameterization you get from the data:
#' head(brms::make_standata(formula = formula, data = data)$X)
#' # Specify a different contrast method to use an alternative
#' # parameterization when fitting the model with brm_model():
#' options(
#'   contrasts = c(unordered = "contr.treatment", ordered = "contr.poly")
#' )
#' # different model matrix than before:
#' head(brms::make_standata(formula = formula, data = data)$X)
brm_formula <- function(
  data,
  intercept = TRUE,
  baseline = !is.null(attr(data, "brm_baseline")),
  baseline_subgroup = !is.null(attr(data, "brm_baseline")) &&
    !is.null(attr(data, "brm_subgroup")),
  baseline_subgroup_time = !is.null(attr(data, "brm_baseline")) &&
    !is.null(attr(data, "brm_subgroup")),
  baseline_time = !is.null(attr(data, "brm_baseline")),
  group = TRUE,
  group_subgroup = !is.null(attr(data, "brm_subgroup")),
  group_subgroup_time = !is.null(attr(data, "brm_subgroup")),
  group_time = TRUE,
  subgroup = !is.null(attr(data, "brm_subgroup")),
  subgroup_time = !is.null(attr(data, "brm_subgroup")),
  time = TRUE,
  covariates = TRUE,
  correlation = "unstructured",
  autoregressive_order = 1L,
  moving_average_order = 1L,
  residual_covariance_arma_estimation = FALSE,
  variance = "heterogeneous",
  effect_baseline = NULL,
  effect_group = NULL,
  effect_time = NULL,
  interaction_baseline = NULL,
  interaction_group = NULL
) {
  brm_data_validate(data)
  text <- "'%s' in brm_formula() must be TRUE or FALSE."
  assert_lgl(intercept, sprintf(text, "intercept"))
  assert_lgl(baseline, sprintf(text, "baseline"))
  assert_lgl(baseline_subgroup, sprintf(text, "baseline_subgroup"))
  assert_lgl(baseline_subgroup_time, sprintf(text, "baseline_subgroup_time"))
  assert_lgl(baseline_time, sprintf(text, "baseline_time"))
  assert_lgl(group, sprintf(text, "group"))
  assert_lgl(group_subgroup, sprintf(text, "group_subgroup"))
  assert_lgl(group_subgroup_time, sprintf(text, "group_subgroup_time"))
  assert_lgl(group_time, sprintf(text, "group_"))
  assert_lgl(subgroup, sprintf(text, "subgroup"))
  assert_lgl(subgroup_time, sprintf(text, "subgroup_time"))
  assert_lgl(time, sprintf(text, "time"))
  assert_lgl(covariates, sprintf(text, "covariates"))
  assert_lgl(
    residual_covariance_arma_estimation,
    sprintf(text, "residual_covariance_arma_estimation")
  )
  assert(
    autoregressive_order,
    is.numeric(.),
    !anyNA(.),
    length(.) == 1L,
    . >= 0,
    message = "autoregressive_order must be a nonnegative integer of length 1"
  )
  assert(
    moving_average_order,
    is.numeric(.),
    !anyNA(.),
    length(.) == 1L,
    . >= 0,
    message = "moving_average_order must be a nonnegative integer of length 1"
  )
  expect_baseline <- baseline ||
    baseline_subgroup ||
    baseline_subgroup_time ||
    baseline_time
  if (expect_baseline) {
    assert_chr(
      attr(data, "brm_baseline"),
      message = "brm_data() found no baseline column in the data."
    )
  }
  expect_subgroup <-  baseline_subgroup ||
    baseline_subgroup_time ||
    group_subgroup ||
    group_subgroup_time ||
    subgroup ||
    subgroup_time
  if (expect_subgroup) {
    assert_chr(
      attr(data, "brm_subgroup"),
      message = "brm_data() found no subgroup column in the data."
    )
  }
  text <- paste0(
    "%s was deprecated on 2024-01-16 (version 0.0.2.9002).",
    "Use %s instead."
  )
  if (!is.null(effect_baseline)) {
    brm_deprecate(sprintf(text, "effect_baseline", "baseline"))
    baseline <- effect_baseline
  }
  if (!is.null(effect_group)) {
    brm_deprecate(sprintf(text, "effect_group", "group"))
    group <- effect_group
  }
  if (!is.null(effect_time)) {
    brm_deprecate(sprintf(text, "effect_time", "time"))
    time <- effect_time
  }
  if (!is.null(interaction_baseline)) {
    brm_deprecate(sprintf(text, "interaction_baseline", "baseline_time"))
    baseline_time <- interaction_baseline
  }
  if (!is.null(interaction_group)) {
    brm_deprecate(sprintf(text, "interaction_group", "group_time"))
    group_time <- interaction_group
  }
  brm_formula_validate_correlation(correlation)
  brm_formula_validate_variance(variance)
  name_outcome <- attr(data, "brm_outcome")
  name_role <- attr(data, "brm_role")
  name_baseline <- attr(data, "brm_baseline")
  name_group <- attr(data, "brm_group")
  name_subgroup <- attr(data, "brm_subgroup")
  name_time <- attr(data, "brm_time")
  name_patient <- attr(data, "brm_patient")
  name_covariates <- attr(data, "brm_covariates")
  terms <- c(
    term("0", !intercept),
    term(name_baseline, baseline),
    term(c(name_baseline, name_subgroup), baseline_subgroup),
    term(c(name_baseline, name_subgroup, name_time), baseline_subgroup_time),
    term(c(name_baseline, name_time), baseline_time),
    term(name_group, group),
    term(c(name_group, name_subgroup), group_subgroup),
    term(c(name_group, name_subgroup, name_time), group_subgroup_time),
    term(c(name_group, name_time), group_time),
    term(name_subgroup, subgroup),
    term(c(name_subgroup, name_time), subgroup_time),
    term(name_time, time),
    unlist(lapply(name_covariates, term, condition = covariates)),
    term_correlation(
      correlation = correlation,
      name_time = name_time,
      name_patient = name_patient,
      autoregressive_order = autoregressive_order,
      moving_average_order = moving_average_order,
      residual_covariance_arma_estimation
    )
  )
  terms <- terms[nzchar(terms)]
  right <- paste(terms, collapse = " + ")
  formula_fixed <- stats::as.formula(paste(name_outcome, "~", right))
  formula_sigma <- if_any(
    variance == "heterogeneous",
    stats::as.formula(paste("sigma ~ 0 +", name_time)),
    sigma ~ 1
  )
  brms_formula <- brms::brmsformula(formula = formula_fixed, formula_sigma)
  formula <- brm_formula_new(
    formula = brms_formula,
    brm_intercept = intercept,
    brm_baseline = baseline,
    brm_baseline_subgroup = baseline_subgroup,
    brm_baseline_subgroup_time = baseline_subgroup_time,
    brm_baseline_time = baseline_time,
    brm_group = group,
    brm_group_subgroup = group_subgroup,
    brm_group_subgroup_time = group_subgroup_time,
    brm_group_time = group_time,
    brm_subgroup = subgroup,
    brm_subgroup_time = subgroup_time,
    brm_time = time,
    brm_covariates = covariates,
    brm_correlation = correlation,
    brm_autoregressive_order = autoregressive_order,
    brm_moving_average_order = moving_average_order,
    brm_residual_covariance_arma_estimation =
      residual_covariance_arma_estimation,
    brm_variance = variance
  )
  brm_formula_validate(formula)
  formula
}

brm_formula_new <- function(
  formula,
  brm_intercept,
  brm_baseline,
  brm_baseline_subgroup,
  brm_baseline_subgroup_time,
  brm_baseline_time,
  brm_group,
  brm_group_subgroup,
  brm_group_subgroup_time,
  brm_group_time,
  brm_subgroup,
  brm_subgroup_time,
  brm_time,
  brm_covariates,
  brm_correlation,
  brm_autoregressive_order,
  brm_moving_average_order,
  brm_residual_covariance_arma_estimation,
  brm_variance
) {
  structure(
    formula,
    class = unique(c("brms_mmrm_formula", class(formula))),
    brm_intercept = brm_intercept,
    brm_baseline = brm_baseline,
    brm_baseline_subgroup = brm_baseline_subgroup,
    brm_baseline_subgroup_time = brm_baseline_subgroup_time,
    brm_baseline_time = brm_baseline_time,
    brm_group = brm_group,
    brm_group_subgroup = brm_group_subgroup,
    brm_group_subgroup_time = brm_group_subgroup_time,
    brm_group_time = brm_group_time,
    brm_subgroup = brm_subgroup,
    brm_subgroup_time = brm_subgroup_time,
    brm_time = brm_time,
    brm_covariates = brm_covariates,
    brm_correlation = brm_correlation,
    brm_autoregressive_order = brm_autoregressive_order,
    brm_moving_average_order = brm_moving_average_order,
    brm_residual_covariance_arma_estimation =
      brm_residual_covariance_arma_estimation,
    brm_variance = brm_variance
  )
}

brm_formula_validate <- function(formula) {
  assert(
    formula,
    inherits(., "brms_mmrm_formula"),
    inherits(., "brmsformula"),
    message = "please use brm_formula() to create the model formula"
  )
  attributes <- c(
    "brm_intercept",
    "brm_baseline",
    "brm_baseline_subgroup",
    "brm_baseline_subgroup_time",
    "brm_baseline_time",
    "brm_group",
    "brm_group_subgroup",
    "brm_group_subgroup_time",
    "brm_group_time",
    "brm_subgroup",
    "brm_subgroup_time",
    "brm_time",
    "brm_covariates"
  )
  for (attribute in attributes) {
    assert_lgl(
      attr(formula, attribute),
      message = paste(attribute, "attribute must be TRUE or FALSE in formula")
    )
  }
  assert_lgl(
    attr(formula, "brm_residual_covariance_arma_estimation"),
    message = "residual_covariance_arma_estimation must be TRUE or FALSE"
  )
  assert(
    attr(formula, "brm_autoregressive_order"),
    is.numeric(.),
    !anyNA(.),
    length(.) == 1L,
    . >= 0,
    message = "autoregressive_order must be a nonnegative integer of length 1"
  )
  assert(
    attr(formula, "brm_moving_average_order"),
    is.numeric(.),
    !anyNA(.),
    length(.) == 1L,
    . >= 0,
    message = "moving_average_order must be a nonnegative integer of length 1"
  )
  brm_formula_validate_correlation(attr(formula, "brm_correlation"))
  brm_formula_validate_variance(attr(formula, "brm_variance"))
}

brm_formula_validate_correlation <- function(correlation) {
  assert_chr(
    correlation,
    "correlation arg must be a nonempty character string"
  )
  choices <- c(
    "unstructured",
    "autoregressive_moving_average",
    "autoregressive",
    "moving_average",
    "compound_symmetry",
    "diagonal"
  )
  assert(
    correlation %in% choices,
    message = paste(
      "correlation arg must be one of:",
      paste(choices, collapse = ", ")
    )
  )
}

brm_formula_validate_variance <- function(variance) {
  assert_chr(
    variance,
    "variance arg must be a nonempty character string"
  )
  choices <- c("heterogeneous", "homogeneous")
  assert(
    variance %in% choices,
    message = paste(
      "variance arg must be one of:",
      paste(choices, collapse = ", ")
    )
  )
}

brm_formula_has_subgroup <- function(formula) {
  attributes <- c(
    "brm_baseline_subgroup",
    "brm_baseline_subgroup_time",
    "brm_group_subgroup",
    "brm_group_subgroup_time",
    "brm_subgroup",
    "brm_subgroup_time"
  )
  any(unlist(lapply(attributes, attr, x = formula)))
}

brm_formula_has_nuisance <- function(formula) {
  attributes <- c(
    "brm_baseline",
    "brm_baseline_subgroup",
    "brm_baseline_subgroup_time",
    "brm_baseline_time",
    "brm_covariates"
  )
  any(unlist(lapply(attributes, attr, x = formula)))
}

term <- function(labels, condition) {
  if_any(condition, paste0(labels, collapse = ":"), character(0L))
}

term_correlation <- function(
  correlation,
  name_time,
  name_patient,
  autoregressive_order,
  moving_average_order,
  residual_covariance_arma_estimation
) {
  if (identical(as.character(correlation), "diagonal")) {
    return(NULL)
  }
  fun <- switch(
    correlation,
    unstructured = "unstr",
    autoregressive_moving_average = "arma",
    autoregressive = "ar",
    moving_average = "ma",
    compound_symmetry = "cosy"
  )
  args <- list(
    time = as.symbol(name_time),
    gr = as.symbol(name_patient),
    p = autoregressive_order,
    q = moving_average_order,
    cov = residual_covariance_arma_estimation
  )[names(formals(getNamespace("brms")[[fun]]))]
  call <- as.call(c(as.symbol(fun), args))
  paste(deparse(call), collapse = " ")
}
