### Introduction to Generalized Linear Models with R
### Date: May 14 & 21, 2015
### Dae-Jin Lee, dlee@bcamath.org

### 5. Poisson regression
###################################################
### read data
###################################################
species<-read.table("data/species.txt",header=TRUE)
names(species)


###################################################
### recode factor variables and plot
###################################################
species$pH<-factor(species$pH)

species$pH<-factor(species$pH, labels=c("Low","Medium","High"))

# or levels(species$pH) <- c("Low","Medium","High")



attach(species)


plot(Biomass,Species,type="n")

spp<-split(Species,pH)

bio<-split(Biomass,pH)

points(bio[[1]],spp[[1]],pch=16,col=1)
points(bio[[2]],spp[[2]],pch=17,col=2)
points(bio[[3]],spp[[3]],pch=15,col=4)
legend("topright",legend=c("Low","Medium","High"),pch=c(16,17,15),col=c(1,2,4))
abline(lm(Species[pH=="Low"]~Biomass[pH=="Low"]),lwd=2,col=1)
abline(lm(Species[pH=="Medium"]~Biomass[pH=="Medium"]),lwd=2,col=2)
abline(lm(Species[pH=="High"]~Biomass[pH=="High"]),lwd=2,col=4)


###################################################
### Fit a Poisson glm's
###################################################
m0=glm(Species~Biomass,family=poisson,data=species)
anova(m0,test="Chisq")

m1=glm(Species~pH,family=poisson,data=species)

anova(m1,test="Chisq")


###################################################
### Include interaction
###################################################
m2 <- glm(Species~Biomass+pH,family=poisson,data=species)
m3 <- glm(Species~Biomass*pH,family=poisson,data=species)

anova(m2,m3,test="Chisq")


###################################################
### summary
###################################################
summary(m3)


###################################################
### plot fits
###################################################


x <- rep(seq(0,10,l=101),3) # Biomass.x

pH.seq <- factor(c(rep("Low",101),rep("Medium",101),rep("High",101)))

fit3 <- predict(m3,data.frame(list(Biomass=x,pH = pH.seq)), type="response")



plot(Biomass,Species,type="n",main="response")
spp3<-split(fit3,pH.seq)
bio3<-split(x,pH.seq)
points(bio3[["Low"]],spp3[["Low"]],pch=16,col=1)
points(bio3[["Medium"]],spp3[["Medium"]],pch=17,col=2)
points(bio3[["High"]],spp3[["High"]],pch=15,col=4)
points(bio[["Low"]],spp[["Low"]],pch=16,col=1)
points(bio[["Medium"]],spp[["Medium"]],pch=17,col=2)
points(bio[["High"]],spp[["High"]],pch=15,col=4)
legend("topright",legend=c("Low","Medium","High"),pch=c(16,17,15),col=c(1,2,4))



fit3a <- predict(m3,data.frame(list(Biomass=x,pH = pH.seq)), type="link")

spp3a<-split(fit3a,pH.seq)
bio3a<-split(x,pH.seq)


plot(Biomass,log(Species),type="n",main="link")
points(bio3[["Low"]],log(spp3[["Low"]]),pch=16,col=1)
points(bio3[["Medium"]],log(spp3[["Medium"]]),pch=17,col=2)
points(bio3[["High"]],log(spp3[["High"]]),pch=15,col=4)
points(bio[["Low"]],log(spp[["Low"]]),pch=16,col=1)
points(bio[["Medium"]],log(spp[["Medium"]]),pch=17,col=2)
points(bio[["High"]],log(spp[["High"]]),pch=15,col=4)
legend("topright",legend=c("Low","Medium","High"),pch=c(16,17,15),col=c(1,2,4))



###################################################
### fitted VS residuals
###################################################
par(mfrow=c(1,2))
plot(predict(m3),residuals(m3))
abline(h=0)
qqnorm(residuals(m3))


###################################################
### Quasi-Poisson
###################################################
m4 <- glm(Species~Biomass*pH,family=quasipoisson,data=species)


###################################################
### test for overdispersion
###################################################
library(AER)
dispersiontest(m3)


###################################################
### Negative Binomial
###################################################
library(MASS)
m5 <- glm.nb(Species~Biomass*pH,data=species)





#################################################################
### Lung cancer cases in Denmark
#################################################################
lung <- read.table("data/lung.txt",header=TRUE)



###################################################
### boxplot
###################################################
boxplot(cases~age,data=lung,col="bisque")


###################################################
### Poisson regression
###################################################
lungmod1 <- glm(cases ~ age, family=poisson, data=lung)

summary(lungmod1)

confint(lungmod1)

anova(lungmod1,test="Chisq")

###################################################
### null model, LRT
###################################################
lungmod0 <- glm(cases ~ 1, family=poisson, data=lung)
anova(lungmod0,lungmod1,test="Chisq")


###################################################
### Plots
###################################################
par(mfrow=c(1,2))
hist(lung$pop,col="lightgrey", main="Population size")
barplot(xtabs(pop~age,data=lung),main="Population counts by age group")


###################################################
### with offset
###################################################
lungmod2 <- glm(cases ~ age + offset(log(pop/2500)), 
                family=poisson, data=lung)

lungmod4 <- glm(cases ~ city + offset(log(pop/2500)), 
                family=poisson, data=lung)


summary(lungmod2)

confint(lungmod2)


###################################################
### null model with offset
###################################################
lungmod3<-glm(cases ~ 1, family = poisson, data = lung, 
              offset = (log(pop/2500)))
anova(lungmod3,lungmod2,test="Chisq")


###################################################
### cross-classifying table
###################################################
xtabs(pop~age,data=lung)
xtabs(cases~age,data=lung)


###################################################
### Relative rates
###################################################
exp(coef(lungmod2))


