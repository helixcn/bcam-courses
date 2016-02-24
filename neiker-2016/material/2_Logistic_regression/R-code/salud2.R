# Alternative estimation of a logistic regression as cross clasification table

salud2=read.table("data/salud2.txt",header=TRUE)

 salud2$g02     <- factor(salud2$g02)
 salud2$sexo    <- factor(salud2$sexo)
 salud2$bebedor <- factor(salud2$bebedor)

# we can reasign the categories
levels(salud2$sexo)[1]<-"male"
levels(salud2$sexo)[2]<-"female"

levels(salud2$g02)[1]<-"good"
levels(salud2$g02)[2]<-"bad"

levels(salud2$bebedor)[1]<-"poco/nada"
levels(salud2$bebedor)[2]<-"ocasional"
levels(salud2$bebedor)[3]<-"frecuente"

salud2=salud2[salud2$g02=="bad",]
attach(salud2)
logistic1a<-glm(cbind(count,n-count)~sexo+bebedor,family=binomial(link=logit),data=salud2)

