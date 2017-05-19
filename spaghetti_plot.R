# graph; times series 

library(tidyr)
library(dplyr)
library(ggplot2)

df = read.csv("all_gbs_ncs_percent_values.csv", na.strings="NA")
colnames(df)[1] = "id"
df = separate(df, id, c("id", "date"), sep="_20")
df$date = as.Date(df$date)
df = gather(df, key, value, L.MM.CMAP1:R.UM.NCV3)
df = separate(df, key, c("side", "nerve", "param"))
df$side.nerve = paste(df$side, df$nerve, sep = ".")
# group by id 
# order by date, day 0, days
# group by side.nerve
# plot time series; CMAP1, DML, DUR1, CMAP2, DUR2, NCV1

filter(df, param == "DUR1") -> DUR1

########################################
nerve.list = unique(df$side.nerve)

ls = list()
for (i in 1:length(nerve.list)){
  filter(DUR1, side.nerve == nerve.list[i]) -> temp1
  select(temp1, id, date, side.nerve, value) -> temp2
  split(temp2, temp2$id) -> temp3
  for (j in 1:length(temp3)){
    temp3[[j]]$day = rep(0, nrow(temp3[[j]]))
    for (k in 1:nrow(temp3[[j]])){
      tp = difftime(temp3[[j]]$date[k], temp3[[j]]$date[1], "days")
      temp3[[j]]$day[k] = as.double(tp)
    }
  }
  ls[[i]] = bind_rows(temp3)
}

DUR1 = bind_rows(ls)

###########

df.DUR1 = separate(DUR1, side.nerve, c("side", "nerve"))
df.DUR1$gr = paste(df.DUR1$id, df.DUR1$side, df.DUR1$nerve, sep=".")
  
ggplot(df.DUR1, aes(day, value, col=factor(nerve), group=factor(gr))) + 
  geom_point() + 
  geom_line() + 
  scale_x_continuous(limits = c(0,30)) + scale_y_continuous(limits = c(0, 400)) + 
  facet_grid(~factor(nerve)) +
  labs(color="Nerve", title="DUR1", y="Values relative to ULN/LLN (%)", x="Days from 1st EDX study")
# 
# need at least two data points, exclude single dots...
# need two data points for which cmap amplitudes increased...
# to differentiate RCF vs. DCB... 





