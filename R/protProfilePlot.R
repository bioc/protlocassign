#' Plot reference compartment profiles overlaid with the profile of 
#'   a single protein
#'
#' This function creates a panel of plots, one for each compartment.  
#'    Each plot contains a reference compartment profile overlaid with 
#'    the profile of one protein of interest and its CPA 
#'    value for that compartment.
#'
#' @param protName name of the protein to plot
#' @param profile data frame of specified protein(row name) profiles
#' @param numDataCols  number of fractions in each profile
#' @param n.compartments number of compartments (8 in Jadot data)
#' @param refLocationProfiles data frame of profiles for the 
#'        reference compartments
#' @param assignPropsMat data frame containing CPA estimates
#' @param transType label for y-axis on each individual plot (default none))
#' @param yAxisLabel label for y-axis of entire panel
#' @return A panel of profile plots
#' @export
#' @examples
#' data(protNSA_test)
#' data(markerListJadot)
#' data(refLocProfNSA)
#' protCPAfromNSA_out <- fitCPA(profile=protNSA_test,
#'                               refLocationProfiles=refLocProfNSA,
#'                               numDataCols=9)
#' # Note that the profile of one protein, AIF1, contains missing values
#' # which causes the cpa routine to generate a nonconvergence message 
#' 
#' protPlotfun(protName="TLN1", profile=protNSA_test,
#'             numDataCols=9, n.compartments=8,
#'             refLocationProfiles=refLocProfNSA,
#'             assignPropsMat=protCPAfromNSA_out,
#'             yAxisLabel="Normalized Specific Amount")

protPlotfun <- function(protName, profile, 
                        numDataCols=9, n.compartments=8,
                        refLocationProfiles, assignPropsMat,
                        transType="", yAxisLabel="") {
  # protPlot is the number of the protein to plot
  # profileUse is a matrix with components:
  #    rownames: name of protein
  #    N, M, L1, ... : relative protein levels for fractions
  #    1 through numDataCols; must sum to 1
  #
  # If standard errors are not available, se is false, and seMat is NULL
  #  If standard errors are available, se is true,
  #   and seMat is the list of proteinss and n.fraction standard errors
  # If Nspectra and Npep (number of peptides) are included, Nspectra=TRUE
  #  refLocationProfiles:  matrix with numDataCols rows and 8 columns.
  #      Column names are the subcellular fractions, Cytosol, ER, Golgi, etc.
  #      Row names are the names of the fractions: N, M, L1, L2, etc.
  #      Column and row names are required
  

  oldpar <- par(no.readonly=TRUE)
  on.exit(par(oldpar))
  protsOK <- {rownames(profile) == rownames(assignPropsMat)}

  # index of protein in profile
  index_profileT <- protIndex(protName, profile, exactMatch=TRUE)
  # index of protein in assign
  index_assignT <- protIndex(protName, assignPropsMat, exactMatch=TRUE)
  protName.i <- protName
  # must be exact to avoid duplicate finds

  # this can be a vector, matrix, or vector, so handling is complicated
  #if (is.matrix(tempx)) temp <- tempx   # leave it alone
  # if temp is not a matrix, can then test for being NA with no error returned
  if (!is.matrix(index_profileT)) {
    if (is.na(index_profileT)[1]) {
      warnD <- paste(protName, " not found \n")
      warning(warnD)  # first element is NA
      return(index_profileT)
    }
  }
  if (nrow(index_profileT) > 1) {
    warning("more than one protein matches pattern \n")
    return(index_profileT)
  }
  index_profile <- as.numeric(index_profileT[1])
  index_assign <- as.numeric(index_assignT[1])

  meanProteinLevels <- profile[,seq_len(numDataCols)]  # just the profiles

  protNames <- rownames(profile)
  protNameUnique <- make.unique(protNames)
  rownames(meanProteinLevels) <- protNameUnique
  subCellNames <- rownames(refLocationProfiles)

  fractions.list <- colnames(refLocationProfiles)

  

  # just use the index number, the first element
  yy <- as.numeric(meanProteinLevels[index_profile[1],])
  if (anyNA(yy)) {
    warnC <- paste(protName,
                   " contains missing values \n profile not plotted\n")
    warning(warnC)  # yy contains NA's
    return(protName.i)
  }

  xvals <- seq_len(numDataCols)
  #max.y <- max(channelsAll, na.rm=TRUE)
  #max.y <- max(meanProteinLevels, na.rm=TRUE)
  min.y <-0
  #if (dataType == "raw") min.y <- 0
  loc.list <- subCellNames
  #windows(width=10, height=8)
  #par(mfrow=c(3,3))
  # # # # # # # # # # # # # # #
  # Set up layout for 8 compartments (and a legend)
  # This will have to be adjusted if there
  #   are more than 8 compartments
  # # # # # # # # # # # # # # #
  layout(rbind(c(14,1,1,1,15),
               c(14,2,3,4,15),
               c(14,5,5,5,15),
               c(14,6,7,8,15),
               c(14,9,9,9,15),
               c(14,10,11,12,15),
               c(14,13,13,13,15)),
         #c(16,12,13,14,15,17),
         #c(16,18,18,18,18,17)),
         heights=c(0.75,2,0.25,2,0.25,2,0.25),
         widths=c(0.4,2,2,2,0.4),respect=FALSE)



  #layout.show(15)
  x <- c(0,5)
  y <- c(0,0.5)
  par(mar=c(0,0,0,0))
  plot(y ~ x,type="n",axes=FALSE,cex=1)

    text(x=2.5,y=0.3,paste(protName.i), cex=2)

    NpeptidesPlot <- profile$Npep[index_profile[1]]
    NspectraPlot <- profile$Nspectra[index_profile[1]]
    if (!is.null(NpeptidesPlot) & !is.null(NspectraPlot)) {
      NpeptidesPlotText <- " peptides and "

      #browser()

      if (NpeptidesPlot == 1) NpeptidesPlotText <- " peptide and "
      NspectraPlotText <- " spectra"
      if (NspectraPlot == 1) NspectraPlotText <- " spectrum"
      text(x=2.5,y=0.1, paste(NpeptidesPlot, NpeptidesPlotText,
                            NspectraPlot , NspectraPlotText), cex=2)
    }
    if (!is.null(NpeptidesPlot) & is.null(NspectraPlot)) {
      NpeptidesPlotText <- " peptides "
      if (NpeptidesPlot == 1) NpeptidesPlotText <- " peptide "
      text(x=2.5,y=0.1, paste(NpeptidesPlot, NpeptidesPlotText), cex=2)
    }
  min.y <- 0
  par(mar=c(2,4,2,1.5))
  # The plots are in alphabetical order
  # re-arrange the plots so that they are in this order:
  #   Mito (7)     Lyso  (4)   Perox (5)
  #   ER (2)       Golgi (1)   PM (8)
  #   Cyto (3 )    Nuc (6)
  #
  #loc.ord <- c(7, 4, 5, 2, 1, 8, 3, 6)
  loc.ord <- c(5, 4, 7, 2, 3, 8, 1, 6)
  for (i in loc.ord) {    # do all the subcellular locations
    # i=1
    if (TRUE) {
      #if ({loc.ord[i] == 4} | {loc.ord[i] == 7}) {
      if ({i == 2} | {i == 1}) {
        x <- c(0,5)
        y <- c(0,0.5)
        par(mar=c(0,1,0,0))
        plot(y ~ x,type="n",axes=FALSE,cex=1, ylab="")
        par(mar=c(2,3.5,2,1.5))
      }
    }

    assign.i <- names(meanProteinLevels)[i]  # channel i name

    assignLong.i <- subCellNames[i]

    mean.i <- as.numeric(refLocationProfiles[i,])
   # if (!is.null(finalList)) max.y <-
    #     max(c(max(means.peptides.i), max(refLocationProfiles[i,])))
    #if (is.null(finalList)) 
    max.y <- max(c(mean.i,yy))
    par(mar=c(2,4.1,2,1.5))
    plot(mean.i ~ xvals,  axes=FALSE, type="l",
         ylim=c(min.y, max.y), ylab=transType)
    axis(1,at=xvals,labels=fractions.list, las=2)
    if (FALSE) {
    axis(side=1,at=xvals,labels=FALSE, cex.axis=0.6)
    text(x = seq_len(length(fractions.list)),
         ## Move labels to just below bottom of chart.
         y = par("usr")[3] - max(mean.i)/12,
         ## Use names from the data list.
         labels = fractions.list,
         ## Change the clipping region.
         xpd = NA,
         ## Rotate the labels by 35 degrees.
         srt = 45,
         ## Adjust the labels to almost 100% right-justified.
         adj = 0.965,
         ## label size.
         cex = 0.8)
    }
    axis(2)

  



    lines(yy ~ xvals, col="red", lwd=2)

    lines(mean.i ~ xvals, lwd=4, col="black", lty=1)  # thick black solid line
    # thinner yellow dashed line
    lines(mean.i ~ xvals, lwd=2, col="yellow", lty=2)


      title(paste(assignLong.i, "\n p = ",
                  round(assignPropsMat[index_assign[1],i], digits=2 )))

  }
  x <- c(0,5)
  y <- c(0,0.5)
  par(mar=c(0,0,0,0))
  plot(y ~ x, type="n", axes=FALSE)
  
  #if (is.null(finalList)) {
    legend(x=1, y=0.4, legend=c("Reference profile", "Average profile"),
           col=c("black", "red"), lwd=c(5,2), lty=c(1,1))
    legend(x=1, y=0.4, legend=c("Reference profile", "Average profile"),
           col=c("yellow", "red"), lwd=c(2,2), lty=c(2,1))
  #}
  x <- c(0,5)
  y <- c(0,0.5)

  plot(y ~ x, type="n", axes=FALSE)
  par(mar=c(0,0,0,0))
  plot(y ~ x, type="n", axes=FALSE)


  text(x=2.5, y=0.25, labels=yAxisLabel, srt=90, cex=2 )

}
