# --------------------------------------------
# R basics
#  www.idaejin.github.io/bcam-courses/
# --------------------------------------------

### Exercises 
# Ex 1. Load VADeaths data set
VADeaths

## Compute row means
apply(VADeaths,1,mean)

## Compute column means
apply(VADeaths,2,mean)

# Ex 2. Load rainforest data
library(DAAG)
rainforest

## Tabulate and barplot
table(rainforest$species)
barplot(table(rainforest$species))

# Ex 3. Create a subset of a data frame
Acmena <- subset(rainforest, species == "Acmena smithii")

## plotting
par(mfrow=c(1,2))
plot(wood~dbh,data=Acmena,pch=19, main="plot of dbh vs wood")
plot(log(wood)~log(dbh),data=Acmena,pch=19,main="log transformation")

## Histogram
hist(Acmena$dbh)

## Ex 4. Create a vector of the positive odd integers less than 100 and remove the values greater than 60 and less than 80.
  x <- seq(1,100,by=2)
  x[x>60 & x<80]

