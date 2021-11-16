
<!-- badges: start -->
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![CRAN status](https://www.r-pkg.org/badges/version/hySpc.chondro)](https://cran.r-project.org/package=hySpc.chondro)
[![R build status](https://github.com/r-hyperspec/hySpc.chondro/workflows/R-CMD-check/badge.svg)](https://github.com/r-hyperspec/hySpc.chondro/actions)
[![Website (pkgdown)](https://github.com/r-hyperspec/hySpc.chondro/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/r-hyperspec/hySpc.chondro/actions/workflows/pkgdown.yaml)

<!--
[![Codecov test coverage](https://codecov.io/gh/r-hyperspec/hySpc.chondro/branch/develop/graph/badge.svg) (develop)](https://codecov.io/gh/r-hyperspec/hySpc.chondro?branch=develop)
-->
<!-- badges: end -->


<!-- ---------------------------------------------------------------------- -->
# R package **hySpc.chondro**
<!-- ---------------------------------------------------------------------- -->

Package **hySpc.chondro** is a part of [**hyperSpec**](https://r-hyperspec.github.io/) family packages.
It contains `chondro`¹  dataset, which is so-called _Raman map_: [Raman scattering spectra](https://en.wikipedia.org/wiki/Raman_spectroscopy) of a cartilage section measured on each point of a grid. 


¹ Word `chondro` is based on word ["chondrocytes"](https://en.wikipedia.org/wiki/Chondrocyte), cells found in cartilage.


## Installation

### Install from CRAN-like Repository

The **recommended** way to install the in-development version:

```r
repos <- c("https://r-hyperspec.github.io/pkg-repo/", getOption("repos"))
install.packages("hySpc.chondro", repos = repos)
```

