# Rscript multi_testing_geotext.R '/home/happyuwen/GeoText/experiment_v2/GeoText_Model_factorization.Rda'  '/home/happyuwen/GeoText/experiment_v2/geotext_testing' 

# Rscript multi_testing.R '/home/happyuwen/Gowalla/gowalla_100_sorted/Gowalla_Model_order1.Rda' '/home/happyuwen/Gowalla/gowalla_data/g_test_data' 

# args<-c('/home/happyuwen/GeoText/experiment_v2/GeoText_Model_order1.Rda' , '/home/happyuwen/GeoText/experiment_v2/geotext_testing' )


library("bgmm")
library("mnormt")
source("dmnormmix.R")
source("accuracy.R")
source("CDF.R")
# input
args <- commandArgs(trailingOnly = TRUE)
modelfile<-args[1]
tmptestingfilename<-args[2]
# start<-as.numeric(args[3])
# end<-as.numeric(args[4])

#args<- c('/home/happyuwen/GeoText/GeoText_Model_order1.Rda', '/home/happyuwen/GeoText/GEOall_v19_training.txt' ,'/home/happyuwen/GeoText/GEOall_v19_testing.txt' ,'/home/happyuwen/GeoText/GEOall_v19_result_NBAIM.txt' ,'/home/happyuwen/GeoText/GEOall_v19_acc_NBAIM.txt' ,'/home/happyuwen/GeoText/GEOall_v19_cdf_NBAIM.txt', 1, 8207)

# training data and testing data
#file_all<-read.table(tmptrainingfilename,col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),quote="",sep=",",stringsAsFactors=F) # those with GPS data  ,stringsAsFactors=F

load(modelfile) ## load model
model<-save_model
print(paste("model length = ",length(save_model)))
#for(file_num in start:end){
  testing_all<-read.table(file = sprintf("%s_CLAR.txt",tmptestingfilename),col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category","NB","SVM","CLAR","NMF","NBAIM"),quote="",sep=",",stringsAsFactors=F) ## testing data  ,stringsAsFactors=F
  print(paste("nrow(testing_all) = ",nrow(testing_all)))

  testing_all$ID<-as.character(testing_all$ID)
  testing_all$ID<-as.factor(testing_all$ID)

  #print(paste("file",file_num,"start"))

  #### testing area ####
  testing<-testing_all
  p_act_ID<-matrix(nrow=10,ncol=nrow(testing),0)
  pro_location<-matrix(nrow=10,ncol=nrow(testing),0)
  p<-matrix(nrow=nrow(pro_location),ncol=nrow(testing),0)
  p_act<-NULL
  ## calculate the time-act probability P(a|t)
  ##p_act_ID is the time-act probability
  for(j in 1:nrow(testing)){ #start:nrow(testing)
    if(j%%1000==0){
      print(j)
    }
    if(length(which(ls(model)==testing$ID[j]))==0){
      #print(j)
      #testing<-testing[-j,]
      next
    }
    target_model<-model[[which(ls(model)==testing$ID[j])]]
    #print(target_model$p_a)
    if(is.null(target_model)==TRUE){
      #p_act<-p_act[-j]
      #testing<-testing[-j,]
      next
    }
    act_time_weekday<-target_model$timemodel$weekday
    act_time_weekend<-target_model$timemodel$weekend
    if(is.null(act_time_weekday)){
      act_time_weekday<-matrix(nrow=10,ncol=24,1)
    }
    if(is.null(act_time_weekend)){
      act_time_weekend<-matrix(nrow=10,ncol=24,1)
    }
    if(length(target_model$timemodel)==0){
      n<-1
      }else{
       n<-1/target_model$timemodel$n
       if(length(n)==0){
        n<-1/(ncol(target_model$timemodel$weekday)/24)
       }
      }
    y<-floor(testing$hour[j]*n +((testing$min[j] /60)*n +1))
    if(testing$day[j]>=1 && testing$day[j]<=5){
      for(i in 1:nrow(p_act_ID)){
        if(sum(act_time_weekday[i,])!=0){
          p_act_ID[i,j]<-act_time_weekday[i,y]*act_time_weekday[i,y]/sum(act_time_weekday[i,])
        }
      }
    }else{
      for(i in 1:nrow(p_act_ID)){
        if(sum(act_time_weekend[i,])!=0){
          p_act_ID[i,j]<-act_time_weekend[i,y]*act_time_weekend[i,y]/sum(act_time_weekend[i,])
        }
      }
    }
    for(i in 1:ncol(p_act_ID)){ # percentage
      if(sum(p_act_ID[,i])!=0){
        p_act_ID[,i]<-p_act_ID[,i]/sum(p_act_ID[,i])
      }
    }
    ## calculate P(l|a)
    for(type in 1:nrow(p_act_ID)){
      modelunSupervised<-target_model[type+1]
      if(length(modelunSupervised[[1]])>1){
        pro_location[type,j]<-dmnormmix(testing[j,2:3],modelunSupervised[[1]])
      }
    }
    ## caculate P(l)
    pl_sum<-sum(pro_location[,j]*target_model$"p_a",na.rm=TRUE)
    
    ## the final probability of testing set
    for(i in 1:nrow(p_act_ID)){
      if(is.na(pro_location[i,j]) || pl_sum==0){
        #p_act<-p_act[-j]
        #testing<-testing[-j,]
        next
      }
      p[i,j]<-p_act_ID[i,j]*pro_location[i,j]/pl_sum
    }
    ## select the max(p)
    tmp<-which(p[,j]==max(p[,j]))
    if(length(tmp)!=1){
      for(tmpp in 1:length(tmp)){
        m<-0
        if(sum(pro_location[,j],na.rm=TRUE)!=0){
          if(is.na(pro_location[tmp[tmpp],j])!=TRUE){
            if(pro_location[tmp[tmpp],j]>m){
              new_tmp<-tmpp
              m<-pro_location[tmp[tmpp],j]
            }
          }
        }else{
          if(testing$day[j]==6 ||testing$day[j]==0){
            if(act_time_weekend[tmp[tmpp],y]>m){
              new_tmp<-tmpp
              m<-act_time_weekend[tmp[tmpp],y]
            }
          }else{
            # print(tmp)
            # print(tmpp)
            #print(act_time_weekend)
            if(act_time_weekday[tmp[tmpp],y]>m){
              new_tmp<-tmpp
              m<-act_time_weekday[tmp[tmpp],y]
            }
          }
        }
      }
      if(!exists("new_tmp")){
        p_act[j]<-testing$SVM[j]
      }else{
        if(any(tmp==new_tmp)){
          p_act[j]<-new_tmp
        }
      }
    }else{
      p_act[j]<-tmp
    }
    print(paste("j=",j,",p_act=",p_act[j],testing_all$category[j]))
  }

  testing_all$NBAIM<-p_act
  write.table(testing_all,file= sprintf('%s_NBAIM.txt',tmptestingfilename),sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
  print(paste("data saved"))

  testing_all<-testing_all[complete.cases(testing_all[,18]),]
  
  acc<-predictive_accuracy(testing_all$category,testing_all$NBAIM,10)
  accuracy<-acc$accuracy
  Tguess<-acc$T_guess
  #print(Tguess)
  print(accuracy)
  print(testing_all[1:5,])
#}

