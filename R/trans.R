# modified on Sept. 28, 2011
#  (1) added 'na.rm=TRUE' to functions 'sum' and 'mean'
#
transFunc<-function(x, transformMethod="boxcox", 
                    criterion=c("cor", "skewness", "kurtosis"), 
                    minL=-10, maxL=10, stepL=0.1, 
                    eps=1.0e-6, plotFlag=FALSE, ITMAX=0)
{
  transformMethod<-match.arg(transformMethod, choices=c("boxcox", "log2", "log10", "log", "none"))
  criterion<-match.arg(criterion, c("cor", "skewness", "kurtosis"))
  tmpx<-as.vector(x)
  minx<-min(tmpx, na.rm=TRUE)
  if(minx<0)
  { cat("****** Begin Warning ******** \n")
    cat("Warning: Data contains non-positive values! To continue box-cox transformation,\n")
    cat("We perform the following transformation:\n")
    cat("x<-x+abs(min(x, na.rm=TRUE))+1\n")
    cat("****** End Warning ******** \n")
    x<-x+abs(minx)+1 
  }

 
  if(transformMethod=="boxcox")
  { x2<-transBoxCoxMat(x, criterion, minL, maxL, stepL, eps, plotFlag, ITMAX)
    return(x2)
  }
  if(transformMethod=="log2")
  { 
    return(log2(x))
  }
  if(transformMethod=="log10")
  { 
    return(log10(x))
  }
  if(transformMethod=="log")
  { 
    return(log(x))
  }
  return(x)
}

transBoxCoxMat<-function(mat,
                      criterion=c("cor", "skewness", "kurtosis"),
                      minL=-10, 
                      maxL=10, 
                      stepL=0.1, 
                      eps=1.0e-3, 
                      plotFlag=FALSE, 
                      ITMAX=0)
{
  lambda.vec<-apply(mat, 2, transBoxCox2, criterion=criterion,
        minL=minL, maxL=maxL, stepL=stepL,
        eps=eps, plotFlag=plotFlag, ITMAX=ITMAX) 
  lambda<-mean(lambda.vec, na.rm=TRUE)
  #print(paste("******** average lambda=", lambda))


  mat.new<-apply(mat, 2, transBoxCox.default, lambda=lambda, eps=eps) 


  return(list(dat=mat.new, lambda.avg=lambda, lambda.vec=lambda.vec))
}

# box-cox transformation
transBoxCox2<-function(x, 
                      criterion=c("cor", "skewness", "kurtosis"),
                      minL=-10, 
                      maxL=10, 
                      stepL=0.1, 
                      eps=1.0e-3, 
                      plotFlag=FALSE, 
                      ITMAX=0)
{
  criterion<-match.arg(criterion, c("cor", "skewness", "kurtosis"))

  xold<-x 
  mycor<- -qqnormCorFunc(xold)
  skewness<-abs(skewnessFunc(xold)[2])
  kurtosis<-abs(kurtosisFunc(xold)[2])
  
  best.criVec<-c(mycor, skewness, kurtosis)
  names(best.criVec)<-c("cor", "skewness", "kurtosis")
  lambda.optim<-0

  loop<-0
  while(loop<=ITMAX)
  {
    loop<-loop+1
    #print(paste("******loop=", loop))
    tmp<-optimalLambda(xold, criterion, minL, maxL, stepL, eps, plotFlag)
    lambda<-tmp$lambda
    if(loop==1)
    { lambda.optim<-lambda }
    #print(paste("optimal lambda=", lambda))
    xnew<-transBoxCox.default(xold, lambda, eps)
    mycor<- -qqnormCorFunc(xnew)
    skewness<-abs(skewnessFunc(xnew)[2])
    kurtosis<-abs(kurtosisFunc(xnew)[2])
    criVec<-c(mycor, skewness, kurtosis)
    names(criVec)<-c("cor", "skewness", "kurtosis")

    diff<-max(abs(best.criVec-criVec), na.rm=TRUE)
    tmp<-sum(best.criVec<criVec, na.rm=TRUE)
    if(tmp>1 || diff<eps)
    { 
      break
    } 
    best.criVec<-criVec
    xold<-xnew
    lambda.optim<-lambda
  }
  return(lambda.optim)
}

# box-cox transformation
transBoxCox.default<-function(x, lambda, eps=1.0e-3)
{
  minx<-min(x, na.rm=TRUE)
  if(minx<0)
  { cat("****** Begin Warning ******** \n")
    cat("Warning: Data contains non-positive values! To continue box-cox transformation,\n")
    cat("We perform the following transformation:\n")
    cat("x<-x+abs(min(x, na.rm=TRUE))+1\n")
    cat("****** End Warning ******** \n")
    x<-x+abs(minx)+1 
  }

  if(abs(lambda)<eps)
  { return(log(x)) }
  res<-(x^lambda-1)/lambda
  return(res)
}


statVecFunc<-function(lambdai,x,eps,criterion=c("cor", "skewness", "kurtosis"))
{
    x2<-transBoxCox.default(x, lambdai, eps)
    if(criterion=="cor")
    { tmp<-qqnormCorFunc(x2) 
      statVecFunc<- -tmp
    }
    else if (criterion=="skewness")
    { tmp<-skewnessFunc(x2)
      statVecFunc<-abs(tmp[2])
    } else # criterion=="kurtosis"
    { tmp<-kurtosisFunc(x2)
      statVecFunc<-abs(tmp[2])
    }
    return(statVecFunc)
}

optimalLambda<-function(x, 
                        criterion=c("cor", "skewness", "kurtosis"), 
                        minL=-10, 
                        maxL=10, 
                        stepL=0.1, 
                        eps=1.0e-3, 
                        plotFlag=FALSE)
{
  criterion<-match.arg(criterion, c("cor", "skewness", "kurtosis"))


# search for the optimal lambda
  res <- optimize(   statVecFunc,c(minL,maxL),
                        x=x,eps=eps,criterion=criterion,tol=stepL,maximum=FALSE )

  lambda <- res$minimum

# statVec and lambdaVec are not calculated and put into arrays when using the lambda optimization
# unless a plot is required (for statVec, the value at optimal lambda is stored by default)
  statVec<- res$objective
  lambdaVec<-lambda

  if(plotFlag)
  { 
    lambdaVec<-seq(from=minL, to=maxL, by=stepL)
    statVec<-lapply(lambdaVec,statVecFunc,x=x,eps=eps,criterion=criterion)

    plot(lambdaVec, statVec, xlab="lambda", ylab="correlation")
    title(main="Box-Cox normality plot", sub=paste("optimal lambda=", lambda, sep=""))
  }

  res<-list(lambda=lambda, lambdaVec=lambdaVec, statVec=statVec)
  return(res)
}

qqnormCorFunc<-function(x)
{
  tmp<-qqnorm(x, plot.it=FALSE) 
  x<-as.vector(tmp$x)
  y<-as.vector(tmp$y)
  sd.x<-sd(x, na.rm=TRUE)
  sd.y<-sd(y, na.rm=TRUE)
  if(sd.x>0 && sd.y>0)
  { res<-cor(x, y, use="na.or.complete") }
  else {
    res<-0
  }

  return(res)
}

skewnessFunc<-function(x)
{
  n<-length(x)
  xbar<-mean(x, na.rm=TRUE)
  numer<-sum((x-xbar)^3, na.rm=TRUE)*sqrt(n)
  denom<-(sum((x-xbar)^2, na.rm=TRUE))^(3/2)
  g1<-numer/denom
  G1<-g1*sqrt(n*(n-1))/(n-2)
  res<-c(g1, G1)
  names(res)<-c("g1", "G1")
  return(res)
}

kurtosisFunc<-function(x)
{
  n<-length(x)
  xbar<-mean(x, na.rm=TRUE)
  numer<-sum((x-xbar)^4, na.rm=TRUE)*n
  denom<-(sum((x-xbar)^2, na.rm=TRUE))^2
  g2<-numer/denom-3

  k2<-sum((x-xbar)^2, na.rm=TRUE)/(n-1)
  part1numer<-(n+1)*n
  part1denom<-(n-1)*(n-2)*(n-3)
  part1<-part1numer/part1denom

  part2numer<-sum((x-xbar)^4, na.rm=TRUE)
  part2<-part2numer/k2^2

  part3<-3*(n-1)^2/((n-2)*(n-3))

  G2<-part1*part2-part3

  res<-c(g2, G2)
  names(res)<-c("g2", "G2")

  return(res)
}

