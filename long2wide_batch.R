# long2wide.R batch version 

library(tidyr)

# read lists of patients
temp1 = read.table("list_r2p", header=F) # a list of patients with raw ncs data
x1 = as.character(temp1$V1)

for (i in 1:length(x1)) {
  input_file = x1[i] # raw ncs data file
  # read input file 
  long = read.csv(input_file)
  long$side.nerve.param = paste(long$side, long$nerve, long$param, sep = ".")
  long = long[,c("side.nerve.param", "percent_value")]
  # convert long to wide format 
  wide = spread(long, side.nerve.param, percent_value)
  
  # save the wide format data
  output_file = paste(strsplit(input_file, ".", fixed=T)[[1]][1], "wide.csv", sep="_")
  pt = strsplit(input_file, "_r2p.", fixed = T)[[1]][1]
  write.csv(wide, output_file, row.names = pt)
}
