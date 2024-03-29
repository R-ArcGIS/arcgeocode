#' Create a GeocodeServer
#'
#' Create an object of class `GeocodeServer` from a URL. This object
#' stores the service definition of the geocoding service as a list object.
#'
#' @param url the URL of a geocoding server.
#' @inheritParams arcgisutils::arc_base_req
#' @examples
#' server_url <- "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
#' geocode_server(server_url)
#' @export
#' @returns an object of class `GeocodeServer`.
geocode_server <- function(url, token = arc_token()) {
  b_req <- arc_base_req(url, token = token, query = c("f" = "json"))
  resp <- httr2::req_perform(b_req)
  jsn <- httr2::resp_body_string(resp)
  res <- RcppSimdJson::fparse(jsn)
  res[["url"]] <- url
  structure(res, class = c("GeocodeServer", "list"))
}

world_geocoder_url <- "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

#' @export
print.GeocodeServer <- function(x, ...) {
  # if the description is "" we don't print it
  descrip <- x$serviceDescription
  if (!nzchar(descrip)) {
    descrip <- NULL
  }

  to_print <- compact(
    list(
      Description = descrip,
      Version = x$currentVersion,
      CRS = x[["spatialReference"]][["latestWkid"]]
    )
  )

  header <- "<GeocodeServer>"
  body <- paste0(names(to_print), ": ", to_print)

  cat(header, body, sep = "\n")
  invisible(x)
}


#' ArcGIS World Geocoder
#'
#' The [ArcGIS World Geocoder](https://www.esri.com/en-us/arcgis/products/arcgis-world-geocoder)
#' is made publicly available for some uses. The `world_geocoder` object is used
#' as the default `GeocodeServer` object in [`default_geocoder()`] when no
#' authorization token is found. The [`find_address_candidates()`],
#' [`reverse_geocode()`], and [`suggest_places()`] can be used without an
#' authorization token. The [`geocode_addresses()`] funciton requires an
#' authorization token to be used for batch geocoding.
"world_geocoder"
check_geocoder <- function(x, arg = rlang::caller_arg(x), call = rlang::current_env()) {
  if (!rlang::inherits_any(x, "GeocodeServer")) {
    cli::cli_abort("Expected {.cls GeocodeServer}, {.arg {arg}} is {obj_type_friendly(x)}")
  }

  invisible(NULL)
}

capabilities <- function(geocoder) {
  tolower(strsplit(geocoder[["capabilities"]], ",")[[1]])
}
