# Titanic data

train <- read.csv('./extra-data/titanic_train.csv',header=TRUE,row.names=1)
test <- read.csv('./extra-data/titanic_test.csv',header=TRUE,row.names=1)


model <- glm(Survived ~.,family=binomial(link='logit'),data=train)
summary(model)

anova(model, test="Chisq")

mod1 <- glm(Survived ~ as.factor(Pclass), family=binomial, data=train)
summary(mod1)
anova(mod1,test="Chisq")

# interaction effect between passenger class and sex, as passenger class showed a much bigger difference in survival rate amongst the women compared to the men (i.e. Higher class women were much more likely to survive than lower class women, whereas first class Men were more likely to survive than 2nd or 3rd class men, but not by the same margin as amongst the women).  
mod2 <- glm(Survived ~ Pclass + Sex  + Age + SibSp, family = binomial(logit), data = train)
summary(mod2)
anova(mod2,test="Chisq")

mod3 <-  glm(Survived ~ Pclass + Sex + Pclass:Sex + Age + SibSp, family = binomial(logit), data = train)
summary(mod3)
anova(mod3,test="Chisq")


# In the steps above, we briefly evaluated the fitting of the model, now we would like to see how the model is doing when predicting y on a new set of data. By setting the parameter type='response', R will output probabilities in the form of P(y=1|X). Our decision boundary will be 0.5. If P(y=1|X) > 0.5 then y = 1 otherwise y=0. Note that for some applications different decision boundaries could be a better option.

fitted.results <- predict(mod3,newdata=test,type='response')
fitted.results <- ifelse(fitted.results > 0.5,1,0)

misClasificError <- mean(fitted.results != test$Survived)
print(paste('Accuracy',1-misClasificError))

# The 0.8075 accuracy on the test set is quite a good result. However, keep in mind that this result is somewhat dependent on the manual split of the data that I made earlier, therefore if you wish for a more precise score, you would be better off running some kind of cross validation such as k-fold cross validation.

# Evaluate predictive performance


library(ROCR)
p <- predict(mod3, newdata=subset(test,select=c(2,3,4,5,6,7,8)), type="response")
pr <- prediction(p, test$Survived)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc






