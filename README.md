![Sistema Mediador](http://www3.mte.gov.br/sistemas/mediador/Content/images/img_inicio_sistemas.jpg)

# MediadoR
A proto-package (still in development) to organize researches on [MTE's Mediador platform](http://www3.mte.gov.br/sistemas/mediador), focusing in trends and conditions of collective bargaining

### How to install

For now, I still haven't got time to submit this package to CRAN, which demands an extensive review of our code, so we're focusing in launching it to tests here in Github.

Our package can be acessed with devtools:

``` r
devtools::install_github("gpistelli/MediadoR", subdir = "pkg")
```

## Aims and objectives

Taking into account how much collective bargaining has been changing in Brazil and how many categories we've got acting in that front, a new tool has been needed to help researchers to directly access and process data in a fast and practical way.

MediadoR is an attempt to do so, working within the R language, which is an easy language that has been adopted by many researchers in different fields. 

We intend to:

- Make it free to any researcher to use. Just don't forget to cite us!
- Keep different collective bargaining data directly stored in this repository
- Develop new folders, keeping both raw and aggregated data
- Create new tools to automate our data wrangling and analysis

You can find a basic introduction to what our package offer right now in our project page: <https://gpistelli.github.io/MediadoR/> 

### How can I help?

For now, we're still working on storing data and creating basic functions that can help us in extracting informations from this raw data.

So, for this time, if you use our code to extract any data, just storing it in our repo would be a great help. Just be careful to follow our folder structure, uploading it to:

data/[type of collective bargaining]/[Main city]/[Workers category]/[Workers Union]/[union_negot_year].csv

Following this pattern will help us to develop functions that will reach directly to our repo, going faster and cleaner than webscraping data from the Mediador system.

If you've got any new data type to store (like wage means per year, types of clauses for each category, etc.), contact this repository authors so that we can, together, find a practical and clear way of structuring our folders.

Also, if you've got any function that you've been using repeatedly and thinks that it would be a good tool to share, reach to us. We're looking forward to have new contributors for this package!

### Bugs and questions

If you've found any bug or does have any question, you can reach me here or through my email (see my profile to find my contacts)

## References

DIEESE. Cesta básica de alimentos. Available at: <http://www.dieese.org.br/cesta/>.

MTE. Sistema Mediador. 1997. Available at: <http://www3.mte.gov.br/sistemas/mediador/Home>.

WICKHAM, Hadley. rvest: Easily Harvest (Scrape) Web Pages. R package version 0.3.6. 2020. Available at: <https://CRAN.R-project.org/package=rvest>.

_____; et al. Welcome to the tidyverse. Journal of Open Source Software, 4(43), 1686, 2019
