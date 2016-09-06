### Variability in Semiconductor Manufacturing

library(nlme)
library(lattice)
data(Oxide)
?Oxide

xyplot(Lot~Thickness,group=Wafer,auto.key=TRUE,pch=Oxide$Site,data=Oxide)
xtabs(~ Lot + Wafer, Oxide)

formula(Oxide) # grouping formula already defined

## ------------------------------------------------------------------------
fm1Oxide <- lme(Thickness~1,random=~1|Lot/Wafer,Oxide) 
fm1Oxide

## ------------------------------------------------------------------------
intervals(fm1Oxide,which="var-cov")

## ------------------------------------------------------------------------
fm2Oxide <- update(fm1Oxide, random = ~1|Lot)
anova(fm1Oxide,fm2Oxide)

## 
coef(fm1Oxide,level=1) # Estimated average oxide layer thickness by lot
## 
coef(fm1Oxide,level=2) # Estimated average oxide layer thickness per Wafer

ranef(fm1Oxide,level=1:2)


# Questions:

# ??



fm3Oxide <- lme(Thickness~Site+Source,random=~1|Lot/Wafer,data=Oxide)

summary(fm3Oxide)

fm4Oxide <- lme(Thickness~Site+Source,random=~1|Lot,data=Oxide)

anova(fm3Oxide,fm4Oxide)




### Productivity Scores for Machines and Workers

library(nlme)
data(Machines)
head(Machines)
?Machines

## 
plot(Machines)

## 
with(Machines,
interaction.plot(Machine,Worker,score,las=1,lwd=1.4,col=1:6)
)

# Questions

#??

fm1Machine <- lme(score ~ Machine,random=~1|Worker,data=Machines)

summary(fm1Machine)


### Soy bean data
library(nlme)
library(lattice)
data(Soybean)
?Soybean




Soy <- Soybean 
xyplot(weight ~ Time, Soy, groups = Plot, type = c('g','l','b'))

head(Soy)

Soy$logweight <- log(Soy$weight)
xyplot(logweight ~ Time, Soy, groups = Plot, type = c('g','l','b')) # Spaghetti plot


xyplot(logweight ~ Time|Year, Soy, groups = Plot, type = c('g','l','b')) # Spaghetti plot

xyplot(fitted(g1) ~ Time|Year+Variety, Soy, groups = Plot, type = c('g','l','b')) # Spaghetti plot



### Pig weights data

library(SemiPar)
data(pig.weights)
library(lattice)
xyplot(weight~num.weeks,data=pig.weights,groups=id.num,type=c("g","l"))
head(pig.weights)

# Questions:
# ??

### Titanic data

train <- read.csv('extra-data/titanic_train.csv',header=TRUE,row.names=1)
 test <- read.csv('extra-data/titanic_test.csv',header=TRUE,row.names=1)



