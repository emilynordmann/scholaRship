# Introduction {#intro}

Getting started with the scholarship of teaching and learning can be difficult. For the majority of academics whose subject expertise does not involve learning and teaching, the first hurdle of figuring out what questions you can ask and answer (and indeed are interested in) can be the toughest one to push past.

Once you have settled on an area of enquiry, you may find that the most appropriate methodologies to investigate your questions are not ones you have been trained in. For quantitatively-minded researchers, the availability of data can feel like simultaneous feast and famine - you may have access to huge amounts of data through learning analytics and standard student records but will be able to use almost none of it for research purposes due to the need for opt-in consent. Where such consent has been obtained, you may have small, non-representative samples and/or non-random attrition.

Finally, the data you do have can be seriously messy: missing data, data from multiple sources with different structures and labels, data from different academic years where course structures and assessments have changed, anonymised data, or aggregated data.

If any of this sounds familiar, this book is for you.

Each tutorial in this book will contain:

-   A short summary of the **evidence-base** for the problem under investigation to promote engagement with the SoTL literature;
-   **Real**[^1] messy, imperfect data drawn from commonly available sources such as Moodle, Turnitin, Microsoft Forms, and Echo360;
-   A walkthrough of how to **clean and wrangle** the data using a predominantly `tidyverse` approach;
-   A walkthrough of how to **analyse**, **interpret, and**, and **write-up** the analysis, alongside an honest discussion of the limitations of the approach used.

[^1]: **Due to the need for ethical approval, the data we use in this book won't be strictly real data, instead, it will be a simulated, synthetic copy of real data. All the mess, none of the consent issues.**

## Expectations of prior knowledge

### R and RStudio

Minimal prior knowledge of R and RStudio is assumed throughout this book. All functions and code used will be explained, however, we assume that the reader understands how to:

-   Install R and RStudio

-   Navigate RStudio

-   Set the working directory appropriately

-   Install and load packages

-   Write and execute code

For any reader that wishes to recap these skills, the appendix contains resources on how to install R and RStudio, and an introduction to R and RStudio.

### Research methods and statistics

We assume a basic level of competency in research methods and statistics. However, we also recognise that many researchers are still less familiar with more modern approaches such as mixed effects models and will provide an appropriate level of explanation and further resources where necessary.
