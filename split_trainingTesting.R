## ./Rscript split_trainingTesting.R "/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_all_category.txt" "/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_training.txt" "/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_testing.txt"

## ./Rscript split_trainingTesting.R "/home/happyuwen/GeoText/GEOall_v19.txt" "/home/happyuwen/GeoText/experiment_v2/geotext_training.txt" "/home/happyuwen/GeoText/experiment_v2/geotext_testing.txt"

## args<-c("/home/happyuwen/GeoText/GEOall_v19.txt" ,"/home/happyuwen/GeoText/experiment_v2/geotext_training.txt", "/home/happyuwen/GeoText/experiment_v2/geotext_testing.txt")

args <- commandArgs(trailingOnly = TRUE)
filename<-args[1]  # the file your want to split it
trainingname<-args[2] # the training data will write to 
testingname<-args[3] #the testing data will write to

#filename<-"/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_all_category.txt"
file<-read.table(filename,col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),quote="",sep=",",stringsAsFactors=F)
file$ID<-as.factor(file$ID)
## select 80% for training and 20% for testing
#rm(training)
typelevel<-levels(as.factor(file$category))
for(u in 1:length(levels(file$ID))){
	print(u)
	data<-file[which(file$ID==levels(file$ID)[u]),]
	for(i in 1:length(typelevel)){
	  rn<-which(as.factor(data$category)==typelevel[i])
	  if(length(rn)==0){
	  	next
	  }
	  training_tmp<-data[sample(rn,floor(length(rn)*0.8+1),replace=F),]
	  if(i==1 && u==1){
	    training<-training_tmp
	  }else{
	    training<-rbind(training,training_tmp)
	  }
	}
}
testing<-file[-as.numeric(row.names(training)),]
rownames(training)<-seq(length=nrow(training))
rownames(testing)<-seq(length=nrow(testing))
write.table(training,file=trainingname,sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
write.table(testing,file=testingname,sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)