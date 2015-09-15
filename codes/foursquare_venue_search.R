library("lubridate")
library("RCurl")
library("RJSONIO")
# download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")
#source("categoryall.Rda")

foursquare<-function(x,y,z,token_num){
  jj<-0
  # y is client ID, y_s is client secret
  y<-c("CX1DIMYKKFWRCSIQXNR52SRDHTZMERKGLVWORD1YFO1Q311S","YFKV15SG4V5LPFZFUZFDRZHLEJD13J0QMM12FIHV4UIFKSYJ","ELGPRGYJ0AZFDI45FZDLQDCW1QLIIJYZ1RH34XO2GQVLT3NI","2ZI2APLAGFKLLVU0PGUCUG2TQQTP52YAMERRYIKS3BQ5WMDC","4BVCHVTE5JDFVMCU2C3KZ3GZYDEBPHN5IEEI3EK1APYJYN4I","4BVCHVTE5JDFVMCU2C3KZ3GZYDEBPHN5IEEI3EK1APYJYN4I","CSSMO45DUO0XHDDHQNXUXEHQBLE1PLXWVC5Y1OHAEQWPJWUQ","T5IHIQG5NXQPKNX505TUEFMYD5NT23IR2N44HPH5EO4KHTST","SJFNHUFGGS3NPOZ4UJOLIKTSXOSVFR5GCTRY3OTW0KDL1XB0","B154DETI0STE44EZ4TEB4T5U2IEWVCETCFUXS3GRH33MWSFE","TLBIG4XDZGUBBYTGMKZQD0FUL1N5Q2PFSXH2BWRCYLUI053C","EWGALP0N5K0OPYNSQLCG1HITGSPXZYAQN3AAS0SJI1GNMVOY","SPPNURCRMTOFYPNYOOCMRCB05BPEEZ1T5PIYE1SOIX35BGTS","VXKA0CFVDSHIZR0KSVCQHNFPDFFANJHJ2G3B5430PG4X0BJT","UEMWKEYUUGJFS43AJLNZUHWUGJWEUQCZWA2SZ4N24KEWL1P0")
  y_s<-c("XASEDYZMGK3F414L030VKLL4SQHGCRTWQTBZZKZAWZUD5XJ5","SREKFMCJBROSX3PPEGMBNKIZGNW1IVDTPRQDJYKNPE2BSDK1","EL4ZSQQ32CKGFIR0VGKQNFM4RBTBQD2WREETDZLNBJX5NKAL","TWFTZNLNKC2JIMC5X2RTTTI3TWO5DO0GHPX3AQFB0SF25WKA","ALRHJBAP0A3WEQBYI5HS5TFQAKCNWE3CMJWI5KNYBVPXQ11C","ALRHJBAP0A3WEQBYI5HS5TFQAKCNWE3CMJWI5KNYBVPXQ11C","TYRNPFLS3NZMN20GKG5YDLDVATECPOORTVFG4C3U2DYVEV3T","LWQTJUF14EOXDBREPF2J2RA412SJHJ0PQYXFQQYXMBZCTJNH","G0OPR4LJ52MSPHOLQAAHN1B0KMEGCKFVKDPFCK4JRVJQYJ13","FARDUVHGGYSDJABPWUHZNYMAVR3JTPLACMQBXGWL251LPTQZ","AJDCOHFYXOPT1Z52C3WI0SQTWQ30IODYSGH2PYBQUUCTESIV","BVIH2W1HHGG4DXXGQJJ4BA4CH52ZXSIHB0RUCB3FUFR0JA03","CG45HVV2FWQBP3D5O3K3SCXYSUV3UOZT2OKLUJUSEANORQIP","2F1KLFXDT2S00MXZLGFVZIL2NVBDHMNUM2MKGVZH0FBWNTOJ","1GOEWTO0VYSXGGIURSWBLNXAURKLKUFXDWIHYOXQL1RJ1BVX")
  #token: my, ziyi, mom, kevin
  w<-paste("https://api.foursquare.com/v2/venues/search?ll=",x,"&client_id=",y[token_num],"&client_secret=",y_s[token_num],"&v=",z,sep="")
  u<-getURL(w,cainfo=system.file("CurlSSL", "cacert.pem", package = "RCurl"))#system.file("CurlSSL", "cacert.pem", package = "RCurl")
  test<-fromJSON(u)
  tmp<-0
  tmp<-tryCatch(test<-fromJSON(u),
      error=function(e){"1"},silent=TRUE
    )
  while(length(tmp)==1){
    tmp<-tryCatch(test<-fromJSON(u),
      error=function(e){"1"},silent=TRUE
    )
  }
  ## or fromJSON(u)
  ## find authentic token
  # y<-c("VR4YUTFZTYIHPTDQD54Z2AMKWPNWMUZ5SZEDHHB22SYGWYIE",
  #      "XBB33GTETUSX1M2QXIEKLX2O2OWI4DFNCEHKZDVYRNW2C0UZ",
  #      "HHCU4LYMILIJW0PXDEYILXCPDBA15FOXWZ5DRUB50DTP5MI5",
  #      "VFSKHIG1J2GTLR40GGTFYZNA2CDNFA23ZIN23OK0AWMAHECR",
  #      "HSRBLQTVU0C3FEBPH1PK1XQZHZ2SYVZCSAIC2RWFSR5XNHHQ") #last brother's
  # if(length(test)==2){
  #     # w<-paste("https://api.foursquare.com/v2/venues/search?ll=",x,"&client_id=",y,"&client_secret=XASEDYZMGK3F414L030VKLL4SQHGCRTWQTBZZKZAWZUD5XJ5",,"&v=",z,sep="")
  #     # u<-getURL(w,cainfo="cacert.pem")
  #     return(NA)
  # }
  ##find the first one as mini base
  dis<-0
  pp<-0
  if(length(test$response$venues)!=0){
    for(bb in 1:length(test$response$venues)){
      if(length(test$response$venues[[bb]]$categories)!=0){
        dis<-test$response$venues[[bb]]$location$distance
        pp<-1
        break
      }
    }
  }
  # if(pp==0){
  #   actTag<-"Professional & Other Places"
  #   return(actTag)
  # }
  if(length(test$response$venues)==0 || dis==0){
    actTag<-"Professional & Other Places"
    return(actTag)
  }
  mini<-bb
  for(f in bb:length(test$response$venues)){
    tmp<-0
    tmp<-tryCatch(test$response$venues[[f]]$location$distance,
      error=function(e){"1"},silent=TRUE
    )
    if(tmp==1){
      loc<-which(names(test$response$venues[[f]]$location)=="distance")
      if(as.numeric(test$response$venues[[f]]$location[loc])<dis && (length(test$response$venues[[f]]$categories)!=0)){
        dis<-test$response$venues[[f]]$location[loc]
        mini<-f
      }
      next
    }
    if(test$response$venues[[f]]$location$distance<dis && (length(test$response$venues[[f]]$categories)!=0)){
      dis<-test$response$venues[[f]]$location$distance
      mini<-f
    }
  }
  #if(mini==0){
  #  actTag<-"Other Places"
  #}else{
    actTag<-test$response$venues[[mini]]$categories[[1]]$pluralName
  #}
  jj<-1
  return(actTag)
}

refind<-function(place,actTag){
  for(tmp1 in 1:length(place)){
    if(place[[tmp1]]$pluralName==actTag){
      return(TRUE)
    }
  }
  return(FALSE)
}

sqtype<-c("Arts & Entertainment","Colleges & Universities","Events","Food","Nightlife Spots","Outdoors & Recreation","Professional & Other Places","Residences","Shops & Services","Travel & Transport")
categories<-function(actTag){
  place<-testc$response$categories
  if(refind(place,actTag)==TRUE){
    act<-actTag
    datatype<-which(sqtype[]==act)
    return(datatype)
  } ## find the first class
  ## find the second class
  for(m1 in 1:length(testc$response$categories)){
    if(length(which(names(testc$response$categories[[m1]])=="categories"))!=0){
      place<-testc$response$categories[[m1]]$categories
      if(refind(place,actTag)==TRUE){
        act<-testc$response$categories[[m1]]$pluralName
        datatype<-which(sqtype[]==act)
        return(datatype)
      }
    } 
  }
  ## find the third class(the final one)
  for(m1 in 1:length(testc$response$categories)){
    if(length(which(names(testc$response$categories[[m1]])=="categories"))!=0){
      for(m2 in 1:length(testc$response$categories[[m1]]$categories)){
        if(length(testc$response$categories[[m1]]$categories[[m2]]$categories)!=0){
          place<-testc$response$categories[[m1]]$categories[[m2]]$categories
          if(refind(place,actTag)==TRUE){
            act<-testc$response$categories[[m1]]$pluralName
            datatype<-which(sqtype[]==act)
            return(datatype)
          }
        }
      }
    } 
  }
  if(length(grep("Restaurant",actTag))>=1){
    datatype<-4
    return(datatype)
  }
}