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

#Testing multiple genes
len<-50
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
#time = 0.500 sec

#What about all genes?
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
##Options: Take a Coffee Break  or Make it Faster

#What about more complex tasks? Longer tests, larger datasets, more combinations?

#e.g, What about gene pairs?
len<-nrow(Data_Matrix_BRCA_RNASeq_Voom) #20501 Genes -> 420291001 Gene Pairs
p_vals_prep <- cbind(rownames(Data_Matrix_BRCA_RNASeq_Voom)[1:len], rep(NA, len))
p_vals <- matrix(NA, 3, len^2)
for(ii in 1:len){
  p_vals[seq(ii,len^2,len),2]<-rownames(Data_Matrix_BRCA_RNASeq_Voom)[ii]
  p_vals[(ii-1)*len+c(1:len), 1]<-rownames(Data_Matrix_BRCA_RNASeq_Voom)[ii]
} 
colnames(p_vals) <- c("Gene", "ER_pval")
p_vals
system.time({
  for(ii in 1:len){
    for(jj in 1:len){
      p_vals[ii,jj,2] <- t.test(Data_Matrix_BRCA_RNASeq_Voom[ii,]*Data_Matrix_BRCA_RNASeq_Voom[jj,]~ER)$p.value
      print(jj)
    }
    print(ii)
  }
})
p_vals
#time = A long time
##Options: Take a Coffee Break  or Make it Faster

#Let's optimise one gene test
#Another way to analyse many genes at the same time: functions
len<-50
p_vals <- cbind(rownames(Data_Matrix_BRCA_RNASeq_Voom)[1:len], rep(NA, len))
colnames(p_vals) <- c("Gene", "ER_pval")
p_vals
system.time({
  p_vals[,2] <- lapply(as.list(1:len), function(ii){
                  print(ii)
                  return(t.test(Data_Matrix_BRCA_RNASeq_Voom[ii,]~ER)$p.value)
                  })
})
p_vals
#time = 0.496 sec
#Same output, slight increase in speed may help if doing many operations

#How can we make it faster? Go parallel
#Local parallel with SNOW: Simple Network of Workstations
install.packages("snow")
library("snow")
cl <- makeSOCKcluster(3) #connect R to several cores (spawns 'slave/children' core/nodes)
#SOCK is flexible and runs on many systems (within your own machine or across a network)
len<-50
p_vals <- cbind(rownames(Data_Matrix_BRCA_RNASeq_Voom)[1:len], rep(NA, len))
colnames(p_vals) <- c("Gene", "ER_pval")
p_vals
clusterExport(cl, list=ls()) #Send all data to each core
system.time({
  p_vals[,2] <- parLapply(cl, as.list(1:len), function(ii){
    print(ii)
    return(t.test(Data_Matrix_BRCA_RNASeq_Voom[ii,]~ER)$p.value)
  })
})
stopCluster(cl) #Ends cluster (note parLapply has returned output to the 'master/parent' core/node)
p_vals
#time = 0.181 sec on 3 cores (0.543 CPU-seconds)
#Same output, substantial increase in speed will help if doing many operations
#Note diminishing returns, communication time between cores, more cores != always faster

#Core     #Real-time    #CPU-time
#1         0.500         0.500
#2         0.258         0.516
#3         0.181         0.542
#4         0.139         0.556    (use all cores on machine at own risk - may mess with GUI/etc)

#Let's see how fast all genes are on the cluster
cl <- makeSOCKcluster(3) #connect R to several cores (spawns 'slave/children' core/nodes)
#SOCK is flexible and runs on many systems (within your own machine or across a network)
len<-nrow(Data_Matrix_BRCA_RNASeq_Voom)
p_vals <- cbind(rownames(Data_Matrix_BRCA_RNASeq_Voom)[1:len], rep(NA, len))
colnames(p_vals) <- c("Gene", "ER_pval")
p_vals
clusterExport(cl, list=ls()) #Send all data to each core
system.time({
  p_vals[,2] <- parLapply(cl, as.list(1:len), function(ii){
    print(ii)
    return(t.test(Data_Matrix_BRCA_RNASeq_Voom[ii,]~ER)$p.value)
  })
})
stopCluster(cl) #Ends cluster (note parLapply has returned output to the 'master/parent' core/node)
p_vals
#time = 73.629 sec on 3 cores (220.887 CPU-seconds)
#Compared to 210.253 (3.5min) on single core

#But I want more Cores? Yes, that's where NeSI comes in.