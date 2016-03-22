### Variability in Semiconductor Manufacturing

library(nlme)
library(lattice)
data(Oxide)
?Oxide

xyplot(Lot~Thickness,group=Wafer,auto.key=TRUE,pch=Oxide$Site,data=Oxide)
xtabs(~ Lot + Wafer, Oxide)

formula(Oxide) # grouping formula already defined

## ------------------------------------------------------------------------
fm1Oxide <- lme(Thickness~1,Oxide) 
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

fm3Oxide <- lme(Thickness~Site+Source,Oxide,random=~1|Lot/Wafer,data=Oxide)

 plot(fm3Oxide) # check resids vs fitted values
 qqnorm(residuals(fm3Oxide)) # check resids for normality
 abline(0,sd(resid(fm3Oxide)))
 qqnorm(fm3Oxide,~ranef(.,level=1))
 qqnorm(fm3Oxide,~ranef(.,level=2))

 fm4Oxide <- lme(Thickness~Site+Source,Oxide,random=~1|Lot)
 

 anova(fm3Oxide,fm4Oxide) # Reject H0
 anova(fm3Oxide) # no evidence of Site or Source Effects
 
 intervals(fm3Oxide)


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

#
fm1Machine <- lme(score ~ Machine, data=Machines,random= ~1|Worker)
fm1Machine
anova(fm1Machine)
anova(fm1Machine,L=c("MachineB"=1,"MachineC"=-1))

fm0Machine <- lm(score~Machine,data=Machines)

library(RLRsim)
exactLRT(update(fm1Machine,method="ML"),fm0Machine)

#
fm2Machine <- update(fm1Machine,random= ~1|Worker/Machine)

fm2Machine

anova(fm2Machine,L=c("MachineB"=1,"MachineC"=-1))

#
anova(fm1Machine,fm2Machine)

#
intervals(fm2Machine)


### Soy bean data
library(nlme)
library(lattice)
data(Soybean)
?Soybean

## ------------------------------------------------------------------------
Soy <- Soybean 
Soy$logweight <- log(Soy$weight)
xyplot(logweight ~ Time, Soy, groups = Plot, type = c('g','l','b')) # Spaghetti plot

## ------------------------------------------------------------------------
g0 <- lme(logweight ~ Year + Variety + Time + I(Time^2),random = list(Plot = ~ 1), data = Soy, method = "REML") 
g1 <- lme(logweight ~ Year + Variety + Time + I(Time^2),random = list(Plot = ~ 1 + Time), data = Soy, method = "REML") 
g2 <- lme(logweight ~ Year + Variety + Time + I(Time^2),random = list(Plot = pdDiag(~ 1 + Time)),data=Soy,method="REML")

g3 <- lme(logweight ~ Year * Variety + Time + I(Time^2),random = list(Plot = ~ 1 + Time), data = Soy, method = "REML") 

summary(g3)

# or g1 <- lme(logweight ~ Year + Variety + Time + I(Time^2),random =  ~ 1 + Time|Plot, data = Soy, method = "REML") 
summary(g1)
xyplot(fitted(g1) ~ Time, Soy, groups = Plot, type = c('g','l','b')) # Spaghetti plot

anova(g1,g2)


### Pig weights data

library(SemiPar)
data(pig.weights)
library(lattice)
xyplot(weight~num.weeks,data=pig.weights,groups=id.num,type=c("g","l"))
head(pig.weights)

# Questions:
library(nlme)
m1 <- lme(weight~num.weeks,random=~1|id.num,data=pig.weights)
library(lme4)
 
print(xyplot(weight ~ num.weeks, groups = id.num, data = pig.weights,type = "l", col = 1))
 
# same model
 pig.mm1 <- lmer(weight ~ num.weeks+(1+num.weeks|id.num),data=pig.weights)
 pig.mm0 <- lme(weight ~ num.weeks,random= ~1+num.weeks|id.num,data=pig.weights)
 
 summary(pig.mm1)
 summary(pig.mm0)
 
 library(lattice)
 library(latticeExtra)
 library(fields)
 attach(pig.weights)
 
 a <- xyplot(weight ~ num.weeks,groups=id.num,lwd=1,pch=19,
 			data=pig.weights,main="Pig weights",cex=.35)
 
 b <- xyplot(fitted(pig.mm1) ~ num.weeks,groups=id.num,lwd=1,pch=19,data=pig.weights,main="Pig weights",cex=.35,type=c("b","g"))
 
 a + as.layer(b)

### Titanic data

train <- read.csv('extra-data/titanic_train.csv',header=TRUE,row.names=1)
 test <- read.csv('extra-data/titanic_test.csv',header=TRUE,row.names=1)


 model <- glm(Survived ~.,family=binomial(link='logit'),data=train)
 summary(model)
 
 anova(model, test="Chisq")
## 
 mod1 <- glm(Survived ~ as.factor(Pclass), family=binomial, data=train)
 summary(mod1)
 anova(mod1,test="Chisq")

## # interaction effect between passenger class and sex, as passenger class showed a much bigger difference in survival rate amongst the women compared to the men (i.e. Higher class women were much more likely to survive than lower class women, whereas first class Men were more likely to survive than 2nd or 3rd class men, but not by the same margin as amongst the women).
 mod2 <- glm(Survived ~ Pclass + Sex  + Age + SibSp, family = binomial(logit), data = train)
 summary(mod2)
 anova(mod2,test="Chisq")
## 
 mod3 <-  glm(Survived ~ Pclass + Sex + Pclass:Sex + Age + SibSp, family = binomial(logit), data = train)
 summary(mod3)
 anova(mod3,test="Chisq")
## 
## 
 # In the steps above, we briefly evaluated the fitting of the model, now we would like to see how the model is doing when predicting y on a new set of data. By setting the parameter type='response', R will output probabilities in the form of P(y=1|X). Our decision boundary will be 0.5. If P(y=1|X) > 0.5 then y = 1 otherwise y=0. Note that for some applications different decision boundaries could be a better option.
## 
 fitted.results <- predict(mod3,newdata=test,type='response')
 fitted.results <- ifelse(fitted.results > 0.5,1,0)
## 
 misClasificError <- mean(fitted.results != test$Survived)
 print(paste('Accuracy',1-misClasificError))
## 
 # The 0.8075 accuracy on the test set is quite a good result. However, keep in mind that this result is somewhat dependent on the manual split of the data that I made earlier, therefore if you wish for a more precise score, you would be better off running some kind of cross validation such as k-fold cross validation.
## 
 # Evaluate predictive performance
 
 
 library(ROCR)
 p <- predict(mod3, newdata=subset(test,select=c(2,3,4,5,6,7,8)), type="response")
 pr <- prediction(p, test$Survived)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
 plot(prf)
## 
 auc <- performance(pr, measure = "auc")
 auc <- auc@y.values[[1]]
 auc


