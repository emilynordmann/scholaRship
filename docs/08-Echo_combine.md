# Combining Echo360 data with other sources of data with `tidyverse` {#Echo_combine}

## Introduction

So far, we have focused on analysing Echo360 data in isolation. However, you might be interested in combining data from multiple sources to explore if there are relationships between lecture capture and engagement/attainment data. 

In this tutorial, we will demonstrate how you can combine data from multiple sources and the kind of identifiers you will need to match people across data sets. In addition to Echo360 data we have used so far, we also have two types of data from the virtual learning environment (VLE) Moodle, based on an introductory research methods course (RM1). We have mock checklist data for how many tasks people complete each week and mock attainment data for scores on a multiple choice quiz (MCQ). We applied the same synthetic data process and created anonymous names and emails to provide consistent information across files to join. 

To follow the tutorial, please download the Echo360 and Moodle data from [this .zip file. ](data/Combine_data.zip). 


```r
library(tidyverse) # Package of packages for plotting and wrangling 
library(plotly) # Creates interactive plots 
```

```
## 
## Attaching package: 'plotly'
```

```
## The following object is masked from 'package:ggplot2':
## 
##     last_plot
```

```
## The following object is masked from 'package:stats':
## 
##     filter
```

```
## The following object is masked from 'package:graphics':
## 
##     layout
```

```r
library(ggpubr) # Builds on ggplot2 to build specific publication ready plots 
```

## Reading in the data

The first step is to read in the data we need for the tutorial. For the first example, we will read in data from one lecture. For later examples, we will combine data from multiple lectures. We only have three lectures of Echo360 data for this course, but to reduce repetition and scale better if you are working with more files, we will still read in data by listing files instead of assigning each file individually to an object. We are using relatives paths for the tutorial and assume you have a folder called `data` in your working directory and two subfolders called `RM1_duplicate` and `Moodle_duplicate`. If you saved the data in another way, you will need to edit the paths. 


```r
# One lecture for an example 
lecture_01 <- read_csv("data/RM1_duplicate/Lecture01.csv")

# Reading the Echo360 data from three lectures into one data object
# Obtain list of files from directory
files <- list.files(path="data/RM1_duplicate/", 
                    pattern=".csv", 
                    full.names = TRUE) 

# Read in all the files to one object and label each file name
Echo360_data <- read_csv(files,
                         id="file_name")

# Preview the columns and data
glimpse(Echo360_data)
```

```
## Rows: 145
## Columns: 16
## $ file_name         <chr> "data/RM1_duplicate//Lecture01.csv", "data/RM1_dupli…
## $ media_id          <chr> "28dcfb20-a198-438b-8dbe-1b5725514231", "28dcfb20-a1…
## $ media_name        <chr> "RM1 Lecture 1", "RM1 Lecture 1", "RM1 Lecture 1", "…
## $ create_date       <chr> "09/23/2022", "09/23/2022", "09/23/2022", "09/23/202…
## $ duration          <time> 01:00:00, 01:00:00, 01:00:00, 01:00:00, 01:00:00, 0…
## $ owner_name        <chr> "James Bartlett", "James Bartlett", "James Bartlett"…
## $ course            <chr> "Research Methods 1 (PGT Conv)", "Research Methods 1…
## $ user_name         <chr> "Yaw, Collin", "Viaan, Jordan", NA, NA, "Sunny, Hali…
## $ email_address     <chr> "214488@university.ac.uk", "211717@university.ac.uk"…
## $ total_views       <dbl> 1, 1, 1, 3, 1, 1, 1, 2, 2, 2, 1, 2, 1, 3, 3, 1, 1, 5…
## $ total_view_time   <time> 00:00:30, 00:01:00, 00:00:08, 00:04:30, 00:01:00, 0…
## $ average_view_time <time> 00:00:30, 00:01:00, 00:00:08, 00:01:30, 00:01:00, 0…
## $ on_demand_views   <dbl> 1, 1, 1, 3, 1, 1, 1, 2, 2, 2, 1, 2, 1, 3, 3, 1, 1, 5…
## $ live_view_count   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
## $ downloads         <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
## $ last_viewed       <chr> "11/04/2022", "09/30/2022", "02/10/2023", "10/21/202…
```

We only have individual files for the checklist and MCQ data, so we can assign those to individual objects. 


```r
# Reading student data from other Moodle activities into two data objects
Checklist <- read.csv("data/Moodle_duplicate/Checklist.csv")  #A log of checklist elements clicked

MCQ <- read.csv("data/Moodle_duplicate/MCQ.csv")  #Results from Multiple Choice Quiz
```

## Joining data using `dplyr`

The <code class='package'>dplyr</code> package in `tidyverse` has several functions that merge or "join" data. There are several versions of these functions depending on how you want to join the files. For a detailed overview, please refer to the [dplyr reference page online](https://dplyr.tidyverse.org/reference/mutate-joins.html).

There are two main types of joins which add and match columns from two data frames. There is <code><span class='fu'>inner_join</span><span class='op'>(</span><span class='op'>)</span></code> which only retains observations from data frame 1 that also has a matching case in data frame 2. There are then different types of outer joins which retain observations that appear in at least one data frame, such as <code><span class='fu'>left_join</span><span class='op'>(</span><span class='op'>)</span></code> which retains all observations in data frame 1. 

To illustrate these functions, we will consider data from Echo360 together with data from a checklist which records the percentage of tasks that student have marked as complete and also with data containing the results of a multiple choice quiz. In both the checklist and MCQ data objects, each student only appears once.

### Merging data where each student only appears once in each data object

If you are interested in combining Echo360 data from just one lecture (and thus where each student will appear once) together with the MCQ data we could follow the following steps.

First, select the variables of interest from each data object, where `lecture_01` contains the Echo360 data from the first lecture.


```r
# Manually select which columns to retain
lecture_01_merge <- lecture_01 %>% 
  select(user_name,
         email_address,
         total_views,
         total_view_time,
         average_view_time,
         last_viewed)

MCQ_merge <- MCQ %>% 
  select(first_name,
         surname,
         id_number,
         email_address,
         quiz_mcq_summative_assessment_real,
         quiz_mcq_summative_assessment_perc)
```

Second, specify the type of 'join' to apply. For this tutorial, we will demonstrate the different types of join to show how the resulting objects differ. Echo360 and Moodle store data differently, so we will need an identifier to use as a key to link people from both files. The participants' email is the only consistent identifier, so we will use that to link participants across files. Other identifying information like the name and student ID number are not consistent across files. 

#### `left_join()`

The first type is <code><span class='fu'>left_join</span><span class='op'>(</span><span class='op'>)</span></code> which retains all observations in data frame 1, meaning we keep everything in `lecture_01_merge` and add information from `MCQ_merge`. We state `email_address` as the shared variable to act as the key. 


```r
lecture_01_MCQ_left <- left_join(lecture_01_merge,
                                MCQ_merge, 
                                by = "email_address")
```

It is important you explore the resulting data frame to make sure everything is as expected. 


```r
glimpse(lecture_01_MCQ_left)
```

```
## Rows: 67
## Columns: 11
## $ user_name                          <chr> "Yaw, Collin", "Viaan, Jordan", NA,…
## $ email_address                      <chr> "214488@university.ac.uk", "211717@…
## $ total_views                        <dbl> 1, 1, 1, 3, 1, 1, 1, 2, 2, 2, 1, 2,…
## $ total_view_time                    <time> 00:00:30, 00:01:00, 00:00:08, 00:0…
## $ average_view_time                  <time> 00:00:30, 00:01:00, 00:00:08, 00:0…
## $ last_viewed                        <chr> "11/04/2022", "09/30/2022", "02/10/…
## $ first_name                         <chr> "Collin", "Jordan", NA, NA, "Hali",…
## $ surname                            <chr> "Yaw", "Viaan", NA, NA, "Sunny", "T…
## $ id_number                          <int> 214488, 211717, NA, NA, 278359, 272…
## $ quiz_mcq_summative_assessment_real <int> 17, 22, NA, NA, 19, 19, 22, NA, 20,…
## $ quiz_mcq_summative_assessment_perc <dbl> 77.27273, 100.00000, NA, NA, 86.363…
```

We started with 67 rows for the Echo360 data and 243 rows for the MCQ data, but because we only wanted to retain all Echo360 observations, we ended up with 67 rows. 

::: {.info data-latex=""}
If you do not enter a column to act as the key, `dplyr` will do its best to identify if there are two columns with the same name. It will warn you about this to make sure you double check it is using the right variables. In the first example, the variable also has the same name which makes things easier. However, you might find the same information has a different name, so you can tell `dplyr` which two columns you want to use as the joining key. See what these alternatives look like below. 
:::


```r
# Warning which column it is joining by
lecture_01_MCQ_left <- left_join(lecture_01_merge,
                                MCQ_merge)
```

```
## Joining with `by = join_by(email_address)`
```


```r
# Rename email
lecture_01_email <- lecture_01_merge %>% 
  rename(email = email_address)

lecture_01_MCQ_left <- left_join(lecture_01_email,
                                MCQ_merge, 
                                by = c("email" = "email_address"))
```

#### `right_join()`

In contrast, <code><span class='fu'>right_join</span><span class='op'>(</span><span class='op'>)</span></code> retains all observations in data frame 2, which is the MCQ data in this example. 


```r
lecture_01_MCQ_right <- right_join(lecture_01_merge,
                                  MCQ_merge, 
                                  by = "email_address")
```

It is important you explore the resulting data frame to make sure everything is as expected. 


```r
glimpse(lecture_01_MCQ_right)
```

```
## Rows: 243
## Columns: 11
## $ user_name                          <chr> "Yaw, Collin", "Viaan, Jordan", "Su…
## $ email_address                      <chr> "214488@university.ac.uk", "211717@…
## $ total_views                        <dbl> 1, 1, 1, 1, 1, 2, 2, 2, 1, 2, 1, 3,…
## $ total_view_time                    <time> 00:00:30, 00:01:00, 00:01:00, 00:0…
## $ average_view_time                  <time> 00:00:30, 00:01:00, 00:01:00, 00:0…
## $ last_viewed                        <chr> "11/04/2022", "09/30/2022", "10/08/…
## $ first_name                         <chr> "Collin", "Jordan", "Hali", "Franki…
## $ surname                            <chr> "Yaw", "Viaan", "Sunny", "Tzivia", …
## $ id_number                          <int> 214488, 211717, 278359, 272061, 275…
## $ quiz_mcq_summative_assessment_real <int> 17, 22, 19, 19, 22, NA, 20, 21, 18,…
## $ quiz_mcq_summative_assessment_perc <dbl> 77.27273, 100.00000, 86.36364, 86.3…
```

We started with 67 rows for the Echo360 data and 243 rows for the MCQ data, but because we wanted to retain all MCQ observations, we ended up with 243 rows. 

#### `full_join()`

Finally, <code><span class='fu'>right_join</span><span class='op'>(</span><span class='op'>)</span></code> retains all observations in data frame 1 and data frame 2. 


```r
lecture_01_MCQ_full <- full_join(lecture_01_merge,
                                MCQ_merge, 
                                by = "email_address")
```

It is important you explore the resulting data frame to make sure everything is as expected. 


```r
glimpse(lecture_01_MCQ_full)
```

```
## Rows: 245
## Columns: 11
## $ user_name                          <chr> "Yaw, Collin", "Viaan, Jordan", NA,…
## $ email_address                      <chr> "214488@university.ac.uk", "211717@…
## $ total_views                        <dbl> 1, 1, 1, 3, 1, 1, 1, 2, 2, 2, 1, 2,…
## $ total_view_time                    <time> 00:00:30, 00:01:00, 00:00:08, 00:0…
## $ average_view_time                  <time> 00:00:30, 00:01:00, 00:00:08, 00:0…
## $ last_viewed                        <chr> "11/04/2022", "09/30/2022", "02/10/…
## $ first_name                         <chr> "Collin", "Jordan", NA, NA, "Hali",…
## $ surname                            <chr> "Yaw", "Viaan", NA, NA, "Sunny", "T…
## $ id_number                          <int> 214488, 211717, NA, NA, 278359, 272…
## $ quiz_mcq_summative_assessment_real <int> 17, 22, NA, NA, 19, 19, 22, NA, 20,…
## $ quiz_mcq_summative_assessment_perc <dbl> 77.27273, 100.00000, NA, NA, 86.363…
```

We started with 67 rows for the Echo360 data and 243 rows for the MCQ data, but because we wanted to retain all MCQ observations, we ended up with 245 rows. 

To summarise:

- The `left` join retains all `nrow(lecture_01_MCQ_left)` student email addresses listed in the Echo360 `lecture_01_merge` object;

- Tthe `right` join retains all `nrow(lecture_01_MCQ_right)` student email addresses listed in the `MCQ_merge` object;

- The `full` join retains all `nrow(lecture_01_MCQ_full)` unique student email addresses listed in both `lecture_01_merge` and `MCQ_merge`.  

On inspection, there are two observations in `lecture_01_merge` that have missing values (`NA`) for `email_address` and these correspond to the two "extra" observations in `lecture_01_MCQ_full` compared to `lecture_01_MCQ_right`.

## Merging data where each student may appear more than once

If we are interested in combining Echo360 data from *multiple* lectures (and thus where students may appear more than once) together with another data object where the students appear only once (such as the checklist and MCQ data described above), then we can still use the `left_join()` function. Despite the function including the argument `multiple` for the "handling of rows in x with multiple matches in y", this argument is not relevant to our scenario since if the Echo360 data is the `x` argument and has multiple rows for each student it can be merged with another data source as the `y` argument (within which each student only appears once) in one of the ways shown previously. 

First, select the variables of interest from each data object, where `Echo360_data` contains the data from the first three lectures.


```r
Echo360_data_merge <- Echo360_data %>% 
  select(user_name, 
         email_address,
         media_name,
         total_views,
         total_view_time,
         average_view_time,
         last_viewed)

MCQ_merge <- MCQ %>% 
  select(first_name,
         surname,
         id_number,
         email_address,
         quiz_mcq_summative_assessment_real,
         quiz_mcq_summative_assessment_perc)
```

::: {.info data-latex=""}
Where students may appear more than once, its necessary to include a variable that distinguishes between the repeated appearances.  In this case its the variable `media_name` which identifies the lecture that the Echo360 data is from.
:::

Second, specify the type of 'join', in this case there is only one.


```r
Echo360_data_MCQ_left <- left_join(Echo360_data_merge,
                                    MCQ_merge,
                                    by = "email_address")
```

Third, check that the input and output data objects are as we expect. 


```r
# Dimensions of original echo 360 data
glimpse(Echo360_data_merge)

# Dimensions of echo 360 data joined with MCQ data 
glimpse(Echo360_data_MCQ_left)
```

```
## Rows: 145
## Columns: 7
## $ user_name         <chr> "Yaw, Collin", "Viaan, Jordan", NA, NA, "Sunny, Hali…
## $ email_address     <chr> "214488@university.ac.uk", "211717@university.ac.uk"…
## $ media_name        <chr> "RM1 Lecture 1", "RM1 Lecture 1", "RM1 Lecture 1", "…
## $ total_views       <dbl> 1, 1, 1, 3, 1, 1, 1, 2, 2, 2, 1, 2, 1, 3, 3, 1, 1, 5…
## $ total_view_time   <time> 00:00:30, 00:01:00, 00:00:08, 00:04:30, 00:01:00, 0…
## $ average_view_time <time> 00:00:30, 00:01:00, 00:00:08, 00:01:30, 00:01:00, 0…
## $ last_viewed       <chr> "11/04/2022", "09/30/2022", "02/10/2023", "10/21/202…
## Rows: 145
## Columns: 12
## $ user_name                          <chr> "Yaw, Collin", "Viaan, Jordan", NA,…
## $ email_address                      <chr> "214488@university.ac.uk", "211717@…
## $ media_name                         <chr> "RM1 Lecture 1", "RM1 Lecture 1", "…
## $ total_views                        <dbl> 1, 1, 1, 3, 1, 1, 1, 2, 2, 2, 1, 2,…
## $ total_view_time                    <time> 00:00:30, 00:01:00, 00:00:08, 00:0…
## $ average_view_time                  <time> 00:00:30, 00:01:00, 00:00:08, 00:0…
## $ last_viewed                        <chr> "11/04/2022", "09/30/2022", "02/10/…
## $ first_name                         <chr> "Collin", "Jordan", NA, NA, "Hali",…
## $ surname                            <chr> "Yaw", "Viaan", NA, NA, "Sunny", "T…
## $ id_number                          <int> 214488, 211717, NA, NA, 278359, 272…
## $ quiz_mcq_summative_assessment_real <int> 17, 22, NA, NA, 19, 19, 22, NA, 20,…
## $ quiz_mcq_summative_assessment_perc <dbl> 77.27273, 100.00000, NA, NA, 86.363…
```

The `left` join retains all 145 observations listed in the `Echo360_data_merge` object and combines them with the (single) corresponding observations in `MCQ_merge`. 

## Visualizing merged data

Merging data enables the exploration of how video engagement (recorded in the Echo360 data) may be related to student performance. For example, the number of times each student views video content can be combined with their performance in an assessment (such as contained in the the MCQ data above). 

First, we need some brief wrangling to summarise the total number of video views per student and repeat the joining process from before.


```r
student_data <- Echo360_data %>% 
  group_by(email_address) %>%
  summarise(total_views = sum(total_views)) %>%
  mutate(email_address = factor(email_address)) %>% 
  ungroup()

student_MCQ <- left_join(student_data,
                         MCQ_merge,
                         by = "email_address") %>% 
  rename(MCQ_perc = quiz_mcq_summative_assessment_perc) # Rename super long name
```

We now have Echo360 and student attainment data that we can use to explore for potential patterns. For example, we can look at the relationship between these two variables in a scatterplot. There is a lot of overlap, so we have added a little jitter to the data points so its easier to see the density. This is why some of the points look like they extend beyond 100%. 


```r
fig.no_viewed.mcq <- student_MCQ %>% 
  ggplot(aes(x = total_views, y = MCQ_perc)) +
  geom_jitter() + 
  labs(title= "Number of Video Views vs. Percentage Score in an MCQ") + 
  ylab("Percentage Score in MCQ (%)") +
  xlab("No. of Video Views") +
  theme_bw()

fig.no_viewed.mcq
```

<img src="08-Echo_combine_files/figure-html/merge_plot-1.png" width="100%" style="display: block; margin: auto;" />

From this plot, it does not look like there is a clear relationship as there are far more video views between 0 and 5, and clustered in the top left to show very good performance above 80%. 

As in the previous chapter, you might want to identify some of these data points in an interactive version of the plot, so you could convert it using <code class='package'>plotly</code>:


```r
ggplotly(fig.no_viewed.mcq)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-925127b1ee4bb57e3131" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-925127b1ee4bb57e3131">{"x":{"data":[{"x":[1.6830885253846646,0.61053204052150245,5.3142882771790028,1.9888711608946323,2.2098684569820763,0.84283447340130802,1.704769678413868,3.37693102452904,1.0982631111517549,4.6738636592403058,2.3926462234929202,0.75231919717043638,1.7582174275070428,0.96858450267463925,0.98103752601891758,6.7988015532493593,1.8592442339286208,0.99892560075968506,3.1225238401442765,6.2613233113661408,0.63317813221365205,1.2271500734612346,1.8351558811962605,2.7198356259614229,3.2303101669996979,1.110190787166357,1.2873677859082817,11.159699680469931,1.7802167043089867,2.8688933618366717,1.3356957970187069,6.1069324886426326,1.3496190115809441,1.2970653757452966,1.0254942931234836,0.90640954636037352,0.71322748549282555,2.8789648504927756,6.9752043003216384,4.0195346090942623,3.7135429942980407,4.2884622650220994,4.9654794102534652,0.60378301963210101,2.6595694970339538,1.3239034408703447,1.6861319890245796,2.2317798210307958,5.63225648291409,0.8073015693575144,1.8967244267463683,3.3535075934603809,0.81775295045226815,0.93746543750166889,5.2498165534809234,5.1488214351236818,8.9283342774957415,1.2678331922739745,2.8513857979327439,0.81241409834474321,0.86876821741461752,0.71697476487606759,0.65580012928694487,2.1297179067507388,9.6909592119976882,1.2055620351806282,6.1660286204889418,2.0720930339768531,0.73821875322610142,1.1314735209569335,2.7225598867982628,15.668494839034974,0.80184998307377098,1.9886330572888256,1.3661477038636805,1.2614556474611165,7.288422577828169,0.77467566281557088,3.3203004492446779,0.97546922639012335,3.2296523902565242,2.1402915302664041,15.626107814721763,0.62126475404948001,4.1536854691803455,0.95324828233569858,0.88730007205158468,5.024003843963146,0.6087435917928814,0.88091258276253936,1.3436974417418242,5.6027254940941926],"y":[96.494569648057222,86.123620015145704,76.191357803446323,87.72535831582816,85.612375576218426,99.138788315044209,78.955427012829603,99.068556085906252,77.302940580147222,92.522207409651429,92.026501777158529,87.78692899187179,93.748615304516122,92.05121794461526,90.707032015039161,75.9689895351502,81.73407886092636,82.984141047874644,86.119008620523587,91.141788658093319,87.864544951272279,100.17455286261711,101.43709363415837,77.54458014599301,81.212670102038174,71.916483283381581,75.568211058324039,82.685310916805818,73.51861425844784,91.611552573740482,98.580254781991243,null,90.273709779774606,100.54816435683857,96.587386660447166,91.270781252533197,60.459736716002226,86.620441257784307,99.414268112318084,69.714921179481507,96.82270587167956,90.062937054105774,99.379950142888859,82.718869793144151,91.335505208169863,94.714751518754795,83.223831711167648,84.682627807117328,89.965259056030348,77.056794842197135,82.84366254017435,84.646495573899969,101.61406121809374,91.122248152440235,82.964121865277946,96.863661100241259,85.07623001763767,86.926556287164033,79.07328792424363,101.03137252344327,82.762406563216999,98.394736515527427,100.68379680880091,92.072256677360684,86.157062672586605,87.745542304421008,69.039908157322884,100.05176460285756,91.892337587408036,100.81814536486159,93.824525689706206,100.71913625029001,89.546909237449825,85.783119312572211,101.33252704346721,90.016504162922502,86.313469906930209,87.740754215893418,83.086759311739698,59.708540212701671,85.259138110347763,null,87.308038820258588,101.32920214906335,84.764947616918519,89.739540252326563,97.176164232025087,92.649795490909696,94.134858877990737,81.636948275633841,86.200705061412663,null],"text":["total_views:  2<br />MCQ_perc:  95.45455","total_views:  1<br />MCQ_perc:  86.36364","total_views:  5<br />MCQ_perc:  77.27273","total_views:  2<br />MCQ_perc:  86.36364","total_views:  2<br />MCQ_perc:  86.36364","total_views:  1<br />MCQ_perc: 100.00000","total_views:  2<br />MCQ_perc:  77.27273","total_views:  3<br />MCQ_perc: 100.00000","total_views:  1<br />MCQ_perc:  77.27273","total_views:  5<br />MCQ_perc:  90.90909","total_views:  2<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc:  86.36364","total_views:  2<br />MCQ_perc:  95.45455","total_views:  1<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc:  90.90909","total_views:  7<br />MCQ_perc:  77.27273","total_views:  2<br />MCQ_perc:  81.81818","total_views:  1<br />MCQ_perc:  81.81818","total_views:  3<br />MCQ_perc:  86.36364","total_views:  6<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc:  86.36364","total_views:  1<br />MCQ_perc: 100.00000","total_views:  2<br />MCQ_perc: 100.00000","total_views:  3<br />MCQ_perc:  77.27273","total_views:  3<br />MCQ_perc:  81.81818","total_views:  1<br />MCQ_perc:  72.72727","total_views:  1<br />MCQ_perc:  77.27273","total_views: 11<br />MCQ_perc:  81.81818","total_views:  2<br />MCQ_perc:  72.72727","total_views:  3<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc: 100.00000","total_views:  6<br />MCQ_perc:        NA","total_views:  1<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc: 100.00000","total_views:  1<br />MCQ_perc:  95.45455","total_views:  1<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc:  59.09091","total_views:  3<br />MCQ_perc:  86.36364","total_views:  7<br />MCQ_perc: 100.00000","total_views:  4<br />MCQ_perc:  68.18182","total_views:  4<br />MCQ_perc:  95.45455","total_views:  4<br />MCQ_perc:  90.90909","total_views:  5<br />MCQ_perc: 100.00000","total_views:  1<br />MCQ_perc:  81.81818","total_views:  3<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc:  95.45455","total_views:  2<br />MCQ_perc:  81.81818","total_views:  2<br />MCQ_perc:  86.36364","total_views:  6<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc:  77.27273","total_views:  2<br />MCQ_perc:  81.81818","total_views:  3<br />MCQ_perc:  86.36364","total_views:  1<br />MCQ_perc: 100.00000","total_views:  1<br />MCQ_perc:  90.90909","total_views:  5<br />MCQ_perc:  81.81818","total_views:  5<br />MCQ_perc:  95.45455","total_views:  9<br />MCQ_perc:  86.36364","total_views:  1<br />MCQ_perc:  86.36364","total_views:  3<br />MCQ_perc:  77.27273","total_views:  1<br />MCQ_perc: 100.00000","total_views:  1<br />MCQ_perc:  81.81818","total_views:  1<br />MCQ_perc: 100.00000","total_views:  1<br />MCQ_perc: 100.00000","total_views:  2<br />MCQ_perc:  90.90909","total_views: 10<br />MCQ_perc:  86.36364","total_views:  1<br />MCQ_perc:  86.36364","total_views:  6<br />MCQ_perc:  68.18182","total_views:  2<br />MCQ_perc: 100.00000","total_views:  1<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc: 100.00000","total_views:  3<br />MCQ_perc:  95.45455","total_views: 16<br />MCQ_perc: 100.00000","total_views:  1<br />MCQ_perc:  90.90909","total_views:  2<br />MCQ_perc:  86.36364","total_views:  1<br />MCQ_perc: 100.00000","total_views:  1<br />MCQ_perc:  90.90909","total_views:  7<br />MCQ_perc:  86.36364","total_views:  1<br />MCQ_perc:  86.36364","total_views:  3<br />MCQ_perc:  81.81818","total_views:  1<br />MCQ_perc:  59.09091","total_views:  3<br />MCQ_perc:  86.36364","total_views:  2<br />MCQ_perc:        NA","total_views: 16<br />MCQ_perc:  86.36364","total_views:  1<br />MCQ_perc: 100.00000","total_views:  4<br />MCQ_perc:  86.36364","total_views:  1<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc:  95.45455","total_views:  5<br />MCQ_perc:  90.90909","total_views:  1<br />MCQ_perc:  95.45455","total_views:  1<br />MCQ_perc:  81.81818","total_views:  1<br />MCQ_perc:  86.36364","total_views:  6<br />MCQ_perc:        NA"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(0,0,0,1)","opacity":1,"size":5.6692913385826778,"symbol":"circle","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)"}},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.762557077625573,"r":7.3059360730593621,"b":40.182648401826498,"l":43.105022831050235},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"title":{"text":"Number of Video Views vs. Percentage Score in an MCQ","font":{"color":"rgba(0,0,0,1)","family":"","size":17.534246575342465},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-0.14945257133804268,16.421730430005116],"tickmode":"array","ticktext":["0","4","8","12","16"],"tickvals":[0,4,7.9999999999999991,12,16],"categoryorder":"array","categoryarray":["0","4","8","12","16"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"No. of Video Views","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[57.613264162432067,103.70933726836334],"tickmode":"array","ticktext":["60","70","80","90","100"],"tickvals":[60,70,80,90,100],"categoryorder":"array","categoryarray":["60","70","80","90","100"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.6529680365296811,"tickwidth":0.66417600664176002,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"Percentage Score in MCQ (%)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(51,51,51,1)","width":0.66417600664176002,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.8897637795275593,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"c0f603cc21f":{"x":{},"y":{},"type":"scatter"}},"cur_data":"c0f603cc21f","visdat":{"c0f603cc21f":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

The purpose of our tutorials has not been to introduce you to inferential statistics, but having the data available means you can explore in different ways. The scatterplot did not suggest there was a clear relationship visually between total video views and MCQ attainment, but maybe there is a subtle statistical relationship. 

Here, we can apply a Spearman correlation since the data may not meet parametric assumptions given the distribution of each variable.  


```r
cor.test(student_MCQ$total_views, 
         student_MCQ$MCQ_perc, 
         method = "spearman")
```

```
## Warning in cor.test.default(student_MCQ$total_views, student_MCQ$MCQ_perc, :
## Cannot compute exact p-value with ties
```

```
## 
## 	Spearman's rank correlation rho
## 
## data:  student_MCQ$total_views and student_MCQ$MCQ_perc
## S = 133575, p-value = 0.2004
## alternative hypothesis: true rho is not equal to 0
## sample estimates:
##        rho 
## -0.1370056
```

The correlation coefficient is slightly negative suggesting as the number of video views increases, the MCQ percentage tends to decrease, but the relationship is not statistically significant. 

This might inspire you to explore additional relationships and variables to see if there patterns worth investigating further to answer research questions you might have. 
