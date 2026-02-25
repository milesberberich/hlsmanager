#' easy calculation of temporal mean (sum, min/max, ....) of grouped and masked raster stacks.
#' @description
#' This function calculates the mean, sum, min/max, sd, model, or median of a given folder filled with masekd and grouped
#' HLS-tiffs. The files had to be produced using the hlsmanager package. The mean, sum and so on are calculated
#' band wise. The new files are saved in a given folder. The user defines the start- and end-day-of-the-year and the
#' intervall. Then the means get calculated for each year, in this intervalls.
#' @param start_doy \code{numeric}. The start-day-of-the-year for the computation. 0 if you want to compute a full timeseries, 100 e.g. if the user is only interested in the summer.
#' @param end_doy \code{numeric}. The end-day-of-the-year for the computation. 365 if you want to compute a full timeseries, 200 e.g. if the user is not interested in the winter.
#' @param intervall \code{(numeric}. The duration of each time step in days. If an intervall is empty because of the temporal resolution of Landsat and Sentinel, you will get an error message and the step will be skipped.
#' @param reducer_mode \code{string}. The mode or reducing: mean, min, max, sum, modal, median are available.
#' @param input_filepath \code{character}. The filepath of the grouped and masked HLS files.
#' @param output_filepath \code{character}. The output filepath.
#' @return just saves the files in the new folder
#' @export

reducer <- function(start_doy, end_doy, intervall, reducer_mode = "mean", input_filepath, output_filepath){

  # 1. generating an df
  rasterlist <- list.files(input_filepath, full.names = TRUE)
  df <- data.frame(filepath = character(length(rasterlist)), year = numeric(length(rasterlist)), doy = numeric(length(rasterlist)))
  for (r in seq_along(rasterlist)){

    df$year <- as.numeric(stringr::str_extract(rasterlist[r], "(?<=STACK_)\\d{4}"))
    df$filepath[r] <- rasterlist[r]
    df$doy[r] <- as.numeric(stringr::str_extract(rasterlist[r], "(?<=\\d{4}_)\\d+"))
  }

  # 2. generating a sequence
  jahre <- unique(df$year)
  sequence <- seq(start_doy, end_doy, by = intervall)

  # for loop over all years and all steps
  for (j in jahre){

    df_year <- df[df$year == j,]

    for (s in (1:length(sequence)-1)){

      start <- sequence[s]
      end <- sequence[s+1]

      df_step <- (df_year[df_year$doy >= start & df_year$doy < end,])

      if (dim(df_step)[1] == 0){
        cat(paste("The time intervall from ", start, "to", end, "in the year", j, "has no scenes. The next step is computed instead.\n\n"))
        next
      }

      list_step <- (df_step$filepath)
      raster <- terra::rast(list_step)

      n_bands <- terra::nlyr(terra::rast(df_step$filepath[1])) # Check how many bands are in one file
      group_index <- rep(1:n_bands, length(df_step$filepath))

      if (reducer_mode == "mean"){
        result <- terra::tapp(raster, index = group_index, fun = mean, na.rm = T)}

      else if (reducer_mode == "median"){
        result <- terra::tapp(raster, index = group_index, fun = median, na.rm = T)}

      else if (reducer_mode == "sd"){
        result <- terra::tapp(raster, index = group_index, fun = sd, na.rm = T)}

      else if (reducer_mode == "max"){
        result <- terra::tapp(raster, index = group_index, fun = max, na.rm = T)}

      else if (reducer_mode == "min"){
        result <- terra::tapp(raster, index = group_index, fun = min, na.rm = T)}

      else if (reducer_mode == "sum"){
        result <- terra::tapp(raster, index = group_index, fun = sum, na.rm = T)}

      else if (reducer_mode == "modal"){
        result <- terra::tapp(raster, index = group_index, fun = modal, na.rm = T)}
      else {stop("Use a valid reducer like: mean, min, max, modal, sd, sum or median")}

      names(result) <- paste0("mean_band_", 1:n_bands)
      terra::writeRaster(result, paste0(output_filepath, "/", reducer_mode, "_", j, "_",start, "-",end, ".tif" ))
      print(paste("Raster from", start, "to", end, "was calculated."))
    }
    cat(paste("THE YEAR", j, "IS FINISHED.\n\n"))
  }
  print("FUNCTION ENDED SUCCESFULLY.\n\n")
}
