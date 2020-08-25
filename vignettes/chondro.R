## ----cleanup-chondro, include = FALSE-----------------------------------------
# Clean up to ensure reproducible workspace ----------------------------------
rm(list = ls(all.names = TRUE))

## ----setup, include = FALSE-----------------------------------------------------------------------
# Packages -------------------------------------------------------------------
library(hyperSpec)
library(latticeExtra)
library(akima)

library(ggplotify)    # To convert plots to necessary class for alignment
library(ggpubr)       # To align plots

# Functions ------------------------------------------------------------------
source("vignette-functions.R", encoding = "UTF-8")

# Settings -------------------------------------------------------------------
source("vignette-default-settings.R", encoding = "UTF-8")

# Temporaty options ----------------------------------------------------------
# Change the value of this option in "vignette-default-settings.R"
show_reviewers_notes = getOption("show_reviewers_notes", TRUE)

## ----bib, echo=FALSE, paged.print=FALSE-----------------------------------------------------------
dir.create("resources", showWarnings = FALSE)

knitr::write_bib(
  c(
    "hyperSpec"
  ),
  file = "resources/chondro-pkg.bib"
)

## ----vis-all, echo=FALSE, fig.cap=CAPTION, out.width="400"----------------------------------------
CAPTION = "
Microphotograph of the cartilage section.
The frame indicates the measurement area of $35×25 \\mu m.$
"

knitr::include_graphics("chondro--080606d-flip-ausw.jpg")

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "The raw spectra: median, 16^th^ and 84^th^, and 5^th^ and 95^th^ percentile
spectra."

## ----rawspc, fig.cap=CAPTION----------------------------------------------------------------------
plot(chondro, "spcprctl5")

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "The sum intensity of the raw spectra."

## -------------------------------------------------------------------------------------------------
# Set a color palette
seq_palette <- colorRampPalette(c("white", "dark green"), space = "Lab")

## ----rawmap, fig.cap=CAPTION----------------------------------------------------------------------
plotmap(chondro, func.args = list(na.rm = TRUE), col.regions = seq_palette(20))

## -------------------------------------------------------------------------------------------------
## disturb a few points
chondro$x[500] <- chondro$x[500] + rnorm(1, sd = 0.01)
chondro$y[660] <- chondro$y[660] + rnorm(1, sd = 0.01)

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION = "
Rounding erros in the point coordinates of lateral measurement grid:
**(A)** off-grid points cause stripes.
"

## ----irregular-a, fig.cap=CAPTION-----------------------------------------------------------------
plotmap(chondro, col.regions = seq_palette(20))

## ----irregular-a-sub, include=FALSE---------------------------------------------------------------
# For subplot A
irregular_grid_a <- as.ggplot(plotmap(chondro, col.regions = seq_palette(20)))

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION = "
Rounding erros in the point coordinates of lateral measurement grid:
**(B)** slightly wrong coordinages.
"

## ----irregular-b, fig.cap=CAPTION-----------------------------------------------------------------
library("latticeExtra")
plotmap(chondro,
  col.regions = seq_palette(20), panel = panel.levelplot.points,
  col = NA, pch = 22, cex = 1.9
)

## ----irregular-b-sub, include=FALSE---------------------------------------------------------------
# For subplot B
irregular_grid_b <- as.ggplot(
  plotmap(chondro, col.regions = seq_palette(20), panel = panel.levelplot.points,
    col = NA, pch = 22, cex = 1.9)
)

## -------------------------------------------------------------------------------------------------
chondro$x <- fitraster(chondro$x)$x
chondro$y <- fitraster(chondro$y)$x

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION = "
Rounding erros in the point coordinates of lateral measurement grid:
**(C)** corrected grid.
"

## ----irregular-c, fig.cap=CAPTION-----------------------------------------------------------------
plotmap(chondro, col.regions = seq_palette(20))

## ----irregular-c-sub, include=FALSE---------------------------------------------------------------
# For subplot C
irregular_grid_c <- as.ggplot(plotmap(chondro, col.regions = seq_palette(20)))

## ----irregular, fig.cap=CAPTION, fig.height=3, fig.width=12, echo=FALSE, out.width="98%"----------
CAPTION = "
Rounding erros in the point coordinates of lateral measurement grid.
**(A)** Off-grid points cause stripes.
**(B)** Slightly wrong coordinages.
**(C)** Corrected grid.  "

# Arrange the subplots
ggpubr::ggarrange(
  irregular_grid_a, irregular_grid_b, irregular_grid_c, ncol = 3,
  labels = LETTERS[1:3]
)

## ----interp---------------------------------------------------------------------------------------
chondro <- spc.loess(chondro, seq(602, 1800, 4))
chondro

## ----save_chondro---------------------------------------------------------------------------------
spectra_to_save <- chondro

## ----bl-------------------------------------------------------------------------------------------
baselines <- spc.fit.poly.below(chondro)
chondro <- chondro - baselines

## ----include=FALSE--------------------------------------------------------------------------------
# The preprocessed spectra.
CAPTION <- "The spectra after smoothing, baseline correction, and normalization.  "

## ----bl-norm, fig.cap=CAPTION---------------------------------------------------------------------
chondro <- chondro / rowMeans(chondro)
plot(chondro, "spcprctl5")

## ----include=FALSE--------------------------------------------------------------------------------
# The preprocessed spectra.
CAPTION <- "The spectra after subtracting the 5^th^ percentile spectrum.  "

## ----bl-perc, fig.cap=CAPTION---------------------------------------------------------------------
chondro <- chondro - quantile(chondro, 0.05)
plot(chondro, "spcprctl5")

## ----pca------------------------------------------------------------------------------------------
pca <- prcomp(chondro, center = TRUE)

scores <- decomposition(chondro, pca$x,
  label.wavelength = "PC",
  label.spc = "score / a.u."
)

loadings <- decomposition(chondro, t(pca$rotation),
  scores = FALSE,
  label.spc = "loading I / a.u."
)

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "The `pairs()`{.r} plot of the first 7 scores. "

## ----pca-pairs, fig.cap=CAPTION, fig.height=5, fig.width=5----------------------------------------
pairs(scores[[, , 1:7]], pch = 19, cex = 0.5)

## ----pca-identify, eval=FALSE---------------------------------------------------------------------
#  ## omit the first 4 PCs
#  out <- map.identify(scores [, , 5])
#  out <- c(out, map.identify(scores [, , 6]))
#  out <- c(out, map.identify(scores [, , 7]))

## ----pca-out, echo=FALSE, results='hide'----------------------------------------------------------
out <- c(105, 140, 216, 289, 75, 69)

## ----pca-cols-------------------------------------------------------------------------------------
out
outcols <- c("red", "blue", "#800080", "orange", "magenta", "brown")

cols <- rep("black", nrow(chondro))
cols[out] <- outcols

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "The suspected outlier spectra. "

## ----pca-outspc, fig.cap=CAPTION, fig.width=5, fig.height=4.5, small.mar=TRUE---------------------
plot(chondro[1],
  plot.args = list(ylim = c(1, length(out) + .7)),
  lines.args = list(type = "n")
)

for (i in seq(along = out)) {
  plot(chondro, "spcprctl5", yoffset = i, add = TRUE, col = "gray")
  plot(chondro[out[i]],
    yoffset = i, col = outcols[i], add = TRUE,
    lines.args = list(lwd = 2)
  )
  text(600, i + .33, out[i])
}

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "The `pairs()`{.r} plot of the first 7 scores with suspected outliers. "

## ----pca-pairs-2, fig.cap=CAPTION, fig.height=5, fig.width=5--------------------------------------
pch <- rep(46L, nrow(chondro))
pch[out] <- 19L

pairs(scores[[, , 1:7]], pch = pch, cex = 1, col = cols)

## ----outdel---------------------------------------------------------------------------------------
chondro <- chondro[-out]

## ----hca------------------------------------------------------------------------------------------
dist <- dist(chondro)
dendrogram <- hclust(dist, method = "ward.D2")

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "Dendogram. "

## ----denddummy, fig.cap=CAPTION-------------------------------------------------------------------
plot(dendrogram, labels = FALSE)

## ----dendcut--------------------------------------------------------------------------------------
chondro$clusters <- as.factor(cutree(dendrogram, k = 3))
cols <- c("dark blue", "orange", "#C02020")

## ----clustname------------------------------------------------------------------------------------
levels(chondro$clusters) <- c("matrix", "lacuna", "cell")

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "Hierarchical cluster analysis: the cluster map for $k=3$ clusters. "

## ----clustmap, fig.cap=CAPTION--------------------------------------------------------------------
print(plotmap(chondro, clusters ~ x * y, col.regions = cols))

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "Hierarchical cluster analysis: the dendrogram."

## ----dend, fig.cap=CAPTION------------------------------------------------------------------------
par(xpd = TRUE) # allow plotting the markers into the margin
plot(dendrogram, labels = FALSE, hang = -1)
mark.dendrogram(dendrogram, chondro$clusters, col = cols)

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "The cluster mean $\\pm$ 1 standard deviation spectra.
The blue cluster shows distinct lipid bands, the yellow cluster collagen, and the red cluster proteins and nucleic acids.  "

## ----clustmeans, fig.cap=CAPTION, fig.width=7-----------------------------------------------------
cluster.means <- aggregate(chondro, chondro$clusters, mean_pm_sd)

op <- par(las = 1, mar = c(4, 6, 1, 1), mgp = c(4, 1, 0))
plot(cluster.means, stacked = ".aggregate", fill = ".aggregate", col = cols)
par(op)

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "False color map of DNA.  "

## ----DNA, fig.cap=CAPTION-------------------------------------------------------------------------
DNAcols <- colorRampPalette(c("white", "gold", "dark green"), space = "Lab")(20)
plotmap(chondro[, , c(728, 782, 1098, 1240, 1482, 1577)],
  col.regions = DNAcols
)

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "False colour map of the DNA band intensities: smoothed DNA abundance. "

## ----DNAsm, fig.cap=CAPTION-----------------------------------------------------------------------
plotmap(chondro[, , c(728, 782, 1098, 1240, 1482, 1577)],
  col.regions = DNAcols,
  panel = panel.2dsmoother, args = list(span = 0.05)
)

## -------------------------------------------------------------------------------------------------
tmp <- sample(chondro[, , c(728, 782, 1098, 1240, 1482, 1577)], 500)

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- 'Two-dimesional (2D) "constant" interpolation with missing values: omitting missing data points. '

## ----DNAmissing, fig.cap=CAPTION------------------------------------------------------------------
plotmap(tmp, col.regions = DNAcols)

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- 'Two-dimesional (2D) "constant" interpolation with missing values: Delaunay triangulation / Voronoi plot.  '

## ----DNAvoronoi, fig.cap=CAPTION------------------------------------------------------------------
plotmap(tmp,
  col.regions = DNAcols,
  panel = panel.voronoi, pch = 19, col = "black", cex = 0.1
)

## ----include=FALSE--------------------------------------------------------------------------------
CAPTION <- "Two-dimensional (2D) interpolation.  "

## ----DNAinterp, fig.cap=CAPTION-------------------------------------------------------------------
if (require("akima")) {
  tmp <- rowMeans(chondro[[, , c(728, 782, 1098, 1240, 1482, 1577)]])
  chondro.bilinear <- interp(chondro$x, chondro$y, as.numeric(tmp), nx = 100, ny = 100)

  image(chondro.bilinear,
    xlab = labels(chondro, "x"), ylab = labels(chondro, "y"),
    col = DNAcols
  )

} else {
  plot(NULL, xlim = c(0, 1), ylim = c(0, 1))
  text(0.5, 0.5, 'Package "akima" is required to create this plot')
}

## ----save-chondro, eval=FALSE---------------------------------------------------------------------
#  spectra_to_save$clusters <- factor(NA, levels = levels(chondro$clusters))
#  spectra_to_save$clusters[-out] <- chondro$clusters
#  
#  pca <- prcomp(spectra_to_save)
#  
#  .chondro_scores <- pca$x[, seq_len(10)]
#  .chondro_loadings <- pca$rot[, seq_len(10)]
#  .chondro_center <- pca$center
#  .chondro_wl <- wl(chondro)
#  .chondro_labels <- lapply(labels(chondro), as.expression)
#  .chondro_extra <- spectra_to_save$..
#  
#  chondro <- new("hyperSpec",
#    spc = tcrossprod(.chondro_scores, .chondro_loadings) +
#        rep(.chondro_center, each = nrow(.chondro_scores)),
#    wavelength = .chondro_wl,
#    data = .chondro_extra,
#    labels = .chondro_labels
#  )
#  

## ----session-info-chondro, paged.print=FALSE------------------------------------------------------
sessioninfo::session_info("hyperSpec")

