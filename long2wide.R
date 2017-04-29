# convert long format to wide format of percentage values data 

# let's get started! 
setwd("/Users/yoonhohong/Desktop/GBS_data")

# need raw data of a patient. 
input_file = "BRM_00067159_JOS_F_60_2010-03-12_r2p.csv"
long = read.csv(input_file)
long$side.nerve.param = paste(long$side, long$nerve, long$param, sep = ".")
long = long[,c("side.nerve.param", "percent_value")]

library(tidyr)
wide = spread(long, side.nerve.param, percent_value)

# save the wide format data
file.name = paste(strsplit(input_file, ".", fixed=T)[[1]][1], "wide.csv", sep="_")
write.csv(wide, file.name, row.names = F)

# the end # 
