source("accuracy.R")
CDF<-function(userID,category,p_act){
	acc_individual<-NULL
	userID<-as.factor(as.character(userID))
	category<-cbind(userID,category,p_act)
	colnames(category)<-c("ID","category","p_act")
	category<-as.data.frame(category)
	for(user in 1:length(levels(userID))){
		testing<-category[which(userID==levels(userID)[user]),]
		acc<-predictive_accuracy(testing$category,testing$p_act,10)
		acc_individual[user]<-acc$accuracy[11]
	}
	return(acc_individual)
}