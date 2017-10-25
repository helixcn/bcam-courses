library(MASS)
data("Boston")


plot(Boston$crim,Boston$medv,col=1+Boston$chas)
legend('topright', legend = levels(factor(Boston$chas)), col = 1:2, cex = 0.8, pch = 1)

plot(Boston[Boston$chas==0,c("crim","medv")],xlim=range(Boston$crim),ylim=range(Boston$medv),col="blue",cex=.35)
points(Boston[Boston$chas==1,c("crim","medv")],col="red",pch=2)
legend("topright",c("CHAS = 0", "CHAS = 1"), col=c(4,2),pch=c(1,2))

boxplot(crim,data=Boston)
boxplot(crim ~ factor(chas), data = Boston,xlab="CHAS",ylab="crim",col=c(4,2),varwidth=TRUE)
boxplot(medv ~ factor(chas), data = Boston,xlab="CHAS",ylab="crim",col=c(4,2),varwidth=TRUE)



library(ggplot2)

qplot(crim,medv,data=Boston, colour=factor(chas))
qplot(crim,medv,data=Boston, colour=tax)


library(lattice)
xyplot(medv~crim,groups=factor(chas),auto.key = TRUE)
xyplot(medv~crim|factor(chas),auto.key = TRUE)
