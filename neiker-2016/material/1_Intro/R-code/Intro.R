### Introduction to Generalized Linear Models with R
### Dae-Jin Lee, dlee@bcamath.org 
### (2015-)

### 1. Introduction to Generalized Linear Models

###################################################
### Load Libraries
###################################################
library(effects)
library(ResourceSelection)
library(Epi)

###################################################
### Simulate some data 
###################################################
set.seed(1234)
n <- 50 

x <- seq(1,n)  # creates a sequence from 1 to n

 beta0 <- 15
 beta1 <- 0.5

sigma <- 3 # standard deviation of the errors
eps <- rnorm(n,mean=0,sd=3) # generate gaussian random errors

# Generate random data
 y <- beta0 + beta1*x  +  eps

###################################################
### Plot
###################################################
plot(x,y,ylim = c(8,45), cex=1.3, xlab = "x", ylab="y",pch=19)
# correlation between x and y
cor(x,y)


###################################################
### Linear regression fit
###################################################
# Using lm()

lin.mod <- lm(y~x)
lin.mod
coefficients(lin.mod)


###################################################
### summary()
###################################################
summary(lin.mod)
names(summary(lin.mod))

summary(lin.mod)$sigma
summary(lin.mod)$r.squared

###################################################
### plot fitted lm
###################################################
plot(x,y)
abline(lin.mod,lwd=2,col="red")



###################################################
### Predict, CI's, residuals, and Deviance
###################################################
# fitted values
 y.hat <- fitted(lin.mod)
 
 # predict new values for given x's
 newx <- data.frame(x=seq(min(x),max(x),l=100))
 newy.hat <- predict(lin.mod,newx)
 newy.hat
 
 # Confidence intervals
 confint(lin.mod,"(Intercept)")
 confint(lin.mod,"x")
 
 # Residuals
 resids <- residuals(lin.mod)
 y.hat <- fitted(lin.mod)
 
 # deviance
 deviance(lin.mod)
 sum(resids^2)
 
 # C.I for predicted mean
 ic.p <- predict(lin.mod, newx, interval = "confidence")
 plot(x,y)
 abline(lin.mod,col="red",lwd=3)
 lines(newx$x,ic.p[,2],lty=2,lwd=3) # lower IC 
 lines(newx$x,ic.p[,3],lty=2,lwd=3) # upper IC
 # C.I for predicted response
 ic.r <- predict(lin.mod, newx, interval = "prediction")
 lines(newx$x,ic.r[,2],lty=3,lwd=3,col="blue") # lower IC 
 lines(newx$x,ic.r[,3],lty=3,lwd=3,col="blue") # upper IC
 legend("topleft", c("CI's for predictions of the mean response", "CI's for predictions of the observed response"), col=c(1,4), lty=c(2,3),lwd=3)
 
 # Checking residuals normality
 plot(y.hat,resids)
 abline(h=0)
 
 # QQ-plot
 qqnorm(resids, ylab = "Raw residuals")
 qqline(resids) # adds a line joining the 1st amd 3rd quantiles
 
 qqnorm(rstudent(lin.mod), ylab="Studentized residuals")
 abline(0,1)
 
 # Histogram
 hist(resids,col="lightgrey")
 boxplot(resids,main="Boxplot of residuals",col="lightgrey")


###################################################
### Multiple linear regression
###################################################
set.seed(1234)
  n <- 100
 x1 <- seq(11,30,l=n)
 x2 <- runif(n,5,95)

 alpha <- 15
 beta1 <- 0.5
 beta2 <- -0.3

 sigma <- 1.3
 
 eps <- rnorm(x1,0,sigma)

 y <- alpha + beta1*x1  + beta2*x2 + eps


###################################################
### plot data
###################################################
df1 = data.frame(x1,x2,y)
plot(df1)


###################################################
### Correlation matrix and model fit
###################################################
# correlation matrix
cor(df1)
# correlation between x1 and x2
cor(df1[,2:3])
# Linear Model fit
mod1 <- lm(y ~ x1 + x2 , data = df1)


###################################################
### 3D fit
###################################################
library(scatterplot3d)
ss<-scatterplot3d(df1,angle=35, pch =19, box=FALSE, type="h", highlight.3d=TRUE)
ss$plane3d(mod1,lty.box="solid",col="blue")


###################################################
### code chunk number 15: BCAM-Course-GLM.Rnw:721-723
###################################################
par(mfrow=c(1,2))
termplot(mod1,rug=TRUE,se=TRUE,col.se="blue")


###################################################
### load salud data
###################################################
rm(list=ls()) # Remove all previous variables
salud <- read.table("data/salud.txt",header=TRUE, dec=",")
class(salud)
dim(salud)
names(salud)


summary(salud)
summary(salud$sexo)
str(salud)

###################################################
### Convert variables to factors
###################################################
 salud$g02     <- factor(salud$g02)
 salud$sexo    <- factor(salud$sexo)
 salud$con_tab <- factor(salud$con_tab)
 salud$educa   <- factor(salud$educa)
 salud$bebedor <- factor(salud$bebedor)


summary(salud)
attach(salud)


###################################################
### tabulate a factor variable
###################################################
 table(sexo)


###################################################
### apply mean of peso by factor bebedor
###################################################
tapply(peso,bebedor,FUN=mean)   


###################################################
### cross classify table
###################################################
xtabs(~sexo+bebedor,data=salud) 


###################################################
### cloud plot
###################################################
cloud( imc ~ peso*sexo, groups = sexo, data=salud)


###################################################
### fit a linear model
###################################################
modelo1 <- lm(imc ~ peso , data = salud)
modelo1

attributes(modelo1)

summary(modelo1)


###################################################
### Plot
###################################################
plot(peso,imc,xlab="Peso",ylab="IMC")
abline(modelo1,lwd=3,col=2)



###################################################
### Linear model with a factor variable
###################################################
  modelo2 <- lm(imc~peso+sexo,data=salud) 
  summary(modelo2)

coefficients(modelo2)


###################################################
### get fitted values
###################################################
 y.ajustados.mod2 <- fitted.values(modelo2) 


###################################################
### obtain fitted values by factor variable
###################################################
 peso.1=peso[sexo==1]
 peso.2=peso[sexo==2]

y.hat.mod2.1=modelo2$coef[1]+modelo2$coef[2]*peso.1
y.hat.mod2.2=modelo2$coef[1]+modelo2$coef[2]*peso.2+modelo2$coef[3]


###################################################
### Predict 
###################################################
# Create a regular sequence of values of length 100
peso.seq <- seq(min(peso),max(peso),l=100)

# Create a factor variable for each level of length 100
sexo1.seq <- as.factor(rep(1,l=100))
sexo2.seq <- as.factor(rep(2,l=100))

# Create new data frames to predict with lm
newdat1 = data.frame(data.frame(peso = peso.seq, sexo = sexo1.seq))
newdat2 = data.frame(data.frame(peso = peso.seq, sexo = sexo2.seq))

  predict.mod2.male <- predict.lm(modelo2,newdat1)
predict.mod2.female <- predict.lm(modelo2,newdat2)


###################################################
### Plot fitted lines by factor sexo
###################################################
plot(peso,imc,xlab="Peso",ylab="IMC",col="grey",pch=19,cex=.5)
lines(peso.seq,predict.mod2.male,col="red",lwd=2,t='l')
lines(peso.seq,predict.mod2.female,col="blue",lwd =2,t='l')
legend("bottomright",c("Male","Female"),col=c("red","blue"),lwd=2)


###################################################
### compare both sexes fits
###################################################
par(mfrow=c(1,2))
plot(peso,imc,xlab="Peso",ylab="IMC",col="grey",cex=.3,pch=19,main="Males fit")
points(peso.1,imc[sexo==1],col="red",cex=.3)
lines(peso.seq,predict.mod2.male,col="black",lwd=2,t='l')
lines(peso.seq,predict.mod2.female,col="blue",lwd=2,t='l',lty=4)

plot(peso,imc,xlab="Peso",ylab="IMC",col="grey",cex=.3,pch=19,main="Females fit")
points(peso.2,imc[sexo==2],col="blue",cex=.3)
lines(peso.seq,predict.mod2.female,col="black",lwd =2,t='l')
lines(peso.seq,predict.mod2.male,col="red",lwd=2,t='l',lty=4)


###################################################
### linear model with interaction of a factor variable
###################################################
modelo3 <- lm(imc~peso+sexo+peso:sexo)
summary(modelo3)


###################################################
### predict values for each sex
###################################################
  predict.mod3.male <- predict.lm(modelo3,newdat1)
predict.mod3.female <- predict.lm(modelo3,newdat2)


###################################################
### plot both fitted lines
###################################################
plot(peso,imc,xlab="Peso",ylab="IMC",col="grey",pch=19,cex=.5)
lines(peso.seq,predict.mod3.male,col="red",lwd=2,t='l')
lines(peso.seq,predict.mod3.female,col="blue",lwd =2,t='l')
legend("bottomright",c("Male","Female"),col=c("red","blue"),lwd=2)


###################################################
### linear model with 2-way interactions of two factors
###################################################
  modelo4 <- lm(imc~peso+sexo+sexo:peso+bebedor+bebedor:peso+sexo:bebedor) 


###################################################
### ANOVA of a fitted model
###################################################
  anova(modelo4)


###################################################
### Likelihood Ratio Test with anova()
###################################################
  modelo5 <- lm(imc~peso+sexo+peso:sexo+bebedor+bebedor:peso)
anova(modelo5,modelo4)


###################################################
### Test for variable selection
###################################################
library(MASS)
  dropterm(modelo4,test="F")


###################################################
###Beyond  linear models
###################################################

# Polynomial regression 
polymod <- lm(imc~poly(peso,degree=3,raw=FALSE))
summary(polymod)
# Or equivalently
polymod<-lm(imc~peso+I(peso^2)+I(peso^3)) # when in poly(...,raw=TRUE)

predict.polymod<-predict(polymod,data.frame(peso=peso.seq))
plot(peso,imc,col="grey")
lines(peso.seq,predict.polymod, lwd = 2, col = "blue")

# Exponential fit
 expmod <- lm(log(imc)~peso)
summary(expmod)

predict.expmod<-predict(expmod,data.frame(peso=peso.seq))
par(mfrow=c(1,2))
plot(peso,log(imc),col="grey")
lines(peso.seq,predict.expmod, lwd = 2, col = "darkgreen")
plot(peso,imc,col="grey")
lines(peso.seq,exp(predict.expmod), lwd = 2, col = "darkgreen")

# Natural splines fit
library(splines)
 nsmod<- lm(imc~ns(peso,df=4))
summary(nsmod)

predict.ns<-predict(nsmod,data.frame(peso=peso.seq))
plot(peso,imc,col="grey")
lines(peso.seq,predict.ns, lwd = 2, col = "orange")


###################################################
### by sex factor
###################################################
# Polynomial fit with interaction by sexo
 polymod2 <- lm(imc~poly(peso,degree=3,raw=FALSE)*sexo)
summary(polymod2)
predict.polymod2.male<-predict(polymod2,newdat1)
predict.polymod2.female<-predict(polymod2,newdat2)
plot(peso,imc)
lines(peso.seq,predict.polymod2.male,col="blue",lwd=3)
lines(peso.seq,predict.polymod2.female,col="red",lwd=3)

# Exponential model fit with interaction by sexo
expmod2 <- lm(log(imc)~peso*sexo)
summary(expmod2)
predict.expmod2.male<-predict(expmod2,newdat1)
predict.expmod2.female<-predict(expmod2,newdat2)

plot(peso,imc)
lines(peso.seq,exp(predict.expmod2.male),col="blue",lwd=3)
lines(peso.seq,exp(predict.expmod2.female),col="red",lwd=3)

# Natural spline model fit with interaction by sexo
nsmod2 <- lm(imc~ns(peso,df=4)*sexo)
summary(nsmod2)
predict.nsmod2.male<-predict(nsmod2,newdat1)
predict.nsmod2.female<-predict(nsmod2,newdat2)

plot(peso,imc)
lines(peso.seq,predict.nsmod2.male,col="blue",lwd=3)
lines(peso.seq,predict.nsmod2.female,col="red",lwd=3)


###################################################
### lm for binary outcomes?
###################################################
g02num<-as.numeric(g02)-1 # go back to g02 as numeric values
plot(peso,g02num,cex=.3,xlab="peso",ylab="g02")
ex1 <- lm(g02num~peso)
abline(ex1,col=2,lwd=3)


###################################################
### logit transformation
###################################################
# Logit function
logit<-function(p){
  y <- log(p/(1-p))
  y
}
n <- 400
p <- seq(0.001,0.9999,l=n)
y <- logit(p)
plot(y,p,xlab="logit(1/1-p)",ylab="p", type='l',lwd=3);abline(v=0,h=0.5,lty=2,col="black",main="logit function")


###################################################
### Turbines example
###################################################
turbinas <- read.table("data/fisuras.txt",header=TRUE)

plot(turbinas,type="h"); points(turbinas,cex=.6,pch=19)


###################################################
### Fit a lm
###################################################
ex2<- lm(fisuras~horas,data=turbinas)


###################################################
### Check fitted values
###################################################
ex2$fitted


###################################################
### plot lm
###################################################
plot(turbinas,type="h"); points(turbinas,cex=.6,pch=19)
abline(ex2,col=2,lwd=2)




