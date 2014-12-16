
library('TSA')
library('forecast')
library(date)
# Question: What kind of does strategy does BP use in its press releases, and can we take advantage of this through forecast/prediction?
############################ load the data 
statdata = statdata[-6,]
statdata= statdata[-which(statdata == 0),]
dates = as.date(as.character(statdata[,2]), order = 'dmy')
unique_dates = unique(dates)
unique_dates = as.date(unique_dates, order = 'dmy')
date_range = as.numeric(unique_dates[length(unique_dates)]):as.numeric(unique_dates[1])
date_range = as.date(date_range)



statdata = statdata[,1]

sentiments = c()
for(i in 1:length(unique_dates)){
  if (length(which(dates == unique_dates[i])) == 1){
    sentiments = append(sentiments,statdata[i])
  }
  else{
    index = which(dates == unique_dates[i])
    average = mean(statdata[index])
    sentiments = append(sentiments,average)
  }
}

non_distorter = mean(sentiments)
full_sent = c()
for(i in 1:length(date_range)){
  index = match(date_range[i], unique_dates)
  if (is.na(index)){
    full_sent = append(full_sent, 0)
  }
  else{
    full_sent = append(full_sent, sentiments[index])
  }
}


day = mean(full_sent[1091:1097])
day10 = c()
for (i in 1:100){
  day10 = append(day10, mean(full_sent[i:(i+10)]))
}
day10 = append(day10, day)
day10 = ts(scale(day10), freq = 30, start = c(2011,11), end = c(2014,11))
plot(day10)


############################# model fitting 

harmonicmod = lm(day10~harmonic(day10, m=1))
linmod = lm(day10~time(day10))
plot(linmod$fitted.values)
lindetrend = day10-linmod$fitted.values
plot(lindetrend)

harmonicmod = lm(lindetrend~harmonic(day10, m=1))
harmdetrend = lindetrend - harmonicmod$fitted.values

plot(harmdetrend)
hist(harmdetrend)
qqnorm(harmdetrend); qqline(harmdetrend)
qqnorm(harmonicmod$residuals); qqline(harmonicmod$residuals)
spec(harmdetrend)
acf(harmdetrend)
runs(harmdetrend)#not independent
shapiro.test(harmdetrend)#not normal
##not really anything useful


#####################
aics = c()
for(i in 0:14){
  for (j in 0:5){
    modfit = arima(day10, order = c(i, 0, j), method = 'ML')
    aics = append(aics, modfit$aic)
  }
}
harmdetrend
which(aics == min(aics))
dim(aics) = c(6,15)
min(aics)
aics
last_obs = day10[91]
last_obs
day10 = day10[-91]
last_obs
modfit = arima(day10, order = c(11,1,4))
modfit$aic


plot(day10)
plot(day10, col = 'red')
plot(harmdetrend)
lines(fitted(modfit), col = 'blue')
acf(modfit$residuals, type = 'partial', lag.max = 1000)
runs(modfit$residuals)$pvalue #independent
qqnorm(modfit$residuals);qqline(modfit$residuals)
hist(modfit$residuals)
shapiro.test(modfit$residuals) #cannot reject null that residuals are normal

plot(modfit, n1 = c(2014,1),n.ahead = 20)
modfit
predict(modfit, n.ahead=1)

########################

periodogram(day10) ; abline(h = 0)
spec(day10)# indicated the sentiment averages change slowly over time 

