# Introduction to mixed models with R
# Dae-Jin Lee, BCAM
# dlee@bcamath.org


## Rail example
library(nlme)
data(Rail)
class(Rail)
?Rail
Rail$Rail # ordered factor

# "Travel time in nanoseconds in a sample of six rails"
plot(Rail)

# mean and std
mean(Rail$travel)
sd(Rail$travel)

#  single-mean model
rail1 <- lm(travel ~ 1,data=Rail)
summary(rail1)

# "Boxplot of residuals by number for the `lm` fit the single-mean model"
boxplot(resid(rail1)~Rail,xlab="Rail",ylab="Residuals",data=Rail)
abline(0,0)

# one-way classification lm
 rail2 <- lm(travel~Rail-1, data=Rail) 
summary(rail2)

# "Boxplot of residuals by rail number for the `lm` fit of the fixed-effects model."
boxplot(resid(rail2)~Rail,xlab="Rail",ylab="Residuals",data=Rail)
abline(0,0)


# random effects model
library(nlme)

rail3 <- lme(travel~1,random=~1|Rail,data=Rail)

# or equivalently

# rail3 <- lme(travel~1,random=list(Rail=~1),data=Rail)

rail3

summary(rail3)
model <- rail3
summ  <- summary(rail3)

# var-cov
VarCorr(model)

# ML
rail3.ml <- update(rail3,method="ML")
VarCorr(rail3.ml)

# "Standard residuals vs fitted values"
plot(model)

#
intervals(model)

# anova/LRT
anova(model)

# with lmer
library(lme4)

rail.lmer <- lmer(travel ~1+(1|Rail),data=Rail)

summary(rail.lmer)

## Ergonometrics data

data(ergoStool)
names(ergoStool)

# "Effort required (Borg scale) to arise from a stool for 9 different subjects each using 4 different types of stools (T1,T2,T3 and T4)."
plot(ergoStool)

ergoStool[ergoStool$Subject==5,]
ergoStool[ergoStool$Subject==8,]

plot.design(ergoStool)  # Design plot
ergoDF <- as.data.frame(ergoStool)   # convert to data.frame
by(ergoDF$effort, ergoDF$Type,mean)  # averages by Type
by(ergoDF$effort, ergoDF$Subject,mean) # averages by Subject

# mixed-effects model
stool.lme <- lme(effort ~ Type-1, random = ~1|Subject,data=ergoStool)
summary(stool.lme)
VarCorr(stool.lme)

# fixed effects model
stool.lm <- lm(effort~Type-1,data=ergoStool) # only fixed effects
# LR test 
test <- -2*logLik(stool.lm) + 2 * logLik(stool.lme,REML=FALSE)
test
mean(pchisq(test,df=c(0,1),lower.tail=FALSE)) # if <0.05 reject H0 

# load RLRsim library for LR test
library(RLRsim)
exactLRT(update(stool.lme,method="ML"),stool.lm)

## check AIC's
AIC(stool.lm)
AIC(stool.lme)

## anova
anova(stool.lme)

## check Type effect with anova function 
stool.lme1 <- lme(effort ~ Type,random = ~1|Subject,data=ergoStool,
                  method="ML")
stool.lme0 <- lme(effort ~ 1,random = ~1|Subject,data=ergoStool,
                  method="ML")
anova(stool.lme0,stool.lme1)

# obtain confidence intervals
intervals(stool.lme)

# Plot of fitted values vs standardized residuals
plot(stool.lme)

# QQ-plot of standardized residuals
qqnorm(stool.lme, abline=c(0,1))

#
shapiro.test(resid(stool.lme)) # for a formal normality test

# Standardized residuals vs fitted values by subject
plot(stool.lme,form=resid(.,type="p") ~ fitted(.)|Subject, abline=0)

# Random effects plot
library(lme4)
stool.lmer <- lmer(effort ~ Type -1 + (1|Subject), data=ergoStool)
ranef(stool.lmer)
rr1 <- ranef(stool.lmer, condVar = TRUE)
library(lattice)
dotplot(rr1) # or qqmath(rr1)


## Multilevel models

MathAchieve <- read.table("data/MathAchieve.txt",header=TRUE,sep="\t")
# Variables
names(MathAchieve)

# convert to factor variables
str(MathAchieve)
MathAchieve$School <- factor(MathAchieve$School,ordered=FALSE)
MathAchieve$Sex <- factor(MathAchieve$Sex,ordered=FALSE)
levels(MathAchieve$Sex) <- c("Male","Female")
MathAchieve$Sector <- factor(MathAchieve$Sector,ordered=FALSE)
levels(MathAchieve$Sector) <- c("Public","Private")

# linear model 
multilev0 <- lm(MathAch~CSES, data=MathAchieve) # fit a lm
multilev0

# plot of linear model fit
plot(MathAchieve$CSES,MathAchieve$MathAch,cex=.5,col="grey")
abline(multilev0,col=2,lwd=3)

# Schools as fixed effect
multilev1 <- lm(MathAch~CSES+School, data=MathAchieve) # fit a lm
multilev1


library(lattice)
## subsample of Schools
attach(MathAchieve)
subMathAchieve=MathAchieve[School==c("91","3","31","52","74"),]
dotplot(reorder(School, MathAch) ~ MathAch,
        subMathAchieve,ylab="School")

# Fit a random effects model by School
multilev.lme <- lme(MathAch~1,random=~1|School, data=MathAchieve)
multilev.lme
VarCorr(multilev.lme)

# get beta's and predict
beta0 <-  fixef(multilev.lme)
beta0
fixef(multilev.lme)-(predict(multilev.lme,
                             newdat=list(School=c("91","3","31","52","74"))))

# Random effects and confidence intervals
multilev.lmer<-lmer(MathAch~1+(1|School),data=MathAchieve)
rr1 <- ranef(multilev.lmer, condVar = TRUE)
dotplot(rr1,ylab="Schools")

# get confidence intervals
intervals(multilev.lme)

# LRT
multilev.NULL=lm(MathAch~1,data=MathAchieve)
test=-2*logLik(multilev.NULL, REML=FALSE) +2*logLik(multilev.lme, REML=FALSE)
test
mean(pchisq(test,df=c(0,1),lower.tail=FALSE))

# or
exactLRT(update(multilev.lme,method="ML"),multilev.NULL)

# random effects model with CSES fixed effect
 ml1 <- lme(MathAch ~ CSES, random = ~1|School, data=MathAchieve)
 ml1

# LRT
 ml0a <-update(multilev.lme, method="ML")
 ml1a <-update(ml1, method="ML")
anova(ml0a,ml1a)

# plot fitted lines for each school model
library(grDevices) 
colfunc<-colorRampPalette(c("red","yellow","springgreen","royalblue")) # Create a palette of colors
cols <- colfunc(length(levels(MathAchieve$School)))

plot(MathAchieve$CSES,fitted(ml1),t='l',col=NULL,xlab="CSES",ylab="MathAchiev")
for(i in 1:length(levels(MathAchieve$School))){
lines(MathAchieve$CSES[MathAchieve$School==levels(MathAchieve$School)[i]],fitted(ml1)[MathAchieve$School==levels(MathAchieve$School)[i]],col=cols[i]) 
}

# with Sector vble as fixed effect
 ml2 <- lme(MathAch ~ Sector, random = ~1|School, data=MathAchieve)
 ml2

# LRT
ml2a <- update(ml2, method="ML")
anova( ml0a,ml2a)

# Boxplot for fitted values by School sector
boxplot(fitted(ml2) ~ Sector, data=MathAchieve)

#
ml3 <- lme(MathAch ~ CSES, random = ~CSES|School, data=MathAchieve)
ml3
VarCorr(ml3)


# Random effects plot
plot(ranef(ml3)[,1],ranef(ml3)[,2],
     xlab="intercepts (u_i)", ylab="slopes (v_i)")

#
ml3a <- lme(MathAch~CSES,random = list(School=pdDiag(~CSES)),
            data=MathAchieve)
anova(ml3a,ml3)

# LRT
test=-2*logLik(ml3, REML=TRUE) +2*logLik(ml3a, REML=TRUE)
mean(pchisq(test,df=c(0,1),lower.tail=FALSE)) 

# check AIC's
AIC(logLik(ml3))
AIC(logLik(ml3a))
AIC(logLik(ml1))

## Fitted lines for each school model
plot(MathAchieve$CSES,fitted(ml3),t='l',col=NULL,xlab="CSES",ylab="MathAchiev")
for(i in 1:length(levels(MathAchieve$School))){
lines(MathAchieve$CSES[MathAchieve$School==levels(MathAchieve$School)[i]],fitted(ml3)[MathAchieve$School==levels(MathAchieve$School)[i]],col=cols[i]) 
}

#
ml4 = lme(MathAch~CSES*Sector,random = list(School=pdDiag(~CSES)),
          data=MathAchieve)
summary(ml4)

#
ml4a <- update(ml4,method="ML")
anova(ml4a)

# Fitted lines for each school model
plot(MathAchieve$CSES,fitted(ml4),t='l',col=NULL,xlab="CSES",ylab="MathAchiev")
for(i in 1:length(levels(MathAchieve$School))){
lines(MathAchieve$CSES[MathAchieve$School==levels(MathAchieve$School)[i] & MathAchieve$Sector=="Public"],fitted(ml4)[MathAchieve$School==levels(MathAchieve$School)[i] & MathAchieve$Sector=="Public"],col="blue",lty=2,lwd=2) 
lines(MathAchieve$CSES[MathAchieve$School==levels(MathAchieve$School)[i] & MathAchieve$Sector=="Private"],fitted(ml4)[MathAchieve$School==levels(MathAchieve$School)[i] & MathAchieve$Sector=="Private"],col="red",lty=5,lwd=2) 
}
legend("topleft", c("Public","Private"), lwd=2, lty=c(2,5), col=c("blue","red"))


#########


## Longitudinal models
child <- read.table("data/child.txt",header=TRUE)

# Plot of children weights and ages
library(lattice)    
library(fields)
xyplot(weight ~ age,groups=id,col=tim.colors(length(unique(child$id))),
       lwd=1,t="b",pch=19,data=child, ylim=c(2,20))

# model with random intercept 
child.mod1 <- lme(weight~age+I(age^2),random=~1|id,data=child)
child.mod1


## # Equivalently with lmer
## child.mod1 <-lmer(weight~age+I(age^2)+(1|id),data=child)

# Fitted model with random intercepts and quadratic trend
xyplot(fitted(child.mod1) ~ age,groups=id,
       col=tim.colors(length(unique(child$id))),
       lwd=1,t="b",pch=19,data=child,ylim=c(2,20))

# model with random slopes 
child.mod2<-lme(weight~age+I(age^2),random=~age|id,
                data=child)
# or with lmer
# child.mod2 <- lmer(weight~age+I(age^2)+(age|id),data=child)
child.mod2

#
child.mod2a<-lme(weight~age+I(age^2),random = list(id=pdDiag(~age)),
                 data=child)
anova(child.mod2a, child.mod2)

# LRT
test=-2*logLik(child.mod1, REML=TRUE)+2*logLik(child.mod2a,REML=TRUE)
mean(pchisq(test,df=c(0,1),lower.tail=FALSE))

# Fitted model with random intercepts and quadratic trend
library(fields)
xyplot(fitted(child.mod2a) ~ age,groups=id,
       col=tim.colors(length(unique(child$id))),
       lwd=1,t="b",pch=19,data=child,ylim=c(2,20))

# Fitted model with random intercepts and quadratic trend for boys and girls
xyplot(fitted(child.mod2a) ~ age|sex,groups=id,lwd=1,t="b",pch=19,
       data=child,ylim=c(2,20))

## 
child.mod3<-lme(weight~age*sex+I(age^2),random=list(id=pdDiag(~age)),
                data=child)
summary(child.mod3)$tTable

##

child.mod4<-lme(weight~age*sex+I(age^2),
                random=list(id=pdDiag(~sex-1),id=pdDiag(~sex:age-1)),
                data=child)
print(child.mod4)
summary(child.mod4)$tTable

xyplot(fitted(child.mod4) ~ age,groups=id,
       col=tim.colors(length(unique(child$id))),
       lwd=1,t="b",pch=19,data=child,ylim=c(2,20))

xyplot(fitted(child.mod4) ~ age|sex,groups=id,lwd=1,t="b",pch=19,
       data=child,ylim=c(2,20))


## Body Weight Growth in Rats

library(nlme)
data(BodyWeight)
head(BodyWeight)

# Body weights of rats by Time and Diet
xyplot(weight ~ Time | Diet, group = Rat, 
       data = BodyWeight, 
       type = "l",  aspect = 2)

# create a centered variable cTime
BodyWeight$cTime <- BodyWeight$Time - mean(BodyWeight$Time)
rat1 <- lme(weight~cTime*Diet, data=BodyWeight,random=~cTime|Rat)
rat1
#
rat1a <- update(rat1,method="ML")
rat1b <- lme(weight~cTime+Diet, data=BodyWeight,random=~cTime|Rat,
             method="ML")
anova(rat1b,rat1a)

#
rat1.1 <- lme(weight~cTime*Diet, data=BodyWeight,
              random = list(Rat=pdDiag(~cTime)))
anova(rat1.1,rat1)

#
# Null model 
Model_NULL <- lme(weight~cTime*Diet, data=BodyWeight,
                  random=~1|Rat) # rat1

# LRT
test=-2*logLik(Model_NULL, REML=TRUE) +2*logLik(rat1.1, REML=TRUE)

# p-value
mean(pchisq(test,df=c(0,1),lower.tail=FALSE))

# Plot of standardized residuals versus fitted values for the homoscedastic model
plot(rat1.1)


rat2 <- update(rat1.1,weights=varPower(form=~fitted(.))) # form=~fitted(.) is by default so it does not need to be specified
rat2

# Plot of standardized residuals versus fitted values for the ``varPower``
plot(rat2)

# Test the significance of the variance parameter in varPower, H0:delta=0
anova(rat1.1,rat2) # reject H0

#
summary(rat2)

# Differences between Diet2 and Diet3 with argument L
anova(rat2, L=c("cTime:Diet2"=1,"cTime:Diet3"=-1))


# Orthodont data
data(Orthodont)

# Orthodont data with individual ``lm`` fits
xyplot(distance~age | Subject, groups=Sex, 
       data=Orthodont,type=c("p","r"), 
       par.strip.text=list(cex=0.75), layout=c(8,4))


age.means <- tapply(distance,age,mean)
plot(c(8,14),c(20,28),xlab="Age",ylab="Mean distance",pch=16,type="n")
points(c(8,10,12,14),age.means,type="b",col=1,pch=16)

I <- Sex=="Male"
age.means.m <- tapply(distance[I],age[I],mean)
points(c(8,10,12,14),age.means.m,pch=16,col=4)
I <- Sex=="Female"
age.means.m <- tapply(distance[I],age[I],mean)
points(c(8,10,12,14),age.means.m,pch=16,col=3)
legend("topleft",legend=c("Males","Females","Combined"),pch=16,col=c(4,3,1))


lmList.obj <- lmList(distance~age|Subject,data=Orthodont) # fits a linear regression model with different slopes and intercepts
                    

# Plot of intercepts VS slopes by sex group
ab <- t(sapply(split(Orthodont, Orthodont$Subject),
        function(u)coef(lm(distance~age, data=u))))
ab <- cbind(ab, data.frame(Sex=sapply(split(as.character(Orthodont$Sex),
Orthodont$Subject),function(x)x[1])))

names(ab) <- c("ybar", "b", "Sex")

sex <- as.character(ab$Sex)

plot(ab[, 1], ab[, 2], col=c(Female="red", Male="blue")[sex],
     pch=c(Female=1, Male=3)[sex], xlab="Intercept", ylab="Slope")

# lmList.obj <- lmList(distance~age|Subject,data=Orthodont) 
# coef(lmList.obj)
# plot(intervals(lmList.obj))
# plot(coef(lmList.obj)[,1],(coef(lmList.obj)[,2]),xlab= "Estimated slope",
#  ylab="Estimated intercept",pch=c(Female=1, Male=3)[sex], col=c(Female="red", Male="blue")[sex]) 


#
attach(ab)
t.test(b[Sex=="Male"], b[Sex=="Female"], var.equal=TRUE)
detach("ab")

# 
# Ages are centered at 11 years
ortho1<-lme(distance~I(age-11),random= ~I(age-11) | Subject,data=Orthodont)

#
ortho2 <- update(ortho1,fixed = distance~Sex*I(age-11))

# is interaction significant?
ortho1.ml <- update(ortho1,method="ML")
ortho2.ml <- update(ortho2,method="ML")
anova(ortho1.ml,ortho2.ml)

# Are intercepts and slopes independent?
ortho4 <- lme(distance ~ Sex*I(age-11), random=pdDiag(~I(age-11)), 
              data=Orthodont, method="ML")
anova(ortho2.ml,ortho4)

#
ortho3 <- update(ortho2.ml,method="REML") 
summary(ortho3)

# Scatterplots of standardized residuals versus fitted values for `ortho3`
  plot(ortho3,resid(.,type="p")~fitted(.)|Sex, id=0.05, adj=-0.3)

# Heterocedastik model (different variance per sex group) 
ortho5 = update(ortho3,weights=varIdent(form = ~1|Sex))
ortho5

# "Scatterplots of standardized residuals versus fitted values for `ortho5`"
  plot(ortho5,resid(.,type="p")~fitted(.)|Sex, id=0.05, adj=-0.3)

# "Observed versus fitted values for `ortho5`"
  plot(ortho5,distance~fitted(.), id=0.05, adj=-0.3)

# LRT to check the different variance
anova(ortho3,ortho5)

# "Scatterplots of standardized residuals versus fitted values for `ortho5`"
  qqnorm(ortho5,~resid(.)|Sex, id=0.05, adj=-0.3)

# Correlation

## ----eval=FALSE----------------------------------------------------------
## cs1AR1 <- corAR1(0.8,form=~1|Subject)
## cs1AR1 <- Initialize(cs1AR1,data=Orthodont)
## corMatrix(cs1AR1)

## ----eval=FALSE----------------------------------------------------------
##  cs1ARMA <- corARMA(0.4,form=~1|Subject,q=1)
##  cs1ARMA <- Initialize(cs1ARMA,data=Orthodont)
## corMatrix(cs1ARMA)
## 
##  cs2ARMA <- corARMA(c(0.8,0.4),form=~1|Subject,p=1,q=1)
##  cs2ARMA <- Initialize(cs2ARMA,data=Orthodont)
## corMatrix(cs2ARMA)

## ----eval=FALSE----------------------------------------------------------
##  cs1CompSymm <- corCompSymm(value=0.3,form=~1|Subject)
##  cs1CompSymm <- Initialize(cs1CompSymm,data=Orthodont)
## corMatrix(cs1CompSymm)

## ----eval=FALSE----------------------------------------------------------
## cs1Symm <- corSymm(value=c(0.2,0.1,-0.1,0,0.2,0),form=~1|Subject)
## cs1Symm <- Initialize(cs1Symm, data=Orthodont)
## corMatrix(cs1Symm)

# Ovary data
data(Ovary) # see ?Ovary

# "Number of ovarian follicies greater than 10mm in diameter detected in mares at various times in their estrus cycles"
plot(Ovary)

#
ovary1 <- lme(follicles~sin(2*pi*Time) + cos(2*pi*Time), data=Ovary, 
              random = pdDiag(~sin(2*pi*Time))) 

ovary1
ovary2 <- lme(follicles~sin(2*pi*Time) + cos(2*pi*Time), data=Ovary, 
              random = pdSymm(~sin(2*pi*Time))) # general positive-def ranef
ovary2
anova(ovary2,ovary1) # can we assume indepedent random effects for different mares
                     # p-value is >0.05 Do not Reject H0 (correlation =0) 

# Autocorrelation function
ACF(ovary1)

# "Empirical autocorrelation function for the standard residuals of ``ovary1``""
plot(ACF(ovary1,maxLag=20),alpha=0.01)

#
ovary3 <- update(ovary2,correlation=corAR1())
ovary3

## ------------------------------------------------------------------------
anova(ovary2,ovary3)

#
intervals(ovary3)$corStruct

#
ovary4 <- update(ovary2,correlation=corARMA(q=2))
anova(ovary3,ovary4,test=FALSE)

#
ovary5 <- update(ovary2,correlation=corARMA(p=1,q=1))
anova(ovary3,ovary5)

# Empirical autocorrelation function corresponding to the normalized residuals of model ``ovary5``
plot(ACF(ovary5, maxLag=10, resType="n"),alpha=0.01)


## GLMM for binary data: Bangladesh Demographic and Health Survey

BDHS <- read.table("data/BDHS.txt", header = TRUE)

BDHS$womid<- factor(BDHS$womid)
BDHS$meduc<- factor(BDHS$meduc)
BDHS$urban <- factor(BDHS$urban)
BDHS$islam <- factor(BDHS$islam)
levels(BDHS$urban) <- c("rural","urban")

library(lme4)
fit <- glmer(antemed ~ (1 | comm), family = binomial("logit"), data = BDHS)

#
summary(fit)

#
fit0 <- glm(antemed ~ 1, family=binomial("logit"),data=BDHS)
test = -2*logLik(fit0) + 2*logLik(fit)
mean(pchisq(test,df=c(0,1),lower.tail=FALSE))

#
library(lattice)
qqmath(ranef(fit, condVar=TRUE),strip=FALSE)$comm

#
BDHS$magec <- BDHS$mage - mean(BDHS$mage)


fit2 <- glmer(antemed~magec+(1|comm),family=binomial("logit"),data=BDHS)
summary(fit2)

# Fitted values
predprob <- fitted(fit2)
library(VGAM)
predlogit <- logit(predprob)
datapred=unique(data.frame(cbind(predlogit = predlogit, comm = BDHS$comm,mage = BDHS$mage)))
xyplot(predlogit ~ mage, data = datapred, groups = comm, type = "l", col = "blue", xlim = c(9, 51), ylim = c(-4, 4))

#
BDHS$meduc <- factor(BDHS$meduc)
BDHS$wealthc <- BDHS$wealth-mean(BDHS$wealth) # we center wealth
fit3 <- glmer(antemed~magec+wealthc+meduc+(1|comm), family=binomial("logit"), data=BDHS)
summary(fit3)

xyplot(predict(fit3,type="response")~mage,data=BDHS)


#
# variance of r.e.
as.numeric(summary(fit3)$varcor)

#
fit4 <- glmer(antemed~magec+meduc+wealthc+(1+wealthc|comm), data = BDHS, family=binomial("logit"))
summary(fit4)

#
anova(fit3,fit4) # reject H0

#
BDHS$urban <- factor(BDHS$urban)
levels(BDHS$urban) <- c("rural","urban")
fit5 <- glmer(antemed~magec+meduc+wealthc+urban+(1+wealthc|comm), 
              data = BDHS, family=binomial("logit"))
summary(fit5)


## Deer data

deer <- read.table('data/deer.txt',header=TRUE)
deer$Farm <- factor(deer$Farm)

# Deer infection data
plot(deer$Length,deer$infect,col='#00000011', pch=19)

#
deer.glm <- glm(infect~Length+Farm,data=deer,family=binomial)

library(lme4)
# use glmer() to fit GLMM.  
#  Farm is a unique identifier for a cluster; does not need to be a factor
deer.glmm <- glmer(infect~Length+(1|Farm),data=deer,family=binomial)
deer.glmm2 <- update(deer.glmm,.~.-Length,data=deer)
anova(deer.glmm2,deer.glmm)

# GLMM predicted probabilities of parasitic infection. The thick line in the middle represents the predicted values for the ‘population of farms’
plot(deer$Length,deer$infect,type="n",xlab="Length",ylab="Infect")
prob<-fitted(deer.glmm)
AllFarms<-unique(deer$Farm)

library(grDevices)
cols<- rainbow(length(AllFarms))

for(i in 1:length(AllFarms)){
points(deer$Length[deer$Farm==AllFarms[i]],deer$infect[deer$Farm==AllFarms[i]],col=cols[i],pch=1,cex=.65)
}

for(i in 1:length(AllFarms)){
l<-deer$Length[deer$Farm==AllFarms[i]]
p<-prob[deer$Farm==AllFarms[i]]
o<-order(l)
lines(l[o],p[o],col=cols[i])
}
L<-deer$Length
o<-order(L)
z <- fixef(deer.glmm)[1]+fixef(deer.glmm)[2]*deer$Length
prob2=exp(z)/(1+exp(z))
lines(L[o],prob2[o],lwd=5)

## 
library(MASS)
 deer2 <- glmmPQL(infect ~ Length, random=~1|Farm,family=binomial("logit"),
                  data=deer)
 summary(deer2)
 
 library(glmmML) # similar to glmer
 deer3 <- glmmML(infect ~ Length, cluster=Farm,family=binomial("logit"),
                 data=deer)
 summary(deer3)

