library("NbClust")
library("geosphere")
source("matrix_factorization.R")
source("accuracy.R")
source("CDF.R")
#source("ALGO_CLAR.R")

# Rscript main_clap_geotext.R '/home/happyuwen/GeoText/experiment_v2/geotext_training' '/home/happyuwen/GeoText/experiment_v2/geotext_testing' '/home/happyuwen/GeoText/experiment_v2/geotext_result_CLAR.txt' '/home/happyuwen/GeoText/experiment_v2/geotext_acc_CLAR.txt' '/home/happyuwen/GeoText/experiment_v2/geotext_cdf_CLAR.txt'

# args<-c('/home/happyuwen/GeoText/experiment_v2/geotext_training' ,'/home/happyuwen/GeoText/experiment_v2/geotext_testing' ,'/home/happyuwen/GeoText/experiment_v2/geotext_result_CLAR.txt' ,'/home/happyuwen/GeoText/experiment_v2/geotext_acc_CLAR.txt' ,'/home/happyuwen/GeoText/experiment_v2/geotext_cdf_CLAR.txt')

args <- commandArgs(trailingOnly = TRUE)
# start<-as.numeric(args[3])
# end<-as.numeric(args[4])
# filename<-args[1]
# method<-args[2]
tmptrainingfilename<-args[1]
tmptestingfilename<-args[2]
resultfile<-args[3]
resultaccfile<-args[4]
cdffile<-args[5]

act_act<-matrix(nrow = 10, ncol = 10,
  c(1130000000 ,127000000 ,455000000 ,475000000 ,1970000 ,12200000  ,170000000 ,1450000 ,237000000 ,55000000 ,
      127000000 ,2290000000  ,182000000 ,158000000 ,991000  ,54900000  ,1520000000  ,254000000 ,346000000 ,114000000,
      455000000, 182000000, 2940000000,  1730000000,  3760000, 27300000,  299000000, 55700000,  217000000, 236000000,
      475000000, 158000000, 1730000000,  3210000000,  6020000, 39000000,  291000000, 64800000,  265000000, 338000000,
      1970000, 991000, 3760000, 6020000, 401000000, 1950000, 128000000, 1180000, 3150000, 23800000,
      12200000, 54900000, 27300000, 39000000, 1950000, 63200000, 29100000, 633000, 13500000, 871000,
      170000000, 1520000000, 299000000, 291000000, 128000000, 29100000, 1280000000, 128000000, 645000000, 176000000,
      1450000, 254000000, 55700000, 64800000, 1180000, 633000, 128000000, 72200000, 22500000, 15700000,
      237000000, 346000000, 217000000, 265000000, 3150000, 13500000, 645000000, 22500000, 2380000000, 192000000,
      55000000, 114000000, 236000000, 338000000, 23800000, 871000, 176000000, 15700000, 192000000, 734000000))

#for(file_num in start:end){
  file_all<-read.table(file = sprintf("%s.txt",tmptrainingfilename),col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),quote="",sep=",",stringsAsFactors=F) ## testing data  ,stringsAsFactors=F
  testing_all<-read.table(file = sprintf("%s_SVM.txt",tmptestingfilename),col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category","NB","SVM","CLAR","NMF","NBAIM"),quote="",sep=",",stringsAsFactors=F) ## testing data  ,stringsAsFactors=F
  print(paste("file_all =",nrow(file_all), ", nrow(testing_all =",nrow(testing_all)))
  test_lon<-testing_all$lon
  file_all$ID<-as.character(file_all$ID)
  file_all$ID<-as.factor(file_all$ID)
  testing_all$ID<-as.character(testing_all$ID)
  testing_all$ID<-as.factor(testing_all$ID)

  file_all$lon<-as.numeric(data.matrix(file_all$lon))
  testing_all$lon<-as.numeric(data.matrix(testing_all$lon))

  file_all$lat<-as.numeric(data.matrix(file_all$lat))
  testing_all$lat<-as.numeric(data.matrix(testing_all$lat))
  file_all<-file_all[which(!is.na(file_all$lon)),]

  file_100<-file_all[which(file_all$Freq>=10),]
  file_all<-file_100

  testing_100<-testing_all[which(testing_all$Freq>=10),]
  testing_all<-testing_100
  print(paste("file_all =",nrow(file_all), ", nrow(testing_all) =",nrow(testing_all)))
  
  mydata<- cbind(as.numeric(file_all$lon),as.numeric(file_all$lat))
  # Determine number of clusters
  wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var),na.rm=TRUE)
  k<-1
  #wss<-0
  # centers<-NULL
  # center_num<-0
  # degree_y<-0.0008983155
  # max_y<-floor((90+90)/degree_y)
  # grid_center<-matrix(ncol=8,NA)
  #while(nrow(mydata)!=0){
    #mydata<- cbind(as.numeric(file_all$lon[which(!is.na(file_all$cluster))]),as.numeric(file_all$lat[which(!is.na(file_all$cluster))]))
c<-0
    #rm(min_k)
    #min_withinss<-min(kmeans(mydata,center = 1)$withinss) ##find the most frequent region
    for (i in 2:100){
      yy<-try(kmeans(mydata, centers=i),silent=TRUE)
      if(!(class(yy)=="try-error")[1]){
        c<-c+1
        print(c)
        wss[i] <- sum(yy$withinss)
        if(wss[i]>=min(wss[1:i-1],na.rm=TRUE)){
          k<-i
          fit<-yy
          center<-fit$centers
        }
        # k<-i
        # tmp<-kmeans(mydata,center = i)
        # if(min(tmp$withinss) < min_withinss){
        #   fit<-tmp
        #   min_withinss<-tmp
        #   min_k<-i
        #   min_point<-which(fit$withinss == min(fit$withinss))
        #   centers<-rbind(centers,fit$centers[min_point,])
        #   center_num<-center_num + 1
        #   print(paste(min_k,min_withinss))
        # }
      }
      print(i)
    }
    # k<-which(wss==min(wss))
    # fit <- kmeans(mydata, k) # k cluster solution
    # center<-fit$centers
    file_all<-cbind(file_all,fit$cluster)
    colnames(file_all)[14]<-"cluster"
    cluster_data<-lapply(1:nrow(center),function(i) data.frame())

    for(i in 1:nrow(center)){
      cluster_data[[i]]<-file_all[which(file_all$cluster==i),]
    }
    location_activity<-matrix(nrow = (length(cluster_data)),ncol = 10, 0)
    location_feature<-matrix(nrow = (length(cluster_data)),ncol = 10, 0)
    # for(i in 1:nrow(location_activity)){
    #   for(data in 1:nrow(cluster_data[[i]])){
    #     location_activity[i,cluster_data[[i]]$category[data]]<-location_activity[i,cluster_data[[i]]$category[data]] + 1
    #   }
    # }
    for(i in 1:nrow(location_feature)){
      for(data in 1:nrow(cluster_data[[i]])){
        location_feature[i,cluster_data[[i]]$category[data]]<-location_feature[i,cluster_data[[i]]$category[data]] + 1
      }
    }
    print("location_feature is ready")
    v_transpose <- chol(act_act)
    R <- factorization(location_feature,10,nrow(location_feature),10,10,20,0.002,0.02)
    U <- R$P
    W_transpose <- R$Q
    location_activity<-U %*% v_transpose
    ####
    #location_activity<-ALGO_CLAR(location_activity,location_feature,act_act)
    ####
    print("location_activity is ready")
    #### testing stage ####
    predict_act<-0
    for(i in 1:nrow(testing_all)){
      if(is.na(testing_all$lon[i])==TRUE){
        testing_all$CLAR[i]<-sample(10,1)
        next
      }
      c_n<-1
      c_dis<-distHaversine(data.matrix(testing_all[i,2:3]),center[1,])
      for(c in 1:nrow(center)){
        if(distHaversine(data.matrix(testing_all[i,2:3]),center[c,])<=c_dis){
          c_dis<-distHaversine(data.matrix(testing_all[i,2:3]),center[c,])
          c_n<-c
        }
      }
      testing_all[i,12]<-c_n
      if(length(which(location_activity[c_n,]==max(location_activity[c_n,])))!=0){
        predict_act[i]<-which(location_activity[c_n,]==max(location_activity[c_n,]))
        testing_all$CLAR[i]<-which(location_activity[c_n,]==max(location_activity[c_n,]))
        }else{
          predict_act[i]<-sample(1:10,1)
          testing_all$CLAR[i]<-sample(1:10,1)
        }
      if(i %% 1000 == 0){
        print(paste(i," is done"))
      }
    }
    testing_all$lon<-test_lon
    cdf<-CDF(testing_all$ID,testing_all$category,predict_act)
    cdf<-cdf[which(!is.na(cdf))]
    #write.table(cdf,file= cdffile,sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
    #print(cdf)
    acc<-predictive_accuracy(testing_all$category,predict_act,10)
    accuracy<-acc$accuracy
    Tguess<-acc$T_guess
    #print(Tguess)
    print(accuracy)
    #write.table(accuracy,file= resultaccfile,sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
    write.table(testing_all,file= sprintf('%s_CLAR.txt',tmptestingfilename),sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)

      




    # testing_all<-cbind(testing_all,predict_act)
    # colnames(testing_all)[17]<-"CLAR"
    # write.table(testing_all,file= sprintf('%s%s_clar.txt',tmptestingfilename,file_num),sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
    # print(paste("data saved"))

    # testing_all<-testing_all[complete.cases(testing_all[,17]),]
    
    # acc<-predictive_accuracy(testing_all$category,testing_all$CLAR,10)
    # accuracy<-acc$accuracy
    # Tguess<-acc$T_guess
    # #print(Tguess)
    # print(accuracy)
    # print(testing_all[1:5,])
    # for(i in 1:nrow(centers))
    #   for(y in 1:max_y){  ##find the stay region square
    #     if(distHaversine(centers[i,],c(centers[i,1],90-degree_y*y))<=100){
    #       grid_center[i,2]<-90-degree_y*(y+3)
    #       grid_center[i,4]<-90-degree_y*(y+3)
    #       grid_center[i,6]<-90-degree_y*(y-2)
    #       grid_center[i,8]<-90-degree_y*(y-2)
    #       for(tmp in 1:4){
    #         degree_x<-100/distHaversine(c(0, grid_center[i,2*tmp]),c(1, grid_center[i,2*tmp])) # the degree when 100 meters
    #         max_x<-floor((180+180)/degree_x)
    #         for(x in 1:max_x){
    #           if(distHaversine(c(centers[i,1],grid_center[i,2*tmp]),c((-180)+x*degree_x,grid_center[i,2*tmp]))<=100){
    #             grid_center[i,1]<-(-180)+(x-2)*degree_x
    #             grid_center[i,5]<-(-180)+(x-2)*degree_x
    #             grid_center[i,3]<-(-180)+(x+3)*degree_x
    #             grid_center[i,7]<-(-180)+(x+3)*degree_x
    #             break
    #           }
    #         }
    #       }
    #       break
    #     }
    #   }
    # #}
    # for(i in 1:nrow(file_all)){ ## assign points to the stay regoin above
    #   token<-0
    #   for(tmp in 1:nrow(grid_center)){
    #     if(as.numeric(file_all[i,2])<=grid_center[tmp,3] && 
    #          as.numeric(file_all[i,2])>=grid_center[tmp,1] &&
    #          as.numeric(file_all[i,3])<=grid_center[tmp,6] &&
    #          as.numeric(file_all[i,3])>=grid_center[tmp,2]){
    #       grid_data[[tmp]]<-rbind(grid_data[[tmp]],file_all[i,])
    #       token<-1
    #     }
    #   }
    #   if(token==0){
    #     grid_data[[tmp+1]]<-rbind(grid_data[[tmp+1]],file_all[i,])
    #   }
    # }

  # } ## end of while mydata!=0
#} ## end of files
