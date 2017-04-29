# r2p.R batch version 

library(dplyr)

# read lists of patients
temp1 = read.table("list_raw", header=F) # a list of patients with raw ncs data
x1 = as.character(temp1$V1)
ref = read.csv("/Users/yoonhohong/Desktop/GBS_data/Reference/reference_ncs.csv")
ref = tbl_df(ref)

# 
for (i in 1:length(x1)) {
  input_file = x1[i] # raw ncs data file
  # read raw ncs data
  raw_ncs = read.csv(input_file)
  ht = raw_ncs$height[1]
  
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
  
  # save converted ncs data
  file.name = paste(strsplit(input_file, ".", fixed=T)[[1]][1], "r2p.csv", sep="_")
  write.csv(per_ncs, file.name, row.names = F)
}
