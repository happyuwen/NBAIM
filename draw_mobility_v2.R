#### infer user mobility ####
data<-read.table(file = "/Users/happyuwen/Google\ 雲端硬碟/HTC_G2/Data/GeoText/experiment_v2/geotext_likelihood_both_60.txt",col.names=c("category","kde","NBAIM"),quote="",sep=",",stringsAsFactors=F) 
#data<-data[which(!is.na(data$kde)),]
data_unscale<-data
mini<-c(-98) #min(data_unscale[,2:3])
maxi<-2 #max(data_unscale[,2:3])
for(i in 1:10){
  for(j in 2:3){
    data[i,j]<-(data_unscale[i,j]-mini) / (maxi-mini)
  }
}
#data<-data[which(!is.na(data$kde)),]
data
data_unscale
# bar plot
mid<-barplot(unlist(t(data[,2:3])) ,axes=FALSE,sub="# of training check-ins = 80", ylab="Average Log-likelihood", beside=TRUE,xlab="Category", col=terrain.colors(2),xaxt="n",ylim=c(0,1))
xl<-c(2,5,8,11,14,17,20,23,26,29)
axis(1, at=xl, labels=c( "AE", "CU" ,"E", "F", "NS", "OR", "PO", "R", "SS", "TT"))
axis(2, at=c(0,0.25,0.5,0.75,1),labels=c("-98","-73","-48","-23","2"))
legend(25.5, 0.33, c("KDE","NBAIM"), cex=0.65, fill=terrain.colors(2))
grid()

## a user's check-in count
d<-c(0,0,0,0,0,0,0,0,8,3,0,0,0,0,0,0,6,4,4,0,6,0,0,0)
mid<-barplot(d,ylim=c(0,60),main="Food",xlab="Hour",ylab="Frequency")
axis(1,at=mid,labels=0:23)

