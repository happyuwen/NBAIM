predictive_accuracy<-function(category,p_act,n_row){
	T_guess<-matrix(nrow=n_row,ncol=n_row,0)
    category<-as.numeric(unlist(category))
    p_act<-as.numeric(unlist(p_act))
    for(i in 1:length(category)){
        if(is.na(p_act[i]) || is.na(category[i])){
            next
        }
        #print(paste(p_act[i], " ;",category[i])," ;i=",i)
    	T_guess[(p_act[i]),category[i]]<-T_guess[(p_act[i]),category[i]]+1
    }
    
    tmp<-0
    for(i in 1:nrow(T_guess)){ # the sum of matrix[i,i] i=1:6
    	tmp<-tmp+T_guess[i,i]
    }
    ##accuracy
    accuracy<-0
    for(i in 1:ncol(T_guess)){
    	accuracy[i]<-T_guess[i,i]/sum(T_guess[1:nrow(T_guess),i])
    }
    accuracy[ncol(T_guess)+1]<-tmp/sum(T_guess)
    output<-list(T_guess,accuracy)
    names(output)<-c("T_guess","accuracy")
    return(output)
}