source("matrix_factorization.R")
source("time_activity_model.R")
source("accuracy.R")
source("build_model_my_method.R")
library("bgmm")
library("mnormt")
# Rscript main_my_method.R '/home/happyuwen/Gowalla/gowalla_v3/NBAIM_models/Gowalla_Model_order1_9.Rda' 'order_1_transition' '/home/happyuwen/Gowalla/gowalla_v3/training/g_train_data9.txt' '/home/happyuwen/Gowalla/gowalla_v3/testing/g_test_data9_v2.txt' 1 0

# args<-c('/home/happyuwen/GeoText/experiment_v2/GeoText_Model_order1.Rda', 'order_1_transition' ,'/home/happyuwen/GeoText/experiment_v2/geotext_training.txt' ,'/home/happyuwen/GeoText/experiment_v2/geotext_testing.txt', 1 ,1)



# input row data
args <- commandArgs(trailingOnly = TRUE)
start<-as.numeric(args[5])
end<-as.numeric(args[6])
filename<-args[1]
method<-args[2]
tmptrainingfilename<-args[3]
tmptestingfilename<-args[4]

#tmptrainingfilename<-"/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_all_category.txt"
#tmptestingfilename<-"/home/happyuwen/GeoText/GEOall_v19_testing.txt"

# training data and testing data
file_all<-read.table(tmptrainingfilename,col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),quote="",sep=",",stringsAsFactors=F) # those with GPS data  ,stringsAsFactors=F
testing_all<-read.table(tmptestingfilename,col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category","NB","SVM","NMF","CLAR","NBAIM"),quote="",sep=",",stringsAsFactors=F) ## testing data  ,stringsAsFactors=F

file_100<-file_all[which(file_all$Freq>=25),]
file_all<-file_100
file_all$ID<-as.character(file_all$ID)
file_all$ID<-as.factor(file_all$ID)
print(paste("train data = ",nrow(file_all),";total users = ",length(levels(file_all$ID))))

testing_100<-testing_all[which(testing_all$Freq>=25),]
testing_all<-testing_100
testing_all$ID<-as.character(testing_all$ID)
testing_all$ID<-as.factor(testing_all$ID)


# build model
if(file.exists(filename)){
	load(filename) ## load model
}else{
	list.names<-levels(file_all$ID) ##give list names
	model<-vector("list",length(list.names))
	names(model)<-list.names
	save_model<-model
}
model<-build_ActivityInferenceModel(file_all,method=method,start,end,save_model,filename) #user start
#print(model)
save_model<-model
save(save_model,file=filename)


#print(file_all$category)
#rm(save_model)
#load('D:/ADSL_yuwen/nctulog/USAModel.Rda') ## load model

