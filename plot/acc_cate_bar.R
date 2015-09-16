data<-read.table(file = "/Users/happyuwen/Google\ 雲端硬碟/HTC_G2/Data/GeoText/experiment_v2/geotext_acc_category.txt",col.names=c("AE", "CU" ,"E", "F", "NS", "OR", "PO", "R", "SS", "TT","All"),quote="",sep=",",stringsAsFactors=F) 

## bar plot
mid<-barplot(as.matrix(data)[,1:10], main="", ylab="Accuracy", beside=TRUE, col=terrain.colors(5),axes=FALSE,xlab="Category",ylim=c(0,1))
xl<-c(4,10,16,22,28,34,40,46,52,58)
#axis(1, at=xl, labels=c( "AE", "CU" ,"E", "F", "NS", "OR", "PO", "R", "SS", "TT"))
axis(2)
legend(55, 0.98, c("NB","SVM","NMF","CLAR","NBAIM"), cex=0.45, fill=terrain.colors(5))