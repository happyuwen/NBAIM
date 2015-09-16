data<-read.table(file = "/Users/happyuwen/Google\ 雲端硬碟/HTC_G2/Data/GeoText/experiment_v2/geotext_acc.txt",col.names=c("ID","Freq","NB","SVM","NMF","CLAR","NBAIM","n"),quote="",sep=",",stringsAsFactors=F)

## plot n FREQ
plot(data$Freq,data$n,xlab = "# of training check-ins", ylab = "Average time slot length" , xlim=c(20,100),ylim=c(1,4))
freq<-c(25,50,75,100,125)
avg<-NULL
sdev<-NULL
name_x<-NULL
for(i in 1:5){ # for GeoText
  avg[i]<-mean(data$n[which(data$Freq==freq[i])],na.rm=TRUE)
  sdev[i]<-sd(data$n[which(data$Freq==freq[i])],na.rm=TRUE)
  name_x<-c(name_x,paste(freq[i]))
}
sdev[which(is.na(sdev))]<-0
x<-c(20,40,60,80,100)
plot(1:5, avg,ylim=c(0, 4),
     pch=19, xlab="# of training Check-ins", ylab="Average Time slot Length (hour)",
     main="",axes=FALSE)# for geotext
axis(1,at=1:5,labels=x)
name_y<-0:4
axis(2,at=0:4,labels=name_y)
# hack: we draw arrows but with very special "arrowheads"
arrows(1:length(freq), avg-sdev, 1:length(freq), avg+sdev, length=0.05, angle=90, code=3)