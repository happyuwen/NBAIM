source("time_activity_model.R")
source("accuracy.R")
action<-0
p_action<-0
build_ActivityInferenceModel<-function(file_all,method=c("factorization","order_1_transition"),start,end,model,filename){
	# list.names<-levels(file_all$ID) ##give list names
	# model<-vector("list",length(list.names))
	# names(model)<-list.names
	if(end==0){
		end<-length(levels(file_all$ID))
	}
	for(user in start:end){ #length(levels(file_all$ID))
		# model_user<-which(ls(model)==levels(file_all$ID)[user]) #for testing code
		# n1<-model[[model_user]]$p_a
		# #n2<-model[[model_user]]$timemodel$weekday
		# print(paste("ID=",model_user,",p_a="))
		# print(n1)
		# file<-file_all[which(file_all$ID==levels(file_all$ID)[user]),]
		# print(file$category)
		# print(n2)
		#user<-1
		#testing<-file_all[which(file_all$ID==levels(file_all$ID)[user]),]
		file<-file_all[which(file_all$ID==names(model[user])),]
		testing<-file
		traintype<-matrix()
	    traintype<-list(traintype,traintype)
	    for(i in 1:max(file_all$category)){ ## seperate training and testing data into groups
		    traintype[[i]]<-file[as.numeric(which(file$category == i)),]
		    #testingG[[i]]<-testing[as.numeric(which(testing$category == i)),]
	  	}

		## calculate the activity percentage of each location data
	  	p_a<-0 
	  	for(i in 1:max(file_all$category)){
	    	p_a[i]<-nrow(traintype[[i]])/nrow(file)
	  	}
	  	model_user<-which(ls(model)==file$ID[1]) ## the user's model place
	  	## location model
	  	model[[model_user]]<-vector("list",max(file_all$category)+1)
	  	tmpname<-c("p_a")
	  	for(i in 1:max(file_all$category)){
			tmpname<-cbind(tmpname,sprintf("type%s",i))
		}
	  	names(model[[model_user]])<-tmpname
	  	model[[model_user]]$p_a<-p_a

	  	loglike<-0
		for(type in 1:max(file_all$category)){
			x<-lapply(traintype[[type]][,2:3],as.numeric)
			#x<-traintype[[type]][,2:3]
			if(length(x$lon)==0){next}
			if(nrow(cbind(x$lon,x$lat))==1){
			  #x[2,1]<-x[1,1]
			  #x[2,2]<-x[1,2]
			  x$lon[2]<-x$lon[1]
			  x$lat[2]<-x$lat[1]
			}
			while(nrow(cbind(x$lon,x$lat))<=10){
			  x$lon[length(x$lon)+1]<-x$lon[length(x$lon)-1]
			  x$lat[length(x$lat)+1]<-x$lat[length(x$lat)-1] 
			}
			knows<-cbind(x$lon,x$lat)
			if(nrow(knows)!=0){
				loglike<-NA
				#bound<-0
				for(k in 1:5){
					yy<-try(unsupervised(X=knows,k=k),silent=TRUE)
					if(!(class(yy)=="try-error")[1]){
						modelunSupervised = yy#unsupervised(X=knows,k=k)
						loglike[k]<-modelunSupervised$likelihood
						if(modelunSupervised$likelihood<=300){break}
					}
				}
			## if all check-ins are sample, only one not
				if(is.na(loglike)==TRUE && length(loglike)==1){
					model[[model_user]][[type+1]]$mu<-matrix(nrow=1,c(mean(knows[,1]),mean(knows[,2])))
				}else{
					k<-which(loglike==min(loglike,na.rm=TRUE))
					modelunSupervised = unsupervised(X=knows,k=k)
					model[[model_user]][[type+1]]<-modelunSupervised
				}
			}
		}
		
		# time model
		result<-matrix()
	  	result<-vector("list",4)
	  	max_acc<-0
	  	model[[model_user]]$timemodel<-list()
	  	# find the best n
		for(n in 1:4){
			n<-1/n
			if(method=="factorization"){
				act_time<-time_activity(file,0.002,0.02,50,n)
				if(is.null(act_time)==TRUE){next}
			}else{
				act_time<-order_1_transition_timeModel(file,n)
				if(is.null(act_time)==TRUE){next}
			}
			act_time_weekday<-act_time$act_time_weekday
			act_time_weekend<-act_time$act_time_weekend
			p_act<-probability_of_act(testing,act_time_weekday,act_time_weekend,n)
			if(is.null(p_act)==TRUE){next}
			acc<-predictive_accuracy(unlist(testing$category),unlist(p_act),10)
			result[[1/n]]<-acc$accuracy
			if(n==1){
				model[[model_user]]$timemodel$weekday<-act_time_weekday
  				model[[model_user]]$timemodel$weekend<-act_time_weekend
			}
			
			# find the max acc when n
			if(result[[1/n]][length(result[[1/n]])]>max_acc){
				max_acc<-result[[1/n]][length(result[[1/n]])]
				model[[model_user]]$timemodel$weekday<-act_time_weekday
  				model[[model_user]]$timemodel$weekend<-act_time_weekend
  				model[[model_user]]$timemodel$n<-1/n
			}
			#print(max_acc)

		}
		
		print(paste("user=",user,"/",end,", total user=",length(levels(file_all$ID)),", acc= ",max_acc))
		if(user %% 10==0){
	        save_model<-model
	        save(save_model,file=filename) #'/home/happyuwen/GeoText/GeoText_Model_factorization.Rda'
	        print("file saved")
    	}
	}
    
	return(model)
}