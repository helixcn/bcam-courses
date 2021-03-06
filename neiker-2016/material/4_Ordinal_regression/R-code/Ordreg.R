### Introduction to Generalized Linear Models with R
### Date: May, 14 & 15 2015
### Dae-Jin Lee, dlee@bcamath.org

### 4. Ordinal regression
###################################################
### read data .dta format
###################################################
library(foreign)

gradschool<-read.dta(file="data/gradschool.dta")


###################################################
### convert to factor
###################################################

 gradschool$apply <- ordered(gradschool$apply)

gradschool$pared  <- factor(gradschool$pared)
gradschool$public <- factor(gradschool$public)


###################################################
### polr function in MASS
###################################################
library(MASS)

ord1 <- polr(apply~pared,data=gradschool)

summary(ord1)


###################################################
### compute p-values of the fitted model
###################################################
# we create a function to obtain a table with p-values
pvals <- function(mod){
# store table
tab <- coef(summary(mod))
## calculate and store p values
p <- pnorm(abs(tab[, "t value"]), lower.tail = FALSE) * 2
## combined table
tab <- cbind(tab, "p value" = round(p,4))
tab
}
pvals(ord1)
confint(ord1)
exp(confint(ord1))


###################################################
### fit polr for public and gpa covariates and test significance
###################################################
ord2 <- polr(apply~public,data=gradschool)
summary(ord2)
ord3 <- polr(apply~gpa,data=gradschool)
summary(ord3)
ord0 <- polr(apply~1,data=gradschool)

summary(ord0)
anova(ord0,ord1)
anova(ord0,ord2)
anova(ord0,ord3)


###################################################
### pared and gpa
###################################################
ord4 <- polr(apply~pared+gpa,data=gradschool)
summary(ord4)
pvals(ord4)


###################################################
### using function vglm in VGAM
###################################################
library(VGAM)
apply2=ordered(gradschool$apply)
m0 <- vglm(apply2~pared+gpa,family=cumulative(parallel=TRUE),data=gradschool)  
m1 <- vglm(apply2~pared+gpa,family=cumulative(parallel=FALSE),data=gradschool)

test.po <- 2*logLik(m1)-2*logLik(m0)
df.po <- length(coef(m1))-length(coef(m0))

test.po
df.po
1-pchisq(test.po,df=df.po) # 0.6584501 (Do not reject the null hypothesis)


###################################################
### plot effects
###################################################
library(effects)
plot(effect("pared",ord4),style="stacked")
plot(effect("gpa",ord4),style="stacked")


