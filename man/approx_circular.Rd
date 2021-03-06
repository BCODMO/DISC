% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/approx_circular.R
\name{approx_circular}
\alias{approx_circular}
\title{"Linearly" interpolates angles along a circle}
\usage{
approx_circular(x, angles, xout, ...)
}
\arguments{
\item{x}{"coordinate" (e.g. time of measurement) of the angles to be interpolated}

\item{angles}{angles to be interpolated, of class circular or in trigonometric reference}

\item{xout}{"coordinates" where the interpolation should take place}

\item{...}{passed to approx}
}
\value{
A list with components x, containing the output coordinate (xout), and y, containing the interpolated angles (in the same circular reference as the input angles)
}
\description{
Interpolate angles by converting them to cardinal coordinates, linearly interpolating positions in cardinal space (x, y) and converting the resulting points back into polar space (i.e. angles). Please note that this will not work for steps of angles >= pi in the input vector of angles; but this is very difficult to check in a general way so no check is made
}
\examples{
x <- c(0, 1)
y <- c(0, pi/2)
approx_circular(x=x, angles=y, xout=c(0, .5, 1))

library("circular")
y <- circular(c(0, 90), template="geographics", units="degrees")
approx_circular(x=x, angles=y, xout=c(0, .5, 1))

# this works
x <- c(0, 1, 2)
y <- c(0, 0.7*pi, 1.5*pi)
approx_circular(x=x, angles=y, xout=c(0, .5, 1, 1.5, 2))

# but gives incorrect results because one step is larger than pi
y <- c(0, 0.4*pi, 1.5*pi)
approx_circular(x=x, angles=y, xout=c(0, .5, 1, 1.5, 2))
y <- c(1.5*pi, 0.6*pi, 0.7*pi)
approx_circular(x=x, angles=y, xout=c(0, .5, 1, 1.5, 2))
}

