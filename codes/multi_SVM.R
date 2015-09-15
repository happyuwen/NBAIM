source("accuracy.R")
source("CDF.R")
# Rscript multi_SVM.R '/home/happyuwen/GeoText/experiment_v2/geotext_training' '/home/happyuwen/GeoText/experiment_v2/geotext_testing' '/home/happyuwen/GeoText/experiment_v2/GeoText_Model_SVM.Rda' start end


# Rscript multi_SVM.R '/home/happyuwen/Gowalla/gowalla_data/g_train_data' '/home/happyuwen/Gowalla/gowalla_data/g_test_data' '/home/happyuwen/Gowalla/gowalla_data/models_SVM/g_model_data' start end 

# Rscript multi_SVM.R '/home/happyuwen/Gowalla/gowalla_monthly/gowalla_200911_training' ,'/home/happyuwen/Gowalla/gowalla_monthly/gowalla_200911_testing','/home/happyuwen/Gowalla/gowalla_monthly/models/SVM/gowalla_200911_SVM' start end 

# args<-c('/home/happyuwen/Gowalla/gowalla_data/g_train_data', '/home/happyuwen/Gowalla/gowalla_data/g_test_data' ,'/home/happyuwen/Gowalla/gowalla_data/models_SVM/g_model_data',1,1)

# args<-c('/home/happyuwen/Gowalla/gowalla_monthly/gowalla_200911_training' ,'/home/happyuwen/Gowalla/gowalla_monthly/gowalla_200911_testing','/home/happyuwen/Gowalla/gowalla_monthly/models/SVM/gowalla_200911_SVM') start end )

# input row data
args <- commandArgs(trailingOnly = TRUE)
start<-args[4]
end<-args[5]
modelfile<-args[3]
tmptrainingfilename<-args[1]
tmptestingfilename<-args[2]

#### NaiveBayes Method Classification ####
library("e1071")
library("class")
c<-c("Arts & Entertainment","Colleges & Universities","Events","Food","Nightlife Spots","Outdoors & Recreation","Professional & Other Places","Residences","Shops & Services","Travel & Transport")
#for(i in start:end){
	file_all <- read.table(file = sprintf('%s.txt',tmptrainingfilename),sep=",",header=F,fill=TRUE,col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),quot="")
	testing_all <- read.table(file = sprintf('%s_NB.txt',tmptestingfilename),sep=",",header=F,fill=TRUE,col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category","NB","SVM","NMF","CLAR","NBAIM"),quot="")
	#print(paste("file ",i," start"))
	file_100<-file_all[which(file_all$Freq>=25),]
	file_all<-file_100
	file_all$ID<-as.character(file_all$ID)
	file_all$ID<-as.factor(file_all$ID)
	testing_100<-testing_all[which(testing_all$Freq>=25),]
	testing_all<-testing_100
	testing_all$ID<-as.character(testing_all$ID)
	testing_all$ID<-as.factor(testing_all$ID)

	file_all<-file_all
	testing_all<-testing_all
	file_all$category<-as.character(file_all$category)
	testing_all$category<-as.character(testing_all$category)
	file_all$category<-as.factor(file_all$category)
	testing_all$category<-as.factor(testing_all$category)

	testing_all[,15]<-NA
	colnames(testing_all)[15]<-"SVM"
	for(user in 1:length(levels(file_all$ID))){
		traindata<-file_all[which(file_all$ID==levels(file_all$ID)[user]),]
		testdata<-testing_all[which(testing_all$ID==levels(file_all$ID)[user]),]
		if(nrow(testdata)==0){
			next
		}
		target_place<-which(testing_all$ID==levels(file_all$ID)[user])
		if(length(levels(as.factor(as.character(traindata$category))))==1){
			testing_all$SVM[target_place]<-as.character(testing_all$category[1])
			print(paste("user",user,"finish; total ",length(levels(file_all$ID))))
			next
		}
		traindata$category<-as.numeric(as.character(traindata[,13]))
		svmmodel<-svm(as.factor(traindata[,13]) ~.,data=data.matrix(traindata[,c(2,3,7,9)]),scale=FALSE)
		# levels(testdata$ID)<-levels(traindata$ID)
		# # levels(testing_all$lon)<-levels(file_all$lon)
		# # levels(testing_all$lat)<-levels(file_all$lat)
		# # levels(testing_all$hour)<-levels(file_all$hour)
		# levels(testdata$day)<-levels(traindata$day)
		# levels(testdata$category)<-levels(traindata$category)

		pre<-predict(svmmodel,testdata[,c(2,3,7,9)])
		testing_all$SVM[target_place]<-pre
		# colnames(testing_all)[14]<-"NB"
		if(user %% 50 == 0){
			print(paste("user",user,"finish; total ",length(levels(file_all$ID))))
		}
	}
	
	# colnames(testing_all)[15]<-"SVM"
	write.table(testing_all,file= sprintf('%s_SVM.txt',tmptestingfilename),sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
	#print(paste("file ",i," data saved"))

	acc<-predictive_accuracy(testing_all$category,testing_all$SVM,length(c))
	accuracy<-acc$accuracy
	Tguess<-acc$T_guess
	#print(Tguess)
	print(accuracy)
	print(testing_all[1:5,])
}


