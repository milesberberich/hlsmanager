
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hlsmanager

<!-- badges: start -->

<!-- badges: end -->

## Key features

The goal of hlsmanager is to simplify to work with the HLS dataset from
NASA. When downloaded from NASA AppEEARS; all the bands get saved as on
tiff-file and the user has to merge them based on their filename. With
this package is easy to get: 1. an overview about the data you
downloaded  
2. merge them based on the default filename 3. cloud mask them

The data can be downloaded from:
<https://appeears.earthdatacloud.nasa.gov/?_ga=2.43130661.1417310973.1723470150-437277444.1719598629>
All the steps are consecutive and can be considered the first part of
your workflow. \## Example

This is a basic example which shows you how to solve a common problem:

``` r


summary_df <- hlsmanager::auto_df("C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/tiffsasdownloaded") # HLS data as downloaded
#> [1] "dataframe with,  15  was created."
head(summary_df)
#>   year doy band
#> 1 2025 218  B04
#> 2 2025 228  B04
#> 3 2025 233  B04
#> 4 2025 235  B04
#> 5 2025 243  B04
#> 6 2025 218  B08
#>                                                                                                           filepath
#> 1 C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/tiffsasdownloaded/HLSS30.020_B04_doy2025218_aid0001_32N.tif
#> 2 C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/tiffsasdownloaded/HLSS30.020_B04_doy2025228_aid0001_32N.tif
#> 3 C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/tiffsasdownloaded/HLSS30.020_B04_doy2025233_aid0001_32N.tif
#> 4 C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/tiffsasdownloaded/HLSS30.020_B04_doy2025235_aid0001_32N.tif
#> 5 C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/tiffsasdownloaded/HLSS30.020_B04_doy2025243_aid0001_32N.tif
#> 6 C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/tiffsasdownloaded/HLSS30.020_B08_doy2025218_aid0001_32N.tif
#>                                    filename satellite_typ non_na_pixels
#> 1 HLSS30.020_B04_doy2025218_aid0001_32N.tif      sentinel             0
#> 2 HLSS30.020_B04_doy2025228_aid0001_32N.tif      sentinel             0
#> 3 HLSS30.020_B04_doy2025233_aid0001_32N.tif      sentinel             0
#> 4 HLSS30.020_B04_doy2025235_aid0001_32N.tif      sentinel             0
#> 5 HLSS30.020_B04_doy2025243_aid0001_32N.tif      sentinel             0
#> 6 HLSS30.020_B08_doy2025218_aid0001_32N.tif      sentinel             0
```

\`\`\`{2. Grouping the bands to individual scenes}

autogroup(“C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/tiffsasdownloaded”,
“C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/grouped”)

print(paste(“Number of files
downloaded”,length(list.files(“C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/tiffsasdownloaded”))))

print(paste(“Number of files
grouped”,length(list.files(“C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/grouped”))))

terra::plot(terra::rast(list.files(“C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/grouped”,
full.names=T)\[1\])\[\[1:2\]\])


    ```{3. Applying the cloud mask to the grouped files}

    #auto_mask("C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/grouped", "C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/masked",   filterClouds = TRUE, filterAdjacent = TRUE, filterCloudshadow = TRUE, filterSnowice = FALSE, filterWater = FALSE, filterAerosol_climatology = FALSE, filterAerosol_low = FALSE, filterAerosol_moderate = FALSE, filterAerosol_high = FALSE)

    #terra::plot(terra::rast(list.files("C:/Users/miles/OneDrive/Dokumente/EAGLE/karlakolumna/masked", full.names=T)[1])[[1:2]])

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
