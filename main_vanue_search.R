source("foursquare_venue_search.R")
#source("categoryall.Rda")
library("lubridate")
library("RCurl")
#remove.packages("RCurl")
#install.packages("RCurl")
#install.packages("RJSONIO")
library("RJSONIO")
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")
# need to input "filename", run from "where" to the end, "client num"
# Rscript main_vanue_search.R "/home/happyuwen/Gowalla/gowalla_v3/catch_category/gowalla_cate1.txt" 1 1


# ## seperate raw data into 10 subfile
# num<-floor(nrow(file)/10)
# filen<-list()
# for(i in 0:9){
#   filen[[i]]<-file[(i*num+1):((i+1)*num),]
# }

# "D:/ADSL_yuwen/nctulog/gowalla"
# file1<-read.table("D:/ADSL_yuwen/nctulog/gowalla/gowalla_100sort_file1.txt",col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),sep=",",stringsAsFactors = F,fill=TRUE,quote="")
# file2<-read.table("D:/ADSL_yuwen/nctulog/gowalla/gowalla_100sort_file2.txt",col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),sep=",",stringsAsFactors = F,fill=TRUE,quote="")
# file3<-read.table("D:/ADSL_yuwen/nctulog/gowalla/gowalla_100sort_file3.txt",col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),sep=",",stringsAsFactors = F,fill=TRUE,quote="")
# file4<-read.table("D:/ADSL_yuwen/nctulog/gowalla/gowalla_100sort_file4.txt",col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),sep=",",stringsAsFactors = F,fill=TRUE,quote="")

# file1<-read.table("/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_100sort_file1.txt",col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),sep=",",stringsAsFactors = F,fill=TRUE,quote="")
# file2<-read.table("/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_100sort_file2.txt",col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),sep=",",stringsAsFactors = F,fill=TRUE,quote="")
# file3<-read.table("/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_100sort_file3.txt",col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),sep=",",stringsAsFactors = F,fill=TRUE,quote="")
# file4<-read.table("/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_100sort_file4.txt",col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),sep=",",stringsAsFactors = F,fill=TRUE,quote="")

# not_yet<-NULL
# yet<-NULL

# targetFile<-file4
# which(is.na(targetFile$category)==TRUE)[1:10]
# n<-which(is.na(targetFile$category)==TRUE)
# #which(is.na(targetFile$category)==TRUE)[length(n)-]

# not_yet<-rbind(not_yet,targetFile[n,])
# yet<-rbind(yet,targetFile[-n,])

# nrow(not_yet)+nrow(yet)

# write.table(not_yet,file="D:/ADSL_yuwen/nctulog/gowalla/gowalla_notyet.txt" ,sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)

# ## seperate raw data into 15 subfile and write table
# num<-(nrow(file)/15) #2132199
# filen<-list()
# for(i in 1:15){
#   filen[[i]]<-file[floor((i-1)*num+1):floor(i*num),]
# }
# n<-0
# for(i in 1:15){
#   n<-n+nrow(filen[[i]])
# }
# n
# for(i in 1:length(filen)){
#   filename<-sprintf("/home/happyuwen/Gowalla/gowalla_v3/catch_category/gowalla_cate%s.txt",i)
#   write.table(filen[[i]],file=filename ,sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
# }

# input row data
args <- commandArgs(trailingOnly = TRUE)
# rnorm(n=as.numeric(args[1]), mean=as.numeric(args[2]))

#args<-c("/home/happyuwen/Gowalla/gowalla_v3/catch_category/gowalla_cate15.txt" ,1, 15)
tempfile<-args[1] # tempfile<-"/home/happyuwen/Gowalla/gowalla_100_sorted/gowalla_file1.txt"
start<-as.numeric(args[2])
token_num<-as.numeric(args[3])

# load data 
file<-read.table(tempfile,col.names=c("ID","lon","lat","year","month","date","hour","min","day","act","datatype","Freq","category"),quote="",sep=",",stringsAsFactors=F) # those with GPS data  ,stringsAsFactors=F
file<-file[order(file$lon,file$lat),]


z<-"20150906"
y<-0
#### map 10 categories to 6 activities ####
sq<-c(1,2,3,4,5,6,7,8,9,10)
actn<-c(2,6,6,1,2,4,6,2,3,5)
#v<-getURL("https://api.foursquare.com/v2/venues/categories?oauth_token=HHCU4LYMILIJW0PXDEYILXCPDBA15FOXWZ5DRUB50DTP5MI5&v=20150629",cainfo="cacert.pem") ## my token
v<-getURL("https://api.foursquare.com/v2/venues/categories?oauth_token=HHCU4LYMILIJW0PXDEYILXCPDBA15FOXWZ5DRUB50DTP5MI5&v=20150629",cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")) 
testc<-fromJSON(v)

jj<-1
for(i in start:nrow(file)){ #nrow(file) 138545
  if(is.na(file$act[i])!=TRUE){
  	next
  }
  #print(i)
  if(i==1){
  	x<-paste(file$lat[i],file$lon[i],sep=",")
  	print(x)
    file[i,10]<-foursquare(x,y,z,token_num)
    if(is.na(file[i,10])!=TRUE){
      file[i,13]<-categories(file[i,10])
      file$datatype[i]<-actn[which(file$category[i]==sq)]
    }
    ll<-0
    print("The first one is done!")
    next
  }
  if(file[i,2]==file[i-1,2] && file[i,3]==file[i-1,3]){
    #tmp<-paste(file$year[i],file$month[i],sep="-")
    #tmp<-paste(tmp,file$date[i],sep="-")
    #file[i,9]<-wday(as.Date(tmp,'%Y-%m-%d'))-1
    file[i,13]<-file[i-1,13]
    file[i,10]<-file[i-1,10]
    file[i,11]<-file[i-1,11]
    if((i%%1000)==0){
      write.table(file,file=tempfile ,sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
      print(file$act[i])
      print(paste(i,"   ", "file saved"))
    } # D:/ADSL_yuwen/nctulog/GEOall_v19nasorted.txt
    next
  }
  ll<-1
  while(jj==1 && ll==1){
    #tmp<-paste(file$year[i],file$month[i],sep="-")
    #tmp<-paste(tmp,file$date[i],sep="-")
    #file[i,9]<-wday(as.Date(tmp,'%Y-%m-%d'))-1
    x<-paste(file$lat[i],file$lon[i],sep=",")
    tmp<-0
    tmp<-tryCatch(file[i,10]<-foursquare(x,y,z,token_num),
      error=function(e){"1"},silent=TRUE
    )
    #print(tmp)
    while(tmp==1){
      next
    }
    file[i,10]<-foursquare(x,y,z,token_num)
    print(file[i,10])
    print(i)
    if(is.na(file[i,10])!=TRUE){
      tmp<-0
      tmp<-tryCatch(categories(file[i,10]),
        error=function(e){"1"},silent=TRUE
      )
      #print(tmp)
      while(is.null(tmp)){
        next
      }
      file[i,13]<-categories(file[i,10])
      if(is.na(file[i,13])){
        next
      }
      file$datatype[i]<-actn[which(file$category[i]==sq)]
    }
    ll<-0
  }
  #print(paste(i, "  ,total file =  ", nrow(file)," ,",file$act[i]," ,",file$datatype[i]))
  #print(file[i,-1])
  if((i%%1000)==0){
    write.table(file,file= tempfile,sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
          print(file$act[i])
    print(paste(i,"   ", "file saved"))
  } # D:/ADSL_yuwen/nctulog/GEOall_v19nasorted.txt
}
write.table(file,file= tempfile,sep = ",", col.names = FALSE,row.names = FALSE,quote = FALSE)
print("finish")
