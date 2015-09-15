factorization<-function(x,NCols_P,NRows_P,NCols_Q,NRows_Q,steps,alpha,beta){
  P<-matrix(runif(NCols_P*NRows_P), ncol=NCols_P) 
  Q<-matrix(runif(NCols_Q*NRows_Q), ncol=NCols_Q) 
  for(step in 1:steps){
    for(i in 1:nrow(x)){
      for(j in 1:ncol(x)){
        if(x[i,j]>0){
          eij<-x[i,j]-P[i,]%*%Q[,j]
          for(k in 1:nrow(Q)){
            if(!is.na(P[i,k] + alpha * (2 * eij * Q[k,j] - beta * P[i,k])) && is.finite(P[i,k] + alpha * (2 * eij * Q[k,j] - beta * P[i,k]))){
              P[i,k] = P[i,k] + alpha * (2 * eij * Q[k,j] - beta * P[i,k])
            }
            #if(P[i,k]<0){P[i,k]=0}
            if(!is.na(Q[k,j] + alpha * (2 * eij * P[i,k] - beta * Q[k,j])) && is.finite(Q[k,j] + alpha * (2 * eij * P[i,k] - beta * Q[k,j]))){
              Q[k,j] = Q[k,j] + alpha * (2 * eij * P[i,k] - beta * Q[k,j])
            }
            #if(Q[k,j]<0){P[k,j]=0}
          }
        }
      }
    }
    R<-P %*% Q
    R[which(is.na(R)==TRUE)]<-0
    e<-0
    for(i in 1:nrow(x)){
      for(j in 1:ncol(x)){
        if(R[i,j]>0){
          e <- e+(R[i,j]-P[i,]%*%Q[,j])^2
          for(k in 1:nrow(Q)){
            e<- e+(beta/2) * (P[i,k]^2 + Q[k,j]^2)
          }
        }
      }
    }
    #if(step %% 10==0){print(paste("step= ", step, ", e= ", e))}
    if(length(which((P%*%Q<0)==TRUE))==0 && step>1000){
      break
    }
    # if(e<0.001){
    #   break
    # }
  }
  R[which((R<0)==TRUE)]<-0
  R<-round(R)
  list.names<-c('R','P','Q')
  result<-vector("list",length(list.names))
  result$R<-R
  result$P<-P
  result$Q<-Q
  return (result)  
}

factorization_PQ<-function(x,P,Q,alpha,beta){
  # P<-matrix(runif(NCols_P*NRows_P), ncol=NCols_P) 
  # Q<-matrix(runif(NCols_Q*NRows_Q), ncol=NCols_Q) 
  for(step in 1:steps){
    for(i in 1:nrow(x)){
      for(j in 1:ncol(x)){
        if(x[i,j]>0){
          eij<-x[i,j]-P[i,]%*%Q[,j]
          for(k in 1:nrow(Q)){
            P[i,k] = P[i,k] + alpha * (2 * eij * Q[k,j] - beta * P[i,k])
            #if(P[i,k]<0){P[i,k]=0}
            Q[k,j] = Q[k,j] + alpha * (2 * eij * P[i,k] - beta * Q[k,j])
            #if(Q[k,j]<0){P[k,j]=0}
          }
        }
      }
    }
    R<-P %*% Q
    e<-0
    for(i in 1:nrow(x)){
      for(j in 1:ncol(x)){
        if(R[i,j]>0){
          e <- e+(R[i,j]-P[i,]%*%Q[,j])^2
          for(k in 1:nrow(Q)){
            e<- e+(beta/2) * (P[i,k]^2 + Q[k,j]^2)
          }
        }
      }
    }
    #if(step %% 10==0){print(paste("step= ", step, ", e= ", e))}
    if(length(which((P%*%Q<0)==TRUE))==0 && step>1000){
      break
    }
    if(e<0.001){
      break
    }
  }
  R[which((R<0)==TRUE)]<-0
  R<-round(R)
  list.names<-c('R','P','Q')
  result<-vector("list",length(list.names))
  result$R<-R
  result$P<-P
  result$Q<-Q
  return (result)  
}