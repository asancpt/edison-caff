cp index.R $1.R
zip releases/$1.zip $1.R R/function.R documentation.Rmd appendix.Rmd
rm $1.R

