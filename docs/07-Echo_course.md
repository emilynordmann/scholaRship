# Exploring Echo360 video/course level data in R with `tidyverse` {#Echo_course}

## Introduction

Now we have introduced you to the basic principles of reading and summarising Echo360 data, in this chapter we will explore how you can wrangle and visualise video and course level data to recreate and build on the kind of dashboards you can access on Echo360. 

You will need the following packages which are the same as chapter 6, but with the addition of `scales` to add some useful functions for plotting graph axes. You will also need the `data` object you created in chapter 6, but you can rerun the code below if you do not have it available already. If you do not have the data downloaded already, please [download the .zip file](data/Echo360_Data/Echo360_data.zip) containing 9 files of Echo360 data. Our tutorial assumes you have a folder called "data" in your working directory, and we created a subfolder called "Echo360_Data" to place these files. If you saved the data in another way, remember to edit the file paths first. 


```r
library(tidyverse) # Package of packages for plotting and wrangling 
library(plotly) # Creates interactive plots 
library(ggpubr) # Builds on ggplot2 to build specific publication ready plots 
library(scales) # Includes functions for specifying plot scales
library(lubridate)
```


```r
# Obtain list of files from directory
files <- list.files(path = "data/Echo360_Data/", 
                    pattern=".csv") 

# Read in all files
data <- read_csv(paste0("data/Echo360_Data/", files), # Add our working directory to the list of files 
                 id="video") # What should be call the column containing the name of the video file? 

# Fill in spaces between column names
data <- tibble(data, 
               .name_repair = "universal") # Setting to universal makes all names unique and syntactic

# To break this code down, we start with the innermost function
# 1. We first make each unique video name a factor (unique category)
# 2. We then make each factor a number, so we get an ascending number from 1 to 9
data$video <- as.numeric(as.factor(data$video))
```

## Handling date/time data with `lubridate`

Handling date/time data in R is somewhat different from other variable types and should be treated differently and handled with care. The `lubridate` package in R (loaded as part of the `tidyverse`) allows us to easily handle tricky date/time data and extract useful information from these. 

### Converting variables to date/time format

The first task will be to convert any date/time data we have into the correct format. In the sample data we are working with, we have five variables which contain such data which are: `Create.Date`, `Duration`, `Total.View.Time`, `Average.View.Time` and `Last.Viewed`. 

On closer inspection, these variables fall into two types:

- `Create.Data` and `Last.Viewed` are listed as a date (a particular day)

- `Duration`, `Total.View.Time` and `Average.View.Time` are listed as a time, recorded in hours, minutes, and seconds.

Several functions can be used to take a data string and convert it into the desired date/time format. There is a useful [cheat sheet you can download](https://rstudio.github.io/cheatsheets/html/lubridate.html) for the `lubridate` library which contains examples of such functions. For our data, we will use the `mdy()` function to convert dates as month-day-year, and the `hms()` function to convert times as hours-minutes-seconds.


```r
# For times, mutate across three columns and convert to hours, minutes, seconds
# For dates, mutate across two columns and convert to month, day, year
data <- data %>%
  mutate(across(.cols = c('duration', 'total_view_time', 'average_view_time'), 
                .fns = hms)) %>%
  mutate(across(.cols = c('create_date', 'last_viewed'), 
                .fns = mdy))
```

Here, we use a combination of mutate and across to apply a given function to multiple columns. Within across, we specify two arguments. In .cols, we specify the columns we want to apply our function to and in .fns, we specify the function we want to apply to those columns.

::: {.info data-latex=""}
`hms()` converts a string into a date/time object which is set by hours-minutes-seconds. `mdy()` converts a string into a date/time object which is set by month-day-year. Echo360 data saves date/times in US format, so pay attention to how date/time data is stored to data you work with to make sure it recognises the information in the right order. There are alternative functions like `ymd()` and `dmy()` if data you work with is stored differently. 
:::

We can take a look at the result of these transformations more closely using `head()` to preview the first five cases of each variable:


```r
# First five cases of duration 
head(data$duration)
# First five cases of last viewed
head(data$last_viewed)
```

```
## [1] "13M 11S" "13M 11S" "13M 11S" "13M 11S" "13M 11S" "13M 11S"
## [1] "2023-01-16" "2023-01-18" "2023-01-24" "2023-01-15" "2023-01-16"
## [6] "2023-02-15"
```

### Extracting elements from date/time data

Sometimes, you may wish to obtain specific parts of a date/time such as the month, the minutes etc. There are several functions in `lubridate` which allow us to extract these easily from a date/time object.

Say we wish to only obtain the minutes from `Average.View.Time`, we can obtain this easily using the <code><span><span class='fu'>minute</span><span class='op'>(</span><span class='op'>)</span></span></code> function and preview the first five cases. 


```r
# Add a new average view minutes column to our data
data <- data %>% 
  mutate(average_view_minute = minute(data$average_view_time)) # Isolate the minutes from the average view time column

# Print the first five cases
head(data$average_view_minute)
```

```
## [1] 10 12 13  5  9  2
```

As we start to get into the habit of visualising data to aid exploration, we can quickly observe some summary statistics by producing a boxplot of the average view time in minutes. 


```r
fig_avg_minutes <- data %>% 
  ggplot(aes(y = average_view_minute)) + # We only need the y axis of view time minutes
  geom_boxplot() + # Add a boxplot layer
  labs(title = "Boxplot of average video viewing times",
       y = "View time (mins)") + # Specify the main title and y axis label
  theme_bw() # Tidy up the theme

fig_avg_minutes
```

<img src="07-Echo_course_files/figure-html/average minute boxplot-1.png" width="100%" style="display: block; margin: auto;" />

Sometimes it can be difficult to precisely identify the y axis value for each element in a plot, so you can also produce an interactive version of the boxplot by using the <code class='package'>plotly</code> package. Once we define a graph in `ggplot2`, we can convert it into an interactive plot using the `ggplotly()` function. 


```r
ggplotly(fig_avg_minutes)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-5a8919f24e84a3803ee4" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-5a8919f24e84a3803ee4">{"x":{"data":[{"y":[10,12,13,5,9,2,6,5,12,13,8,0,10,13,13,12,13,6,13,12,11,6,6,0,13,12,12,12,13,13,13,2,13,13,13,13,13,7,13,6,6,13,6,6,6,13,13,0,4,13,4,13,13,6,6,2,13,11,10,11,13,3,6,8,13,6,13,1,4,11,13,13,13,13,1,12,13,5,11,13,7,13,6,13,12,6,13,13,13,13,3,9,10,13,6,3,13,6,3,12,13,6,13,6,0,13,13,12,13,12,12,6,12,13,13,2,13,13,6,13,13,12,10,13,6,13,4,13,3,6,6,10,6,6,0,6,13,13,13,7,13,13,6,6,6,12,4,12,7,12,13,6,13,11,5,13,6,9,13,8,13,13,13,6,6,13,4,4,4,12,13,11,13,13,13,13,10,12,10,13,5,11,4,2,13,4,5,13,13,13,6,13,11,13,13,12,13,13,6,13,12,6,13,13,11,12,13,13,12,12,6,13,11,12,6,13,0,7,7,12,13,6,13,13,13,12,13,13,13,6,13,6,13,4,13,13,12,11,13,13,13,13,10,13,13,0,6,13,12,11,13,3,6,0,12,3,13,0,11,7,13,12,13,7,1,7,13,12,13,13,13,13,6,13,13,6,13,13,13,7,13,11,6,12,13,6,5,13,7,9,13,13,13,12,0,4,13,13,13,13,13,13,3,13,13,12,5,12,7,13,0,13,4,13,12,6,12,12,13,13,3,13,12,10,6,6,11,13,13,13,9,12,13,13,6,13,13,4,13,13,13,13,12,13,12,13,13,9,13,6,13,13,13,13,4,13,6,6,13,13,7,13,12,2,6,13,9,13,12,12,6,4,6,7,6,6,3,13,13,13,10,13,13,13,14,14,14,13,12,14,3,15,6,12,5,15,14,4,13,14,15,9,4,7,11,0,15,15,14,14,15,14,15,7,14,15,15,14,15,14,15,3,15,7,12,5,14,10,15,13,15,14,14,15,12,0,15,15,15,6,14,0,14,6,14,0,6,6,14,14,7,15,2,15,15,12,6,15,14,15,15,12,12,7,15,15,14,14,8,8,15,0,6,15,14,1,10,15,15,8,7,15,15,14,15,15,12,5,15,14,6,7,14,15,14,14,14,14,14,6,1,9,13,9,15,6,15,10,15,14,6,13,14,15,15,6,13,15,14,5,5,7,14,15,15,15,15,14,12,15,8,7,15,15,15,14,14,14,7,15,5,9,2,14,14,14,13,15,14,9,7,10,14,3,8,15,7,4,13,13,14,15,9,15,11,15,15,15,16,14,16,16,16,16,0,16,16,16,16,16,8,16,13,14,8,3,8,16,8,0,16,8,16,6,16,16,16,16,5,15,16,16,16,16,16,16,5,16,16,15,4,8,16,1,16,16,16,7,16,8,8,7,0,3,8,16,16,0,16,16,16,15,16,11,16,16,15,6,8,7,16,16,8,16,8,2,8,16,0,12,16,16,12,16,16,13,8,16,14,8,16,16,16,16,16,8,8,16,16,10,14,16,16,5,13,8,10,10,16,8,16,16,7,16,16,16,1,12,16,15,5,16,15,16,0,8,16,16,14,16,16,13,16,14,16,10,16,16,15,16,16,8,15,8,11,16,16,0,5,16,5,12,12,8,16,13,2,16,7,5,7,0,16,0,13,10,3,10,5,5,5,10,0,10,10,10,10,10,10,10,8,2,10,10,10,10,10,10,10,5,10,10,10,10,5,10,10,10,10,7,10,10,10,10,10,9,10,10,10,10,10,10,10,10,10,4,5,10,10,1,10,10,10,10,10,9,10,10,10,6,5,10,5,10,10,10,5,3,1,0,5,10,10,10,10,5,10,5,0,10,10,10,10,10,5,10,10,5,10,10,9,5,10,5,9,10,7,10,10,10,8,10,10,10,10,10,10,10,10,5,10,10,10,10,10,10,10,5,10,4,10,10,10,5,5,10,10,10,6,5,10,6,10,10,4,10,10,10,10,10,10,0,6,5,10,10,10,16,14,13,7,8,13,10,16,3,11,14,16,16,3,10,15,14,9,8,7,8,16,16,16,14,15,16,8,7,16,16,16,11,12,16,16,16,10,9,16,16,16,16,16,16,13,9,12,6,11,15,5,0,15,9,16,11,16,3,16,16,14,5,7,16,16,6,16,16,16,5,0,15,16,16,11,6,12,16,12,13,13,10,8,10,13,16,16,16,16,10,9,14,16,5,4,16,7,0,16,14,11,16,16,16,16,16,12,11,4,5,9,16,16,16,0,16,14,16,8,5,16,11,14,16,16,14,16,16,16,13,16,16,14,16,16,4,13,13,8,16,2,13,14,15,11,14,14,5,7,4,14,2,14,14,6,13,14,14,14,7,0,12,14,14,13,14,14,14,14,14,14,14,14,14,12,14,14,14,14,13,14,14,13,14,6,7,14,0,14,14,14,14,7,14,14,14,14,14,14,4,7,10,14,14,1,7,2,14,14,14,9,14,14,13,14,14,4,14,7,14,13,9,12,14,7,8,14,6,14,14,14,14,13,13,14,7,14,14,14,13,12,11,13,14,14,7,14,7,4,14,14,5,14,14,14,14,14,14,14,13,14,13,14,14,14,14,14,14,12,0,14,13,14,14,13,13,0,14,7,14,14,0,7,14,14,13,14,14,14,12,14,14,7,7,7,14,14,14,7,14,14,14,4,14,3,14,14,14,3,14,5,14,14,13,12,14,14,14,14,14,14,14,7,14,9,14,14,14,14,14,14,14,14,14,14,13,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,7,14,14,7,2,14,14,14,14,14,14,14,14,7,14,14,14,14,6,14,7,3,9,12,14,7,14,14,7,14,7,14,14,14,14,13,7,14,14,14,7,14,14,2,14,14,7,0,14,14,7,14,14,5,3,14,14,14,14,14,14,14,14,2,14,14,14,14,14,13,14,6,14,14,4,7,14,14,14,11,14,14,2,14,5,1,7,14,12,14,14,14,5,8,11,14,7,15,18,18,8,18,8,18,18,2,15,18,14,18,18,14,13,9,16,18,18,7,18,18,18,14,18,0,5,0,15,14,18,14,9,17,18,15,18,18,17,14,16,13,18,7,9,16,18,18,14,9,18,9,13,11,11,13,6,18,15,16,18,4,6,15,7,9,15,7,18,18,13,18,8,18,18,18,3,5,12,17,4,18,7,18,8,0,18,18,14,15,18,18,14,12,6,17,15,18,18,18,1,16,18,18,18,13,18,9,10,12,18,18,17,9,18,18,15,18,9,14,9,0,9,8,5,8,13,16],"hoverinfo":"y","type":"box","fillcolor":"rgba(255,255,255,1)","marker":{"opacity":null,"outliercolor":"rgba(0,0,0,1)","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)"},"size":5.6692913385826778},"line":{"color":"rgba(51,51,51,1)","width":1.8897637795275593},"showlegend":false,"xaxis":"x","yaxis":"y","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":25.570776255707766,"l":37.260273972602747},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Boxplot of average video viewing times","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-0.41249999999999998,0.41249999999999998],"tickmode":"array","ticktext":["-0.4","-0.2","0.0","0.2","0.4"],"tickvals":[-0.40000000000000002,-0.19999999999999998,0,0.20000000000000007,0.40000000000000002],"categoryorder":"array","categoryarray":["-0.4","-0.2","0.0","0.2","0.4"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-0.90000000000000002,18.899999999999999],"tickmode":"array","ticktext":["0","5","10","15"],"tickvals":[0,5.0000000000000009,10,15],"categoryorder":"array","categoryarray":["0","5","10","15"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"View time (mins)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(51,51,51,1)","width":0.66417600664176002,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.8897637795275593,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"577845005bcd":{"y":{},"type":"box"}},"cur_data":"577845005bcd","visdat":{"577845005bcd":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

As a further example using a date variable, suppose we want to look at the last month students viewed videos across the course. We can obtain this by applying the <code><span><span class='fu'>month</span><span class='op'>(</span><span class='op'>)</span></span></code> function to the `Last.Viewed` variable.


```r
# Add a new month column 
data <- data %>% 
  mutate(month_last_viewed = month(data$last_viewed))

last_viewed <- data %>% 
  ggplot(aes(x = month_last_viewed)) + # Only specify x axis for a bar chart
  geom_bar() + # Create a bar chart 
  labs(title = "Frequency of last month video viewed",
       y = "Frequency",
       x = "Last month video viewed") + 
  theme_bw() + 
  scale_x_continuous(breaks = breaks_pretty()) # Function to tidy up the x axis breaks specifically for dates

last_viewed
```

<img src="07-Echo_course_files/figure-html/last month viewed bar chart-1.png" width="100%" style="display: block; margin: auto;" />

As above, we can convert the bar chart to make it interactive using the <code><span><span class='fu'>ggplotly</span><span class='op'>(</span><span class='op'>)</span></span></code> function. This allows you to hover over the plot and see what the frequency was for each month. 


```r
ggplotly(last_viewed)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-74abe68ec227ba830782" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-74abe68ec227ba830782">{"x":{"data":[{"orientation":"v","width":[0.89999999999999991,0.90000000000000013,0.89999999999999858],"base":[0,0,0],"x":[1,2,12],"y":[1339,126,1],"text":["count: 1339<br />month_last_viewed:  1","count:  126<br />month_last_viewed:  2","count:    1<br />month_last_viewed: 12"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(89,89,89,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826491,"l":48.949771689497723},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Frequency of last month video viewed","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-0.044999999999999929,13.045],"tickmode":"array","ticktext":["0","2","4","6","8","10","12"],"tickvals":[0,2,4,6,8,10,12],"categoryorder":"array","categoryarray":["0","2","4","6","8","10","12"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Last month video viewed","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-66.950000000000003,1405.95],"tickmode":"array","ticktext":["0","500","1000"],"tickvals":[0,500.00000000000006,1000],"categoryorder":"array","categoryarray":["0","500","1000"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Frequency","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(51,51,51,1)","width":0.66417600664176002,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.8897637795275593,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"577823e9c":{"x":{},"type":"bar"}},"cur_data":"577823e9c","visdat":{"577823e9c":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

### Maths with date-times

Sometimes, we may wish to compare the difference in time between events. <code class='package'>lubridate</code> provides some useful functions to help us with this. For example, we can look at the difference in average view time to the total duration of the video by using simple arithmetic operators.


```r
data_video1 <- data %>% 
  filter(video == 1) %>% # Filter the videos to select only video 1
  mutate(time_difference = average_view_time - duration) # Add a time difference column between average view time and total duration

head(data_video1$time_difference)
```

```
## [1] "-3M 44S"  "-1M 35S"  "-2S"      "-8M 5S"   "-4M 48S"  "-11M -9S"
```

As this data returns values in minutes and seconds, we can transform this to one unit type for consistency, then use that data to create a boxplot. 


```r
data_video1 <- data_video1 %>% 
  mutate(time_difference = second(time_difference))

time_difference <- data_video1 %>% 
  ggplot(aes(y = time_difference)) + 
  geom_boxplot() + 
  labs(title="Boxplot of average video viewing times compared to total video duration", 
       y = "View time (Seconds)") + 
  theme_bw() + 
  geom_hline(yintercept = 0, color = "red") # Add a horizontal line at 0 to show no difference

time_difference
```

<img src="07-Echo_course_files/figure-html/time difference boxplot-1.png" width="100%" style="display: block; margin: auto;" />

There's a little skew here so we cannot see the full box, but the red horizontal line shows no difference in average view time to the duration of video 1, so where students viewed the whole video. More positive values represent students who watched less of the video than the total duration. 

As before, we can make these values interactive by converting our ggplot visualisation to a <code class='package'>plotly</code> object. 


```r
ggplotly(time_difference)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-ba7027d55ee7d1a533f8" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-ba7027d55ee7d1a533f8">{"x":{"data":[{"y":[44,35,-2,5,48,-9,9,37,44,0,48,4,47,0,0,32,0,0,-1,46,14,22,19,-5,0,40,32,27,0,-1,0,48,-2,0,0,-1,-4,2,-6,21,-4,-6,35,43,7,0,0,-9,10,0,-3,0,-2,31,-11,34,-3,-10,48,-2,0,47,19,3,0,15,0,47,40,30,-2,0,-5,0,1,44,-5,48,14,0,18,0,2,-3,20,12,-3,0,0,0,3,13,18,-7,6,7,0,15,3,44,0,25,0,24,37,0,-1,23,0,44,20,-5,17,0,-1,33,0,0,31,-7,0,-1,-6,-2,13,0,-9,0,27,-2,15,5,27,27,6,33,0,0,0,35,0,0,25,24,25,24,9,20,-11,48,0,23,-7,20,20,-4,29,46,0,19,0,0,0,26,25,0,13,43,11,21,0,39,0,-2,0,0,4,24,-4,0,46,-11,13,29,0,10,6,-3,0,-1,13,0,43,0,0],"hoverinfo":"y","type":"box","fillcolor":"rgba(255,255,255,1)","marker":{"opacity":null,"outliercolor":"rgba(0,0,0,1)","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)"},"size":5.6692913385826778},"line":{"color":"rgba(51,51,51,1)","width":1.8897637795275593},"showlegend":false,"xaxis":"x","yaxis":"y","frame":null},{"x":[-0.41249999999999998,0.41249999999999998],"y":[0,0],"text":"yintercept: 0","type":"scatter","mode":"lines","line":{"width":1.8897637795275593,"color":"rgba(255,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":25.570776255707766,"l":43.105022831050235},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Boxplot of average video viewing times compared to total video duration","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-0.41249999999999998,0.41249999999999998],"tickmode":"array","ticktext":["-0.4","-0.2","0.0","0.2","0.4"],"tickvals":[-0.40000000000000002,-0.19999999999999998,0,0.20000000000000007,0.40000000000000002],"categoryorder":"array","categoryarray":["-0.4","-0.2","0.0","0.2","0.4"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-13.949999999999999,50.950000000000003],"tickmode":"array","ticktext":["-10","0","10","20","30","40","50"],"tickvals":[-10,0,10,20.000000000000004,30.000000000000004,40,50],"categoryorder":"array","categoryarray":["-10","0","10","20","30","40","50"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"View time (Seconds)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(51,51,51,1)","width":0.66417600664176002,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.8897637795275593,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"577871b34895":{"y":{},"type":"box"},"577845de4beb":{"yintercept":{}}},"cur_data":"577871b34895","visdat":{"577871b34895":["function (y) ","x"],"577845de4beb":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

## Total views for each video

In the following section, we will mostly be creating plots of our data summarised at the video level. Given that our data is currently stored at student level (one row per student per video), we will first transform our data into a new data set called `video_data` which will group the data by video and create some variables of interest. First, let's create this new data set with two columns:

* `video`: The video number stored as a factor (this will make it easier to plot later on);

* `total_views`: The total number of views per video.


```r
video_data <- data %>% 
  group_by(video) %>%
  summarise(total_views = sum(total_views)) %>% # for each video, add up all the views across students
  mutate(video = factor(video)) %>%  # Turn video into a factor
  ungroup() # Retaining the group by can sometimes cause problems
```

We can now easily create a bar chart of the total number of views per video.


```r
fig.total.views <- video_data %>% 
  ggplot(aes(x = video, y = total_views)) +
  geom_bar(stat = "identity") + # Since we specify a y value, just show as the value
  labs(title="Total number of views per video",
       y = "Total Views",
       x = "Video") + 
  theme_bw()

fig.total.views
```

<img src="07-Echo_course_files/figure-html/views bar chart-1.png" width="100%" style="display: block; margin: auto;" />

Here, we plot the video number along the x-axis and the total number of views for each video on the y-axis. These numbers include duplications from students who have watched the videos multiple times. 

We may also be interested in the total number of unique views, i.e. the total number of students who watched the video at least once. To do this, we need to create a new variable called `unique_views` which will contain the sum of the rows for each video. We can add this to the video-level data set `video_data`.


```r
video_data <- data %>% 
  group_by(video) %>%
  summarise(total_Views = sum(total_views), 
            unique_views = n()) %>% # For each video, count the number of rows
  mutate(video = factor(video)) %>% 
  ungroup()
```

We can edit the code for the previous bar chart to create a bar chart of the total number of unique student views per video as follows.


```r
fig.unique.views <- video_data %>% 
  ggplot(aes(x = video, y = unique_views)) +
  geom_bar(stat = "identity") + # Since we specify a y value, just show as the value
  labs(title="Total number of unique student views per video",
       y = "Unique Student Views",
       x = "Video") + 
  theme_bw()

fig.unique.views
```

<img src="07-Echo_course_files/figure-html/unique views bar-1.png" width="100%" style="display: block; margin: auto;" />

If you want to view the values per video more precisely like a data dashboard, then you can convert your unique views bar plot into a <code class='package'>plotly</code> object. 


```r
ggplotly(fig.unique.views)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-0019f4ccb46f22695462" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-0019f4ccb46f22695462">{"x":{"data":[{"orientation":"v","width":[0.89999999999999991,0.90000000000000013,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.90000000000000036,0.89999999999999947,0.89999999999999858],"base":[0,0,0,0,0,0,0,0,0],"x":[1,2,3,4,5,6,7,8,9],"y":[195,189,182,169,151,147,155,144,134],"text":["video: 1<br />unique_views: 195","video: 2<br />unique_views: 189","video: 3<br />unique_views: 182","video: 4<br />unique_views: 169","video: 5<br />unique_views: 151","video: 6<br />unique_views: 147","video: 7<br />unique_views: 155","video: 8<br />unique_views: 144","video: 9<br />unique_views: 134"],"type":"bar","textposition":"none","marker":{"autocolorscale":false,"color":"rgba(89,89,89,1)","line":{"width":1.8897637795275593,"color":"transparent"}},"showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826491,"l":43.105022831050235},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Total number of unique student views per video","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.40000000000000002,9.5999999999999996],"tickmode":"array","ticktext":["1","2","3","4","5","6","7","8","9"],"tickvals":[1,2,3,4,5,6,6.9999999999999991,8,9],"categoryorder":"array","categoryarray":["1","2","3","4","5","6","7","8","9"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Video","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-9.75,204.75],"tickmode":"array","ticktext":["0","50","100","150","200"],"tickvals":[0,50,100.00000000000001,150,200],"categoryorder":"array","categoryarray":["0","50","100","150","200"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Unique Student Views","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(51,51,51,1)","width":0.66417600664176002,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.8897637795275593,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"57782950cc5":{"x":{},"y":{},"type":"bar"}},"cur_data":"57782950cc5","visdat":{"57782950cc5":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

### Advanced `plotly` customisation

So far, we have simply transformed our ggplots into a <code class='package'>plotly</code> object. However, we can add additional information in the hover text such as total views, duration of video, and average view time that might be useful to you or your viewer. 

This is going to be a longer process, so we will break it down into a few steps. First, we need to wrangle the data so we have our key summary statistics per video. The first few lines follow the same process as above, but then we add additional summary variables like the average view time and modify existing variables in <code><span><span class='fu'>mutate</span><span class='op'>(</span><span class='op'>)</span></span></code>. 


```r
# Isolate video number and duration of the video to append later
video_duration <- data %>% 
  distinct(video, duration) %>% 
  mutate(duration = period_to_seconds(duration)) # Convert duration from a period to seconds

video_data <- data %>%
  group_by(video) %>%
  summarise(total_views = sum(total_views), 
            unique_views = n(), 
            average_view_time = round(
              mean(period_to_seconds(average_view_time), # lubridate function to transform a period to seconds
                   na.rm = T), # Ignore NA values when taking mean
              0)) %>% # 0 decimals to round
  left_join(video_duration, # Add video duration data to our summary data
            by = "video") %>% # Join by video number
  mutate(video = factor(video),
         repeated_views = total_views - unique_views, # Calculate repeated views subtracting unique views from total views
         percentage_viewed = round(average_view_time / duration * 100, 2)) %>% # Calculate average percentage from average view time as percentage of duration
  ungroup()

head(video_data)
```

<div class="kable-table">

|video | total_views| unique_views| average_view_time| duration| repeated_views| percentage_viewed|
|:-----|-----------:|------------:|-----------------:|--------:|--------------:|-----------------:|
|1     |         291|          195|               590|      791|             96|             74.59|
|2     |         257|          189|               653|      835|             68|             78.20|
|3     |         224|          182|               707|      908|             42|             77.86|
|4     |         226|          169|               752|      994|             57|             75.65|
|5     |         189|          151|               546|      648|             38|             84.26|
|6     |         163|          147|               756|      980|             16|             77.14|

</div>

For each video, we now have a bunch of summary statistics like their view time, duration, and percentage of the video viewed. We can now use this information to present as a dashboard for an overview of each video. 

This time, we are going to use <code class='package'>plotly</code> directly as its easier to edit the hover text options than if we simply convert a `ggplot` object to `plotly`. In the code below, we first create a bar plot for the number of unique views for each video. We then edit the hover template to add additional information into the interactive dashboard like the duration and average view time. 


```r
fig.all.views <- plot_ly(video_data,
  x = ~video,
  y = ~unique_views,
  name = "Unique Views",
  type = "bar",
  hovertemplate = paste0("Video %{x}", # Paste adds all the elements together, <br> is html code for a line break
                         "<br>Total views:", video_data$total_views,
                         "<br>Unique views: %{y}",
                         "<br> Duration: ", seconds_to_period(video_data$duration), # Convert from seconds to minutes and seconds for easier viewing
                         "<br> Average view time: ", seconds_to_period(video_data$average_view_time))) %>%
  layout(title = 'Unique Views per Video', 
         xaxis = list(title = 'Video Number'),
         yaxis = list(title = 'Unique Views'))

fig.all.views
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-cef224f5ff43f40eb26e" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-cef224f5ff43f40eb26e">{"x":{"visdat":{"57784ba05cc6":["function () ","plotlyVisDat"]},"cur_data":"57784ba05cc6","attrs":{"57784ba05cc6":{"x":{},"y":{},"hovertemplate":["Video %{x}<br>Total views:291<br>Unique views: %{y}<br> Duration: 13M 11S<br> Average view time: 9M 50S","Video %{x}<br>Total views:257<br>Unique views: %{y}<br> Duration: 13M 55S<br> Average view time: 10M 53S","Video %{x}<br>Total views:224<br>Unique views: %{y}<br> Duration: 15M 8S<br> Average view time: 11M 47S","Video %{x}<br>Total views:226<br>Unique views: %{y}<br> Duration: 16M 34S<br> Average view time: 12M 32S","Video %{x}<br>Total views:189<br>Unique views: %{y}<br> Duration: 10M 48S<br> Average view time: 9M 6S","Video %{x}<br>Total views:163<br>Unique views: %{y}<br> Duration: 16M 20S<br> Average view time: 12M 36S","Video %{x}<br>Total views:198<br>Unique views: %{y}<br> Duration: 14M 11S<br> Average view time: 11M 58S","Video %{x}<br>Total views:178<br>Unique views: %{y}<br> Duration: 14M 42S<br> Average view time: 12M 30S","Video %{x}<br>Total views:162<br>Unique views: %{y}<br> Duration: 18M 28S<br> Average view time: 13M 40S"],"name":"Unique Views","alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"bar"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"Unique Views per Video","xaxis":{"domain":[0,1],"automargin":true,"title":"Video Number","type":"category","categoryorder":"array","categoryarray":["1","2","3","4","5","6","7","8","9"]},"yaxis":{"domain":[0,1],"automargin":true,"title":"Unique Views"},"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":["1","2","3","4","5","6","7","8","9"],"y":[195,189,182,169,151,147,155,144,134],"hovertemplate":["Video %{x}<br>Total views:291<br>Unique views: %{y}<br> Duration: 13M 11S<br> Average view time: 9M 50S","Video %{x}<br>Total views:257<br>Unique views: %{y}<br> Duration: 13M 55S<br> Average view time: 10M 53S","Video %{x}<br>Total views:224<br>Unique views: %{y}<br> Duration: 15M 8S<br> Average view time: 11M 47S","Video %{x}<br>Total views:226<br>Unique views: %{y}<br> Duration: 16M 34S<br> Average view time: 12M 32S","Video %{x}<br>Total views:189<br>Unique views: %{y}<br> Duration: 10M 48S<br> Average view time: 9M 6S","Video %{x}<br>Total views:163<br>Unique views: %{y}<br> Duration: 16M 20S<br> Average view time: 12M 36S","Video %{x}<br>Total views:198<br>Unique views: %{y}<br> Duration: 14M 11S<br> Average view time: 11M 58S","Video %{x}<br>Total views:178<br>Unique views: %{y}<br> Duration: 14M 42S<br> Average view time: 12M 30S","Video %{x}<br>Total views:162<br>Unique views: %{y}<br> Duration: 18M 28S<br> Average view time: 13M 40S"],"name":"Unique Views","type":"bar","marker":{"color":"rgba(31,119,180,1)","line":{"color":"rgba(31,119,180,1)"}},"error_y":{"color":"rgba(31,119,180,1)"},"error_x":{"color":"rgba(31,119,180,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

Like <code class='package'>ggplot2</code>, once we have defined a <code class='package'>plotly</code> object, we can add additional layers. In this example, we might also want to create a stacked bar plot with the total number of views split into unique student views and repeated views.


```r
# Take the plotly object and add a trace (variable to split by) for the repeated views
fig.all.views <- fig.all.views %>% 
  add_trace(y = ~repeated_views, 
            name = 'Repeated views') %>% 
  layout(yaxis = list(title = 'Count'), # Amend the type of bar plot to make it stacked
         barmode = 'stack')

fig.all.views
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-1f7cd63de59523aeb71e" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-1f7cd63de59523aeb71e">{"x":{"visdat":{"57784ba05cc6":["function () ","plotlyVisDat"]},"cur_data":"57784ba05cc6","attrs":{"57784ba05cc6":{"x":{},"y":{},"hovertemplate":["Video %{x}<br>Total views:291<br>Unique views: %{y}<br> Duration: 13M 11S<br> Average view time: 9M 50S","Video %{x}<br>Total views:257<br>Unique views: %{y}<br> Duration: 13M 55S<br> Average view time: 10M 53S","Video %{x}<br>Total views:224<br>Unique views: %{y}<br> Duration: 15M 8S<br> Average view time: 11M 47S","Video %{x}<br>Total views:226<br>Unique views: %{y}<br> Duration: 16M 34S<br> Average view time: 12M 32S","Video %{x}<br>Total views:189<br>Unique views: %{y}<br> Duration: 10M 48S<br> Average view time: 9M 6S","Video %{x}<br>Total views:163<br>Unique views: %{y}<br> Duration: 16M 20S<br> Average view time: 12M 36S","Video %{x}<br>Total views:198<br>Unique views: %{y}<br> Duration: 14M 11S<br> Average view time: 11M 58S","Video %{x}<br>Total views:178<br>Unique views: %{y}<br> Duration: 14M 42S<br> Average view time: 12M 30S","Video %{x}<br>Total views:162<br>Unique views: %{y}<br> Duration: 18M 28S<br> Average view time: 13M 40S"],"name":"Unique Views","alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"bar"},"57784ba05cc6.1":{"x":{},"y":{},"hovertemplate":["Video %{x}<br>Total views:291<br>Unique views: %{y}<br> Duration: 13M 11S<br> Average view time: 9M 50S","Video %{x}<br>Total views:257<br>Unique views: %{y}<br> Duration: 13M 55S<br> Average view time: 10M 53S","Video %{x}<br>Total views:224<br>Unique views: %{y}<br> Duration: 15M 8S<br> Average view time: 11M 47S","Video %{x}<br>Total views:226<br>Unique views: %{y}<br> Duration: 16M 34S<br> Average view time: 12M 32S","Video %{x}<br>Total views:189<br>Unique views: %{y}<br> Duration: 10M 48S<br> Average view time: 9M 6S","Video %{x}<br>Total views:163<br>Unique views: %{y}<br> Duration: 16M 20S<br> Average view time: 12M 36S","Video %{x}<br>Total views:198<br>Unique views: %{y}<br> Duration: 14M 11S<br> Average view time: 11M 58S","Video %{x}<br>Total views:178<br>Unique views: %{y}<br> Duration: 14M 42S<br> Average view time: 12M 30S","Video %{x}<br>Total views:162<br>Unique views: %{y}<br> Duration: 18M 28S<br> Average view time: 13M 40S"],"name":"Repeated views","alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"bar","inherit":true}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"Unique Views per Video","xaxis":{"domain":[0,1],"automargin":true,"title":"Video Number","type":"category","categoryorder":"array","categoryarray":["1","2","3","4","5","6","7","8","9"]},"yaxis":{"domain":[0,1],"automargin":true,"title":"Count"},"barmode":"stack","hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":["1","2","3","4","5","6","7","8","9"],"y":[195,189,182,169,151,147,155,144,134],"hovertemplate":["Video %{x}<br>Total views:291<br>Unique views: %{y}<br> Duration: 13M 11S<br> Average view time: 9M 50S","Video %{x}<br>Total views:257<br>Unique views: %{y}<br> Duration: 13M 55S<br> Average view time: 10M 53S","Video %{x}<br>Total views:224<br>Unique views: %{y}<br> Duration: 15M 8S<br> Average view time: 11M 47S","Video %{x}<br>Total views:226<br>Unique views: %{y}<br> Duration: 16M 34S<br> Average view time: 12M 32S","Video %{x}<br>Total views:189<br>Unique views: %{y}<br> Duration: 10M 48S<br> Average view time: 9M 6S","Video %{x}<br>Total views:163<br>Unique views: %{y}<br> Duration: 16M 20S<br> Average view time: 12M 36S","Video %{x}<br>Total views:198<br>Unique views: %{y}<br> Duration: 14M 11S<br> Average view time: 11M 58S","Video %{x}<br>Total views:178<br>Unique views: %{y}<br> Duration: 14M 42S<br> Average view time: 12M 30S","Video %{x}<br>Total views:162<br>Unique views: %{y}<br> Duration: 18M 28S<br> Average view time: 13M 40S"],"name":"Unique Views","type":"bar","marker":{"color":"rgba(31,119,180,1)","line":{"color":"rgba(31,119,180,1)"}},"error_y":{"color":"rgba(31,119,180,1)"},"error_x":{"color":"rgba(31,119,180,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":["1","2","3","4","5","6","7","8","9"],"y":[96,68,42,57,38,16,43,34,28],"hovertemplate":["Video %{x}<br>Total views:291<br>Unique views: %{y}<br> Duration: 13M 11S<br> Average view time: 9M 50S","Video %{x}<br>Total views:257<br>Unique views: %{y}<br> Duration: 13M 55S<br> Average view time: 10M 53S","Video %{x}<br>Total views:224<br>Unique views: %{y}<br> Duration: 15M 8S<br> Average view time: 11M 47S","Video %{x}<br>Total views:226<br>Unique views: %{y}<br> Duration: 16M 34S<br> Average view time: 12M 32S","Video %{x}<br>Total views:189<br>Unique views: %{y}<br> Duration: 10M 48S<br> Average view time: 9M 6S","Video %{x}<br>Total views:163<br>Unique views: %{y}<br> Duration: 16M 20S<br> Average view time: 12M 36S","Video %{x}<br>Total views:198<br>Unique views: %{y}<br> Duration: 14M 11S<br> Average view time: 11M 58S","Video %{x}<br>Total views:178<br>Unique views: %{y}<br> Duration: 14M 42S<br> Average view time: 12M 30S","Video %{x}<br>Total views:162<br>Unique views: %{y}<br> Duration: 18M 28S<br> Average view time: 13M 40S"],"name":"Repeated views","type":"bar","marker":{"color":"rgba(255,127,14,1)","line":{"color":"rgba(255,127,14,1)"}},"error_y":{"color":"rgba(255,127,14,1)"},"error_x":{"color":"rgba(255,127,14,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

## Video duration vs. average percentage viewed

As one final type of data visualisation, we will create a scatterplot of video duration against the average percentage of video viewed using <code><span><span class='st'>"ggplot()"</span></span></code>.


```r
fig.duration.viewed <- video_data %>% 
  ggplot(aes(x = duration, y = percentage_viewed)) +
  geom_point() + 
  labs(title = "Video duration vs. average percentage viewed",
       y = "Average percentage of video viewed",
       x = "Video duration (Seconds)") + 
  theme_bw() + 
  scale_y_continuous(breaks = pretty_breaks()) # Convert the y axis to tidier labels for percentages

fig.duration.viewed
```

<img src="07-Echo_course_files/figure-html/duration percentage scatterplot-1.png" width="100%" style="display: block; margin: auto;" />

As before, we can convert our scatterplot into a <code class='package'>plotly</code> object to make it interactive as we scroll across the values. 


```r
ggplotly(fig.duration.viewed)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-ef2e76748277ece06f76" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-ef2e76748277ece06f76">{"x":{"data":[{"x":[791,835,908,994,648,980,851,882,1108],"y":[74.590000000000003,78.200000000000003,77.859999999999999,75.650000000000006,84.260000000000005,77.140000000000001,84.370000000000005,85.030000000000001,74.010000000000005],"text":["duration:  791<br />percentage_viewed: 74.59","duration:  835<br />percentage_viewed: 78.20","duration:  908<br />percentage_viewed: 77.86","duration:  994<br />percentage_viewed: 75.65","duration:  648<br />percentage_viewed: 84.26","duration:  980<br />percentage_viewed: 77.14","duration:  851<br />percentage_viewed: 84.37","duration:  882<br />percentage_viewed: 85.03","duration: 1108<br />percentage_viewed: 74.01"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(0,0,0,1)","opacity":1,"size":5.6692913385826778,"symbol":"circle","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)"}},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826491,"l":37.260273972602747},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Video duration vs. average percentage viewed","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[625,1131],"tickmode":"array","ticktext":["700","800","900","1000","1100"],"tickvals":[700,800,900,1000,1100],"categoryorder":"array","categoryarray":["700","800","900","1000","1100"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Video duration (Seconds)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[73.459000000000003,85.581000000000003],"tickmode":"array","ticktext":["74","76","78","80","82","84"],"tickvals":[74,76,78,80,82,84],"categoryorder":"array","categoryarray":["74","76","78","80","82","84"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Average percentage of video viewed","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(51,51,51,1)","width":0.66417600664176002,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.8897637795275593,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"577857e570f1":{"x":{},"y":{},"type":"scatter"}},"cur_data":"577857e570f1","visdat":{"577857e570f1":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

### Advanced `plotly` customisation

Like we demonstrated for the bar plot, we can create a scatterplot entirely within <code class='package'>plotly</code> to allow us to modify the hover template to include additional summary statistics. 


```r
fig.duration.viewed.2 <- plot_ly(video_data,
               x = ~duration,
               y = ~percentage_viewed,
               type = "scatter",
               mode = "markers",
               hovertemplate = paste0("Video ", video_data$video,
                                      "<br>Average percentage viewed: ", round(video_data$percentage_viewed,1), "%",
                                      "<br> Duration: ", video_data$duration,
                                      "<br> Average view time: ", video_data$average_view_time,
                                      "<extra></extra>"))%>%
  layout(xaxis = list(title = 'Duration of video'),
         yaxis = list(title = 'Percentage of video viewed'))

fig.duration.viewed.2
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-d8cf08e77fd11be7413a" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-d8cf08e77fd11be7413a">{"x":{"visdat":{"57784a697452":["function () ","plotlyVisDat"]},"cur_data":"57784a697452","attrs":{"57784a697452":{"x":{},"y":{},"mode":"markers","hovertemplate":["Video 1<br>Average percentage viewed: 74.6%<br> Duration: 791<br> Average view time: 590<extra><\/extra>","Video 2<br>Average percentage viewed: 78.2%<br> Duration: 835<br> Average view time: 653<extra><\/extra>","Video 3<br>Average percentage viewed: 77.9%<br> Duration: 908<br> Average view time: 707<extra><\/extra>","Video 4<br>Average percentage viewed: 75.7%<br> Duration: 994<br> Average view time: 752<extra><\/extra>","Video 5<br>Average percentage viewed: 84.3%<br> Duration: 648<br> Average view time: 546<extra><\/extra>","Video 6<br>Average percentage viewed: 77.1%<br> Duration: 980<br> Average view time: 756<extra><\/extra>","Video 7<br>Average percentage viewed: 84.4%<br> Duration: 851<br> Average view time: 718<extra><\/extra>","Video 8<br>Average percentage viewed: 85%<br> Duration: 882<br> Average view time: 750<extra><\/extra>","Video 9<br>Average percentage viewed: 74%<br> Duration: 1108<br> Average view time: 820<extra><\/extra>"],"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"xaxis":{"domain":[0,1],"automargin":true,"title":"Duration of video"},"yaxis":{"domain":[0,1],"automargin":true,"title":"Percentage of video viewed"},"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[791,835,908,994,648,980,851,882,1108],"y":[74.590000000000003,78.200000000000003,77.859999999999999,75.650000000000006,84.260000000000005,77.140000000000001,84.370000000000005,85.030000000000001,74.010000000000005],"mode":"markers","hovertemplate":["Video 1<br>Average percentage viewed: 74.6%<br> Duration: 791<br> Average view time: 590<extra><\/extra>","Video 2<br>Average percentage viewed: 78.2%<br> Duration: 835<br> Average view time: 653<extra><\/extra>","Video 3<br>Average percentage viewed: 77.9%<br> Duration: 908<br> Average view time: 707<extra><\/extra>","Video 4<br>Average percentage viewed: 75.7%<br> Duration: 994<br> Average view time: 752<extra><\/extra>","Video 5<br>Average percentage viewed: 84.3%<br> Duration: 648<br> Average view time: 546<extra><\/extra>","Video 6<br>Average percentage viewed: 77.1%<br> Duration: 980<br> Average view time: 756<extra><\/extra>","Video 7<br>Average percentage viewed: 84.4%<br> Duration: 851<br> Average view time: 718<extra><\/extra>","Video 8<br>Average percentage viewed: 85%<br> Duration: 882<br> Average view time: 750<extra><\/extra>","Video 9<br>Average percentage viewed: 74%<br> Duration: 1108<br> Average view time: 820<extra><\/extra>"],"type":"scatter","marker":{"color":"rgba(31,119,180,1)","line":{"color":"rgba(31,119,180,1)"}},"error_y":{"color":"rgba(31,119,180,1)"},"error_x":{"color":"rgba(31,119,180,1)"},"line":{"color":"rgba(31,119,180,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

