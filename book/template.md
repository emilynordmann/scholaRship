--- 
title: "scholaRship" 
#subtitle: "optional" 
author: "Craig Alexander, James Bartlett, Mitchum Bock, Eilidh Jack, Gaby Mahrholz, Emily Nordmann" # edit
date: "2022-01-09"
site: bookdown::bookdown_site
documentclass: book
classoption: oneside # for PDFs
geometry: margin=1in # for PDFs
bibliography: [book.bib, packages.bib]
csl: include/apa.csl
link-citations: yes
url: https://psyteachr.github.io/template # edit
github-repo: psyteachr/scholaRship # edit
cover-image: images/logos/logo.png # replace with your logo
apple-touch-icon: images/logos/apple-touch-icon.png # replace with your logo
apple-touch-icon-size: 180
favicon: images/logos/favicon.ico # replace with your logo
---



# Overview {-}

<div class="small_right"><img src="images/logos/logo.png" 
     alt="ADS Hex Logo" /></div>





`scholaRship` is a collection of tutorials on how to engage in the scholarship of teaching and learning using quantitative methods and R. It is written by Learning, Teaching, and Scholarship focused academics in the School of Psychology and Neuroscience and the School of Mathematics and Statistics at the University of Glasgow.

This book should be considered a living document. The tutorials will be added over time as they are developed and both the content and structure of new and existing tutorials may be updated.

Contact: Emily Nordmann (Emily.Nordmann@glasgow.ac.uk)


<!--chapter:end:index.Rmd-->

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

<!--chapter:end:01-intro.Rmd-->

# (APPENDIX) Appendices {-} 

<!--chapter:end:appendix-0.Rmd-->

# Installing `R` {#installing-r}

Installing R and RStudio is usually straightforward. The sections below explain how and [there is a helpful YouTube video here](https://www.youtube.com/watch?v=lVKMsaWju8w){target="_blank"}.

## Installing Base R

[Install base R](https://cran.rstudio.com/){target="_blank"}. Choose the download link for your operating system (Linux, Mac OS X, or Windows).

If you have a Mac, install the latest release from the newest `R-x.x.x.pkg` link (or a legacy version if you have an older operating system). After you install R, you should also install [XQuartz](http://xquartz.macosforge.org/){target="_blank"} to be able to use some visualisation packages.

If you are installing the Windows version, choose the "[base](https://cran.rstudio.com/bin/windows/base/)" subdirectory and click on the download link at the top of the page. After you install R, you should also install [RTools](https://cran.rstudio.com/bin/windows/Rtools/){target="_blank"}; use the "recommended" version highlighted near the top of the list.

If you are using Linux, choose your specific operating system and follow the installation instructions.

## Installing RStudio

Go to [rstudio.com](https://www.rstudio.com/products/rstudio/download/#download){target="_blank"} and download the RStudio Desktop (Open Source License) version for your operating system under the list titled **Installers for Supported Platforms**.

## RStudio Settings

There are a few settings you should fix immediately after updating RStudio. Go to **`Global Options...`** under the **`Tools`** menu (&#8984;,), and in the General tab, uncheck the box that says **`Restore .RData into workspace at startup`**.  If you keep things around in your workspace, things will get messy, and unexpected things will happen. You should always start with a clear workspace. This also means that you never want to save your workspace when you exit, so set this to **`Never`**. The only thing you want to save are your scripts.

You may also want to change the appearance of your code. Different fonts and themes can sometimes help with visual difficulties or [dyslexia](https://datacarpentry.org/blog/2017/09/coding-and-dyslexia){target="_blank"}. 

\begin{figure}

{\centering \includegraphics[width=1\linewidth]{images/rstudio_settings_general_appearance} 

}

\caption{RStudio General and Appearance settings}(\#fig:settings-general)
\end{figure}

You may also want to change the settings in the Code tab. Foe example, Lisa prefers two spaces instead of tabs for my code and likes to be able to see the <a class='glossary' target='_blank' title='Spaces, tabs and line breaks' href='https://psyteachr.github.io/glossary/w#whitespace'>whitespace</a> characters. But these are all a matter of personal preference.

\begin{figure}

{\centering \includegraphics[width=1\linewidth]{images/rstudio_settings_code} 

}

\caption{RStudio Code settings}(\#fig:settings-code)
\end{figure}


## Installing LaTeX

You can install the LaTeX typesetting system to produce PDF reports from RStudio. Without this additional installation, you will be able to produce reports in HTML but not PDF. This course will not require you to make PDFs. To generate PDF reports, you will additionally need to install <code class='package'>tinytex</code> [@R-tinytex] and run the following code:


```r
tinytex::install_tinytex()
```

<!--chapter:end:appendix-a-installing-r.Rmd-->

# Symbols {#symbols}

| Symbol | psyTeachR Term    | Also Known As     |
|:------:|:------------------|:------------------|
| ()     | (round) brackets  | parentheses       |
| []     | square brackets   | brackets          |
| {}     | curly brackets    | squiggly brackets |
| <>     | chevrons          | angled brackets / guillemets |
| <      | less than         |                   |
| >      | greater than      |                   |
| &      | ampersand         | "and" symbol      |
| #      | hash              | pound / octothorpe|
| /      | slash             | forward slash     |
| \\     | backslash         |                   |
| -      | dash              | hyphen / minus    |
| _      | underscore        |                   |
| *      | asterisk          | star              |
| ^      | caret             | power symbol      |
| ~      | tilde             | twiddle / squiggle|
| =      | equal sign        |                   |
| ==     | double equal sign |                   |
| .      | full stop         | period / point    |
| !      | exclamation mark  | bang / not        |
| ?      | question mark     |                   |
| '      | single quote      | quote / apostrophe|
| "      | double quote      | quote             |
| %>%    | pipe              | magrittr pipe     |
| \|     | vertical bar      | pipe              |
| ,      | comma             |                   |
| ;      | semi-colon        |                   |
| :      | colon             |                   |
| @      | "at" symbol       | [various hilarious regional terms](https://www.theguardian.com/notesandqueries/query/0,5753,-1773,00.html) |
| ...    | `glossary("ellipsis")`| dots     |


\begin{figure}

{\centering \includegraphics[width=1\linewidth]{images/soundimals_hash} 

}

\caption{[Image by James Chapman/Soundimals](https://soundimals.tumblr.com/post/167354564886/chapmangamo-the-symbol-has-too-many-names)}(\#fig:img-soundimals-hash)
\end{figure}





<!--chapter:end:appendix-b-symbols.Rmd-->

# Conventions

This book will use the following conventions:

* Generic code: `list(number = 1, letter = "A")`
* Highlighted code: <code><span class='fu'>dplyr</span><span class='fu'>::</span><span class='fu'><a target='_blank' href='https://dplyr.tidyverse.org/reference/slice.html'>slice_max</a></span><span class='op'>(</span><span class='op'>)</span></code>
* File paths: <code class='path'>data/sales.csv</code>
* R Packages: <code class='package'>tidyverse</code>
* Functions: <code><span class='fu'><a target='_blank' href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='op'>(</span><span class='op'>)</span></code>
* Strings: <code><span class='st'>"psyTeachR"</span></code>
* Numbers: <code><span class='fl'>100</span></code>, <code><span class='fl'>3.14</span></code>
* Logical values: <code><span class='cn'>TRUE</span></code>, <code><span class='cn'>FALSE</span></code>
* Glossary items: <a class='glossary' target='_blank' title='Discrete variables that have an inherent order, such as number of legs' href='https://psyteachr.github.io/glossary/o#ordinal'>ordinal</a>
* Citations: @R-tidyverse
* Internal links: Chapter\ \@ref(intro)
* External links: [R for Data Science](https://r4ds.had.co.nz/){target="_blank"}
* Menu/interface options: **`New File...`**

## Webexercises

See [webexercises](https://psyteachr.github.io/webexercises/) for more details about how to use this in your materials.

* Type an integer: <input class='webex-solveme nospaces regex' size='1' data-answer='["^[0-9]{1}$"]'/>
* I am going to learn a lot: <select class='webex-select'><option value='blank'></option><option value='answer'>TRUE</option><option value='x'>FALSE</option></select>
* What is a p-value? <div class='webex-radiogroup' id='radio_WCXBRTQDFT'><label><input type="radio" autocomplete="off" name="radio_WCXBRTQDFT" value="x"></input> <span>the probability that the null hypothesis is true</span></label><label><input type="radio" autocomplete="off" name="radio_WCXBRTQDFT" value="answer"></input> <span>the probability of the observed (or more extreme) data, under the assumption that the null-hypothesis is true</span></label><label><input type="radio" autocomplete="off" name="radio_WCXBRTQDFT" value="x"></input> <span>the probability of making an error in your conclusion</span></label></div>


<div class='webex-solution'><button>Hidden Text</button>
You found some hidden text!
</div>


<div class='webex-solution'><button>Hidden Code</button>

```r
print("You found some hidden code!")
```

```
## [1] "You found some hidden code!"
```


</div>

## Alert boxes

::: {.info data-latex=""}
Informational asides.
:::

::: {.warning data-latex=""}
Notes to warn you about something.
:::

::: {.dangerous data-latex=""}
Notes about things that could cause serious errors.
:::

::: {.try data-latex=""}
Try it yourself.
:::

## Code Chunks


```r
# code chunks
paste("Applied", "Data", "Skills", 1, sep = " ")
```

```
## [1] "Applied Data Skills 1"
```


<div class='verbatim'><pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;{r setup, message = FALSE}</code></pre>

```r
# code chunks with visible r headers
library(tidyverse)
```

<pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;</code></pre></div>

## Glossary


\begin{tabular}{l|l}
\hline
term & definition\\
\hline
ordinal & Discrete variables that have an inherent order, such as number of legs\\
\hline
\end{tabular}



<!--chapter:end:appendix-c-conventions.Rmd-->

# Glossary

You can use the `glossary()` function to automatically link to a term in the [psyTeachR glossary](https://psyteachr.github.io/glossary/) or make your own project-specific glossary.

This will create a link to the glossary and include a tooltip with a short definition when you hover over the term. Use the following syntax in inline r: `glossary("word")`. For example, common <a class='glossary' target='_blank' title='The kind of data represented by an object.' href='https://psyteachr.github.io/glossary/d#data-type'>data types</a> are <a class='glossary' target='_blank' title='A data type representing whole numbers.' href='https://psyteachr.github.io/glossary/i#integer'>integer</a>, <a class='glossary' target='_blank' title='A data type representing a real decimal number' href='https://psyteachr.github.io/glossary/d#double'>double</a>, and <a class='glossary' target='_blank' title='A data type representing strings of text.' href='https://psyteachr.github.io/glossary/c#character'>character</a>.

If you need to link to a definition, but are using a different form of the word, add the display version as the second argument (`display`). You can also override the automatic short definition by providing your own in the third argument (`def`). Add the argument `link = FALSE` if you just want the hover definition and not a link to the psyTeachR glossary.


```r
glossary("data type", 
         display = "Data Types", 
         def = "My custom definition of data types", 
         link = FALSE)
```

[1] "<a class='glossary' title='My custom definition of data types'>Data Types</a>"

You can add a glossary table to the end of a chapter with the following code. It creates a table of all terms used in that chapter previous to the `glossary_table()` function. It uses `kableExtra()`, so if you use it in a code chunk, set `results='asis'`.

<div class='verbatim'><pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;{r, echo=FALSE, results='asis'}</code></pre>

```r
glossary_table()
```

<pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;</code></pre></div>


\begin{tabular}{l|l}
\hline
term & definition\\
\hline
character & A data type representing strings of text.\\
\hline
data-type & My custom definition of data types\\
\hline
double & A data type representing a real decimal number\\
\hline
integer & A data type representing whole numbers.\\
\hline
\end{tabular}



If you want to contribute to the glossary, fork the [github project](https://github.com/PsyTeachR/glossary), add your terms and submit a pull request, or suggest a new term at the [issues page](https://github.com/PsyTeachR/glossary/issues).

<!--chapter:end:appendix-d-glossary.Rmd-->

# License {-}

This book is licensed under Creative Commons Attribution-ShareAlike 4.0 International License [(CC-BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/){target="_blank"}. You are free to share and adapt this book. You must give appropriate credit [@psyteachr-template], provide a link to the license, and indicate if changes were made. If you adapt the material, you must distribute your contributions under the same license as the original. 





<!--chapter:end:appendix-y-license.Rmd-->



<!--chapter:end:appendix-z-refs.Rmd-->

