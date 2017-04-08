#' Make an API call
#'
#' @param model model name
#' @param func function name
#' @param req request data, typically a list or data
#' @param host the host of the API server
#' @export
#' @examples
#' \dontrun{
#' api_run("iris", "pred", iris)
#' }
#'
api_call <- function(model, func, req, host = "http://127.0.0.1:5000") {
  require(httr)
  host <- file.path(host, "r", model, func)
  res <- POST(host, body = jsonlite::toJSON(req))
  fromJSON(content(res, "text"))
}

#' Deploy a model to API
#' @param ... list of objects
#' @param host API server
#' @param .model_name the name of the model
#' @export
#'
api_deploy <- function(..., model_name, host = "http://127.0.0.1:5000") {
  require(httr)
  # Make a list based on ...
  dots <- substitute(list(...))
  dotsname <- as.character(dots)[-1L]
  dots <- eval(dots)
  names(dots) <- dotsname
  # Write to a temperary RDS file
  rdsdir <- tempfile()
  dir.create(rdsdir)
  on.exit(unlink(rdsdir, recursive = TRUE))
  fname <- sprintf("%s.rds", model_name)
  fpath <- file.path(rdsdir, fname)
  saveRDS(dots, file = fpath)
  # Deploy to API server
  POST(file.path(host, "deploy"),
       body = list(name = fname,
                   rdsfile = upload_file(fpath)))
  cat("SUCCESS!")
}
