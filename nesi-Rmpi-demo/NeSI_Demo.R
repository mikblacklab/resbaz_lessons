setwd("~/Downloads/ResBaz2016/NeSI_Demo/")
load("ResBaz_NeSI&RmpiDemo.RData")

ls()
head(Clinical_RNASeq_BRCA)
dim(Clinical_RNASeq_BRCA)
head(Data_Matrix_BRCA_RNASeq_Voom)
dim(Data_Matrix_BRCA_RNASeq_Voom)

table(Clinical_RNASeq_BRCA$er_status_by_ihc)
ER<-ifelse(Clinical_RNASeq_BRCA$er_status_by_ihc=="Positive", 1, ifelse(Clinical_RNASeq_BRCA$er_status_by_ihc=="Negative", 0, NA))
table(ER)
boxplot(Data_Matrix_BRCA_RNASeq_Voom[1,]~ER)
t.test(Data_Matrix_BRCA_RNASeq_Voom[1,]~ER)

#Let's test all genes
len<-nrow(Data_Matrix_BRCA_RNASeq_Voom) #20501 Genes
p_vals <- cbind(rownames(Data_Matrix_BRCA_RNASeq_Voom)[1:len], rep(NA, len))
colnames(p_vals) <- c("Gene", "ER_pval")
p_vals
system.time({
  for(ii in 1:len){
    p_vals[ii,2] <- t.test(Data_Matrix_BRCA_RNASeq_Voom[ii,]~ER)$p.value
    print(ii)
  }
})
p_vals
#time = 210.253 sec (3.5 min)
##Options: Take a Coffee Break or Make it Faster

#What about more complex tasks? Longer tests, larger datasets, more combinations?

#e.g, What about gene pairs?
len<-nrow(Data_Matrix_BRCA_RNASeq_Voom)^2 #20501 Genes -> 420291001 Gene Pairs
#time = A long time
##Options: Take a very long Coffee Break  or Make it much Faster

#Let's optimise one gene test
#Another way to analyse many genes at the same time: functions
len<-nrow(Data_Matrix_BRCA_RNASeq_Voom)
p_vals <- cbind(rownames(Data_Matrix_BRCA_RNASeq_Voom)[1:len], rep(NA, len))
colnames(p_vals) <- c("Gene", "ER_pval")
system.time({
  p_vals[,2] <- lapply(as.list(1:len), function(ii){
                  print(ii)
                  return(t.test(Data_Matrix_BRCA_RNASeq_Voom[ii,]~ER)$p.value)
                  })
})
p_vals
#time = 228.948 sec (3.8min)
#Same output

#How can we make it faster? Go parallel
#Local parallel with SNOW: Simple Network of Workstations
install.packages("snow")
library("snow")
#Let's see how fast all genes are on the "cluster" - Running multiple cores within your machine.
cl <- makeSOCKcluster(3) #connect R to several cores (spawns 'slave/children' core/nodes)
#SOCK is flexible and runs on many systems (within your own machine or across a network)
len<-nrow(Data_Matrix_BRCA_RNASeq_Voom)
p_vals <- cbind(rownames(Data_Matrix_BRCA_RNASeq_Voom)[1:len], rep(NA, len))
colnames(p_vals) <- c("Gene", "ER_pval")
clusterExport(cl, list=ls()) #Send all data to each core
system.time({
  p_vals[,2] <- parLapply(cl, as.list(1:len), function(ii){
    print(ii)
    return(t.test(Data_Matrix_BRCA_RNASeq_Voom[ii,]~ER)$p.value)
  })
})
stopCluster(cl) #Ends cluster (note parLapply has returned output to the 'master/parent' core/node)
head(p_vals)
#time = 73.629 sec on 3 cores (220.887 CPU-seconds)
#Compared to 210.253 (3.5min) on single core

#Core     #Real-time    #CPU-time
#1        210.253s      210.253 cpu-sec
#2        107.078s      214.156 cpu-sec
#3         73.629s      220.887 cpu-sec
#10        .......      .......

#But I want more Cores? Yes, that's where NeSI comes in.
#They also offer "Big Memory" nodes for Genomics-scale jobs.