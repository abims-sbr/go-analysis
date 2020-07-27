#!/usr/bin/env Rscript

library(ggplot2)
library("optparse")
library(RColorBrewer)


option_list = list(
  make_option(c("--infile1"), type="character", default=NULL,
              help="dataset1 filename (ex: subset1.goslim_generic.count.tab)", metavar="character"),
  make_option(c("--infile2"), type="character", default=NULL,
              help="dataset2 filename (ex: global.goslim_generic.count.tab)", metavar="character"),
  make_option(c("--total1"), type="integer", default=NULL,
              help="total nbr of transcrits in dataset1", metavar="number"),
  make_option(c("--total2"), type="integer", default=NULL,
              help="total nbr of transcrits in dataset2", metavar="number"),
  make_option(c("--shortname1"), type="character", default=NULL,
              help="a shortname for infile1 (ex: subset1)", metavar="character"),
  make_option(c("--shortname2"), type="character", default=NULL,
              help="a shortname for infile2 (ex: global)", metavar="character"),
  make_option(c("--other_info"), type="character", default=NULL,
              help="other info that will be added in the output filename and in the graph title (ex: goslim_pir)", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (length(opt) > 0) {
  display=F
} else {  # if through RStudio for exemple
  setwd(wd)
  display=T
  opt=list()
  # Complete here
  opt$file1 = NULL
  opt$file2 = NULL
  opt$shortname1 = NULL
  opt$shortname2 = NULL
}

#display=T


datafilename=paste(paste0(opt$shortname1,"_vs_",opt$shortname2),gsub("[[:space:]]", "", opt$other_info),sep=".")
datatitle=paste(paste0(opt$shortname1," (red) vs ",opt$shortname2," (green-normed & white)\n"), opt$other_info,sep="")

print(datafilename)

cond1=read.table(opt$infile1); colnames(cond1) = c("GO","spacename","count")
cond2=read.table(opt$infile2); colnames(cond2) = c("GO","spacename","count")

# normalization on the number of GO in the cond1
cond2$count.ynorm=round(cond2$count*opt$total1/opt$total2)


merged=merge(cond1,cond2,by=c("GO","GO"),all=T)
#merged=merged[merged$count.x!=0 & merged$countnorm!=0,] # pour les conditions vs whole

merged$count.x[is.na(merged$count.x)]=0  # si absent de cond1
merged$count.ynorm[is.na(merged$count.ynorm)]=0  # si absent de cond2
merged$count.y[is.na(merged$count.y)]=0  # si absent de cond2
merged$spacename.y[is.na(merged$spacename.y)]=merged$spacename.x[is.na(merged$spacename.y)] # si absent de cond1

merged$chisq.obtained.x=merged$count.x
merged$chisq.obtained.y=merged$count.y-merged$count.x
merged$chisq.expected.x=merged$count.y*opt$total1/opt$total2
merged$chisq.expected.y=merged$count.y-merged$chisq.expected.x
merged$chisq.prop.x=merged$chisq.expected.x/merged$count.y
merged$chisq.prop.y=merged$chisq.expected.y/merged$count.y
head(merged)
merged$khi2_pvalue=apply(cbind(merged$chisq.obtained.x,merged$chisq.obtained.y,merged$chisq.prop.x,merged$chisq.prop.y), 1, function(x) { chisq.test(cbind(x[1],x[2]),p=cbind(x[3],x[4]))$p.value })
write.table(merged, file=paste(datafilename,"tab",sep="."))

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



