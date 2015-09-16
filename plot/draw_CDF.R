data<-read.table(file = "/Users/happyuwen/Google\ 雲端硬碟/HTC_G2/Data/GeoText/experiment_v2/geotext_acc.txt",col.names=c("ID","Freq","NB","SVM","NMF","CLAR","NBAIM","n"),quote="",sep=",",stringsAsFactors=F)

NB<-data$NB
SVM<-data$SVM
NMF<-data$NMF
CLAR<-data$CLAR
NBAIM<-data$NBAIM

df <- data.frame(x = c(NB, SVM, NMF, CLAR, NBAIM), ggg=factor(rep(1:5, c(length(NB),length(SVM),length(NMF),length(CLAR), length(NBAIM)))))
ggplot(df, aes(x, colour = ggg)) + xlab("Accuracy") +
  ylab("Probability") +
  stat_ecdf()+ xlim(-0.08,1) + ylim(0,1) +
  scale_colour_hue(name="GeoText", labels=c('NB', 'SVM', 'NMF', "CLAR", 'NBAIM'))