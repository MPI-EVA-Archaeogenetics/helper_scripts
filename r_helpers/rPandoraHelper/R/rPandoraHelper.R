#' @title Helper Functions for Parsing Pandora IDs
#' @description This package provides helper functions for parsing Pandora IDs.
#' @author Thiseas C. Lamnidis

#' @title Remove Suffix from ID
#' @description Remove the '_ss' suffix from an ID if present.
#' @param ind_id The ID to remove the suffix from.
#' @param keep_ss_suffix Whether to keep the '_ss' suffix in the ID.
#' @return The ID with the suffix removed if keep_ss_suffix is FALSE, otherwise the original ID.
#' @export
#' @examples
#' remove_suffix("ABC001_ss")
#' remove_suffix("ABC001_ss", keep_ss_suffix = TRUE)

# Define an internal function to remove the '_ss' suffix from an ID
remove_suffix <- function(ind_id, keep_ss_suffix = FALSE) {
  if (substr(ind_id, nchar(ind_id) - 2, nchar(ind_id)) == "_ss") {
    if (keep_ss_suffix) {
      return(ind_id)
    } else {
      return(substring(ind_id, 1, nchar(ind_id) - 3))
    }
  } else {
    return(ind_id)
  }
}

#' @title Extract Site ID from Pandora ID
#' @description Extract the Site ID from a Pandora ID.
#' @param id The Pandora ID to extract the Site ID from.
#' @param keep_ss_suffix Whether to keep the '_ss' suffix in the Site ID.
#' @return The extracted Site ID.
#' @export
#' @examples
#' get_site_id("ABC001.A0101")
#' get_site_id("ABC001.A0101.SG1.1", keep_ss_suffix = TRUE)

get_site_id <- function(id, keep_ss_suffix = FALSE) {
  if (nchar(id) < 6 || (nchar(id) == 6 & !grepl("\\d{3}$", id))) {
    ## No other ID can be shorter than 6 characters, so if that's the case, the Pandora ID provided must be a Site ID
    result <- id
  } else {
    ind_id <- rPandoraHelper::get_ind_id(id, keep_ss_suffix)
    if (nchar(ind_id) > 3 & endsWith(ind_id, "_ss")) {
      result <- substring(ind_id, 1, nchar(ind_id) - 6)
    } else {
      result <- substring(ind_id, 1, nchar(ind_id) - 3)
    }
  }
  return(result)
}

#' @title Individual ID
#' @description Extract the Individual ID from a Pandora ID.
#' @param id The Pandora ID to extract the Individual ID from.
#' @param keep_ss_suffix Whether to keep the '_ss' suffix in the Individual ID.
#' @return The extracted Individual ID.
#' @export
#' @examples
#' get_ind_id("ABC001")
#' get_ind_id("ABC001.A0101", keep_ss_suffix = TRUE)

get_ind_id <- function(id, keep_ss_suffix = FALSE) {
  first_part <- strsplit(id, "\\.")[[1]][1]
  if (nchar(id) < 6 | !grepl("\\d{3}(|_ss)$", first_part)) {
    ## If the id is not long enough, or the first part of it does not end in 3 digits (optionally followed by _ss)
    warning("The provided Pandora_ID \'", id, "\' does not contain the Individual_ID")
    return(NA_character_)
  }
  result <- rPandoraHelper::remove_suffix(
    strsplit(id, "\\.")[[1]][1],
    keep_ss_suffix
    )

  return(result)
}

#' @title Sample ID
#' @description Extract the Sample ID from a Pandora ID.
#' @param id The Pandora ID to extract the Sample ID from.
#' @param keep_ss_suffix Whether to keep the '_ss' suffix in the Sample ID.
#' @return The extracted Sample ID.
#' @export
#' @examples
#' get_sample_id("ABC001.A0101")
#' get_sample_id("ABC001.A0101.SG1.1", keep_ss_suffix = TRUE)

get_sample_id <- function(id, keep_ss_suffix = FALSE) {
  x <- strsplit(id, "\\.")[[1]]
  if (length(x) < 2) {
    warning("The provided Pandora_ID \'", id, "\' does not contain the Sample_ID.")
    return(NA_character_)
  }
  result <- paste0(rPandoraHelper::remove_suffix(x[1], keep_ss_suffix), ".", substr(x[2],1,1))
  return(result)
}

#' @title Extract ID
#' @description Extract the Extract ID from a Pandora ID.
#' @param id The Pandora ID to extract the Extract ID from.
#' @param keep_ss_suffix Whether to keep the '_ss' suffix in the Extract ID.
#' @return The extracted Extract ID.
#' @export
#' @examples
#' get_extract_id("ABC001.A0101")
#' get_extract_id("ABC001.A0101.SG1.1", keep_ss_suffix = TRUE)

get_extract_id <- function(id, keep_ss_suffix = FALSE) {
  x <- strsplit(id, "\\.")[[1]]
  if (length(x) < 2 | nchar(x[2]) < 3) {
    warning("The provided Pandora_ID \'", id, "\' does not contain the Extract_ID.")
    return(NA_character_)
  }
  result <- paste0(rPandoraHelper::remove_suffix(x[1], keep_ss_suffix), ".", substr(x[2], 1, 3))
  return(result)
}

#' @title Library ID
#' @description Extract the Library ID from a Pandora ID.
#' @param id The Pandora ID to extract the Library ID from.
#' @param keep_ss_suffix Whether to keep the '_ss' suffix in the Library ID.
#' @return The extracted Library ID.
#' @export
#' @examples
#' get_library_id("ABC001.A0101")
#' get_library_id("ABC001.A0101.SG1.1", keep_ss_suffix = TRUE)

get_library_id <- function(id, keep_ss_suffix = FALSE) {
  x <- strsplit(id, "\\.")[[1]]
  if (length(x) < 2 | nchar(x[2]) < 5) {
    warning("The provided Pandora_ID \'", id, "\' does not contain the Library_ID.")
    return(NA_character_)
  }
  result <- paste0(rPandoraHelper::remove_suffix(x[1], keep_ss_suffix), ".", x[2])
  return(result)
}

#' @title Capture ID
#' @description Extract the Capture ID from a Pandora ID.
#' @param id The Pandora ID to extract the Capture ID from.
#' @param keep_ss_suffix Whether to keep the '_ss' suffix in the Capture ID.
#' @return The extracted Capture ID.
#' @export
#' @examples
#' get_capture_id("ABC001.A0101.SG1.1")
#' get_capture_id("ABC001.A0101.SG1.1", keep_ss_suffix = TRUE)

get_capture_id <- function(id, keep_ss_suffix = FALSE) {
  x <- strsplit(id, "\\.")[[1]]
  if (length(x) < 3) {
    warning("The provided Pandora_ID \'", id, "\' does not contain the Capture_ID.")
    return(NA_character_)
  }
  result <- paste0(rPandoraHelper::remove_suffix(x[1], keep_ss_suffix), ".", x[2], ".", x[3])
  return(result)
}

#' @title Sequencing ID
#' @description Extract the Sequencing ID from a Pandora ID.
#' @param id The Pandora ID to extract the Sequencing ID from.
#' @param keep_ss_suffix Whether to keep the '_ss' suffix in the Sequencing ID.
#' @return The extracted Sequencing ID.
#' @export
#' @examples
#' get_sequencing_id("ABC001.A0101.SG1.1")
#' get_sequencing_id("ABC001.A0101.SG1.1", keep_ss_suffix = TRUE)

get_sequencing_id <- function(id, keep_ss_suffix = FALSE) {
  x <- strsplit(id, "\\.")[[1]]
  if (length(x) < 4) {
    warning("The provided Pandora_ID \'", id, "\' does not contain the Sequencing_ID.")
    return(NA_character_)
  }
  result <- paste0(rPandoraHelper::remove_suffix(x[1], keep_ss_suffix), ".", x[2], ".", x[3], ".", x[4])
  return(result)
}

#' @title Run Test Cases
#' @description Run test cases for the functions in this package.
#' @examples
#' test()

# test <- function() {
#   print("This is a helper module for the pyPandora package.")
#   print("It contains functions that help parse Pandora_IDs.")
#   print("The functions are:")
#   print("get_site_id(id) -> str")
#   print("get_ind_id(id) -> str")
#   print("get_sample_id(id) -> str")
#   print("get_extract_id(id) -> str")
#   print("get_library_id(id) -> str")
#   print("get_capture_id(id) -> str")
#   print("get_sequencing_id(id) -> str")
#   print("")
#   print("Running test cases...")
#
#   format_str <- paste0("{:15} {:25} {:25}")
#   for (id in c("ABC001", "ABC001.A0101", "ABC001.A0101.SG1.1", "ABCDE001_ss.A0101.SG1.1")) {
#     try {
#       print(format_str, "Pandora_ID:", id, id)
#       print(format_str, "Site_ID:", get_site_id(id, keep_ss_suffix = FALSE), get_site_id(id, keep_ss_suffix = TRUE))
#       print(format_str, "Individual_ID:", get_ind_id(id, keep_ss_suffix = FALSE), get_ind_id(id, keep_ss_suffix = TRUE))
#       print(format_str, "Sample_ID:", get_sample_id(id, keep_ss_suffix = FALSE), get_sample_id(id, keep_ss_suffix = TRUE))
#       print(format_str, "Extract_ID:", get_extract_id(id, keep_ss_suffix = FALSE), get_extract_id(id, keep_ss_suffix = TRUE))
#       print(format_str, "Library_ID:", get_library_id(id, keep_ss_suffix = FALSE), get_library_id(id, keep_ss_suffix = TRUE))
#       print(format_str, "Capture_ID:", get_capture_id(id, keep_ss_suffix = FALSE), get_capture_id(id, keep_ss_suffix = TRUE))
#       print(format_str, "Sequencing_ID:", get_sequencing_id(id, keep_ss_suffix = FALSE), get_sequencing_id(id, keep_ss_suffix = TRUE))
#       print("")
#     } catch (e) {
#       print(e)
#       print("")
#     }
#   }
# }

#' @title Parse Command-Line Arguments
#' @description Parse command-line arguments for the functions in this package.
#' @examples
#' parse_args()

#' parse_args <- function() {
#'   args <- commandArgs(trailingOnly = TRUE)
#'   if (length(args) == 0) {
#'     warning("No arguments provided.")
#'   }
#'   if (args[1] == "--test") {
#'     test()
#'   } else if (args[1] == "--get") {
#'     if (args[2] %in% c("site_id", "ind_id", "individual_id", "sample_id", "extract_id", "library_id", "lib_id", "capture_id", "sequencing_id")) {
#'       id <- args[3]
#'       keep_ss_suffix <- args[4] == "--keep_ss_suffix"
#'       if (args[2] == "site_id") {
#'         print(get_site_id(id, keep_ss_suffix))
#'       } else if (args[2] %in% c("ind_id", "individual_id")) {
#'         print(get_ind_id(id, keep_ss_suffix))
#'       } else if (args[2] == "sample_id") {
#'         print(get_sample_id(id, keep_ss_suffix))
#'       } else if (args[2] == "extract_id") {
#'         print(get_extract_id(id, keep_ss_suffix))
#'       } else if (args[2] %in% c("library_id", "lib_id")) {
#'         print(get_library_id(id, keep_ss_suffix))
#'       } else if (args[2] == "capture_id") {
#'         print(get_capture_id(id, keep_ss_suffix))
#'       } else if (args[2] == "sequencing_id") {
#'         print(get_sequencing_id(id, keep_ss_suffix))
#'       }
#'     } else {
#'       warning("Invalid value for --get argument.")
#'     }
#'   } else {
#'     warning("Invalid argument.")
#'   }
#' }
#'
#' #' @title Run the Main Function
#' #' @description Run the main function for the package.
#' #' @examples
#' #' main()
#'
#' main <- function() {
#'   parse_args()
#' }
#'
#' #' @title Run the Main Function if the Script is Run Directly
#' #' @description Run the main function if the script is run directly.
#' #' @examples
#' #' if (interactive()) {
#' #'   main()
#' #' }
#'
#' if (interactive()) {
#'   main()
#' }
