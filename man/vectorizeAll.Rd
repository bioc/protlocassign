% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cpaProgs.R
\name{vectorizeAll}
\alias{vectorizeAll}
\title{Unitize series of vectors}
\usage{
vectorizeAll(protMatOrig)
}
\arguments{
\item{protMatOrig}{matrix of profiles}
}
\value{
Matrix with all rows having unit length
}
\description{
Normalize all rows of a matrix to have unit length
}
\examples{
data(protNSA_test)
round(head(vectorizeAll(protNSA_test[,1:9])), digits=4)
}
