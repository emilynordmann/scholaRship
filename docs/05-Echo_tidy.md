# Getting started with Echo360 data in R with `tidyverse` {#Echo_tidy}

## How to access Echo360 Data

## Reading downloaded data into R using tidyverse

The `readr` library in tidyverse provides us with a host of functions for reading in data to R. Often in a course, you will have multiple video recordings which you have Echo360 data on. It is useful to keep all this data within one data frame in R for analysis, as we will often consider metrics across the full course and not for one video.

The list.files command will list all of the files available within our current working directory. Echo360 data is stored in .csv files and we can specifically list those files using the command pattern = ".csv" as shown below:
