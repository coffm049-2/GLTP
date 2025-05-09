#' readPivotGLENDA
#'
#' @description
#' A function to read the full GLENDA csv file and convert it to a more user friendly long format.
#'
#' @details
#' `.readPivotGLENDA` This is a hidden function, this should be used for development purposes only, users will only call
#' this function implicitly when assembling their full water quality dataset. This function contains some
#' of the filtering functions in order to easily be compatible with the testing schema because
#' when we filtered later on, we lost too many sample ids that would be included in the test data.
#'
#'
#' @param filepath a filepath to the GLENDA csv
#' @param n_max Number of rows to read in from the raw GLENDA data (this is really just for testing purposes)
#' @param sampleIDs a list of sampleIDs to keep in the final dataset
#'
#' @return a dataframe
.readPivotGLENDA <- function(Glenda, n_max = Inf, sampleIDs = NULL) {
  # [ ] Make glendaData the argument for load anssemble data function
  df <- Glenda %>%
    {
      if (grepl(tools::file_ext(Glenda), ".csv", ignore.case = TRUE)) {
        readr::read_csv(.,
          col_types = readr::cols(
            YEAR = "i",
            STN_DEPTH_M = "d",
            LATITUDE = "d",
            LONGITUDE = "d",
            SAMPLE_DEPTH_M = "d",
            SAMPLING_DATE = col_datetime(format = "%Y/%m/%d %H:%M"),
            # Skip useless or redundant columns
            Row = "-",
            .default = "c"
          ),
          show_col_types = FALSE,
          n_max = n_max
        )
      } else {
        .
      }
    } %>%
    {
      if (grepl(tools::file_ext(Glenda), ".Rds", ignore.case = TRUE)) {
        readr::read_rds(.) %>%
          # This is so that everything can be pivoted, we change
          # to final datatypes later once it's in long format
          dplyr::mutate(across(everything(), as.character)) %>%
          dplyr::mutate(
            Year = as.integer(YEAR),
            STN_DEPTH_M = as.double(STN_DEPTH_M),
            Latitude = as.double(LATITUDE),
            Longitude = as.double(LONGITUDE),
            SAMPLE_DEPTH_M = as.double(SAMPLE_DEPTH_M),
            SAMPLING_DATE = lubridate::ymd_hm(SAMPLING_DATE)
          ) %>%
          dplyr::select(-Row)
      } else {
        .
      }
    } %>%
    # this if statement is only for saving test data
    {
      if (!is.null(sampleIDs)) {
        dplyr::filter(
          .,
          SAMPLE_ID %in% sampleIDs
        )
      } else {
        .
      }
    } %>%
    # pivot each set of columns (analyte, units, flag, etc.) into a long
    # format while compressing redundant columns into a single column
    # (i.e. f: ANALYTE_1, ANALYTE_2, ..., ANALYTE_k -> ANALYTE)
    tidyr::pivot_longer(
      cols = -c(1:18),
      names_to = c(".value", "Number"),
      names_pattern = "(.*)_(\\d*)$"
    ) %>%
    # there are a lot of empty columns because of the data storage method
    # so once they are pivoted they are appear as missing
    tidyr::drop_na(ANALYTE) %>%
    # Select samples that haven't been combined
    dplyr::filter(
      SAMPLE_TYPE %in% c("Individual", "INSITU_MEAS"),
      QC_TYPE == "routine field sample",
      # If value and remarks are missing, we assume sample was never taken
      !is.na(VALUE) | !is.na(RESULT_REMARK) # ,
      # The only QA Codes worth removing "Invalid" and "Known Contamination".
      # The rest already passed an initial QA screening before being entered
      # !grepl("Invalid", RESULT_REMARK, ignore.case = T),
      # RESULT_REMARK != "Known Contamination"
    )
  return(df)
}

