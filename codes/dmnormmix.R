dmnormmix <- function(x,modelunSupervised) {
  #for(i in 1:length(mixture)){
  lambda <- modelunSupervised$pi
  k <- length(lambda)
  varc<-list()
  for(tmp in 1:k){
    varc[[tmp]]<-matrix(nrow=2,ncol=2,c(modelunSupervised$cvar[tmp],modelunSupervised$cvar[tmp+k],modelunSupervised$cvar[2*k+tmp],modelunSupervised$cvar[3*k+tmp]))
  }
  pnorm.from.mix <- function(x,component) {
    yy<-try(pmnorm(x,mean=modelunSupervised$mu[component,],varcov=varc[[component]]),silent=TRUE)
    if(!(class(yy)=="try-error")[1]){
      lambda[component]*pmnorm(x,mean=modelunSupervised$mu[component,],varcov=varc[[component]])
    }else{
      names(x)<-names(modelunSupervised$mu)
      dis<-dist(rbind(data.frame(x),data.frame(modelunSupervised$mu)), method = "euclidean", diag = FALSE, upper = FALSE, p = 2)
      if(nrow(modelunSupervised$mu)==1 && dis<=1){
        1
      }else{
        0
      }
    }
  }
  dmnorms <- sapply(1:k,pnorm.from.mix,x=x)
  #if(length(dmnorms)==1){
    return(sum(dmnorms))
  #}else{
  #  return(rowSums(dmnorms))
  #}
}