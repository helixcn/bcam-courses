### Introduction to Generalized Linear Models with R
### Dae-Jin Lee, dlee@bcamath.org
### (2015-)

### 3. Multinomial regression

###################################################
### read mammography experience data
###################################################
mamexp=read.table("data/mammexp.txt",header=TRUE)
names(mamexp)


###################################################
### transform numeric variables to factors
###################################################
mamexp$me<-factor(mamexp$me)
mamexp$symp<-factor(mamexp$symp)
mamexp$hist<-factor(mamexp$hist)
mamexp$bse<-factor(mamexp$bse)
mamexp$dect<-factor(mamexp$dect)


# levels(mamexp$me)<-c("never","1yearago","over2years")
# levels(mamexp$hist)<-c("no","yes")

attach(mamexp)


###################################################
### load libraries
###################################################
library(VGAM)   
library(nnet)  
library(mlogit)


###################################################
### cross table
###################################################
xtabs(~me+hist,data=mamexp)

###################################################
### fit model using vglm
###################################################
vglm1 <- vglm(me ~ hist, family=multinomial(refLevel=1), 
			 data=mamexp)
summary(vglm1)

###################################################
### fit model with multinom() in nnet library
###################################################
library(nnet)

multi1=multinom(me ~ hist, data=mamexp)
summary(multi1)

###################################################
### Get p-values
###################################################
pvals<-function(test){
z <- summary(test)$coefficients/summary(test)$standard.errors
p<-pnorm(abs(summary(test)$coefficients/summary(test)$standard.errors),lower.tail=FALSE)*2
output <- list(z=z,p=p)
return(output)
}

pvals(multi1)

pvals(multi1)$p<0.05

###################################################
### multi1 object
###################################################
multi1


###################################################
### get coefficients
###################################################
coefficients(multi1) # We can extract the coefficients of the model


###################################################
### Odds
###################################################
exp(coefficients(multi1))


###################################################
### C.I's
###################################################
exp(confint(multi1))


###################################################
### Model with only an intercept
###################################################
multi0 <- multinom(me~1,data=mamexp)
anova(multi0,multi1)


###################################################
### cross table
###################################################
xtabs(~me+dect,data=mamexp)


###################################################
### with dect covariate
###################################################
multi2 <- multinom(me~dect,data=mamexp)


###################################################
### LRT test
###################################################
anova(multi0,multi2)


###################################################
### coefficients and odds
###################################################
coef(multi2)
exp(coef(multi2))


###################################################
### confidence intervals for odds
###################################################
exp(confint(multi2))


###################################################
### LRT significance tests
###################################################
multi3 <- multinom(me~symp,data=mamexp); anova(multi0,multi3)

multi4 <- multinom(me~bse,data=mamexp); anova(multi0,multi4)

multi5 <- multinom(me~pb,data=mamexp); anova(multi0,multi5)


multi6 <- multinom(me~symp+pb+bse+hist+dect,data=mamexp)


###################################################
### with additional covariates
###################################################
 vglm6 <- vglm(me ~ symp+pb+bse+hist+dect,
               family=multinomial(refLevel=1), data=mamexp)

summary(vglm6)

###################################################
### recode variable symp in library(car)
###################################################
mamexp$symp01<-mamexp$symp  # create a new variable symp01

library(car)
mamexp$symp01<-recode(mamexp$symp,"1=0;2=0;3=1;4=1")

 vglm6a <- vglm(me ~ symp01+pb+bse+hist+dect,
               family=multinomial(refLevel=1), data=mamexp)


 mod1 <- vglm(me ~ pb+bse+hist+dect,
               family=multinomial(refLevel=1), data=mamexp)
summary(mod1)

summary(vglm6a)


###################################################
### use multinom to compare models LRT
###################################################
multi6a <- multinom(me~symp01+pb+bse+hist,data=mamexp)
multi7a <- multinom(me~symp01+pb+bse+hist+dect,data=mamexp)
anova(multi6a,multi7a)

multiA <- multinom(me~pb+bse+hist,data=mamexp)
multiB <- multinom(me~pb+bse+hist+dect,data=mamexp)
anova(multiA,multiB)

###################################################
### recode dect
###################################################
table(dect)
mamexp$dect01 <- mamexp$dect
mamexp$dect01 <- recode(mamexp$dect01,"0=0; 1=0; 2=1")

multi7b <- multinom(me~symp01+pb+bse+hist+dect01,data=mamexp)
anova(multi6a,multi7b)



###################################################
### fit with dect01
###################################################
 vglm7a <- vglm(me ~ symp01+pb+bse+hist+dect01,
                family=multinomial(refLevel=1), data=mamexp)

summary(vglm7a)

###################################################
### use anova for LRT
###################################################
multi7b <- multinom(me~hist+symp01+bse,data=mamexp)
multi7c <- multinom(me~hist+symp01+bse+dect01,data=mamexp)
anova(multi7b,multi7c)


###################################################
### group pb variable
###################################################
mamexp$benef <- mamexp$pb
mamexp$benef[mamexp$benef<=5] =  0
mamexp$benef[mamexp$benef>5 & mamexp$benef <=7] =  1
mamexp$benef[mamexp$benef>7 & mamexp$benef <=9] =  2
mamexp$benef[mamexp$benef>9] = 3
mamexp$benef <- factor(mamexp$benef)

###################################################
### estimate and plot coefficients
###################################################
 multi8 <- multinom(me~hist+symp01+bse+benef,data=mamexp)

pvals(multi8)
pvals(multi8)$p<0.05

 vglm8 <- vglm(me ~ symp01+benef+bse+hist+dect01,
                family=multinomial(refLevel=1), data=mamexp)
 
matplot(t(coef(multi8)[,5:7]),t='b',lwd=3,main="Plot of the estimated logit regression coefficients",xlab="pb (created as benef)", ylab="Estimated logit")


multi7c <- multinom(me~hist+symp01+bse+pb,data=mamexp)


###################################################
### add pb
###################################################
multi9 <- multinom(me~hist+symp01+bse+pb+dect01,data=mamexp)

summary(multi9)
###################################################
### Odds
###################################################
exp(coef(multi9))


###################################################
### plot effects
###################################################
library(effects)

plot(effect("symp01",multi9))
plot(effect("hist",multi9))
plot(effect("bse",multi9))
plot(effect("dect01",multi9))
plot(effect("pb",multi9),style="stacked")
plot(effect("pb",multi9),style="lines")


