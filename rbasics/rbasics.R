# --------------------------------------------
# R basics
#  www.idaejin.github.io/bcam-courses/
# --------------------------------------------

# Load libraries
library(DAAG) # or require(DAAG)
library(gdata)
library(foreign)

## Create a variable with weights and heights

weight<-c(60,72,57,90,95,72) # function c is used to concatenate data/numbers or vectors 

class(weight)

height<-c(1.75,1.80,1.65,1.90,1.74,1.91)

## Compute body mass index

bmi<- weight/height^2
bmi

## Compute basic statistics

mean(weight)
median(weight)
sd(weight)
var(weight)

## Summary of the variable
summary(weight)

## or 
min(weight)
max(weight)
range(weight)
quantile(weight)
sum(weight)
length(weight)

## New create a data.frame of subjects by sex

subject <- c("John","Peter","Chris","Tony","Mary","Jane")
sex <- c("MALE","MALE","MALE","MALE","FEMALE","FEMALE")
class(subject)
table(sex)

## Create a data.frame of subjects with weights and heigths

Dat <- data.frame(subject,sex,weight,height)

# add bmi to Dat
Dat$bmi <- bmi  # or Dat$bmi <- weight/height^2
class(Dat)
str(Dat) # display object structure

## Working on data frames
# Change rownames
rownames(Dat)<-c("A","B","C","D","E","F")

# Access to data frame elements (similar to a matrix)
Dat[,1]     # 1st column
Dat[,1:3]   # 1st to 3rd columns
Dat[1:2,]   # 1st to 2nd row

# Show only rows of males/females
Dat[sex=="MALE",]
Dat[sex=="FEMALE",]

# Compute statistics by factor/s
mean(Dat[sex=="MALE",3])  # weight average of MALEs
mean(Dat[sex=="MALE","weight"])

# Use apply function
apply(Dat[sex=="FEMALE",3:5],2,mean)
apply(Dat[sex=="MALE",3:5],2,mean)

# we can use apply with our own function
apply(Dat[sex=="FEMALE",3:5],2,function(x){x+2})

# function by
by(Dat[,3:5],sex, colMeans) # 'by' splits your data by factors and do calculations on each subset.

# another option
aggregate(Dat[,3:5], by=list(sex),mean) 

# logic operations on variables
bmi
bmi>22
as.numeric(bmi>22) # convert a logical condition to a numeric value 0/1
which(bmi>22)  # gives the position of bmi for which bmi>22

## ----results='hide'------------------------------------------------------
bmi > 20 & bmi < 25
which(bmi > 20 & bmi < 25)

## ----results='hide'------------------------------------------------------
x <- c(2, 3, 5, 2, 7, 1)
y <- c(10, 15, 12)
z <- c(x,y)  # concatenates x and y

## ------------------------------------------------------------------------
zz <- list(x,y) # create a list
unlist(zz) # unlist the list converting it to a concatenated vector

## ------------------------------------------------------------------------
x[c(1,3,4)]

x[-c(2,6)] # negative subscripts omit the chosen elements 

## ------------------------------------------------------------------------
seq(1,9) # or 1:9
seq(1,9,by=1)
seq(1,9,by=0.5)
seq(1,9,length=20)

## ----results='hide'------------------------------------------------------
oops <- c(7,9,13)
rep(oops,3) # repeats the entire vector "oops" three times
rep(oops,1:3) # this function has the number 3 replaced 
              #  by a vector with the three values (1,2,3) 
              #  indicating that 7 should be repeated once, 9 twice and 13 three times.

rep(c(2,3,5), 4)
rep(1:2,c(10,15))

rep(c("MALE","FEMALE"),c(4,2)) # it also works with character vectors 
c(rep("MALE",3), rep("FEMALE",2))

## ------------------------------------------------------------------------
x<- 1:12
x
dim(x)<-c(3,4)  # 3 rows and 4 columns

X <- matrix(1:12,nrow=3,byrow=TRUE)
X <- matrix(1:12,nrow=3,byrow=FALSE)

# rownames, colnames

rownames(X) <- c("A","B","C")
colnames(X) <- LETTERS[4:7]
colnames(X) <- month.abb[4:7]

## ------------------------------------------------------------------------
Y <- matrix(0.1*(1:12),3,4)

cbind(X,Y)  # bind column-wise
rbind(X,Y)  # bind row-wise

## ------------------------------------------------------------------------
gender<-c(rep("female",691),rep("male",692))
class(gender)

# change vector to factor (i.e. a category)
gender<- factor(gender)
levels(gender)

summary(gender)
table(gender)

status<- c(0,3,2,1,4,5)    # This command creates a numerical vector ???pain???, encoding the pain level of five patients.
fstatus <- factor(status, levels=0:5)
levels(fstatus) <- c("student","engineer","unemployed","lawyer","economist","dentist")

Dat$status <- fstatus
Dat

## ------------------------------------------------------------------------
a <- c(1,2,3,4,5)
b <- c(TRUE,FALSE,FALSE,TRUE,FALSE)

max(a[b])

sum(a[b])

## ------------------------------------------------------------------------
a <- c(1,2,3,4,NA)
sum(a)
sum(a,na.rm=TRUE)

a <- c(1,2,3,4,NA)
is.na(a)

## ----results="hide"------------------------------------------------------
mtcars
?mtcars       # or help(mtcars)

## ------------------------------------------------------------------------
head(mtcars)

## ------------------------------------------------------------------------
str(mtcars) # display the structure of the data frame

## ------------------------------------------------------------------------
mtcars["Mazda RX4",] # using rows and columns names
mtcars[c("Datsun 710", "Camaro Z28"),] 

## ------------------------------------------------------------------------
mtcars[,c("mpg","am")]

## ------------------------------------------------------------------------
attach(mtcars)
plot(wt, mpg, main="Scatterplot Example",
   xlab="Car Weight ", ylab="Miles Per Gallon ", pch=19) 

## ------------------------------------------------------------------------
pairs(~mpg+disp+drat+wt,data=mtcars,
   main="Simple Scatterplot Matrix")

## ----fig.pos='center'----------------------------------------------------
tab <- table(mtcars[,c("cyl")])
barplot(tab)

## ------------------------------------------------------------------------
pie(tab)

## ------------------------------------------------------------------------
VADeaths

## ----echo=FALSE----------------------------------------------------------
apply(VADeaths,1,mean)

## ----echo=FALSE----------------------------------------------------------
apply(VADeaths,2,mean)

## ---- results='hide'-----------------------------------------------------
library(DAAG)
rainforest

## ----echo=FALSE----------------------------------------------------------
table(rainforest$species)
barplot(table(rainforest$species))

## ------------------------------------------------------------------------
Acmena <- subset(rainforest, species == "Acmena smithii")

## ----echo=FALSE----------------------------------------------------------
par(mfrow=c(1,2))
plot(wood~dbh,data=Acmena,pch=19, main="plot of dbh vs wood")
plot(log(wood)~log(dbh),data=Acmena,pch=19,main="log transformation")

## ----echo=FALSE----------------------------------------------------------
hist(Acmena$dbh)

## ----echo=FALSE----------------------------------------------------------
  x <- seq(1,100,by=2)
  x[x>60 & x<80]

