library("MASS")
source("KDE.R")
# Rscript main_mobilityInfer_v2.R '/home/happyuwen/GeoText/experiment_v2/geotext_training' '/home/happyuwen/GeoText/experiment_v2/geotext_testing' '/home/happyuwen/GeoText/experiment_v2/geotext'

# args<-c('/home/happyuwen/GeoText/experiment_v2/geotext_training' ,'/home/happyuwen/GeoText/experiment_v2/geotext_testing' ,'/home/happyuwen/GeoText/experiment_v2/geotext',1,1)
args <- commandArgs(trailingOnly = TRUE)

tmptrainingfilename<-args[1]
tmptestingfilename<-args[2]
locationfile<-args[3]
start<-as.numeric(args[4])
end<-as.numeric(args[5])


  file_all<-read.table(file = sprintf("%s.txt",tmptrainingfilename),col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),quote="",sep=",",stringsAsFactors=F) ## testing data  ,stringsAsFactors=F
  testing_all<-read.table(file = sprintf("%s_NBAIM_v2.txt",tmptestingfilename),col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category","NB","SVM","CLAR","NMF","NBAIM"),quote="",sep=",",stringsAsFactors=F) ## testing data  ,stringsAsFactors=F
  print(paste("file_all =",nrow(file_all), ", nrow(testing_all =",nrow(testing_all)))
  file_all$ID<-as.character(file_all$ID)
  file_all$ID<-as.factor(file_all$ID)
  testing_all$ID<-as.character(testing_all$ID)
  testing_all$ID<-as.factor(testing_all$ID)

  file_all$lon<-as.numeric(file_all$lon)
  file_all$lat<-as.numeric(file_all$lat)
  testing_all$lon<-as.numeric(testing_all$lon)
  testing_all$lat<-as.numeric(testing_all$lat)

  file_100<-file_all[which(file_all$Freq>=25),]
  file_all<-file_100

  testing_100<-testing_all[which(testing_all$Freq>=25),]
  testing_all<-testing_100
  print(paste("file_all =",nrow(file_all), ", nrow(testing_all) =",nrow(testing_all)))

  likelihoodfile<-matrix(ncol=4,nrow=0)
  likelihoodfile<-as.data.frame(likelihoodfile)
  colnames(likelihoodfile)<-c("ID","category","loglikelihood","Freq")
  for(user in 1:length(levels(as.factor(file_all$ID)))){
  	for(act in 1:10){
  		traindata<-file_all[which(file_all$category==act),]
  		traindata<-traindata[which(traindata$ID==levels(as.factor(file_all$ID))[user]),]
  		if(nrow(traindata)==0){
  			next
  		}
  		testdata<-testing_all[which(testing_all$category==act),]
  		testdata<-testdata[which(testdata$ID==levels(as.factor(file_all$ID))[user]),]
  		if(nrow(testdata)==0){
  			next
  		}
  		likelihoodfile[nrow(likelihoodfile)+1,1]<-as.character(traindata$ID[1])
  		likelihoodfile[nrow(likelihoodfile),2]<-traindata$category[1]
  		if(is.na(traindata$lon[1])){
  			next
  		}
  		likelihoodfile[nrow(likelihoodfile),3]<-KDE(traindata[,2:3],testdata[,2:3])
  		likelihoodfile[nrow(likelihoodfile),4]<-traindata$Freq[1]
  		#print(likelihoodfile[nrow(likelihoodfile),])
  		if(user%%150==0){
  			print(paste(user,likelihoodfile[nrow(likelihoodfile),]))
  		}
  	}
  }
 
	likelihoodfile<-likelihoodfile[!duplicated(likelihoodfile),]

	write.table(likelihoodfile,file= sprintf('%s_kde.txt',locationfile),sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)