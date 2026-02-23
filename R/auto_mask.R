
#' @description
#' This function stack all bands of HLS data from the same day. Thats very handy because the data you download are one banded
#' tiffs, merging them based on their filename is labour intense. You can also generate an info_df similar to the
#' df you would get using the hlsmanager::auto_df() function. Thats helpful if you want to check how many scenes you actually have and
#' whats their aqcuisition date. If you dont have the same number of bands for each date,
#' you will get an error message. All of the function do only work if you did not rename the original data, or the names the package gave the files.
#'
#' @param input_filepath \code{character}. The filepath of the grouped HLS files. The files need to be grouped using the auto_group command before.
#' @param output_filepath \code{character}. The filepath where the filtered data should be saved.
#' @param filterClouds \code{logical}. If \code{TRUE}, the function sets all cloud pixels to \code{NA}.
#' @param filerAdjacent \code{logical}. If \code{TRUE}, the function sets all pixels adjacent to clouds to \code{NA}.
#' @param filterSnowice \code{logical}. If \code{TRUE}, the function sets all snow/ice pixels to \code{NA}.
#' @param filterWaster \code{logical}. If \code{TRUE}, the function sets all water pixels to \code{NA}.
#' @param filterAerosol_climatology \code{logical}. If \code{TRUE}, the function sets all aerosol_climatology pixels to \code{NA}.
#' @param filterAerosol_low \code{logical}. If \code{TRUE}, sets all pixels with low aerosol content to \code{NA}.
#' @param filterAerosol_moderate \code{logical}. If \code{TRUE}, sets all pixels with moderate aerosol content to \code{NA}.
#' @param filterAerosol_high \code{logical}. If \code{TRUE}, sets all pixels with high aerosol content to \code{NA}.
#' @return All the files will be filtered and saved in the new folder.
#' @export
#'
automask <- function(input_filepath, output_filepath,
                     filterClouds = FALSE, filterAdjacent = FALSE, filterCloudshadow = FALSE,
                     filterSnowice = FALSE, filterWater = FALSE, filterAerosol_climatology = FALSE,
                     filterAerosol_low = FALSE, filterAerosol_moderate = FALSE, filterAerosol_high = FALSE){

  rasterlist <- list.files(input_filepath, full.names = TRUE)

  for (v in seq_along(rasterlist)){

    rasterpath <- rasterlist[v]
    r <- rast(rasterpath)


    # 1. If-blocks to mask each "obstacle" ------------------------------------

    if (filterClouds == TRUE){

      maskrast <- ((r[[nlyr(r)]]) %/% 2) %% 2
      r0 <- mask(x = r[[1:(nlyr(r)-1)]], mask = maskrast, maskvalues = 1)
      r <- c(r0, r[[(nlyr(r))]])
    }
    if (filterAdjacent == TRUE){

      maskrast <- ((r[[nlyr(r)]]) %/% 4) %% 2
      r0 <- mask(x = r[[1:(nlyr(r)-1)]], mask = maskrast, maskvalues = 1)
      r <- c(r0, r[[(nlyr(r))]])
    }

    if (filterCloudshadow == TRUE){

      maskrast <- ((r[[nlyr(r)]]) %/% 8) %% 2
      r0 <- mask(x = r[[1:(nlyr(r)-1)]], mask = maskrast, maskvalues = 1)
      r <- c(r0, r[[(nlyr(r))]])
    }

    if (filterSnowice == TRUE){

      maskrast <- ((r[[nlyr(r)]]) %/% 16) %% 2
      r0 <- mask(x = r[[1:(nlyr(r)-1)]], mask = maskrast, maskvalues = 1)
      r <- c(r0, r[[(nlyr(r))]])
    }

    if (filterWater == TRUE){

      maskrast <- ((r[[nlyr(r)]]) %/% 32) %% 2
      r0 <- mask(x = r[[1:(nlyr(r)-1)]], mask = maskrast, maskvalues = 1)
      r <- c(r0, r[[(nlyr(r))]])
    }

    aersolmask <- ((r[[nlyr(r)]]) %/% 64)
    if (filterAerosol_climatology == TRUE){

      r0 <- mask(x = r[[1:(nlyr(r)-1)]], mask = maskrast, maskvalues = 0)
      r <- c(r0, r[[(nlyr(r))]])
    }

    if (filterAerosol_low == TRUE){

      r0 <- mask(x = r[[1:(nlyr(r)-1)]], mask = maskrast, maskvalues = 1)
      r <- c(r0, r[[(nlyr(r))]])
    }

    if (filterAerosol_moderate == TRUE){

      r0 <- mask(x = r[[1:(nlyr(r)-1)]], mask = maskrast, maskvalues = 2)
      r <- c(r0, r[[(nlyr(r))]])

    }

    if (filterAerosol_high == TRUE){

      r0 <- mask(x = r[[1:(nlyr(r)-1)]], mask = maskrast, maskvalues = 3)
      r <- c(r0, r[[(nlyr(r))]])
    }
    r <- r[[1:(nlyr(r)-1)]]
    e <- paste0(output_filepath, "/MASKED_", basename(rasterpath))
    writeRaster(r, e)
    print(paste0(e, " was filtered and saved."))
  }
  print("MASKING FINISHED.")
}


