\name{gsMMD2.default}
\alias{gsMMD2.default}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Gene selection based on a mixture of marginal distributions}
\description{
Gene selection based on the marginal distributions of gene profiles that characterized by a mixture of three-component multivariate distributions.
Input is a data matrix. The user needs to provide initial gene cluster membership.
}
\usage{
gsMMD2.default(X, 
               memSubjects, 
               memIni,
               maxFlag = TRUE, 
               thrshPostProb = 0.5, 
               geneNames = NULL, 
               alpha = 0.05, 
               transformFlag = FALSE, 
               transformMethod = "boxcox", 
               scaleFlag = TRUE, 
               criterion = c("cor", "skewness", "kurtosis"), 
               minL = -10, 
               maxL = 10, 
               stepL = 0.1, 
               eps = 0.001, 
               ITMAX = 100, 
               plotFlag = FALSE,
               quiet=TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{X}{a data matrix. The rows of the matrix are genes. The columns of the matrix are subjects.}
  \item{memSubjects}{a vector of membership of subjects. \code{memSubjects[i]=1} means the \eqn{i}-th subject belongs to diseased group, \eqn{0} otherwise. 
  }
  \item{memIni}{a vector of user-provided gene cluster membership.}
  \item{maxFlag}{logical. Indicate how to assign gene class membership. \code{maxFlag}=TRUE means that a gene will be assigned
to a class in which the posterior probability of the gene belongs to this class is maximum. \code{maxFlag}=FALSE means that a gene will be assigned to class 1 if the posterior probability of the gene belongs to class 1 is
greater than \code{thrshPostProb}. Similarly, a gene will be assigned to class 1 if the posterior probability of the gene belongs to class 1 is
greater than \code{thrshPostProb}. If  the posterior probability is less than \code{thrshPostProb}, the gene
will be assigned to class 2 (non-differentially expressed gene group).}
  \item{thrshPostProb}{threshold for posterior probabilities. For example, if the posterior probability that a gene belongs to cluster 1 given its gene expression levels is larger than \code{thrshPostProb}, then this gene will be assigned to cluster 1.}
  \item{geneNames}{an optional character vector of gene names}
  \item{alpha}{significant level which is equal to \code{1-conf.level}, 
\code{conf.level} is the argument for the function \code{t.test}.
  }
  \item{transformFlag}{logical. Indicate if data transformation is needed}
  \item{transformMethod}{method for transforming data. Available methods include "boxcox", "log2", "log10", "log", "none".}
  \item{scaleFlag}{logical. Indicate if gene profiles are to be scaled. If \code{transformFlag=TRUE} and \code{scaleFlag=TRUE}, then scaling is performed after transformation.  
To avoid linear dependence of tissue samples after scaling
    gene profiles, we delete one tissue sample after scaling (c.f. details).
}
  \item{criterion}{if \code{transformFlag=TRUE}, \code{criterion} indicates what criterion to determine if data looks like normal.  \dQuote{cor} means using Pearson's correlation. The idea is that the observed quantiles after transformation should be close to theoretical normal quantiles. So we can use Pearson's correlation to check if the scatter plot of theoretical normal quantiles versus observed quantiles is a straightline.  \dQuote{skewness} means using skewness measure to check if the distribution of the transformed data are close to normal distribution; \dQuote{kurtosis} means using kurtosis measure to check normality.}
  \item{minL}{lower limit for the \code{lambda} parameter used in Box-Cox transformation}
  \item{maxL}{upper limit for the \code{lambda} parameter used in Box-Cox transformation}
  \item{stepL}{tolerance when searching the optimal \code{lambda} parameter used in Box-Cox transformation}
  \item{eps}{a small positive value. If the absolute value of a value is smaller than \code{eps}, this value is regarded as zero.  }
  \item{ITMAX}{maximum iteration allowed for iterations in the EM algorithm}
  \item{plotFlag}{logical. Indicate if the Box-Cox normality plot should be output.}
  \item{quiet}{logical. Indicate if intermediate results should be printed out.}
}
\details{
We assume that the distribution of gene expression profiles is 
a mixture of 3-component multivariate normal distributions 
\eqn{\sum_{k=1}^{3} \pi_k f_k(x|\theta)}. Each component distribution \eqn{f_k} 
corresponds to a gene cluster. The 3 components correspond to 3 gene clusters:
(1) up-regulated gene cluster, (2) non-differentially expressed gene cluster, 
and (3) down-regulated gene cluster. 
The model parameter vector is \eqn{\theta=(\pi_1}, \eqn{\pi_2}, 
\eqn{\pi_3}, \eqn{\mu_{c1}}, 
\eqn{\sigma^2_{c1}}, \eqn{\rho_{c1}}, \eqn{\mu_{n1}}, \eqn{\sigma^2_{n1}}, 
\eqn{\rho_{n1}},
\eqn{\mu_2}, \eqn{\sigma^2_2}, \eqn{\rho_2}, 
\eqn{\mu_{c3}}, 
\eqn{\sigma^2_{c3}}, \eqn{\rho_{c3}}, \eqn{\mu_{n3}}, \eqn{\sigma^2_{n3}}, 
\eqn{\rho_{n3}}.
where \eqn{\pi_1}, \eqn{\pi_2}, and \eqn{\pi_3} are the mixing proportions; 
\eqn{\mu_{c1}}, \eqn{\sigma^2_{c1}}, and \eqn{\rho_{c1}} are 
the marginal mean, variance, and correlation of gene expression levels 
of cluster 1 (up-regulated genes) for diseased subjects; 
\eqn{\mu_{n1}}, \eqn{\sigma^2_{n1}}, and \eqn{\rho_{n1}} are 
the marginal mean, variance, and correlation of gene expression levels 
of cluster 1 (up-regulated genes) for non-diseased subjects; 
\eqn{\mu_2}, \eqn{\sigma^2_2}, and \eqn{\rho_2} are the marginal mean, 
variance, and correlation of gene 
expression levels of cluster 2 (non-differentially expressed genes); 
\eqn{\mu_{c3}}, \eqn{\sigma^2_{c3}}, and \eqn{\rho_{c3}} are 
the marginal mean, variance, and correlation of gene expression levels 
of cluster 3 (up-regulated genes) for diseased subjects; 
\eqn{\mu_{n3}}, \eqn{\sigma^2_{n3}}, and \eqn{\rho_{n3}} are 
the marginal mean, variance, and correlation of gene expression levels 
of cluster 3 (up-regulated genes) for non-diseased subjects. 

Note that genes in cluster 2 are non-differentially expressed across
abnormal and normal tissue samples. Hence there are only 3 parameters for
cluster 2.

To make sure the identifiability, we set the following contraints: 
\eqn{\mu_{c1}>\mu_{n1}} and \eqn{\mu_{c3}<\mu_{n3}}.

To make sure the marginal covariance matrices are poisitive definite,
we set the following contraints: 
\eqn{-1/(n_c-1)<\rho_{c1}<1},
\eqn{-1/(n_n-1)<\rho_{n1}<1},
\eqn{-1/(n-1)<\rho_{2}<1},
\eqn{-1/(n_c-1)<\rho_{c3}<1},
\eqn{-1/(n_n-1)<\rho_{n3}<1}.

We also has the following constraints for the mixing proportion:
\eqn{\pi_3=1-\pi_1-\pi_2}, \eqn{\pi_k>0}, \eqn{k=1,2,3}.

We apply the EM algorithm to estimate the model parameters. 
We regard the cluster membership of genes as missing values.

To facilitate the estimation of the parameters,
we reparametrize the parameter vector as
\eqn{\theta^*=(\pi_1}, \eqn{\pi_2}, 
\eqn{\mu_{c1}}, 
\eqn{\sigma^2_{c1}}, \eqn{r_{c1}}, \eqn{\delta_{n1}}, \eqn{\sigma^2_{n1}}, 
\eqn{r_{n1}},
\eqn{\mu_2}, \eqn{\sigma^2_2}, \eqn{r_2}, 
\eqn{\mu_{c3}}, 
\eqn{\sigma^2_{c3}}, \eqn{r_{c3}}, \eqn{\delta_{n3}}, \eqn{\sigma^2_{n3}}, 
\eqn{r_{n3})},
where
\eqn{\mu_{n1}=\mu_{c1}-\exp(\delta_{n1})},
\eqn{\mu_{n3}=\mu_{c3}+\exp(\delta_{n3})},
\eqn{\rho_{c1}=(\exp(r_{c1})-1/(n_c-1))/(1+\exp(r_{c1}))},
\eqn{\rho_{n1}=(\exp(r_{n1})-1/(n_n-1))/(1+\exp(r_{n1}))},
\eqn{\rho_{2}=(\exp(r_{2})-1/(n-1))/(1+\exp(r_{2}))},
\eqn{\rho_{c3}=(\exp(r_{c3})-1/(n_c-1))/(1+\exp(r_{c3}))},
\eqn{\rho_{n3}=(\exp(r_{n3})-1/(n_n-1))/(1+\exp(r_{n3}))}.

Given a gene, the expression levels of the gene are assumed independent. However, after scaling, the scaled expression levels of the gene are no longer independent and the rank \eqn{r^*=r-1} of the covariance matrix for the scaled gene profile will be one less than the rank \eqn{r} for the un-scaled gene profile Hence the covariance matrix of the
gene profile will no longer be positive-definite. 
To avoid this problem,
we delete a tissue sample after scaling since its information has been incorrporated by other scaled tissue samples. We arbitrarily select the tissue sample, which has the biggest label number, from the tissue sample group that has larger size than the other tissue sample group. For example, if there are 6 cancer tissue samples and 10 normal tissue samples, we delete the 10-th normal tissue sample after scaling.

}
\value{
A list contains 13 elements.
  \item{dat}{the (transformed) microarray data matrix. If tranformation
performed, then \code{dat} will be different from the input 
microarray data matrix.}
  \item{memSubjects}{the same as the input \code{memSubjects}.}
  \item{memGenes}{a vector of cluster membership of genes. \eqn{1} means up-regulated gene; \eqn{2} means non-differentially expressed gene; 
\eqn{3} means down-regulated gene.}
  \item{memGenes2}{an variant of the vector of cluster membership of genes. 
\eqn{1} means differentially expressed gene; \eqn{0} means non-differentially expressed gene.}
  \item{para}{parameter estimates (c.f. details).}
  \item{llkh}{value of the loglikelihood function.}
  \item{wiMat}{posterior probability that a gene belongs to a cluster given the expression levels of this gene. Column i is for cluster i.}
  \item{memIni}{the initial cluster membership of genes.}
  \item{paraIni}{the parameter estimates based on initial gene cluster membership.}
  \item{llkhIni}{the value of loglikelihood function.}
 \item{lambda}{the parameter used to do Box-Cox transformation}
  \item{paraRP}{parameter estimates for reparametrized parameter vector (c.f. details).}
  \item{paraIniRP}{the parameter estimates for reparametrized parameter vector based on initial gene cluster membership.}
}
\references{ Qiu, W.-L., He, W., Wang, X.-G. and Lazarus, R. (2008). 
A Marginal Mixture Model for Selecting Differentially Expressed Genes across Two Types of Tissue Samples. \emph{The International Journal of Biostatistics. 4(1):Article 20.} \url{http://www.bepress.com/ijb/vol4/iss1/20}
}
\author{ 
Jarrett Morrow \email{remdj@channing.harvard.edu},
Weiliang Qiu \email{Weiliang.Qiu@gmail.com},
Wenqing He \email{whe@stats.uwo.ca},
Xiaogang Wang \email{stevenw@mathstat.yorku.ca},
Ross Lazarus \email{ross.lazarus@channing.harvard.edu}
}
\seealso{
\code{\link{gsMMD}},
\code{\link{gsMMD.default}},
\code{\link{gsMMD2}}
}
\note{
The speed of the program can be slow for large data sets, however it has been improved using Fortran code.
}
\examples{

  \dontrun{
    library(ALL)
    data(ALL)
    eSet1 <- ALL[1:100, ALL$BT == "B3" | ALL$BT == "T2"]
    mat <- exprs(eSet1)
    
    mem.str <- as.character(eSet1$BT)
    nSubjects <- length(mem.str)
    memSubjects <- rep(0, nSubjects)
    # B3 coded as 0, T2 coded as 1
    memSubjects[mem.str == "T2"] <- 1
   
    myWilcox <-
    function(x, memSubjects, alpha = 0.05)
    {
      xc <- x[memSubjects == 1]
      xn <- x[memSubjects == 0]
    
      m <- sum(memSubjects == 1)
      res <- wilcox.test(x = xc, y = xn, conf.level = 1 - alpha)
      res2 <- c(res$p.value, res$statistic - m * (m + 1) / 2)
      names(res2) <- c("p.value", "statistic")
    
      return(res2)
    }
    
    tmp <- t(apply(mat, 1, myWilcox, memSubjects = memSubjects))
    colnames(tmp) <- c("p.value", "statistic")
    memIni <- rep(2, nrow(mat))
    memIni[tmp[, 1] < 0.05 & tmp[, 2] > 0] <- 1
    memIni[tmp[, 1] < 0.05 & tmp[,2] < 0] <- 3
    
    cat("initial gene cluster size>>\n"); print(table(memIni)); cat("\n");
    
    obj.gsMMD <- gsMMD2.default(mat, memSubjects, memIni = memIni,
            transformFlag = TRUE, transformMethod = "boxcox", scaleFlag = TRUE)
    round(obj.gsMMD$para, 3)
  }
  
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ classif }
