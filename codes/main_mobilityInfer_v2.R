library("bgmm")
library("mnormt")

# Rscript main_mobilityInfer_v2.R '/home/happyuwen/Gowalla/gowalla_100_sorted/Gowalla_Model_order1.Rda' '/home/happyuwen/Gowalla/gowalla_data/g_test_data' '/home/happyuwen/Gowalla/gowalla_data/' start end

# Rscript main_mobilityInfer_v2.R '/home/happyuwen/GeoText/experiment_v2/GeoText_Model_order1.Rda' '/home/happyuwen/GeoText/experiment_v2/geotext_testing' '/home/happyuwen/GeoText/experiment_v2/geotext'

# args<-c('/home/happyuwen/GeoText/experiment_v2/GeoText_Model_order1.Rda' ,'/home/happyuwen/GeoText/experiment_v2/geotext_testing' ,'/home/happyuwen/GeoText/experiment_v2/geotext',1,1)

# args<-c('/home/happyuwen/Gowalla/gowalla_100_sorted/Gowalla_Model_order1.Rda', '/home/happyuwen/Gowalla/gowalla_data/g_test_data','/home/happyuwen/Gowalla/gowalla_data/',1,1)

args <- commandArgs(trailingOnly = TRUE)
modelfile<-args[1] 	
tmptestingfilename<-args[2]  
locationfile<-args[3] ## the likelihood will be save here
start<-as.numeric(args[4])
end<-as.numeric(args[5])
load(modelfile)
model<-save_model


#for(file_num in start:end){
	#print(paste(file_num,"start"))
	testing_all<-read.table(file = sprintf("%s.txt",tmptestingfilename),col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),quote="",sep=",",stringsAsFactors=F) ## testing data  ,stringsAsFactors=F # for Geotext
	#likelihoodfile<-read.table(file = sprintf("%s_likelihood.txt",locationfile),col.names=c("ID","category","NBAIM","NB","SVM"),quote="",sep=",",stringsAsFactors=F) 
	#likelihoodfile<-cbind(likelihoodfile,0)
	#colnames(likelihoodfile)[6]<-"ndata"
	#location_predict<-read.table(file = sprintf("%s_locationPredict.txt",locationfile),quote="",sep=",",stringsAsFactors=F)
	testing_all<-testing_all[which(testing_all$Freq>=25),]
	rownames(testing_all)<-1:nrow(testing_all)
	#testing_all<-read.table(file = sprintf("%s%s.txt",tmptestingfilename,file_num),col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category","NB","SVM","NMF"),quote="",sep=",",stringsAsFactors=F) ## testing data  ,stringsAsFactors=F # for gowalla

	
	##calculate the log likelihood by user and category
	#testing_all<-cbind(testing_all[,1:13],location_predict)
	likelihoodfile<-matrix(ncol=3,nrow=0)
	likelihoodfile<-as.data.frame(likelihoodfile)
	colnames(likelihoodfile)<-c("ID","category","loglikelihood")
	
	testing_all[,14]<-0
	colnames(testing_all)[ncol(testing_all)]<-"testBit"
	testing_all$ID<-as.character(testing_all$ID)
	testing_all$category<-as.numeric(testing_all$category)
	# for(item in 1:nrow(likelihoodfile)){
	# 	data<-testing_all[which(testing_all$category==likelihoodfile$category[item]),]
	# 	data<-data[which(data$ID==likelihoodfile$ID),]
	# 	likelihoodfile[item,6]<-nrow(data)
	# }
	testing_all$lon<-as.numeric(as.character(testing_all$lon))
	testing_all$lat<-as.numeric(as.character(testing_all$lat))
	for(j in 1:nrow(testing_all)){ #nrow(testing_all)
		if(testing_all$testBit[j]==1){
			next
		}
		target_model<-model[[which(ls(model)==testing_all$ID[j])]]
		type<-sprintf("type%s",testing_all$category[j])
		target_act<-target_model[[paste(type)]]
		data<-testing_all[which(testing_all$category==testing_all$category[j]),]
		data<-data[which(data$ID==testing_all$ID[j]),]
		testing_all$testBit[as.numeric(rownames(data))]<-1
		if(is.null(target_act)){
			# likelihoodfile<-rbind(likelihoodfile,c((testing_all$ID[j]),testing_all$category[j],NA))
			likelihoodfile[nrow(likelihoodfile)+1,1]<-testing_all$ID[j]
			likelihoodfile[nrow(likelihoodfile),2]<-testing_all$category[j]
			likelihoodfile[nrow(likelihoodfile),3]<-NA
			likelihoodfile[nrow(likelihoodfile),4]<-testing_all$Freq[j]
			#print(paste(likelihoodfile[nrow(likelihoodfile),]))
			next
		}
		if(length(target_act)==1){
			# likelihoodfile<-rbind(likelihoodfile,c((testing_all$ID[j]),testing_all$category[j],0))
			likelihoodfile[nrow(likelihoodfile)+1,1]<-testing_all$ID[j]
			likelihoodfile[nrow(likelihoodfile),2]<-testing_all$category[j]
			likelihoodfile[nrow(likelihoodfile),3]<-NA
			likelihoodfile[nrow(likelihoodfile),4]<-testing_all$Freq[j]
			#print(paste(likelihoodfile[nrow(likelihoodfile),]))
			next
		}
		# tmp<-matrix(nrow=1,c((testing_all$ID[j]),testing_all$category[j],loglikelihood.mModel(target_act,data[,17:18])))
		# likelihoodfile<-rbind(likelihoodfile,tmp)
		likelihoodfile[nrow(likelihoodfile)+1,1]<-testing_all$ID[j]
		likelihoodfile[nrow(likelihoodfile),2]<-testing_all$category[j]
		likelihoodfile[nrow(likelihoodfile),3]<-loglikelihood.mModel(target_act,data[,2:3])/nrow(data)
		likelihoodfile[nrow(likelihoodfile),4]<-testing_all$Freq[j]
		if(j%%1000==0){
			print(paste(likelihoodfile[nrow(likelihoodfile),]))
		}
	}
	likelihoodfile<-likelihoodfile[!duplicated(likelihoodfile),]

	write.table(likelihoodfile,file= sprintf('%s_likelihood.txt',locationfile),sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
	#print(paste(file_num,"finished"))
#}

# likelihoodfile
# max(likelihoodfile$loglikelihood,na.rm=TRUE)
# min(likelihoodfile$loglikelihood,na.rm=TRUE)
# getModelStructure(mean = )
# loglikelihood.mModel(tt,location_predict)