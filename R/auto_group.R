
#' @description
#' This function stack all bands of HLS data from the same day. Thats very handy because the data you download are one banded
#' tiffs, merging them based on their filename is labour intense. You can also generate an info_df similar to the
#' df you would get using the hlsmanager::auto_df() function. Thats helpful if you want to check how many scenes you actually have and
#' whats their aqcuisition date. If you dont have the same number of bands for each date,
#' you will get an error message. All of the function do only work if you did not rename the original data, or the names the package gave the files.
#'
#' @param input_filepath \code{character}. The filepath of the downloaded HLS files.
#' @param output_filepath \code{character}. The filepath where the grouped data should be saved.
#' @param give_df_info \code{logical}. If \code{TRUE}, the function returns a \code{data.frame} where each file is a row and columns include: bands, filepath, filename, and satellite type.
#' @return all the files will be grouped and saved in the new folder,
#' @export

autogroup <- function(input_filepath, output_filepath, give_df_info = FALSE){

  my_df <- auto_df(input_filepath) #andere funktion benutzen
  dates <- unique(my_df[c("doy", "year")]) # hier erstmal alle tage raussuchen
  df_info <- data.frame(year = integer(nrow(dates)),
                        doy = integer(nrow(dates)),
                        number_of_bands = integer(nrow(dates)),
                        bands = character(nrow(dates)),
                        filepath = character(nrow(dates)),
                        filename =character(nrow(dates)),
                        satellite_type = character(nrow(dates)))

  for(d in 1:nrow(dates)){

    doy_now <- dates[d,1]
    year_now <- dates[d,2]

    path <- my_df$filepath[my_df$doy == doy_now & my_df$year == year_now] |> sort() # alle pfade für den Tag schnabulieren
    bandtest <- my_df$band[my_df$doy == doy_now & my_df$year == year_now] |> length() #für die anzahl der bänder im df und um später zu checken ob alle gleich viele bänder haben
    bands <-  my_df$band[my_df$doy == doy_now & my_df$year == year_now] |> sort() |> paste(collapse ="-")
    df_info$number_of_bands[d] <- bandtest #das ist zu checken ob immer gleich viele bänder
    df_info$year[d] <- year_now
    df_info$doy[d] <- doy_now

    stack <- rast(path) #raster stacken
    name <- paste0(output_filepath, "/HLS_STACK_",year_now, "_", doy_now, "_", bands, ".tif")
    writeRaster(stack, filename = name, overwrite = TRUE)
    print(paste0(year_now, "_", doy_now, "-stack was saved."))

    #wenn der nutzer den info df analog zu nasatodf gewünscht hat, wird er hier jetzt erstellt!
    if(give_df_info == TRUE){

      df_info$bands[d] <- bands
      df_info$filepath[d] <- name
      df_info$filename[d] <- basename(name)
      df_info$satellite_type[d] <- my_df$satellite_typ[my_df$year == year_now & my_df$doy == doy_now][1]

    }else{

      df_info <- df_info[ ,-c(4,5,6,7)]

    }
    # an sich wäre man hier schon fertig, ich will aber auch noch checken ob jedes tiff die gleiche zahl an bändern hat
  }
  if (length(unique(df_info$number_of_bands)) ==1){print("All rasterstacks seems to have the same amount of bands. The data should be complete.")
  }else{print("Not all the rasterstacks have the same amount of bands. Here you can see the statistics of the rasterstacks and the number of bands. The Fmask is counted as a band as well. You can still use the data, its just not complete.")
    print(df_info)}
  print(paste0(d, " RASTERSTACKS WERE SAVED."))

  if(give_df_info == TRUE){
    return(df_info)
  }
}
