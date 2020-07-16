#!/usr/local/public/bin/Rscript
wd='/projet/fr2424/sib/lecorguille/15-01-29-Camille-Bathy-GO/tmp/bathy'

datainfile1="Croco_bathy"
datainfile2="Pop_nat_Bathy"

goslims=c("generic","pir")

display=F
#display=T

argv <- commandArgs(TRUE)
if (length(argv) > 0) {
  datainfile1 = argv[1]
  datainfile2 = argv[2]
  goslims=argv[3:length(argv)]
  display=F
} else {
  setwd(wd)
}

library(ggplot2)
library(RColorBrewer)


for (goslim in goslims) {
  infile1=paste(datainfile1,".goslim_",goslim,".count.tab",sep="")
  infile2=paste(datainfile2,".goslim_",goslim,".count.tab",sep="")

  datafilename=paste(datainfile1,"_vs_",datainfile2,".goslim_",goslim,sep="")
  datatitle=paste(datainfile1," (red) vs ",datainfile2," (green-normed & white)\nusing goslim_",goslim,sep="")

  print(datafilename)

  cond1=read.table(infile1); colnames(cond1) = c("GO","spacename","count")
  cond2=read.table(infile2); colnames(cond2) = c("GO","spacename","count")

  # normalization on the number of GO in the cond1
  cond2$count.ynorm=round(cond2$count*sum(cond1$count)/sum(cond2$count))


  merged=merge(cond1,cond2,by=c("GO","GO"),all=T)
  #merged=merged[merged$count.x!=0 & merged$countnorm!=0,] # pour les conditions vs whole

  merged$count.x[is.na(merged$count.x)]=0  # si absent de cond1
  merged$count.ynorm[is.na(merged$count.ynorm)]=0  # si absent de cond2
  merged$count.y[is.na(merged$count.y)]=0  # si absent de cond2
  merged$spacename.y[is.na(merged$spacename.y)]=merged$spacename.x[is.na(merged$spacename.y)] # si absent de cond1

  data=data.frame(
    "GO"=merged$GO,
    "spacename"=merged$spacename.y,
    "count.x"=merged$count.x,
    "count.ynorm"=-merged$count.ynorm,
    "count.y"=-merged$count.y
  )

  if (!display) pdf(file=paste(datafilename,"pdf",sep="."), width=15, height=12)
  for (spacename in unique(data$spacename)) {
    data_tmp=data[data$spacename==spacename,]


    mypalette<-brewer.pal(3,"Set1")

    gg = ggplot(data_tmp, aes(x=reorder(GO,-(count.x+count.ynorm)))) +
      geom_bar(aes(y=count.x), position="identity",stat="identity", fill=mypalette[1], colour="black") +
      geom_text(aes(y=count.x,label=count.x),vjust=-0.5, colour=mypalette[1], size=3.5) +
      facet_grid(. ~ spacename, scales = "free", space = "free") +
      theme_bw() +
      theme(axis.text.x = element_text(angle=-90, hjust=0, vjust=0.5), plot.title = element_text(vjust=1.5), axis.title.x = element_blank(), axis.title.y = element_blank(), panel.grid.major = element_line(colour = "grey")) +
      labs(title = datatitle)

    # si second condition
    if (sum(data$count.y) < 0) {
      gg = gg + geom_bar(aes(y=count.y), position="identity",stat="identity", fill="white", colour="grey")
      gg = gg + geom_bar(aes(y=count.ynorm), position="identity",stat="identity", fill=mypalette[3], colour="black")
      gg = gg + geom_text(aes(y=count.y,label=(-1*count.y)),vjust=1.5, colour="grey", size=3.5)
      gg = gg + geom_text(aes(y=count.ynorm,label=(-1*count.ynorm)),vjust=1.5, colour=mypalette[3], size=3.5)
      gg = gg + expand_limits(y = c(min(data_tmp$count.y)-1,max(data_tmp$count.x)+1))
    } else {
      gg = gg + expand_limits(y = c(0,max(data_tmp$count.x)+1))
    }

    print(gg)
  }
  if (!display) dev.off()
}



