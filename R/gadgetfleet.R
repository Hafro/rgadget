#' Create a gadgetfleet object
#'
#' Create a fleet file object, from fresh or an existing file.
#'
#' @param file_name	The name of the fleet file
#' @param path		The path to the gadget directory to read from
#' @param missingOkay	If \code{TRUE}, return an empty fleet file object if file does not exist.
#' @return A list of fleet components representing file
#' @examples
#' \dontrun{
#' path <- './cod-model'
#' # Read 'fleet' fleet file, creating it if it doesn't exist
#' gadgetfleet('fleet', path, missingOkay = TRUE)  
#' }
#' @export
gadgetfleet <- function(file_name, path, missingOkay = FALSE) {
  gf <- read.gadget.file(path, file_name, file_type = "fleet",
                         missingOkay = missingOkay)
  class(gf) <- c("gadgetfleet", class(gf))
  
  return(gf)
} 

#' Update gadget fleet components in a fleet file
#'
#' Replace and/or append new fleet comonents to an existing file
#'
#' @param gf		The gadgetfile object to update
#' @param component	Either a replacement \code{gadget_fleet_component} (from MFDB or rgadget), or a component type name
#' @param ...		If a component type was provided above, the extra options to supply to \code{gadget_fleet_component}
#'
#' @examples
#' \dontrun{
#' library(magrittr)  # import %>% function
#' path <- './model'
#' gadgetfleet('fleet', path, missingOkay = TRUE) %>%
#'    gadget_update( # Add a fleet component
#'        'totalfleet',
#'        name = 'comm',
#'        data = data.frame(year = 1990, step = 1, area = 1, weight = 1)) %>%
#'    write.gadget.file(path)
#'    }
#' @export
gadget_update.gadgetfleet <- function(gf, component, ...) {
  if (!("gadget_fleet_component" %in% class(component))) {
    # Assume arguments are function call for gadget_fleet_component
    component <- gadgetfleetcomponent(component, ...)
  }
  
  # fleet components always have some kind of preamble, to space out
  if (is.null(attr(component, "preamble"))) {
    attr(component, "preamble") <- ""
  }
  
  # Replace component with matching name/type, or append
  gf <- gadget_component_replace(gf, component, function(comp) {
    if (length(comp) == 0) "" else comp[[1]]
  })
  
  return(gf)
}

#' this function removes named fleet components
#' @param gf		The gadgetfile object to update
#' @param comp_name named components to remove
#' @export 
gadget_discard.gadgetfleet <- function(gf,comp_name) {
  ## TODO: this function should also clean up asociated data files 
  file_config <- attr(gf,'file_config')
  file_name <- attr(gf,'file_name')
  class_val <- class(gf)
  gf <- gf %>% purrr::discard(function(x) x[[1]] %in% comp_name)
  attr(gf,'file_config') <- file_config
  attr(gf,'file_name') <- file_name 
  class(gf) <- class_val
  return(gf)
}