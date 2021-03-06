% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotxs.R
\name{plotxs}
\alias{plotxs}
\title{Visualise a section in data space}
\usage{
plotxs(xs, y, xc.cond, model, model.colour = NULL, model.lwd = NULL,
  model.lty = NULL, model.name = NULL, yhat = NULL, mar = NULL,
  col = "black", weights = NULL, view3d = FALSE, theta3d = 45,
  phi3d = 20, xs.grid = NULL, prednew = NULL, conf = FALSE,
  probs = FALSE, pch = 1, residuals = FALSE, main = NULL, xlim = NULL,
  ylim = NULL)
}
\arguments{
\item{xs}{A dataframe with one or two columns.}

\item{y}{A dataframe with one column.}

\item{xc.cond}{A dataframe with a single row, with all columns required for
passing to \code{\link{predict}} methods of models in \code{model}.}

\item{model}{A fitted model object, or a list of such objects.}

\item{model.colour}{Colours for fitted models. If \code{model} is a list,
this should be of same length as \code{model}.}

\item{model.lwd}{Line weight for fitted models. If \code{model} is a list,
this should be of same length as \code{model}.}

\item{model.lty}{Line style for fitted models. If \code{model} is a list,
this should be of same length as \code{model}.}

\item{model.name}{Character labels for models, for legend.}

\item{yhat}{Fitted values for the observations in \code{y}. Calculated if
needed and not provided. Only used if showing residuals, or \code{xs} has
two columns.}

\item{mar}{Margins for plot.}

\item{col}{Colours for observed data. Should be of length \code{nrow(xs)}.}

\item{weights}{Similarity weights for observed data. Should be of length
\code{nrow(xs)}. Usually calculated with \code{\link{similarityweight}}.}

\item{view3d}{Logical; if \code{TRUE} plots a three-dimensional
regression surface if possible.}

\item{theta3d, phi3d}{Angles defining the viewing direction. \code{theta3d}
gives the azimuthal direction and \code{phi3d} the colatitude. See
\code{\link[graphics]{persp}}.}

\item{xs.grid}{The grid of values defining the part of the section to
visualise. Calculated if not provided.}

\item{prednew}{The \code{y} values where the models in \code{model} intersect
the section. Useful when providing \code{theta3d}, \code{phi3d}, or
\code{weights}, where the predict methods have been called elsewhere.}

\item{conf}{Logical; if \code{TRUE} plots confidence bounds (or equivalent)
for models which provide this.}

\item{probs}{Logical; if \code{TRUE}, shows predicted class probabilities
instead of just predicted classes. Only available if \code{xs} contains two
numeric predictors and the model's predict method provides this.}

\item{pch}{Plot symbols for observed data}

\item{residuals}{Logical; if \code{TRUE}, plots a residual versus predictor
plot instead of the usual scale of raw response.}

\item{main}{Character title for plot, default is
\code{"Conditional expectation"}.}

\item{xlim}{Graphical parameter passed to plotting functions.}

\item{ylim}{Graphical parameter passed to plotting functions.}
}
\value{
A list containing relevant information for updating the plot.
}
\description{
Visualise a section in data space, showing fitted models where
  they intersect the section, and nearby observations. The \code{weights} for
  observations can be calculated with \code{\link{similarityweight}}. This
  function is mainly for use in \code{\link{ceplot}} and
  \code{\link{condtour}}.
}
\examples{
data(mtcars)
model <- lm(mpg ~ ., data = mtcars)
plotxs(xs = mtcars[, "wt", drop = FALSE], y = mtcars[, "mpg", drop = FALSE],
  xc.cond = mtcars[1, ], model = list(model))

}
\references{
O'Connell M, Hurley CB and Domijan K (2017). ``Conditional
  Visualization for Statistical Models: An Introduction to the
  \strong{condvis} Package in R.''\emph{Journal of Statistical Software},
  \strong{81}(5), pp. 1-20. <URL:http://dx.doi.org/10.18637/jss.v081.i05>.
}
\seealso{
\code{\link{plotxc}}, \code{\link{ceplot}}, \code{\link{condtour}}
}

