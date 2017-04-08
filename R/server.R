#' Load all RDS files from a folder into global enrironment
#'
#' @param folder folder containing the RDS objects
#' @examples
#' folder <- "rdsfiles"
#' rds_to_env(folder)
#' @export
#'
rds_to_env <- function(folder) {
  rdss <- list.files(folder, "\\.rds$")
  rds_names <- gsub("\\.rds$", "", rdss)
  env_names <- paste0("env_", rds_names)
  # Create environments for each model with name based on the model name
  for (i in seq(length(rdss))) {
    obj <- readRDS(file.path(folder, rdss[i]))
    nenv <- list2env(obj, parent = .GlobalEnv)
    for (s in names(obj)) environment(nenv[[s]]) <- nenv
    assign(env_names[i], nenv, envir = .GlobalEnv)
  }
}

#' Wrap function output to be compatible with jsonify in Flask
#'
#' The output object from function should be a names list, otherwise
#' the jsonify function in Flask would fail to convert. This function will
#' check if the object is a named list, if not it will wrap the whole object
#' into an element of a list with name response: list(response = object)
#'
#' @param x R function output object
#' @export
#'
json_wrapper <- function(x) {
  if (!is.list(x)) return(list(response = x))
  if (is.null(names(x))) return(list(response = x))
  if (any(names(x) == "")) return(list(response = x))
  x
}
