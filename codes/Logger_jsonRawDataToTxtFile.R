require(RJSONIO)
library(jsonlite)
#SFTP server directory:
#setwd("/home/happyuwen/LoggerDataset/ex1")
file_list <- list.files("/home/happyuwen/LoggerDataset")

#setwd("D:/ADSL_yuwen/nctulog/Hardware/tmp2")
#file_list <- list.files("D:/ADSL_yuwen/nctulog/Hardware/tmp2")

##raw data to T*****.txt
countGPS<-0
countact<-matrix(nrow=1,ncol=6,0)
c<-0
for (file in file_list){
  json_data <- tryCatch({fromJSON(file)}, error = function(e) {"1"})
  if(length(json_data)!=9 || (length(json_data)==1 && json_data=="1")){
    if (file.exists(file)){ file.remove(file)}
    next 
  }
  GPS<-as.data.frame(do.call("rbind", json_data$GPS))
  if(ncol(GPS)==0){
    if (file.exists(file)){ file.remove(file)}
    next
  }
  lable<-as.data.frame(json_data$lifelable)
  n<-nrow(lable)
  u<-matrix(nrow=n,ncol=1)
  c<-c+1
  u[1:n,1]<-substr(file_list[c], 22, 36)  ##user ID
  #GPS
  if(ncol(GPS)==0){
    #time<-matrix(nrow=n,ncol=1)
    #for(i in 1:n){
    #  if(ncol(as.data.frame(json_data$Magne[i]))!=0){
    #    time[i,1]<-floor((as.data.frame(json_data$Magne[i])$time[1])/1e+3)
    #  }
    #} 
    #tt<-as.POSIXlt(time, origin="1970-01-01")
    #data<-cbind(u,time,lable,tt,tt$wday)  
  }else{
    time<-floor((GPS$time)/1e+3)[1:n]
    tt<-as.POSIXlt(time, origin="1970-01-01")
    long<-which(is.na(tt)==TRUE)[1]-1
    if(is.na(long)==TRUE){
      long<-length(tt)
    }
    tt<-tt[1:long]
    #data<-cbind(u,time,lable,tt,tt$wday)
    data1<-cbind(u[1:long],GPS$Y[1:long],GPS$X[1:long],tt$year-100,tt$mon+1,tt$mday,tt$hour,tt$min,tt$wday,lable[1:long,])
    data1<-na.omit(data1)
    l<-lable[1,1]
    for(ttmp in 1:length(tt)){
      if(!(is.na(tt[ttmp]))){
        t<-ttmp
        break
      } 
    }
    write.table(data1,file= sprintf('%s %s %s %s %s %s %s %s %s .txt',"G",u[1,1],tt[t]$year-100,tt[t]$mon+1,tt[t]$mday,tt[t]$hour,tt[t]$min,tt[t]$wday,l),sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
    countGPS<-countGPS+1
  }
  if (file.exists(file)){ file.remove(file)}
  
  #l<-lable[1,1]
  #data<- na.omit(data)
  ## count activity
  #if(lable[1,1]=="Dining"){x<-1}
  #else if(lable[1,1]=="Entertainment"){x<-2}
  #else if(lable[1,1]=="Shopping"){x<-3}
  #else if(lable[1,1]=="Sporting"){x<-4}
  #else if(lable[1,1]=="Transportation"){x<-5}
  #else if(lable[1,1]=="Working"){x<-6}
  #countact[1,x]<-countact[1,x]+1

  #for(ttmp in 1:length(tt)){
  #  if(!(is.na(tt[ttmp]))){
  #    t<-ttmp
  #    break
  #  } 
  #}
  #write.table(data,file= sprintf('%s %s %s %s %s %s %s %s %s .txt',"T",u[1,1],tt[t]$year-100,tt[t]$mon+1,tt[t]$mday,tt[t]$hour,tt[t]$min,tt[t]$wday,l),sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
  rm(file)
}