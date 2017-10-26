# **Introduction to Statistical Modeling in `R`**
Dae-Jin Lee < dlee@bcamath.org >  
BCAM/UPV-EHU Courses 2016-2017  


***********

# Solutions to proposed exercises 
## Probability distributions 


### Questions



**Question:**
Suppose there are twelve multiple choice questions in an Maths class quiz. Each question has five possible answers, and only one of them is correct. Find the probability of having four or less correct answers if a student attempts to answer every question at random. 

*Solution*

Since only one out of five possible answers is correct, the probability of answering a question correctly by random is $1/5=0.2$. We can find the probability of having exactly 4 correct answers by random attempts as follows. 


```r
p = 1/5
n = 12
k = 4
dbinom(k,size=n,prob=0.2)
```

```
## [1] 0.1328756
```

To find the probability of having four or less correct answers by random attempts, we apply the function `dbinom` with `k=0,1,2,4`.

```r
prob <- NULL
for(k in 0:4){
prob <- c(prob,dbinom(k,n,p))
prob
}
prob
```

```
## [1] 0.06871948 0.20615843 0.28346784 0.23622320 0.13287555
```

```r
sum(prob)
```

```
## [1] 0.9274445
```

```r
# or simply
sum(dbinom(0:4,n,p))
```

```
## [1] 0.9274445
```

Alternative, we can use the cumulative probability function for the binomial distribution `pbinom`

```r
pbinom(4,size=n,prob=0.2)
```

```
## [1] 0.9274445
```

**Answer:** the probability of four or less questions answered correctly by random in a twelve question multiple choice quiz is 92.7%. 


**Question**
What is the probability of 2 or 3 questions answered correctly?

```r
sum(dbinom(2:3,n,p))
```

```
## [1] 0.519691
```



**Question:** Suppose company **A** produced a product **B** which have probability 0.005 of being defective. Suppose product **B** is shipped in cartons containing 25 **B** items. What is the probability that a randomly chosen carton contains exactly one defective product?

Question Rephrased: What is P(X = 1) when X has the Bin(25, 0.005) distribution? 


```r
dbinom(1,25,0.005)
```

```
## [1] 0.1108317
```

What is the probability that a randomly chosen carton contains no more than one defective widgit? 


```r
pbinom(1,25,0.005)
```

```
## [1] 0.9930519
```
### Poisson distribution

**Question:** Suppose the number of individual plants of a given species we expect to find in a one meter square quadrat follows the Poisson distribution with mean $\lambda= 10$. Find the probability of finding
exactly $12$ individuals.

*Solution:*
Let $Y \sim Pois(\lambda=10)$
$$
\mbox{Pr}(Y=12 ~|~ \lambda=10) = \frac{e^{-10}10^{12}}{12!} = 0.0948
$$

In `R`

```r
dpois(12,lambda=10)
```

```
## [1] 0.09478033
```

**Question:** If there are twelve cars crossing a bridge per minute on average, find the probability of having seventeen or more cars crossing the bridge in a particular minute. 


*Solution*

The probability of having sixteen or less cars crossing the bridge in a particular minute is given by the function `ppois`. 


```r
ppois(16,lambda=12)
```

```
## [1] 0.898709
```
 Hence the probability of having seventeen or more cars crossing the bridge in a minute is in the upper tail of the probability density function.

```r
ppois(16, lambda=12, lower=FALSE)   # upper tail 
```

```
## [1] 0.101291
```

If there are twelve cars crossing a bridge per minute on average, the probability of having seventeen or more cars crossing the bridge in a particular minute is 10.1%. 

### Exponential distribution

**Question:**

Suppose that the amount of time one spends in a bank is exponentially distributed with mean 10 minutes, $\lambda=1/10$. 

a) What is the probability that a customer will spend more than 15 minutes in the bank? 
b) What is the probability that a customer will spend more than 15 minutes in the bank given that he is still in the bank
after 10 minutes?


*Solution*

a)

$$
P(X>15) = e^{-15 \lambda} = e^{-3/2} = 0.2231
$$

In `R`

```r
pexp(15,rate=1/10,lower.tail = FALSE) # or 1-pexp(15,rate=1/10)
```

```
## [1] 0.2231302
```

b)

$$
P(X>15~|~X>10) = P(X>5) = e^{-1/2} = 0.606
$$

In `R`

```r
pexp(5,rate=1/10,lower.tail = FALSE)
```

```
## [1] 0.6065307
```


### Normal distribution


**Question:**

$X$ is a normally distributed variable with mean $\mu = 30$ and standard deviation $\sigma = 4$. Find

a) $P(x<40)$

b) $P(x>21)$

c) $P(30<x<35)$

<!--
http://www.analyzemath.com/statistics/normal_distribution.html
-->

*Solution*

a) For $x=40$, the standardized $z$ is $(40-30)/4=2.5$ and hence
$$
P(X<40) = P(Z<2.5) = 0.9938
$$
In `R`

```r
pnorm(2.5) # or pnorm(40,mean=30,sd=4,lower.tail=TRUE)
```

```
## [1] 0.9937903
```

b) $P(x>21)$

```r
pnorm(21,mean=30,sd=4,lower.tail = FALSE)
```

```
## [1] 0.9877755
```
c) $P(30<x<35)$

```r
pnorm(35,mean=30,sd=4,lower.tail = TRUE)-pnorm(30,mean=30,sd=4,lower.tail = TRUE)
```

```
## [1] 0.3943502
```



**Question:**

Entry to a certain University is determined by a national test. The scores on this test are normally distributed with a mean of 500 and a standard deviation of 100. Tom wants to be admitted to this university and he knows that he must score better than at least 70% of the students who took the test. Tom takes the test and scores 585. Will he be admitted to this university?


*Solution*


```r
pnorm(585,mean=500,sd=100)
```

```
## [1] 0.8023375
```
Tom scored better than 80.23% of the students who took the test and he will be admitted to this University.



-----------------------------------------------------





