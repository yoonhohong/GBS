# this is R script to analyze EDX data of GBS. 

# start with a long format which contains raw NCS data of an individual. 
# convert the raw values into the percentage values relative to upper/lower limits of normal values. 

# i will later develop a script for interpretation based on several published criteria, 
# and also graphic representations. 

# let's get started! 
setwd("/Users/yoonhohong/Desktop/GBS_data")

# need raw data of a patient. 
input_file = "BRM_00067159_JOS_F_60_2010-03-12.csv"
raw_ncs = read.csv(input_file)

# need the reference values. 
ref = read.csv("reference_ncs.csv")

# need the formula to calculate height-adjusted F-wave latency values. 
# median
# 0.183*ht-4.81+3.10
# ulnar 
# 0.202*ht-8.51+3.82
# peroneal 
# 0.323*ht-8.61+4.70
# tibial 
# 0.436*ht-27.01+6.22

ht = raw_ncs$height[1]

library(dplyr)
raw_ncs %>%
  select(side, nerve, param, value) -> raw_ncs
ref = tbl_df(ref)

ref %>%
  mutate(limit_value = ifelse(nerve == "MM" & param == "FL",
                              0.183*ht-4.81+3.10, limit_value)) -> ref
ref %>%
  mutate(limit_value = ifelse(nerve == "UM" & param == "FL",
                              0.202*ht-8.51+3.82, limit_value)) -> ref
ref %>%
  mutate(limit_value = ifelse(nerve == "PM" & param == "FL",
                              0.323*ht-8.61+4.70, limit_value)) -> ref
ref %>%
  mutate(limit_value = ifelse(nerve == "TM" & param == "FL",
                              0.436*ht-27.01+6.22, limit_value)) -> ref

# calculate percentage values relative to limit values
ref$npar = paste(ref$nerve, ref$param, sep=".")
raw_ncs$npar = paste(raw_ncs$nerve, raw_ncs$param, sep=".")
temp1 = merge(raw_ncs, ref, by="npar", all=T); temp1 = tbl_df(temp1)
temp1 %>%
  select(side, nerve.x, param.x, value, limit_value) -> temp2
colnames(temp2)[2:3] = c("nerve", "param")
temp2 %>%
  mutate(percent_value = round(value/limit_value*100)) -> per_ncs

per_ncs$nerve = factor(per_ncs$nerve, levels=c("MM","UM","PM","TM"))
o1 = order(per_ncs$side, per_ncs$nerve); per_ncs = per_ncs[o1,]

# save converted ncs data
file.name = paste(strsplit(input_file, ".", fixed=T)[[1]][1], "r2p.csv", sep="_")
write.csv(per_ncs, file.name, row.names = F)

# the end # 

