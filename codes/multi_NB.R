source("accuracy.R")
source("CDF.R")

# Rscript multi_NB.R '/home/happyuwen/Gowalla/gowalla_data/g_train_data' '/home/happyuwen/Gowalla/gowalla_data/g_test_data' '/home/happyuwen/Gowalla/gowalla_data/models/g_model_data' start end 

# Rscript multi_NB.R '/home/happyuwen/GeoText/experiment_v2/geotext_training' '/home/happyuwen/GeoText/experiment_v2/geotext_testing' '/home/happyuwen/GeoText/experiment_v2/GeoText_Model_NB.Rda' start end

# args<-c('/home/happyuwen/GeoText/experiment_v2/geotext_training' ,'/home/happyuwen/GeoText/experiment_v2/geotext_testing' ,'/home/happyuwen/GeoText/experiment_v2/GeoText_Model_NB.Rda' ,1,1)

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
	testing_all <- read.table(file = sprintf('%s.txt',tmptestingfilename),sep=",",header=F,fill=TRUE,col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category","NB","SVM","NMF","CLAR","NBAIM"),quot="")
	#print(paste("file",i,"start"))
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
	file_all$hour<-as.numeric(file_all$hour)
	testing_all$hour<-as.numeric(testing_all$hour)
	file_all$day<-as.numeric(file_all$day)
	testing_all$day<-as.numeric(testing_all$day)
	file_all$lon<-as.numeric(file_all$lon)
	testing_all$lon<-as.numeric(testing_all$lon)
	file_all$lat<-as.numeric(file_all$lat)
	testing_all$lat<-as.numeric(testing_all$lat)

	testing_all[,14]<-NA
	colnames(testing_all)[14]<-"NB"
	for(user in 1:length(levels(file_all$ID))){
		traindata<-file_all[which(file_all$ID==levels(file_all$ID)[user]),]
		testdata<-testing_all[which(testing_all$ID==levels(file_all$ID)[user]),]
		if(nrow(testdata)==0){
			next
		}
		target_place<-which(testing_all$ID==levels(file_all$ID)[user])
		classifier<-naiveBayes(traindata[,c(2,3,7,9)], as.factor(traindata[,13]))
		# save_model<-classifier
		# save(classifier,file=sprintf('%s%s.Rda',modelfile,i))
		# print(paste(i,"model saved"))
		if(length(levels(as.factor(traindata$category)))==1){
			pre<-traindata$category[1]
		}else{
			pre<-predict(classifier, list(var=testdata[,c(2,3,7,9)]))
		}
		testing_all$NB[target_place]<-pre
		print(paste("user",user,"finish; total ",length(levels(file_all$ID))))
		
	}
	write.table(testing_all,file= sprintf('%s_NB.txt',tmptestingfilename),sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
	#print(paste("file ",i," data saved"))

	acc<-predictive_accuracy(testing_all$category,testing_all$NB,length(c))
	accuracy<-acc$accuracy
	Tguess<-acc$T_guess
	#print(Tguess)
	print(accuracy)
	print(testing_all[1:5,])
}


