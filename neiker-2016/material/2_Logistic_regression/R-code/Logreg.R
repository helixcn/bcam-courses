### Introduction to Generalized Linear Models with R
### Dae-Jin Lee, dlee@bcamath.org
### (2015-)

### 2. Models for Binary data

###################################################
### Load libraries
###################################################
library(effects)
library(ResourceSelection)
library(Epi)


###################################################
### Health perception data
###################################################
rm(list=ls()) # Remove all previous variables
salud <- read.table("data/salud.txt",header=TRUE, dec=",")
 ## salud$g02     <- factor(salud$g02)
 salud$sexo    <- factor(salud$sexo)
 salud$con_tab <- factor(salud$con_tab)
 salud$educa   <- factor(salud$educa)
 salud$bebedor <- factor(salud$bebedor)
attach(salud)

# we can reasign the categories
levels(sexo)[1]<-"male"
levels(sexo)[2]<-"female"

##levels(g02)[1]<-"bad"  # !!!!!  It is better to keep 0 & 1 
##levels(g02)[2]<-"good" # !!!!!

levels(bebedor)[1]<-"poco/nada"
levels(bebedor)[2]<-"ocasional"
levels(bebedor)[3]<-"frecuente"



###################################################
### ftable
###################################################
ftable(list(g02,sexo,bebedor))

ftable(list(bebedor,sexo,g02))
apply(ftable(list(bebedor,sexo,g02)),1,sum)

###################################################
### logistic regression model 1
###################################################

logistic1 <- glm(g02~sexo+bebedor,family=binomial(link=logit))


summary(logistic1)


attributes(logistic1)

###################################################
### Confidence Intervals
###################################################
confint(logistic1)


###################################################
### Odds-Ratio and C.I.
###################################################
exp(coefficients(logistic1))

exp(confint(logistic1))


###################################################
###  tabulate
###################################################
table(g02,sexo)


###################################################
### dichotomous predictor
###################################################
logistica0 <- glm(g02~sexo,family=binomial(logit),data=salud)
exp(coefficients(logistica0))
exp(confint(logistica0))


###################################################
### Polytomous predictor
###################################################
# Create a new variable edad2
salud$edad2 <- salud$edad
salud$edad2[salud$edad >= 18 & salud$edad <= 29] <- 1
salud$edad2[salud$edad >= 30 & salud$edad <= 44] <- 2
salud$edad2[salud$edad >= 45 & salud$edad <= 64] <- 3

# make it factor
salud$edad2<-factor(salud$edad2)

###################################################
### logistic reg model with polytomous predictor
###################################################
logistic2=glm(g02~edad2,family=binomial(link=logit),data=salud)
exp(coefficients(logistic2))


###################################################
### logistic reg model with continous predictor
###################################################
logistic3 <- glm(g02~imc,family=binomial(link=logit))


summary(logistic3)


###################################################
### OR
###################################################
exp(coefficients(logistic3))


###################################################
### Predict values
###################################################
logit54 <- predict(logistic3,data.frame(imc=55))
logit55 <- predict(logistic3,data.frame(imc=56))

# Take the difference
logit55-logit54


###################################################
### OR change
###################################################
exp(logit55-logit54)


###################################################
### increase of c units
###################################################
c = 10
exp(logit55-logit54)^c # is equivalent to exp(c*logit55-c*logit54)


###################################################
### predict
###################################################
# if type="link" the values are the logit
fitted3 <- predict(logistic3,type="response") 

plot(imc[order(imc)],fitted3[order(imc)],t='b',
     xlab="imc", ylab="Fitted",ylim=c(0,1), main="response") # order by imc
abline(h=c(0,1),col="grey",lty=2)


###################################################
### plot fitted values
###################################################
# if type="link" the values are the logit
fitted3 <- predict(logistic3,type="link") 
plot(imc[order(imc)],fitted3[order(imc)],t='b',
     xlab="imc", ylab="Fitted", main = "logit") # order by imc


###################################################
### dichotomous and continuous predictors
###################################################
logistic4<-glm(g02~sexo,family=binomial(link=logit))
logistic5<-glm(g02~sexo+edad,family=binomial(link=logit))
coefficients(logistic4)
coefficients(logistic5)

exp(coefficients(logistic4))
exp(coefficients(logistic5))

###################################################
### plot
###################################################
  fitted5=predict(logistic5,type="response")
  plot(edad,fitted5,type="n",main="No interaction (response)",ylim =c(0,1))
  abline(h=c(0,1),col="grey", lty=2)
  points(edad[sexo=="male"],fitted5[sexo=="male"],col=2,t='p', lwd=3)
  points(edad[sexo=="female"],fitted5[sexo=="female"],col=4,t='p', lwd=3)
  legend("topright", col=c(2,4),c("male","female"), lty=1, lwd=5)


  fitted5=predict(logistic5,type="link")
  plot(edad,fitted5,type="n",main="No interaction (logit)")
  points(edad[sexo=="male"],fitted5[sexo=="male"],col=2,t='l', lwd=3)
  points(edad[sexo=="female"],fitted5[sexo=="female"],col=4,t='l', lwd=3)
  legend("topright", col=c(2,4),c("male","female"), lty=1, lwd=5)


###################################################
### compare coefficients
###################################################
coefficients(logistic5)[2]
coefficients(logistic4)[2]


###################################################
### fit model with interaction
###################################################
logistic7<-glm(g02~sexo+edad+sexo:edad,family=binomial(link=logit))
summary(logistic7)
coefficients(logistic7)

anova(logistic5,logistic7)

###################################################
### plot
###################################################
fitted7=predict(logistic7,type="link")
plot(edad,fitted5,type="n",main="without & with interaction sexo:edad")
points(edad[sexo=="male"],fitted5[sexo=="male"],col=2)
points(edad[sexo=="female"],fitted5[sexo=="female"],col=4)
points(edad[sexo=="female"],fitted7[sexo=="female"],col=3,pch=2)
legend("topright", col=c(2,4,3),pch=c(1,1,2),c("male","female", "female-interact"),cex=1.2)


###################################################
### logistic model 
###################################################
logistic8<-glm(g02~sexo+peso,family=binomial(link=logit))
summary(logistic8)


###################################################
### compare coefficients
###################################################
coefficients(logistic4)
coefficients(logistic8)


###################################################
### with interaction
###################################################
logistic9<-glm(g02~sexo+peso+sexo:peso,family=binomial(link=logit))
summary(logistic9)

###################################################
### plot
###################################################
fitted9=predict(logistic9,type="response")
plot(peso,fitted9,type="n",main="with interaction")
points(peso[sexo=="male"],fitted9[sexo=="male"],col=2)
points(peso[sexo=="female"],fitted9[sexo=="female"],col=4)
legend("bottomleft", col=c(2,4),pch=c(1,1),c("male","female"),cex=1.2)

fitted9=predict(logistic9,type="link")
plot(peso,fitted9,type="n",main="with interaction")
points(peso[sexo=="male"],fitted9[sexo=="male"],col=2)
points(peso[sexo=="female"],fitted9[sexo=="female"],col=4)
legend("bottomleft", col=c(2,4),pch=c(1,1),c("male","female"),cex=1.2)


coefficients(logistic9)


###################################################
### plot fits with C.I.
###################################################
fitted8=predict(logistic8,se.fit=TRUE,type="link")

L.inf=with(fitted8,exp(fit-1.96*se.fit)/(1+exp(fit-1.96*se.fit)))
L.sup=with(fitted8,exp(fit+1.96*se.fit)/(1+exp(fit+1.96*se.fit)))
with(fitted8,plot(peso[sexo=="male"],(exp(fit)/(1+exp(fit)))[sexo=="male"],ylim=c(0.1,1),ylab="Probability",cex=0.6))
points(peso[sexo=="male"],L.inf[sexo=="male"],col=2,cex=0.6)
points(peso[sexo=="male"],L.sup[sexo=="male"],col=2,cex=0.6)
legend("topright", c("probability","C.I."),col=c(1,2),pch=c(1,1))
abline(v=mean(peso[sexo=="male"]),col=c("red"),lwd=2,lty=1)



# probability for males with 80 kgr.
fit.males80=predict(logistic8,data.frame(sexo="male",peso=80),type="response",se.fit=TRUE)

prob.males80 <- with(fit.males80,exp(fit)/(1+exp(fit)))
prob.males80.L.inf=with(fit.males80,exp(fit-1.96*se.fit)/(1+exp(fit-1.96*se.fit)))
prob.males80.L.sup=with(fit.males80,exp(fit+1.96*se.fit)/(1+exp(fit+1.96*se.fit)))

# probability for males with 165 kgr.
fit.males165=predict(logistic8,data.frame(sexo="male",peso=165),se.fit=TRUE,type="link")

prob.males165 <- with(fit.males165,exp(fit)/(1+exp(fit)))
prob.males165.L.inf=with(fit.males165,exp(fit-1.96*se.fit)/(1+exp(fit-1.96*se.fit)))
prob.males165.L.sup=with(fit.males165,exp(fit+1.96*se.fit)/(1+exp(fit+1.96*se.fit)))

abline(v=165, col="lightblue")


###################################################
### fit model with and without bebedor predictor
###################################################
  logistic4 <- glm(formula = g02 ~ sexo, family = binomial(link = logit))
 logistic4a <- glm(formula = g02 ~ sexo + bebedor, family = binomial(link = logit))


###################################################
### LRT
###################################################
anova(logistic4,logistic4a,test="Chisq")


###################################################
### Wald test
###################################################
library(aod)
wald.test(coef(logistic4a), Sigma=vcov(logistic4a),Terms=3:4)


l <- cbind(0, 0, 1, -1)
wald.test(coef(logistic4a), Sigma=vcov(logistic4a),L=l)


###################################################
### include sexo:peso interaction
###################################################
logistic12 <- glm(formula = g02 ~ educa+edad2+sexo+peso, family = binomial(link = logit),data=salud)
logistic13 <- glm(formula = g02 ~ educa+edad2+sexo+peso+sexo:peso, family = binomial(link = logit),data=salud)


###################################################
### LRT
###################################################
anova(logistic12,logistic13,test="Chisq")


###################################################
### plot effects
###################################################
library(effects)

plot(effect("educa",logistic13,ylab="Prob(salud)"))

plot(effect("sexo*peso",logistic13,ylab="Prob(salud)"))


###################################################
###  variable selection
###################################################
mod <- glm(formula=g02~educa+edad2+bebedor+sexo*peso+anio, family = binomial(link = logit),data=salud)

library(MASS)
stepAIC(mod,trace=FALSE)$anova


###################################################
### sum of square residuals
###################################################
sum(residuals(logistic1, type = "pearson")^2)
sum(residuals(logistic1, type = "deviance")^2)


###################################################
### Hosmer-Lemeshow GoF test
###################################################
library(ResourceSelection)
g02num <- as.numeric(g02)-1 # transform to numeric 0/1
hoslem.test(g02num,fitted(logistic13))


###################################################
### ROC curve
###################################################
library(Epi)
ROC(form=g02~educa+edad2+sexo*peso, data=salud,plot="ROC",lwd=3,cex=1.5)


###################################################
### check linear assumptions
###################################################
library(mgcv)
 logistic13a <- gam(g02~educa+edad2+s(peso, by=sexo), family=binomial(logit),data=salud, method="REML")
 par(mfrow=c(1,2))
 plot(logistic13a, shade=TRUE)


summary(logistic13)

exp(logistic13$coeff)

exp(confint(logistic13))

### Automated model selection 
# See www.jstatsoft.org/v34/i12/paper

 dat <- salud[,-c(2,11)]


library(glmulti)

glmulti.logistic.out <-
    glmulti(g02 ~., data = dat,
            level = 1,               # No interaction considered
            method = "h",            # Exhaustive approach
            crit = "aic",            # AIC as criteria
            confsetsize = 5,         # Keep 5 best models
            plotty = F, report = F,  # No plot or interim reports
            fitfunction = "glm",     # glm function
            family = binomial)       # binomial family for logistic regression


## Show result for the best model
summary(glmulti.logistic.out@objects[[1]])


