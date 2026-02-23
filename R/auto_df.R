
#' @description
#' This function create a dataframe of a folder filled with HLS data. Each row of the dataframe is one file.
#' The columns consist of: - year, - doy, - band, - filepath, - filename, - satellite type, - non_na_pixels.
#' All of the function do only work if you did not rename the original data, or the names the package gave the files.
#' @param folder_filepath \code{character}. The filepath of the HLS files.
#' @param calculate_non_na_pixels \code{logical}. If \code{TRUE}, calculates the number of non-NA pixels; otherwise, it does not.
#' @return the dataframe for the HLS files
#' @export


auto_df <- function(folder_filepath, calculate_non_na_pixels = FALSE){

  #1., the function checks how many file there are in the folder to then build the dataframe


  filepath <- list.files(folder_filepath, full.names=TRUE)
  filename <- list.files(folder_filepath)

  # 2. dataframe with neccesary dimension is build
  df <- data.frame(

    year = numeric(length(filename)),
    doy = numeric(length(filename)),
    band = character(length(filename)),
    filepath = character(length(filename)),
    filename = character(length(filename)),
    satellite_typ = character(length(filename)),
    non_na_pixels = numeric(length(filename))
  )

  # 3. now the dataframe will be filled with the filepath defined previously in 1.
  df$filepath <- filepath
  df$filename <- filename
  rm(filename, filepath)


  # 4. now we want to find out the doy and year of the image
  df$doy <- as.numeric(str_extract(df$filename, "(?<=doy\\d{4})\\d{3}"))
  df$year <- as.numeric(str_extract(df$filename, "(?<=doy)\\d{4}"))

  # 5. now we want to find out the satellite typ as well
  for(x in seq_along(df$filename)){
    kürzel <- str_extract(df$filename[x], "HLSS|HLSL")
    if(kürzel == "HLSS"){df$satellite_typ[x] <- "sentinel"
    }else if(kürzel == "HLSL"){df$satellite_typ[x] <- "landsat"
    }else{print("Some of the filenames do not contain HLSS or HLSL. Check if the filenames are correct!")}
  }
  rm(kürzel)

  # 6. now we want to export the band
  df$band <- str_extract(df$filename, "(?<=_)[A-Za-z0-9]+(?=_)")

  # 7. optional command to calculate the non_NA_values

  if (calculate_non_na_pixels==TRUE){

    for(z in seq_along(df$filename)){

      raster <- rast(df$filepath[z])
      na_raster <- is.na(raster)
      na_count <- global(is.na(raster), fun="sum")
      na_count <- na_count[,1]
      df$non_na_pixels[z] <- 1-(na_count/ncell(raster))
    }
    rm(raster, na_raster, na_count)
  }


  # 8. end
  print(paste("dataframe with, ", length(df$filename), " was created."))
  return(df)
}
