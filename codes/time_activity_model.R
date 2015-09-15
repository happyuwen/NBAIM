source("matrix_factorization.R")
time_activity<-function(file,alpha,beta,times,n){
	# alpha,beta,times for factorization
	action<-0
	file<-file[,c(1,4,5,6,7,8,9,10,13)]
  
	## count act_time by weekday and weekend
    act_time_weekday<-matrix(nrow=max(file_all$category), ncol=n*24,0)
    act_time_weekend<-matrix(nrow=max(file_all$category), ncol=n*24,0)
    for(i in 1:nrow(file)){
    	y<-floor(file$hour[i]*n +((file$min[i] /60)*n +1))
    	if(file$day[i]>=1 && file$day[i]<=5){
        	act_time_weekday[file[i,9],y]<-act_time_weekday[file[i,9],y]+1
    	}
      	else{
        	act_time_weekend[file[i,9],y]<-act_time_weekend[file[i,9],y]+1
      	}
    }
    act_time_weekday<-factorization(act_time_weekday,2,nrow(act_time_weekday),ncol(act_time_weekday),2,times,alpha,beta)$R
    act_time_weekend<-factorization(act_time_weekend,2,nrow(act_time_weekend),ncol(act_time_weekend),2,times,alpha,beta)$R
    for(i in 1:ncol(act_time_weekday)){ # percentage
		if(sum(act_time_weekday[,i])!=0){
			act_time_weekday[,i]<-act_time_weekday[,i]/sum(act_time_weekday[,i])
		}
		if(sum(act_time_weekend[,i])!=0){
			act_time_weekend[,i]<-act_time_weekend[,i]/sum(act_time_weekend[,i])
		}
    }
    if(is.na(sum(act_time_weekday))==TRUE || is.na(sum(act_time_weekend))==TRUE){
    	action<-1 
    	return()
    }
    output<-list(act_time_weekday,act_time_weekend)
    names(output)<-c("act_time_weekday","act_time_weekend")
    return(output)
}

probability_of_act<-function(testing,act_time_weekday,act_time_weekend,n){
	p_action<-0
	## calculate the time-act probability
    ## p_act_ID is the time-act probability
    p_act_ID<-matrix()
    #p_act_ID<-vector("list",nrow(act_time_weekday))
    p_act_ID<-matrix(nrow=nrow(act_time_weekday),ncol=nrow(testing),0)
    for(j in 1:nrow(testing)){
	    y<-floor(testing$hour[j]*n +((testing$min[j] /60)*n +1))
	    if(testing$day[j]>=1 && testing$day[j]<=5){
			for(i in 1:nrow(act_time_weekday)){
				if(sum(act_time_weekday[i,])!=0){
					p_act_ID[i,j]<-act_time_weekday[i,y]*act_time_weekday[i,y]/sum(act_time_weekday[i,])
				}
			}
	    }else{
			for(i in 1:nrow(act_time_weekday)){
				if(sum(act_time_weekend[i,])!=0){
					p_act_ID[i,j]<-act_time_weekend[i,y]*act_time_weekend[i,y]/sum(act_time_weekend[i,])
				}
			}
	    }
  	}
    for(i in 1:ncol(p_act_ID)){ # percentage
	    if(sum(p_act_ID[,i])!=0){
	    	p_act_ID[,i]<-p_act_ID[,i]/sum(p_act_ID[,i])
	    }
    }
    if(sum(p_act_ID)==0){
    	p_action<-1
    	return()
    }
    
    ## select the max(p)
    p_act<-matrix(ncol=ncol(p_act_ID),0)
    for(i in 1:ncol(p_act_ID)){
    	tmp<-which(p_act_ID[,i]==max(p_act_ID[,i]))
    	if(length(tmp)!=1){
			if (testing$day[i]>=1 && testing$day[i]<=5){ #check weekday/weekend
				y<-floor(testing$hour[i]*n +((testing$min[i] /60)*n +1))
				m<-0
				for(tmp2 in 1:length(tmp)){
					if(sum(act_time_weekday[tmp[tmp2],])>m){
						m<-sum(act_time_weekday[tmp[tmp2],])
						new_tmp<-tmp[tmp2]
					}
				}
    		}else{ ##if weekend
      			y<-floor(testing$hour[i]*n +((testing$min[i] /60)*n +1))
				m<-0
				for(tmp2 in 1:length(tmp)){
					if(sum(act_time_weekend[tmp[tmp2],])>m){
						m<-sum(act_time_weekend[tmp[tmp2],])
						new_tmp<-tmp[tmp2]
					}else{
						new_tmp<-1
					}
				}
   			}
		    if(any(tmp==new_tmp)){
		     	p_act[i]<-new_tmp
		    }
   		}else{
      		p_act[i]<-tmp
    	}
    }
    return(p_act)
}

order_1_transition_timeModel<-function(file,n){
	action<-0
	act_time<-matrix(nrow=max(file_all$category),ncol=n*24,0)
	for(i in 1:nrow(file)){
		y<-floor(file$hour[i]*n +((file$min[i] /60)*n +1)) 
		act_time[file[i,13],y]<-act_time[file[i,13],y]+1
	}
	## (activity,activity) transactionmodel[[model_user]]$
	act_act<-matrix(nrow=max(file_all$category), ncol=max(file_all$category), 0)
	for(i in 1:nrow(act_time)){
		for(j in 1:ncol(act_time)){
			if(j==ncol(act_time)){
				for(k in 1:max(file_all$category)){
					act_act[i,k]<-act_act[i,k]+act_time[i,j]*act_time[k,1]
				}
			}else{
				for(k in 1:max(file_all$category)){
					act_act[i,k]<-act_act[i,k]+act_time[i,j]*act_time[k,j+1]
				}
			}
		}
	}
    if(sum(act_act)==0){
    	action<-1 
    	return()
    }
    for(i in 1:nrow(act_act)){
		if(sum(act_act[i,]!=0)){
			act_act[i,]<-act_act[i,]/sum(act_act[i,])
		}
    }
    ## count act_time by weekday and weekend
    act_time_weekday<-matrix(nrow=max(file_all$category), ncol=n*24,0)
    act_time_weekend<-matrix(nrow=max(file_all$category), ncol=n*24,0)
    for(i in 1:nrow(file)){
		y<-floor(file$hour[i]*n +((file$min[i] /60)*n +1))
		if(file$day[i]>=1 && file$day[i]<=5){
			act_time_weekday[file[i,13],y]<-act_time_weekday[file[i,13],y]+1
		}
		else{
			act_time_weekend[file[i,13],y]<-act_time_weekend[file[i,13],y]+1
		}
    }
    for(i in 1:ncol(act_time_weekday)){ # percentage
		if(sum(act_time_weekday[,i])!=0){
			act_time_weekday[,i]<-act_time_weekday[,i]/sum(act_time_weekday[,i])
		}
		if(sum(act_time_weekend[,i])!=0){
			act_time_weekend[,i]<-act_time_weekend[,i]/sum(act_time_weekend[,i])
		}
    }
    d<-0
    e<-0
    for(i in 1:ncol(act_time_weekday)-1){
      if(sum(act_time_weekday[,i])!=0 || d==1){
        d<-1
        for(tmp in 1:nrow(act_time_weekday)){
          for(tmp1 in 1:nrow(act_time_weekday)){
            act_time_weekday[tmp,i+1]<-act_time_weekday[tmp,i+1]+act_time_weekday[tmp1,i]*act_act[tmp1,tmp]##p0_weekday[tmp1]*act_act[tmp1,tmp]
          }
        }
        act_time_weekday[,i+1]<-act_time_weekday[,i+1]/sum(act_time_weekday[,i+1])
      }
      if(sum(act_time_weekend[,i])!=0 || e==1){
        e<-1
        for(tmp in 1:nrow(act_time_weekend)){
          for(tmp1 in 1:nrow(act_time_weekend)){
            act_time_weekend[tmp,i+1]<-act_time_weekend[tmp,i+1]+act_time_weekend[tmp1,i]*act_act[tmp1,tmp]##p0_weekday[tmp1]*act_act[tmp1,tmp]
          }
        }
        act_time_weekend[,i+1]<-act_time_weekend[,i+1]/sum(act_time_weekend[,i+1])
    	}
      
    }
    if(is.na(sum(act_time_weekday))==TRUE || is.na(sum(act_time_weekend))==TRUE){
    	action<-1 
    	return()
    }
    output<-list(act_time_weekday,act_time_weekend)
    names(output)<-c("act_time_weekday","act_time_weekend")
    return(output)
}