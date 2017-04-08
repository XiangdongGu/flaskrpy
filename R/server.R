#' Load all RDS files from a folder into global enrironment
#'
#' @param folder folder containing the RDS objects
#' @examples
#' folder <- "rdsfiles"
#' load_rds()
#' @export
#'
load_rds <- function(folder) {
  rdss <- list.files(folder, "\\.rds$")
  rds_names <- gsub("\\.rds$", "", rdss)
  for (i in seq(length(rdss))) {
    obj <- readRDS(file.path(folder, rdss[i]))
    assign(rds_names[i], list2env(obj, parent = .GlobalEnv), envir = .GlobalEnv)
  }
}

