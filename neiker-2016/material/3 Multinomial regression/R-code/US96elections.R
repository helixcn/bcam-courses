# load the 'faraway' package:

library(faraway)

# loading the 'nes96' dataset:

data(nes96)

# attaching the 'nes96' dataset:

attach(nes96)

# defining a 3-category party variable:

sPID <- nes96$PID
levels(sPID) <- c("Democrat","Democrat", "Independent", "Independent", "Independent", "Republican", "Republican")

##-- What's income look like?
table(income) 
##-- Make a vector that is the mean of each category
inca <- c(1.5,4,6,8,9.5,10.5,11.5,12.5,13.5,14.5,16,18.5,21,23.5,27.5,32.5,37.5,42.5,47.5,55,67.5,82.5,97.5,115)
nincome <- inca[unclass(income)]
summary(nincome)


matplot(prop.table(table(educ,sPID),1),type="l",xlab="Education",ylab="Proportion",lty=c(1,2,3),lwd=4,col=c("black", "red", "blue"))
legend("topright",legend = c("Democrat","Independent","Republican"), lty=c(1,2,3), lwd=4, col = c("black", "red", "blue")) # check the help files on prop.table and matplot if what they're doing isn't clear


cutinc <- cut(nincome,7) # break numeric factor into ordered factors

il <- c(8,26,42,58,74,90,107) # income levels -- mean income of each level
matplot(il,prop.table(table(cutinc,sPID),1),
	    lty=c(1,2,3),type="l",ylab="Proportion",xlab="Income",
	    lwd=4, col = c("black", "red", "blue")); 

legend("topright",legend = c("Democrat","Independent","Republican"), lty=c(1,2,3), lwd=4, col = c("black", "red", "blue"))


al <- c(24,34,44,54,65,75,85) # age levels -- mean age of each level
cutage <- cut(nes96$age,7) # ditto now with age
matplot(prop.table(table(cutage,sPID),1),lty=c(1,2,5),type="l",ylab="Proportion",xlab="Age",lwd=4, col = c("black", "red", "blue")); legend("topright",legend = c("Democrat","Independent","Republican"), lty=c(1,2,3), col = c("black", "red", "blue"),lwd=4)



######################################
##
#  Multinomial Logit Model
##
######################################

# loading the 'nnet' package:

library(nnet)

# Fitting a multinomial logit model:

mod1 <- multinom(sPID ~ age + nincome + educ , data=nes96)

# Model with only age and nincome:

mod2 <- multinom(sPID ~ age + nincome, data=nes96)

# LRT
anova(mod1,mod2) # educ is not significative

# Equivalently: Deviance test indicates we should drop 'educ' from the model:

pchisq(deviance(mod2) - deviance(mod1), df=mod1$edf-mod2$edf, lower=F)

# Model with only nincome:

mod3 <- multinom(sPID ~ nincome, data=nes96)

anova(mod2,mod3)

# Deviance test indicates we should drop 'age' from the model:

pchisq(deviance(mod3) - deviance(mod2), df=mod2$edf-mod3$edf, lower=F)

step(mod1)



## Predicting party affiliation corresponding to a set of income values:

inc.vals <- c(8,26,42,58,74,90,107)

p1 <- predict(mod3, data.frame(nincome=inc.vals), type='probs')

data.frame(inc.vals,p1)

# Just giving the most probable category:

predict(mod3, data.frame(nincome=inc.vals))

# Examining estimated regression coefficients:

summary(mod3)

######
