% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cpaProgs.R
\name{locationProfileSetup}
\alias{locationProfileSetup}
\title{Reference profiles for CPA}
\usage{
locationProfileSetup(profile, markerList, numDataCols)
}
\arguments{
\item{profile}{data frame of specified protein(row name) profiles}

\item{markerList}{list of reference proteins and their subcellular locations}

\item{numDataCols}{number of fractions in each profile}
}
\value{
A data frame of profiles of
        the subcellular locations
}
\description{
Set up reference profiles for constrained proportional assignment
}
\examples{
data(protNSA_test)
data(markerListJadot)
refLocProfNSA_out <- locationProfileSetup(profile=protNSA_test,
  markerList=markerListJadot, numDataCols=9)
round(head(refLocProfNSA_out), digits=4)
}
