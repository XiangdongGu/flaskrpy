#' Make API call
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
