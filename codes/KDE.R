library("MKLE")
KDE<-function(traindata,testdata){
  #traindata<-file_all[,2:3]
  traindata<-traindata[which(is.na(data.matrix(traindata[,2]))==FALSE),]
  traindata<-traindata[which(is.na(data.matrix(traindata[,1]))==FALSE),]
  #testdata<-testing_all[,2:3]
  testdata<-testdata[which(is.na(data.matrix(testdata[,2]))==FALSE),]
  testdata<-testdata[which(is.na(data.matrix(testdata[,1]))==FALSE),]
  kdensity<-density(data.matrix(traindata))
  min<-c(kdensity$x[1])
  grid<-c(kdensity$x[2]-min)

  # finds the kernel log likelihood at the sample mean
  # for(i in -10:10){
  #   print(klik(i,data.matrix(testdata), kdensity, grid, min))
  # }
  like<-klik(0,data.matrix(testdata), kdensity, grid, min)
  return(like)
}