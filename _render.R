# render the book as HTML and open in a browser
xfun::in_dir("book", bookdown::render_book("index.Rmd", "bookdown::bs4_book"))
browseURL("docs/index.html")


if (TRUE) {
  # webexercises render oddly in PDFs
  # verbatim code chunk headers don't render
  xfun::in_dir("book", bookdown::render_book("index.Rmd", "bookdown::pdf_book"))
  browseURL("docs/_main.pdf")

}
