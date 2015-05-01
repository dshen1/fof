#' Z1 Flow of funds.
#'
#' A1 Flow of funds (FOF), ALL data, national, from a recent release.
#'
#' @source Federal Reserve Board Z1 release (http://www.federalreserve.gov/releases/z1/current/), download and parse entire html file using library(apitools)
#' @format Data frame with 1 row per variable per date, NA records have been removed.
#' \describe{
#' \item{variable}{FOF variable name, including suffix denoting frequency, factor}
#' \item{freq}{Frequency of data (A or Q), factor}
#' \item{description}{Long description of variable, factor}
#' \item{date}{first day of quarter for Q data, first day of year for A data}
#' \item{value}{$ amount, in units described in FOF documentation [ADD a units var], numeric}
#' }
#' @examples
#'   head(fz1)
"fz1"

