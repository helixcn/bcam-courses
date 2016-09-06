library(xlsx)


data <- read.xlsx("MixedModels.xlsx",2)

head(data)
str(data)
names(data)
data$Tratamiento <- as.factor(data$Tratamiento)
data$pressure <- data$pressure..Kpa.
data$pressure <- factor(data$pressure,ordered=FALSE)
data$pres <- data$pressure..Kpa.^(1/2)
#levels(data$pressure)

levels(data$Tratamiento)

head(data)

library(lattice)

xyplot(log(Water)~pres|lok,groups=Tratamiento,data,type=c("p","l"))

library(nlme)
mod0 <- lme(log(Water)~lok,random=~1|Tratamiento,data)
mod1 <- lme(log(Water)~lok,random=~1|Tratamiento/sample,data)

anova(mod0,mod1)

mod0a <- lme(log(Water)~lok+pres,random=~1|Tratamiento,data)
 mod2 <- lme(log(Water)~lok+pres,random=~1|Tratamiento/sample,data)

summary(mod2)

anova(mod0a,mod2)


 mod3 <- lme(log(Water)~lok+pres+I(pres^2),random=~1|Tratamiento/sample,data)

library(lme4)

mod3a <- lmer(log(Water)~lok + (1+pressure|Tratamiento) + (1|sample) , data)


pres.g <- seq(min(data$pres),max(data$pres),l=100)
xyplot(fitted(mod3) ~ pres | lok, groups=Tratamiento,data = data,grid = TRUE,
type = c("p", "p"))
