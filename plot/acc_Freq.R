data<-read.table(file = "/Users/happyuwen/Google\ 雲端硬碟/HTC_G2/Data/GeoText/experiment_v2/geotext_acc.txt",col.names=c("ID","Freq","NB","SVM","NMF","CLAR","NBAIM","n"),quote="",sep=",",stringsAsFactors=F)

## plot acc_category_baseline
data<-read.table(file = "/Users/happyuwen/Google\ 雲端硬碟/HTC_G2/Data/GeoText/experiment_v2/geotext_acc_trainingSize.txt",quote="",sep=",",stringsAsFactors=F) 
plot(range(1:12), range(0:1), type="n", xlab="# of training check-ins",ylab="Accuracy" ,axes=FALSE) 
nlines<-5
colors <- rainbow(6)[c(1,3,4,5,6)] 
linetype <- c(1,3,5,6,7) 
plotchar <- seq(18,18+nlines,1)
# add lines 
for (i in 1:nlines) { 
  lines(1:10, data[1:10,i], type="o", lwd=1.5,
        lty=linetype[i], col=colors[i], pch=plotchar[i]) 
} 
axis(1, at=1:10, labels=c( "10", "20" ,"30", "40", "50", "60", "70", "80", "90", "100"))
axis(2)
# add a title and subtitle 
#title("Tree Growth", "example of line plot")
# add a legend 
legend(10.5,0.95, c("NB","SVM","NMF","CLAR","NBAIM"), cex=0.7, col=colors,pch=plotchar,lty=linetype)
grid()