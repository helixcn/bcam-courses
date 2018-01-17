# **Introduction to penalized regression with `R`**
Dae-Jin Lee < dlee@bcamath.org >  
BCAM - Basque Center for Applied Mathematics  


***********

Slides [here](http://idaejin.github.io/bcam-courses/jjseb3/JJSEB3.pdf)

Install some `R` libraries


```r
install.packages(c("car","SemiPar","KernSmooth","nlme","MortalitySmooth","Matrix","svcm"))
```

Download `wood.txt` data files [here](http://idaejin.github.io/bcam-courses/jjseb3/data/wood.txt)


# Penalized splines 

## Basis and penalties


**Example** 

Suppose $n$ pairs $(x_i ,y_i)$ and we want to fit the model
$$
    y_i = f(x_i)  + \epsilon_i \quad \epsilon_i \sim \mathcal{N}(0,\sigma^2)
$$

Let us consider the next simulated example


```r
set.seed(2018)
n <- 200
x <- seq(0,1,l=n)
# original function
f <- sin(3*pi*x)
y <- f + rnorm(n,.33)

plot(x,y,col="grey",pch=19)
lines(x,f,col=1,lwd=3)
```

<div class="figure" style="text-align: center">
<img src="R-jjseb3_files/figure-html/unnamed-chunk-2-1.png" alt="*Simulated data example*"  />
<p class="caption">*Simulated data example*</p>
</div>

Our aim is to estimate the function $f(x) = \sin(3\pi x)$ from the observed data $(x_i,y_i)$. P-splines were proposed by @Eilers96 although many other authors have popularized the techniques in different applications (See @Ruppert03 and @Wood06book).



### Basis functions and knots

#### Truncated polynomials


```r
# Function to create TPFs
tpoly <- function(x,t,p){
  B = NULL
  for (i in 1:length(t)){
    B <- cbind(B,(x-t[i])^p*(x>t[i]))
  }
  B
}
```

Nex Figure illustrates the TPFs with different degrees with equally-spaced knots


```r
K <- 10
knots <- seq(0,1, length= (K+2))[-c(1,K+2)]
x <- seq(0,1,l=100)
B = list()
p <- c(0,1,2,3)
for(i in 1:4){
  B[[i]] <- tpoly(x,knots,p[i])
}

par(mfrow=c(2,2))
for(i in 1:4){
matplot(x,B[[i]],col=i,t="l",lwd=2,xlab="x", ylab = " ", lty=2:5); title(bquote(p == .(p[i])))
points(knots,0*knots,col=i,pch=15)
}
```

![*Truncated Polynomial Functions with different degrees $p$*](R-jjseb3_files/figure-html/unnamed-chunk-4-1.png)

#### $B$-splines

Basic references are @Boor78 and @Dierckx93


The next function creates a B-spline basis function:


```r
library(splines)
bspline <- function(x,xl,xr,ndx,bdeg){
  dx <- (xr-xl)/ndx
  knots <- seq(xl-bdeg*dx,xr+bdeg*dx,by=dx)
  B <- spline.des(knots,x,bdeg+1,0*x,outer.ok=TRUE)$design
  output <- list(knots=knots,B=B)
  return(output)
}
```
where 

  - `xl` is the left bound of $x$
  - `xr` is the right bound of $x$
  - `ndx` is the number of segments (*inner knots*) in which we divide the range of $x$
  - `bdeg` degree of the piecewise polynomial (usually cubic splines `q=3`)


The next Figure illustrates B-spline bases with different degrees of the polynomials. 


```r
ndx = 7
x <- seq(0,1,l=200)
B = list()
xl <- min(x)+0.01
xr <- max(x)+0.01
deg <- c(0,1,2,3)
knots <- bspline(x,xl,xr,ndx,bdeg=3)$knots
for(i in 1:4){
  B[[i]] <- bspline(x,xl,xr,ndx,bdeg=deg[i])$B
}

par(mfrow=c(2,2))
for(i in 1:4){
matplot(x,B[[i]],col=i,t="l",lwd=2,xlab="x", ylab = " ", lty=1); title(bquote(q == .(deg[i])))
points(knots,0*knots,col=i,pch=15)
}
```

![*B-spline bases with different degrees $q$*](R-jjseb3_files/figure-html/unnamed-chunk-6-1.png)




## Penalties and coefficients

@Eilers96 proposed a penalty based on discrete differences of order $d$ between adjacent coefficients of the $B$-spline basis. This is a more flexible penalty as it is independent from the degree of the polynomial used to construct the regression basis. Moreover, it is a good discrete approximation to the integral of the square of the $d$th derivative. The minimization criteria becomes:

$$
\min \mathrm{SS}(\boldsymbol{\theta},\boldsymbol{y},\lambda) =   (\boldsymbol{y}-\boldsymbol{B}\boldsymbol{\theta})^\prime(\boldsymbol{y}-\boldsymbol{B}\boldsymbol{\theta}) + \lambda \boldsymbol{\theta}^\prime \boldsymbol{P}_d \boldsymbol{\theta}
$$
where $\hat{\boldsymbol{\theta}} = (\boldsymbol{B}^\prime \boldsymbol{B}  + \boldsymbol{P}_d  )^{-1}\boldsymbol{B}^\prime\boldsymbol{y}$, with $\boldsymbol{P}_d = (\boldsymbol{\Delta}^d ) ^\prime \boldsymbol{\Delta}^d$, for $d=0$ we have a ridge penalty. In general, we use $d=2$, although other orders can be used, according to the variability of the curve and the amount of noise in the data. 

A second order penalty $d=2$ is equivalent to 
$$
(\theta_1 - 2 \theta_2 + \theta_3)^2 + ... + (\theta_{k-2} - 2 \theta_{k-1} + \theta_{k})^2  = \boldsymbol{\theta}^\prime \boldsymbol{D}^\prime\boldsymbol{D}\boldsymbol{\theta}
$$
where 
$$
\boldsymbol{D} = 
\begin{bmatrix}
1 & -2 & \phantom{-1}1 & \phantom{-1}0 & ... \\
0 & \phantom{-1}1 & -2 & \phantom{-1}1 & ... \\
0 & \phantom{-1}0 & \phantom{-1}1 & -2 & ... \\
\vdots  & \phantom{-1}\vdots & \phantom{-1}\vdots & \phantom{-1}\vdots  & \ddots
\end{bmatrix}\qquad \mathrm{of~size~} (c-d) \times c
$$
where $c=k+deg+1$ the number of columns of $\boldsymbol{B}$.

In `R`, $\boldsymbol{D}$ can be created as

```r
# 1st order differences
D1 <- diff(diag(6),differences=1)
D1
```

```
##      [,1] [,2] [,3] [,4] [,5] [,6]
## [1,]   -1    1    0    0    0    0
## [2,]    0   -1    1    0    0    0
## [3,]    0    0   -1    1    0    0
## [4,]    0    0    0   -1    1    0
## [5,]    0    0    0    0   -1    1
```

```r
# 2nd order differences
D2 <- diff(diag(6),differences=2)
D2
```

```
##      [,1] [,2] [,3] [,4] [,5] [,6]
## [1,]    1   -2    1    0    0    0
## [2,]    0    1   -2    1    0    0
## [3,]    0    0    1   -2    1    0
## [4,]    0    0    0    1   -2    1
```

```r
# Penalty matrices
P1 <- t(D1)%*%D1
P2 <- t(D2)%*%D2

P1
```

```
##      [,1] [,2] [,3] [,4] [,5] [,6]
## [1,]    1   -1    0    0    0    0
## [2,]   -1    2   -1    0    0    0
## [3,]    0   -1    2   -1    0    0
## [4,]    0    0   -1    2   -1    0
## [5,]    0    0    0   -1    2   -1
## [6,]    0    0    0    0   -1    1
```

```r
P2
```

```
##      [,1] [,2] [,3] [,4] [,5] [,6]
## [1,]    1   -2    1    0    0    0
## [2,]   -2    5   -4    1    0    0
## [3,]    1   -4    6   -4    1    0
## [4,]    0    1   -4    6   -4    1
## [5,]    0    0    1   -4    5   -2
## [6,]    0    0    0    1   -2    1
```


The next Figure illustrates the $P$-spline fit with different values of the smoothing parameter $\lambda$ and second order penalty $d=2$.


```r
ndx = 10
pord <- 2
lam <- c(1e-3,10,100)
plot(x,y,col="grey",pch=19,cex=.55); title(paste("ndx = ",ndx, "and d =", pord))
for(i in 1:3){
B <- bspline(x,xl,xr,ndx=ndx,bdeg=3)$B
D <- diff(diag(ncol(B)),differences=pord)
P <- lam[i]*t(D)%*%D
fit <- B%*%solve(t(B)%*%B + P,t(B)%*%y)
lines(x,fit,col=i,lwd=3,lty=1)
}
legend("topright", lty=1,col=1:3,lwd=4, legend = as.expression(lapply(lam, function(m)bquote(lambda ==.(m)))))
```

![*B-spline regression with different values of the smoothing parameter*](R-jjseb3_files/figure-html/unnamed-chunk-8-1.png)


The next Figure illustrates the $P$-spline fit with different values of $\lambda$. The basis function multiplied by the coefficients and the regression coefficients are also represented in the plots. The equally-spaced knots are represented by squares ($\blacksquare$) and the coefficients by $\circ$. It results clear to visualize the fact that as the penalty increases it forces the coefficient to be smooth.


```r
ndx = 15
pord <- 2
lam <- c(1e-3,1,100,1000)
par(mfrow=c(2,2))
for(i in 1:4){
plot(x,y,col="grey",pch=19,cex=.55); title(bquote(lambda == .(lam[i])))
Basis <- bspline(x,0,1,ndx=ndx,bdeg=3)
B <- Basis$B
knots <- Basis$knots
D <- diff(diag(ncol(B)),differences=pord)
P <- lam[i]*t(D)%*%D
theta <- solve(t(B)%*%B + P,t(B)%*%y)
fit <- B%*%theta
lines(x,fit,col=i,lwd=3,lty=1)
matlines(x,B%*%diag(c(theta)),col=i,lty=2)
points(knots,0*knots,col=i,cex=1.5,lwd=2.5,pch=15)
points(knots[-c(1:2,length(knots)-1,length(knots))],theta,col=i,cex=1.5,lwd=2.5)
}
```

![*P-spline regression fit with basis and coefficients*](R-jjseb3_files/figure-html/unnamed-chunk-9-1.png)

## Effective degrees of freedom

In a $P$-spline model with $\lambda=0$ the degrees of freedom of the model corresponds to the number of columns (regression coefficients) of the basis function $\boldsymbol{B}$, in contrast, with a large $\lambda \rightarrow \infty$ the model is not very flexible and there are few degrees of freedom. 


The degrees of freedom are computed analogously to linear models as the trace of the so-called hat matrix 

$$
\boldsymbol{H} = \boldsymbol{B} ( \boldsymbol{B}^\prime  \boldsymbol{B} + \lambda  \boldsymbol{D}^\prime \boldsymbol{D})^{-1}\boldsymbol{B}^\prime,
$$

where 
$$\mathrm{tr}(\boldsymbol{H}) = \mathrm{tr}(\boldsymbol{B}^\prime \boldsymbol{B} + \lambda\boldsymbol{D}^\prime \boldsymbol{D})^{-1} \boldsymbol{B}^\prime\boldsymbol{B}.$$


**Residual variance**
Another parameter of interest is the estimation of the residual variance $\hat{\sigma}^2$. For Gaussian errors, we use

$$
\hat{\sigma}^2 = \frac{\mathrm{RSS}}{n-\mathrm{tr}(\boldsymbol{H})},
$$
where $\mathrm{RSS}$ is the residual sum of squares, i.e. $\sum_{i=1}^{n} (y_i - \hat{y}_i )^2$.

The function `psfit` below, estimates a $P$-spline for a given $\lambda$ using the function `ls.fit` and giving the generalized cross validation criteria value `gcv`. 



```r
# Function to fit a Gaussian P-spline for given lambda
psfit <- function(x,y,pord=2,ndx=10,lambda=1){
    xl = min(x)
    xr = max(x)
   n <- length(y)
   B <- bspline(x,xl,xr,ndx,bdeg=3)$B
  nb <- ncol(B)
   P <- diff(diag(nb),differences=pord)
  
   # Construct penalty stuff
   P <- sqrt(lambda) * diff(diag(nb), diff = pord)
nix = rep(0, nb - pord)

    # Fit
    f = lsfit(rbind(B, P), c(y, nix), intercept = FALSE)
    h = hat(f$qr)[1:n]
    theta = f$coef
    f.hat = B %*% theta
    
   # Cross-validation and dispersion
    trH <- sum(h)
    rss <- sum((y-f.hat)^2)
    gcv <- n*rss/(n-trH)^2
    sigma = sqrt(rss / (n - trH))
   
   # Error bands ("Bayesian estimate")
    Covb = solve(t(B) %*% B + t(P) %*% P)
    Covz = sigma ^ 2 * B %*% Covb %*% t(B)
    seb = sqrt(diag(Covz))

output <- list(gcv=gcv,sigma=sigma,
               f=f,theta=theta,f.hat=f.hat,seb=seb,trH=trH)
  return(output)
}
```

## Choosing $\lambda$

We can use generalized cross-validation criteria:
$$
\mathrm{GCV} =  \sum_{i=1}^{n} \frac{y_i - \hat{y}_i}{ n - \mathrm{tr}(\boldsymbol{H})}, 
$$
or $\mathrm{AIC}$
$$
    \mathrm{AIC} = 2 \log \left( \sum_{i=1}^{n} (y_i - \hat{y}_i )^2\right) - 2 \log(n) + 2\log(\mathrm{tr}{\boldsymbol{H}})
$$


<div class="figure" style="text-align: center">
<img src="R-jjseb3_files/figure-html/unnamed-chunk-11-1.png" alt="*P-spline fit with confidence bands computed with `psfit`*"  />
<p class="caption">*P-spline fit with confidence bands computed with `psfit`*</p>
</div>



```r
# plot of GCV criteria is more useful
lla = seq(-2, 2, by = 0.10)
cvs = 0 * lla
for (k in 1:length(lla)) {
  lambda = 10 ^ lla[k]
  pn =  psfit(x,y, lambda = lambda)
  cvs[k] = pn$gcv
}
# 
lam.cv <- 10^(lla[which.min(cvs)])
lam.cv # lambda chosen by generalized cv
```

```
## [1] 5.011872
```

```r
fit.cv <- psfit(x,y,lambda=lam.cv)

fit.cv$sigma # estimated sigma error
```

```
## [1] 0.9630074
```

<div class="figure" style="text-align: center">
<img src="R-jjseb3_files/figure-html/unnamed-chunk-13-1.png" alt="*P-spline fit with confidence bands computed with `psfit` and smoothing parameter selected by minimizing gcv*"  />
<p class="caption">*P-spline fit with confidence bands computed with `psfit` and smoothing parameter selected by minimizing gcv*</p>
</div>




## Penalized splines as mixed models

The great popularity of $P$-splines during the last decade is due to the possibility of rewriting the non-parametric model as a mixed model (with random effects). Hence, we are able to use the methodology developed in the context of mixed models to smoothing and use the available mixed model software for estimation and inference. 


The connection between smoothing and mixed model was initially addressed by several authors (@Speed91, @Verbyla99 and @Brumback98). The idea is to reformulate the smoothing model as a mixed-effects model:

$$
\begin{array}{rcl}
   \boldsymbol{y} &=& \boldsymbol{B}\boldsymbol{\theta}+\boldsymbol{\epsilon} \quad
  \boldsymbol{\epsilon}\sim \mathcal{N}(0,\sigma^2\boldsymbol{I})\quad \text{is reformulated as}\\
 \boldsymbol{y}&=&\boldsymbol{X} \boldsymbol{\beta} +\boldsymbol{Z} \boldsymbol{u} +\boldsymbol{\epsilon} \quad \boldsymbol{u}\sim \mathcal{N}(0,\boldsymbol{G}) \text{ and }\boldsymbol{\epsilon}\sim \mathcal{N}(0,\sigma^2\boldsymbol{I})
\end{array}
$$

where $\boldsymbol{G} =  \sigma_u^2\boldsymbol{Q}^{-1}$ is the variance-covariance matrix of the random effects $\boldsymbol{u}$ that depends on $\sigma_u^2$ and a matrix $\boldsymbol{Q}$.


@Wand03 uses truncated power functions for the construction of $\boldsymbol{X}$ and $\boldsymbol{Z}$ where:

$$
    \boldsymbol{X} = [1,x,x^2,...,x^p] \text{ and } \boldsymbol{Z} =[(x_i - k_\kappa)^p_+]\quad 1 \leq i \leq n \text{ and } 1\leq k \leq \kappa
$$

Using $B$-splines we have different alternatives, e.g.:

* @Eilers99 proposed 

$$
    \boldsymbol{X} = [1,x,x^2,...,x^p] \text{ and } \boldsymbol{Z} = \boldsymbol{B}\boldsymbol{D}^\prime(\boldsymbol{D}^\prime \boldsymbol{D})^{-1}
$$

* @Currie02 proposed the use of the singular value decomposition of the matrix $\boldsymbol{D}^\prime \boldsymbol{D}$, i.e.:
$$
    \boldsymbol{X} = [1,x,x^2,...,x^p] \text{ and } \boldsymbol{Z} = \boldsymbol{B}\boldsymbol{U}_s {\boldsymbol{\Sigma}}_s^{-1/2}
$$
where $\boldsymbol{U}_s$ are the left singular vectors (of the *span*) of the SVD of $\boldsymbol{D}^\prime\boldsymbol{D} = \boldsymbol{U}\boldsymbol{\Sigma}\boldsymbol{V}^\prime$. 

In both reparameterizations we obtain the mixed model 
$$
 \boldsymbol{y}=\boldsymbol{X} \boldsymbol{\beta} +\boldsymbol{Z} \boldsymbol{u} +\boldsymbol{\epsilon} \quad \boldsymbol{u}\sim \mathcal{N}(0,\boldsymbol{G}) \text{ and }\boldsymbol{\epsilon}\sim \mathcal{N}(0,\sigma^2\boldsymbol{I})
$$
where $\boldsymbol{Q}=\boldsymbol{I}_{c-q}$ and then $\boldsymbol{G}=\sigma_u^2\boldsymbol{I}_{c-q}$ is multiple of a diagonal matrix. $c$ is the number of columns of the original basis $\boldsymbol{B}$ and $q$ is the order of the penalty (usually $q=2$). Then the smoothing parameter becomes the ratio $\lambda=\sigma^2 / \sigma_u^2$. 


### Estimation of the variance components, and fixed and random effects $\beta$ and $u$

In the context of mixed models the standard method for estimating the variance components is *restricted or residual maximum likelihood* (REML)

$$
   \ell_R(\sigma^2_u,\sigma^2) = - \frac{1}{2} \log |\boldsymbol{V}| - \frac{1}{2} \log
    |\boldsymbol{X}^\prime \boldsymbol{V}^{-1} \boldsymbol{X}| -  \frac{1}{2}\boldsymbol{y}^\prime
  (\boldsymbol{V}^{-1} - \boldsymbol{V}^{-1} \boldsymbol{X} (\boldsymbol{X}^\prime
   \boldsymbol{V}^{-1} \boldsymbol{X})^{-1} \boldsymbol{X}^\prime \boldsymbol{V}^{-1} )\boldsymbol{y}, 
$$ 

where $\boldsymbol{V}  = \sigma^2 \boldsymbol{I} + \boldsymbol{Z}\boldsymbol{G}\boldsymbol{Z}^\prime$ and

$$
 \begin{array}{rcl}
  \boldsymbol{\beta} & = & (\boldsymbol{X}\boldsymbol{V}^{-1}\boldsymbol{X} ) \boldsymbol{X}^\prime \boldsymbol{V}^{-1} \boldsymbol{y}\\
  \boldsymbol{u} & = & \sigma_u^2 \boldsymbol{Z}^\prime \boldsymbol{V}^{-1}(\boldsymbol{y}-\boldsymbol{X}\hat{\boldsymbol{\beta}})
 \end{array}
$$
 with $\boldsymbol{V}^{-1} = 1/\sigma^2 (\boldsymbol{I} - \boldsymbol{Z}(\boldsymbol{Z}^\prime \boldsymbol{Z} + (\sigma^2/\sigma_u^2)\boldsymbol{I}_{c-q})^{-1}\boldsymbol{Z}^\prime)$.
 
 
 In the mixed models context, we can consider more complex structures, e.g. correlated data, with $\epsilon \sim \mathcal{N}(0,\sigma^2\boldsymbol{\Omega})$, where $\boldsymbol{\Omega}$ is a correlation matrix (e.g. $AR(1)$). We will discuss this situation later on.
 
 
 

# Software 

In this section we will focus on the use of penalized splines with `R` software. Although many `R` packages are available, `library(mgcv)` has become a very popular package which implements a wide variety of flexible models for smoothing via the function `gam` (for generalized additive models). For the mixed model reparameterization of a smooth model, the function `gamm` (for additive mixed models). However, first we will start introducing the function `spm` in `SemiPar` which uses the mixed model representation with truncated polynomials by @Ruppert03. 


## ``spm`` function in ``library(SemiPar)`` 

For illustration we consider the fossil data described by @Chaudhuri99



```r
library(SemiPar)
data(fossil)
attach(fossil)
y <- 10000*strontium.ratio
x <- age
```

We can fit the model with `spm` function, specifyng the smooth term with `f()`, i.e.:


```r
fit.spm <- spm(y ~ f(x, basis="trunc.poly", degree=3))
summary(fit.spm)
```

```
## 
## 
## Summary for non-linear components:
## 
##        df  spar knots
## f(x) 8.87 3.419    25
## 
## Note this includes 1 df for the intercept.
```

Fitted curve can be simply plotted with


```r
plot(fit.spm, xlab="Age", ylab="Ratio of strotium isotopes (x10,000)") 
points(x,y,pch=15,col="red") # add points
```

<div class="figure" style="text-align: center">
<img src="R-jjseb3_files/figure-html/unnamed-chunk-16-1.png" alt="*P-splines fit using the mixed model reparameterization by @Ruppert03*"  />
<p class="caption">*P-splines fit using the mixed model reparameterization by @Ruppert03*</p>
</div>

The object fitted by `spm` has three components:

```r
names(fit.spm)
```

```
## [1] "fit"  "info" "aux"
```
* `$fit` containing the same information as a `lme` object

```r
names(fit.spm$fit)
```

```
##  [1] "modelStruct"  "dims"         "contrasts"    "coefficients"
##  [5] "varFix"       "sigma"        "apVar"        "logLik"      
##  [9] "numIter"      "groups"       "call"         "terms"       
## [13] "method"       "fitted"       "residuals"    "fixDF"       
## [17] "na.action"    "data"         "sigma"        "coef"
```
* `$info` with information about the model, the bases, the knots, degree of the polynomial, etc...

```r
names(fit.spm$info)
```

```
## [1] "formula"   "y"         "intercept" "lin"       "pen"       "krige"    
## [7] "off.set"   "trans.mat"
```
* `$aux` with the covariance matrix of the fixed and random effects (`$cov.mat`), the estimated variance of the random effects $\hat{\sigma}^2$ (`$random.var`), the residual variance $\hat{\sigma}^2$ (`$error.var`) and the approximated degrees of freedom for each component `$df`.

```r
names(fit.spm$aux)
```

```
## [1] "cov.mat"    "df"         "block.inds" "resid.var"  "random.var"
## [6] "df.fit"     "df.res"     "mins"       "maxs"
```
For more details see @Ngo04.


## ``mgcv`` package

The main reference for this section is the book by @Wood06book.


### The `gam` function 



```r
library(mgcv)
fit.gam <- gam(y ~ s(x))
```

Now we plot the fitted curve with confidence bands


```r
# See ?plot.gam for plotting options
plot(fit.gam,shade=TRUE,seWithMean=TRUE,pch=19,1,cex=.55)
```

<div class="figure" style="text-align: center">
<img src="R-jjseb3_files/figure-html/unnamed-chunk-22-1.png" alt="*Smooth fit with `mgcv`'s `gam` function*"  />
<p class="caption">*Smooth fit with `mgcv`'s `gam` function*</p>
</div>


The main function for smoothing with `mgcv` is `gam`. For example:


```r
gam(formula,method="",select="",family=gaussian())
```

The main arguments for this function must be specified as a `formula`:

  * The first choice is the basis used to represent the smooth terms `s(x)` (See `?s` or `?smooth.terms`). The default is to use the thin plate splines. The type of basis function can be modified using `bs` argument inside `s(x,bs="ps")`, where `ps` uses P-splines. Other alternatives are describe in the next Table (from @Wood06book, page 226)



**`bs`**        |  **Description**      
----------------|-----------------------
`"tp"`          | Thin Plate Regression Splines 
`"ts"`          | Thin Plate Regression Splines with Shrinkage 
`"cr"`          | Cubic regression spline
`"crs"`         | Cubic regression spline with Shrinkage
`"cc"`          | Cyclic cubic regression spline
`"ps"`          | P-splines (see `?p.spline`)



 * `m` The order of the penalty. 
 * `k` the dimension of the basis used to represent the smooth term. `k` should not be less than the dimension of the null space of the penalty for the term (the order of the penalty `m`).
 * `by` a numeric or factor variable of the same dimension as each covariate.
 * `sp` any supplied smoothing parameter for the smooth term.
 * `fx` indicates whether the term is a fixed e.d.f. regression spline (`TRUE`) or a penalized regression spline (`FALSE`).
 * `id` used to allow different smooths to be forced to use the same basis and smoothing parameter


For more option in function `gam` see `?gam`, i.e. `method` for the selection of the smoothing parameter (in general likelihood-based methods tend to be more robust)

 * `method= ` choosing between `"REML"`, `"ML"` `"GCV.Cp"`, `"GACV.Cp"`
 
`gam` returns and object of class `"gam"`, which can be further used with method functions such as `print`, `summary`, `fitted`, `plot`, `residuals`, etc ...



```r
summary(fit.gam)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## y ~ s(x)
## 
## Parametric coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 7073.7412     0.0255  277398   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##        edf Ref.df     F p-value    
## s(x) 8.339  8.876 87.86  <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =  0.881   Deviance explained =   89%
## GCV = 0.075588  Scale est. = 0.068928  n = 106
```

`gam.check` function produces some basic residual plots, and provides some information related to the fitting procces


```r
gam.check(fit.gam)
```

<div class="figure" style="text-align: center">
<img src="R-jjseb3_files/figure-html/unnamed-chunk-25-1.png" alt="*Diagnostics for fitted gam model with `gam.check`, see `?gam.check` for details*"  />
<p class="caption">*Diagnostics for fitted gam model with `gam.check`, see `?gam.check` for details*</p>
</div>

```
## 
## Method: GCV   Optimizer: magic
## Smoothing parameter selection converged after 7 iterations.
## The RMS GCV score gradiant at convergence was 4.638002e-06 .
## The Hessian was positive definite.
## The estimated model rank was 10 (maximum possible: 10)
## Model rank =  10 / 10 
## 
## Basis dimension (k) checking results. Low p-value (k-index<1) may
## indicate that k is too low, especially if edf is close to k'.
## 
##         k'   edf k-index p-value
## s(x) 9.000 8.339   0.941    0.23
```



Other residual plots should be examined, e.g.:


```r
plot(fitted(fit.gam),residuals(fit.gam))
```

<div class="figure" style="text-align: center">
<img src="R-jjseb3_files/figure-html/unnamed-chunk-26-1.png" alt="*Residuals plots*"  />
<p class="caption">*Residuals plots*</p>
</div>

As you may have noticed, there are some choices to make, specially the dimension `k` of the basis used to represent the smooth term. The choice of basis dimensions amounts to setting the maximum possible degress of freedom allowed to the smooth term. Usually, the choice of `k` makes sligth (almost negligible) difference as long as enough flexibility is provided (see `?choose.k`). Sometimes the choice of `k` depends on the computational efficiency (size of the basis for large data sets). 


```r
fit10.gam <- gam(y~s(x,k=10,bs="ps"), method="REML")
fit20.gam <- gam(y~s(x,k=20,bs="ps"))
fit30.gam <- gam(y~s(x,k=30,bs="ps"))
fit40.gam <- gam(y~s(x,k=40,bs="ps"))

x.seq <- seq(min(x),max(x),l=100)
plot(x,y,cex=.55,pch=15)
lines(x.seq,predict(fit10.gam,data.frame(x=x.seq)),col=2,lwd=3)
lines(x.seq,predict(fit20.gam,data.frame(x=x.seq)),col=3,lwd=3)
lines(x.seq,predict(fit30.gam,data.frame(x=x.seq)),col=4,lwd=3,lty=2)
lines(x.seq,predict(fit40.gam,data.frame(x=x.seq)),col=5,lwd=3,lty=3)
legend("bottomleft",paste(" k = ", c(10,20,30,40)),col=2:5,lwd=4)
```

<div class="figure" style="text-align: center">
<img src="R-jjseb3_files/figure-html/unnamed-chunk-27-1.png" alt="*Different smooth fits for $k=10,20,30,40$*"  />
<p class="caption">*Different smooth fits for $k=10,20,30,40$*</p>
</div>



### The `gamm` function 


`mgcv` library includes the function `gamm` which fits a generalized additive mixed model (GAMM) based on linear mixed models as implemented in the `nmle` library. The function is a wrapper of `lme` and `glmmPQL` in `MASS` library. Its purpose is to perform the reparametrization of the smooth model into a mixed models as shown in Section 2.6.



```r
gamm(formula,method="",random=NULL,correlation=NULL,select="",family=gaussian())
```


```r
fit.gamm <- gamm(y ~s(x,bs="ps",k=20), method="REML") 
```

The fitted object with `gamm` returns a list with two components: `$lme` is the object returned by `lme`; `$gam` is the complete object of class `gam` which can be treated like a `gam` object for prediction, plotting etc ...


```r
summary(fit.gamm$gam)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## y ~ s(x, bs = "ps", k = 20)
## 
## Parametric coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 7073.7412     0.0245  288713   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##        edf Ref.df     F p-value    
## s(x) 10.33  10.33 82.07  <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =   0.89   
##   Scale est. = 0.063631  n = 106
```

```r
summary(fit.gamm$lme)
```

```
## Linear mixed-effects model fit by REML
##  Data: strip.offset(mf) 
##        AIC     BIC    logLik
##   56.57453 67.1521 -24.28727
## 
## Random effects:
##  Formula: ~Xr - 1 | g
##  Structure: pdIdnot
##               Xr1       Xr2       Xr3       Xr4       Xr5       Xr6
## StdDev: 0.1277468 0.1277468 0.1277468 0.1277468 0.1277468 0.1277468
##               Xr7       Xr8       Xr9      Xr10      Xr11      Xr12
## StdDev: 0.1277468 0.1277468 0.1277468 0.1277468 0.1277468 0.1277468
##              Xr13      Xr14      Xr15      Xr16      Xr17      Xr18
## StdDev: 0.1277468 0.1277468 0.1277468 0.1277468 0.1277468 0.1277468
##          Residual
## StdDev: 0.2522526
## 
## Fixed effects: y.0 ~ X - 1 
##                 Value Std.Error  DF   t-value p-value
## X(Intercept) 7073.741 0.0245009 104 288713.12  0.0000
## Xs(x)Fx1        0.108 0.3215396 104      0.34  0.7372
##  Correlation: 
##          X(Int)
## Xs(x)Fx1 0     
## 
## Standardized Within-Group Residuals:
##         Min          Q1         Med          Q3         Max 
## -2.38374441 -0.59772858  0.02233536  0.60088298  2.41386908 
## 
## Number of Observations: 106
## Number of Groups: 1
```

Note that the main difference between `fit.gamm` fitted with `gamm` and `fit20.gam` with `gam` is how the smoothing parameter is estimated (REML vs GCV), and hence the results are basically the same. 


## ``lme`` package

We saw that the P-splines has a mixed model representation in Section 2.6. In this section we will see how we can use the function `lme` in `library(nlme)` for smoothing. Note, that this is what `gamm` function is doing internally, but we will show how you can construct all the elements by yourself.

The `R` functions `mixed.model.B` and `mixed.model.T` creates the mixed model bases $\boldsymbol{X}$ and $\boldsymbol{Z}$ based on the methods described in Section 2.6.



```r
# Mixed model representation of B-splines (using svd)
mixed.model.B<-function(x,xl,xr,ndx,bdeg,pord,type="Eilers"){
  Bbasis=bspline(x,xl,xr,ndx,bdeg)
  B <- Bbasis$B
  m=ncol(B)
  D=diff(diag(m),differences=pord)
  
  if(type=="Eilers"){
  Z <- B%*%t(D)%*%solve(D%*%t(D))
  }else if(type=="SVD"){ print("SVD method")
  P.svd=svd(t(D)%*%D)
  U=(P.svd$u)[,1:(m-pord)]
  d=(P.svd$d)[1:(m-pord)]
  Delta=diag(1/sqrt(d))
  Z=B%*%U%*%Delta
  }
  X=NULL
    for(i in 0:(pord-1)){
        X=cbind(X,x^i)
        }
  output <- list(X=X,Z=Z)
  return(output)
}
  
# Mixed model representation using Truncated Power Functions (as in Ruppert, Wand and Carroll)
mixed.model.T<- function(x,ndx,bdeg){
  knots <- quantile(unique(x),seq(0,1,length=ndx+2))[-c(1,ndx+2)]
  Z<-tpoly(x,knots,bdeg)
  X<-NULL
    for(i in 0:bdeg){X=cbind(X,x^i)}
  output <- list(X=X,Z=Z)
  return(output)
}
```

First we create the bases


```r
# Create MM bases
nseg = 20
MM <- mixed.model.B(x,min(x)-0.01,max(x)+0.01,ndx=nseg,bdeg=3,pord=2,type="Eilers")
names(MM)
```

```
## [1] "X" "Z"
```

```r
X <- MM$X
Z <- MM$Z
```

In order to use `lme` we need the to provide the information in the correct way: 


```r
library(nlme)
n <- length(y)

Id <- factor(rep(1,n))  # create an Id factor for each observation (individual)
                        #  hence there is no nesting

# random effects has a cov matrix multiple of the Identity
Z.block <- list(list(Id=pdIdent(~Z-1)))
Z.block <- unlist(Z.block,recursive=FALSE)

data.fr <- groupedData(y ~ X[,-1] | Id, 
                       data=data.frame(y,X,Z)) 

fit.lme <- lme(y ~ X[,-1],data=data.fr,
               random=Z.block) # method="REML" by default

class(fit.lme)
```

```
## [1] "lme"
```

What can we get from `fit.lme`?

* $\hat{\sigma}^2$  

```r
sig2 <- fit.lme$sigma^2
```

* $\hat{\sigma}_\alpha^2$  

```r
sig2.alpha <- sig2*exp(2*unlist(fit.lme$modelStruct))
```

* $REML$ score

```r
reml <- fit.lme$logLik
```

* $\hat{\beta}$  

```r
beta.hat <- fit.lme$coeff$fixed
```

* $\hat{\alpha}$  

```r
alpha.hat <- unlist(fit.lme$coeff$random)
```

* $\hat{f}$ 

```r
f.hat <- c(X%*%beta.hat + Z%*%alpha.hat[1:ncol(Z)])
d <- ncol(fit.lme$fitted)
f.hat <- fit.lme$fitted[,d]
```

* Confidence Intervals of the fitted curve $\hat{f}$

```r
# 1st we create a function to obtain 95% CI's from a fitted lme object
Int.Conf<-function(X,Z,f.hat,sigma2,sigma2.alpha) 
{
C=cbind(X,Z)
D=diag(c(rep(0,ncol(X)),rep(sigma2/sigma2.alpha,ncol(Z))))
S=sigma2*rowSums(C%*%solve(t(C)%*%C+D)*C)
IC1=f.hat-1.96*sqrt(S)
IC2=f.hat+1.96*sqrt(S)
IC=cbind(IC1,IC2)
colnames(IC) <- c("lower","upper")
IC
}

ci <- Int.Conf(X,Z,f.hat,sig2,sig2.alpha)
```

We can now plot the fitted curve and the CI's


```r
plot(x,y,cex=.65,pch=15,col="grey")
lines(x[order(x)],f.hat[order(x)],col=2,lwd=3)
matlines(x[order(x)],ci[order(x)],col=4,lty=2,lwd=3)
```

Or on a finer grid


```r
# Predict
x.grid <- seq(min(x),max(x),l=200)
MM.grid <- mixed.model.B(x.grid,min(x.grid)-0.01,max(x.grid)+0.01,
                         ndx=nseg,bdeg=3,pord=2,type="Eilers")
X.grid <- MM.grid$X
Z.grid <- MM.grid$Z

# Compute the fitted curve on a finer grid of x points
f.hat.grid <- c(X.grid%*%beta.hat+Z.grid%*%alpha.hat)

ci.grid <- Int.Conf(X.grid,Z.grid,f.hat.grid,sig2,sig2.alpha)
plot(x,y,cex=.65,col="grey")
lines(x.grid,f.hat.grid,col=2,lwd=3)
matlines(x.grid,ci.grid,lwd=2,lty=2,col=4)
```

We can use `gam` with GLM's by specifying the argument `family` as in the `glm` function. For instance:


```r
library(mgcv)
# Poisson example
n = 100
x <- seq(0,1,l=n)
f <- sin(2.8*x*pi)
g <- exp(f)
z <- rpois(rep(1,n),g) # simulate a Poisson response vble with mean exp(f)

# gam fit 
fit.pois <- gam(z ~ s(x,bs="ps",m=2,k=40),family=poisson,
                method="REML")

# gamm fit (using PQL)
fit.pois2 <- gamm(z ~ s(x,bs="ps",m=2,k=40),family=poisson,
                  method="REML")
```

```
## 
##  Maximum number of PQL iterations:  20
```


![*Simulated example with Poisson data*](R-jjseb3_files/figure-html/unnamed-chunk-44-1.png)

As mentioned before, 



```r
library(MASS)

# Create MM bases
nseg = 20
MM <- mixed.model.B(x,min(x)-0.01,max(x)+0.01,
                    ndx=nseg,bdeg=3,pord=2,type="Eilers")
names(MM)
X <- MM$X
Z <- MM$Z
n <- length(z)

# create Id factor and Z.block as shown in lme
Id <- factor(rep(1,n))  # create an Id factor for each observation (individual)
                        #  hence there is no nesting

Z.block <- list(list(Id=pdIdent(~Z-1)))
Z.block <- unlist(Z.block,recursive=FALSE)

data.fr <- groupedData(z ~ X[,-1] | Id,
                       data=data.frame(z,X,Z))

# fit with glmmPQL function in library(MASS)

fit.pois.glmmPQL <- glmmPQL(z ~ X[,-1], 
                            data=data.fr, random=Z.block, family=poisson)
```



# Applications

In this section we will present some examples using the smoothing techniques presented previously applied to some real examples. 





## Air quality data 

In this Section, we analyze the `data(airquality)` (see `?airquality`) consisting of air quality measurements in New York, from Maty to September 1973. The data frame contains with 154 observations on 6 variables.

* `[,1] Ozone`    	numeric	Ozone (ppb)
* `[,2]	Solar.R`	  numeric	Solar R (lang)
* `[,3]	Wind`	      numeric	Wind (mph)
* `[,4]	Temp`	      numeric	Temperature (degrees F)
* `[,5]	Month`	    numeric	Month (1--12)
* `[,6]	Day`	      numeric	Day of month (1--31)

For more details `?airquality`



```r
data(airquality)
pairs(airquality)
```

![*Scatterplot matrix*](R-jjseb3_files/figure-html/unnamed-chunk-47-1.png)

A simple scatterplot shows that some of the variables have a non-linear relationship.

Let us fit a GAM model, firstly with a single variable, i.e,:


```r
library(mgcv)
airq.gam1 <- gam(log(Ozone) ~ s(Wind,bs="ps",m=2,k=10), 
                 method="REML", select=TRUE,data=airquality)
summary(airq.gam1)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## log(Ozone) ~ s(Wind, bs = "ps", m = 2, k = 10)
## 
## Parametric coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   3.4185     0.0655   52.19   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##           edf Ref.df     F  p-value    
## s(Wind) 2.565      9 6.453 2.76e-12 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =  0.336   Deviance explained =   35%
## -REML = 128.69  Scale est. = 0.49769   n = 116
```

The results show that the smooth effect `s(Wind)` is significative (with an approximate $p$-value close to zero and `edf` $2.56$). The next Figure shows the smooth wind effect. The increment of the wind speed decreases the $\log$ Ozone levels (dramatically until 10mph). Note that including the intercept, the smooth effects are centered at zero. 



```r
plot(airq.gam1,residuals=TRUE,scheme=1)
```

![*Estimated smooth effect of `Wind` on `log(Ozone)`. Data points are the residuals*](R-jjseb3_files/figure-html/unnamed-chunk-49-1.png)





```r
gam.check(airq.gam1)
```

![*Check plots by `gam.check`*](R-jjseb3_files/figure-html/unnamed-chunk-50-1.png)

```
## 
## Method: REML   Optimizer: outer newton
## full convergence after 8 iterations.
## Gradient range [-1.455961e-06,1.183099e-06]
## (score 128.6926 & scale 0.4976891).
## Hessian positive definite, eigenvalue range [0.4379927,57.51548].
## Model rank =  10 / 10 
## 
## Basis dimension (k) checking results. Low p-value (k-index<1) may
## indicate that k is too low, especially if edf is close to k'.
## 
##            k'   edf k-index p-value
## s(Wind) 9.000 2.565   0.689       0
```



Note that, in model `airq.gam1` we used `k=10` knots, the variable `Wind` has $31$ unique values, and hence 10 knots should be enough. We fit a model for the residuals of the fitted gam model 



```r
resids <- residuals(airq.gam1)
resids.gam <- gam(resids~s(Wind,k=20,m=2),method="REML",
                  select=TRUE,data=airq.gam1$model)
summary(resids.gam)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## resids ~ s(Wind, k = 20, m = 2)
## 
## Parametric coefficients:
##              Estimate Std. Error t value Pr(>|t|)
## (Intercept) 1.137e-15  6.477e-02       0        1
## 
## Approximate significance of smooth terms:
##               edf Ref.df F p-value
## s(Wind) 7.419e-05     19 0       1
## 
## R-sq.(adj) =  -5.66e-07   Deviance explained = 7.89e-06%
## -REML = 124.14  Scale est. = 0.48659   n = 116
```

The results show that there is no unexplained variability between the variable and the residuals. Hence, we can conclude that we do not need more knots. The next Figure supports this statement.



```r
plot(resids.gam)
```

![*Wind effect vs the residuals of `airq.gam1`*](R-jjseb3_files/figure-html/unnamed-chunk-52-1.png)


```r
airq.pred <- data.frame(Wind=seq(min(airquality$Wind),max(airquality$Wind)),
                        length.out=200)
p <- predict(airq.gam1, newdata = airq.pred, type="response", se.fit = TRUE)

plot(airq.pred$Wind,p$fit, xlab="Wind", ylab="log(Ozone)", 
     type="l", ylim=c(0,6))
lines(airq.pred$Wind,p$fit + 1.96 * p$se.fit, lty=2)
lines(airq.pred$Wind,p$fit - 1.96 * p$se.fit, lty=2)
points(airquality$Wind,log(airquality$Ozone),cex=.55,col="grey", pch=15)
```

![*Predicted curve and CI's*](R-jjseb3_files/figure-html/unnamed-chunk-53-1.png)



Now we add the variable `Temp`:


```r
airq.gam2 <- gam(log(Ozone)~s(Wind,bs="ps",m=2,k=10)+s(Temp,bs="ps",m=2,k=10),
                 method="REML",select=TRUE,data=airquality)
summary(airq.gam2)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## log(Ozone) ~ s(Wind, bs = "ps", m = 2, k = 10) + s(Temp, bs = "ps", 
##     m = 2, k = 10)
## 
## Parametric coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  3.41852    0.04963   68.89   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##           edf Ref.df      F  p-value    
## s(Wind) 2.068      9  1.353 0.000981 ***
## s(Temp) 3.990      9 10.496  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =  0.619   Deviance explained = 63.9%
## -REML = 101.64  Scale est. = 0.28568   n = 116
```
Hence, the `Temp` effect is significative. The next Figure show both smooth effects.



```r
par(mfrow=c(1,2))
plot(airq.gam2,residuals=TRUE,scheme=1)
```

![*Estimated smooth effect of `Wind` and `Temp` on `log(Ozone)`. Data points are the residuals*](R-jjseb3_files/figure-html/unnamed-chunk-55-1.png)



We can compare both models using the function `anova` for a $F$-test:

```r
anova(airq.gam1,airq.gam2)
```

```
## Analysis of Deviance Table
## 
## Model 1: log(Ozone) ~ s(Wind, bs = "ps", m = 2, k = 10)
## Model 2: log(Ozone) ~ s(Wind, bs = "ps", m = 2, k = 10) + s(Temp, bs = "ps", 
##     m = 2, k = 10)
##   Resid. Df Resid. Dev     Df Deviance
## 1    111.16     55.958                
## 2    105.98     31.123 5.1832   24.835
```

We can conclude that `Temp` variable is relevant. Note that, strictly, in this case both models are not nested, as the effective dimension of the variable `Wind` is different when the variable `Temp` is present. Hence, we use the AIC to confirm the results. 



```r
AIC(airq.gam1)
```

```
## [1] 255.0315
```

```r
AIC(airq.gam2)
```

```
## [1] 195.6561
```

Now, we include the covariate `Solar.R`. Notice that this variables contains missing values (`NA`'s). 


```r
sum(is.na(airquality$Solar.R))
```

```
## [1] 7
```
In order to compare the previous model `airq.gam2` and the new model that includes `Solar.R` we will use the same data, so we will omit the missing values and refit the models.



```r
new.airquality <- na.omit(airquality)

airq.gam22=gam(log(Ozone)~s(Wind,bs="ps",m=2,k=10)+s(Temp,bs="ps",m=2,k=10),
               method="REML",select=TRUE,data=new.airquality)

airq.gam3=gam(log(Ozone)~s(Wind,bs="ps",m=2,k=10)+s(Temp,bs="ps",m=2,k=10)+s(Solar.R,bs="ps",m=2,k=20),
              method="REML",select=TRUE,data=new.airquality)

summary(airq.gam22)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## log(Ozone) ~ s(Wind, bs = "ps", m = 2, k = 10) + s(Temp, bs = "ps", 
##     m = 2, k = 10)
## 
## Parametric coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  3.41593    0.05128   66.61   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##            edf Ref.df     F  p-value    
## s(Wind) 2.1879      9 1.919    1e-04 ***
## s(Temp) 0.9874      9 8.601 7.73e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =  0.611   Deviance explained = 62.2%
## -REML = 95.215  Scale est. = 0.29194   n = 111
```

```r
summary(airq.gam3)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## log(Ozone) ~ s(Wind, bs = "ps", m = 2, k = 10) + s(Temp, bs = "ps", 
##     m = 2, k = 10) + s(Solar.R, bs = "ps", m = 2, k = 20)
## 
## Parametric coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  3.41593    0.04586   74.49   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##              edf Ref.df     F  p-value    
## s(Wind)    2.318      9 2.255 2.44e-05 ***
## s(Temp)    1.852      9 6.128 1.12e-12 ***
## s(Solar.R) 2.145     19 1.397 1.23e-06 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =  0.689   Deviance explained = 70.7%
## -REML = 86.106  Scale est. = 0.23342   n = 111
```

```r
AIC(airq.gam22)
```

```
## [1] 185.7769
```

```r
AIC(airq.gam3)
```

```
## [1] 166.0423
```

Is the `Solar.R` variable relevant?



The next Figure shows the estimated smooth effects for `Wind`, `Temp` and `Solar.R` covariables (partial residuals are also plotted). 



```r
par(mfrow=c(2,2))
plot(airq.gam3,residuals=TRUE)
```

![*Smooth effects of `Wind`, `Temp` and `Solar.R`*](R-jjseb3_files/figure-html/unnamed-chunk-60-1.png)

**Bivariate smoothing**

Tensor products in `mgcv` can be specified using the argument `te()` in the model formula. See `?te` 


```r
airq.tensor <- gam(log(Ozone)~te(Wind,Temp,bs="ps",m=2,k=10),
              method="REML",select=TRUE,data=new.airquality)

par(mfrow=c(1,2))
vis.gam(airq.tensor,plot.type = "persp")
vis.gam(airq.tensor,plot.type = "contour")
```

<img src="R-jjseb3_files/figure-html/unnamed-chunk-61-1.png" style="display: block; margin: auto;" />

`library(visreg)` includes several functions to visualize outputs from fitted models, e.g.: `visreg2d`



```r
library(visreg)

visreg2d(airq.tensor,x="Wind",y="Temp",plot.type = "image")
```

<img src="R-jjseb3_files/figure-html/unnamed-chunk-62-1.png" style="display: block; margin: auto;" />

```r
visreg2d(airq.tensor,x="Wind",y="Temp",plot.type = "persp")
```

<img src="R-jjseb3_files/figure-html/unnamed-chunk-62-2.png" style="display: block; margin: auto;" />


```r
airq.tensor <- gam(log(Ozone)~te(Wind,Temp,bs="ps",m=2,k=10)+s(Solar.R,bs="ps",m=2,k=10),
              method="REML",select=TRUE,data=new.airquality)
```




## Onions data 

To illustrate a simple case of a semi-parametric model, we consider the `data(onions)` in the `library(SemiPar)`. The data consist of 84 observations form an experiment involving the production of white Spanish onions in two South Australian locations. The variables are:


* `dens` areal density of plants (plants per square metre)

* `yield` onion yield (grammes per plant).

* `location` indicator of location: `0=Purnong Landing`, `1=Virginia`.

The next Figure shows that for higher density of plants the Purnong Landing yield of onios is greater.


```r
library(SemiPar)
data(onions)
attach(onions)
points.cols <- c("red","blue")
plot(dens,log(yield),col=points.cols[location+1],pch=16)
legend("topright",c("Purnong Landing","Virginia"),col=points.cols,pch=rep(16,2))
```

![*Onions yield in two locations*](R-jjseb3_files/figure-html/unnamed-chunk-64-1.png)


The linear model will be 

$$
    \log(\text{yield}_i) = \beta_0 + \beta_1\text{location}_{ij} + \beta_2 \text{dens}_i + \epsilon_i
$$

where


$$
\text{location}_{ij} = 
\left\{
        \begin{array}{cl}
        0 & \mbox{if the $i$th observation is from Purnong Landing} \\
        1 & \mbox{if the $i$th observation is from Virginia}
        \end{array}
\right.
$$


The Figure suggest a non-linear terms for `dens`, hence a better model would be:

$$
    \log(\text{yield}_i) = \beta_0 + \beta_1\text{location}_{ij} + f(\text{dens}_i) + \epsilon_i
$$


```r
# create a factor for location
L <- factor(location)

levels(L) <- c("Purnong Landing","Virginia")

# fit a gam with location factor
fit1 <- gam(log(yield) ~ L + s(dens,k=20,m=2,bs="ps"), 
            method="REML", select=TRUE)

summary(fit1)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## log(yield) ~ L + s(dens, k = 20, m = 2, bs = "ps")
## 
## Parametric coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  4.85011    0.01688  287.39   <2e-16 ***
## LVirginia   -0.33284    0.02409  -13.82   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##           edf Ref.df     F p-value    
## s(dens) 4.568     19 72.76  <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =  0.946   Deviance explained = 94.9%
## -REML = -54.242  Scale est. = 0.011737  n = 84
```


The next Figure shows the fitted curves for each location with model `fit1`, we assumed both curves are parallel.


![*Fitted curves for each location*](R-jjseb3_files/figure-html/unnamed-chunk-66-1.png)

Assuming parallel curves for both locations implies that the decrease of the yield as the density increases is the same in both locations. Instead of fitting an additive effect model we can fit an interaction effect model such as:

$$
     \log(\text{yield}_i) =\beta_0 + \beta_1 \beta_1\text{location}_{ij} +  f(\text{dens}_i)_{L(j)} + \epsilon_i
$$


where

$$
L(j) = 
\left\{
        \begin{array}{cl}
        0 & \mbox{if the $i$th observation is from Purnong Landing} \\
        1 & \mbox{if the $i$th observation is from Virginia}
        \end{array}
\right.
$$


```r
fit2 <- gam(log(yield) ~ L + s(dens,k=20,m=2,bs="ps",by=L), 
            method="REML", select=TRUE)
summary(fit2)
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## log(yield) ~ L + s(dens, k = 20, m = 2, bs = "ps", by = L)
## 
## Parametric coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  4.84407    0.01603  302.12   <2e-16 ***
## LVirginia   -0.33003    0.02271  -14.54   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##                            edf Ref.df     F p-value    
## s(dens):LPurnong Landing 3.097     18 37.62  <2e-16 ***
## s(dens):LVirginia        4.728     17 52.10  <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =  0.952   Deviance explained = 95.7%
## -REML = -53.616  Scale est. = 0.01045   n = 84
```

Which model is better?


```r
AIC(fit1)
```

```
## [1] -125.2307
```

```r
AIC(fit2)
```

```
## [1] -131.1844
```

```r
fit1$sp
```

```
##     s(dens)1     s(dens)2 
## 164.66124239   0.00147493
```

```r
fit2$sp
```

```
## s(dens):LPurnong Landing1 s(dens):LPurnong Landing2 
##              4.264039e+02              1.604648e-03 
##        s(dens):LVirginia1        s(dens):LVirginia2 
##              6.437458e+01              1.053443e-03
```



```r
# plot the smooth effects 
par(mfrow=c(2,2))
plot(fit2, se=TRUE)

# In the same plot
fit2.P <- predict(fit2,newdata=data.frame(L=L.P,dens=dens.g),se.fit=TRUE)
fit2.V <- predict(fit2,newdata=data.frame(L=L.V,dens=dens.g),se.fit=TRUE)

plot(dens,log(yield),col=points.cols[location+1],pch=16,cex=.55)
lines(dens.g,fit2.P$fit,col=2,lwd=2)
lines(dens.g,fit2.P$fit+1.96*fit1.P$se.fit,col=2,lwd=2,lty=2)
lines(dens.g,fit2.P$fit-1.96*fit1.P$se.fit,col=2,lwd=2,lty=2)
lines(dens.g,fit2.V$fit,col=4,lwd=2)
lines(dens.g,fit2.V$fit+1.96*fit2.V$se.fit,col=4,lwd=2,lty=2)
lines(dens.g,fit2.V$fit-1.96*fit2.V$se.fit,col=4,lwd=2,lty=2)
```

![*Fitted curves by location*](R-jjseb3_files/figure-html/unnamed-chunk-69-1.png)



## Correlated data


The data were analyzed in @Pandit83. They present  a  dataset (`wood.txt`) describing  320  measurements  of  a  block of wood that was subject to grinding. Next Figure shows the profile (depth) height at different distances. The profile variation follows a curve determined by the radius of the grinding stone. 

![*Profile of a block of wood subject to grinding*](R-jjseb3_files/figure-html/unnamed-chunk-70-1.png)

Using $P$-splines we can estimate a smooth trend and possible correlation simultaneously. The mixed model representation of $P$-splines helps us to estimate both effects pretty easily. Let us consider, firstly a smooth model that ignores the correlation between the observations. 

The left figure shows the estimated smooth trend. This shows that ignoring the correlation gives a non-smooth trend. The right panel show the autocorrelation function with correlation in the errors.



```r
library(mgcv)
cor.gamm0 <- gamm(depth ~ s(distance,k=40,bs="ps",m=2), method="REML")
par(mfrow=c(1,2))
plot(distance,depth,cex=.55,pch=15,col="grey")
lines(distance,fitted(cor.gamm0$gam),main="Smooth trend with AR(1)",lwd=2,col="blue")
acf(residuals(cor.gamm0$lme,type="n"), main="Residuals autocorrelation function")
```

![](R-jjseb3_files/figure-html/unnamed-chunk-71-1.png)<!-- -->

A correlated data model can be added with an AR(1) or AR(2) structure, i.e.


```r
# create a factor per observation
#  to define the correlation structure
Id <- factor(rep(1,length(depth)))

# AR(1)
cor.gamm1 <- gamm(depth ~ s(distance, k=40, bs="ps", m=2), 
                  correlation=corARMA(form=~distance|Id,p=1,q=0), 
                  method="REML")
# AR(2)
cor.gamm2 <- gamm(depth ~ s(distance, k=40, bs="ps", m=2), 
                  correlation=corARMA(form=~distance|Id,p=2,q=0),
                  method="REML")
```

The next Figure shows how including a correlation structure results in a smoother trend. In particular, the AR(2) model autocorrelation shows uncorrelated residuals. 


![*Smooth trends and ACF for AR(1) and AR(2) error models*](R-jjseb3_files/figure-html/unnamed-chunk-73-1.png)

Check the smoothing parameters

```r
print(c(cor.gamm0$gam$sp,cor.gamm1$gam$sp,cor.gamm2$gam$sp))
```

```
## s(distance) s(distance) s(distance) 
##    2.117994 3228.963757 2014.146325
```

We can compare the model using `anova` function

```r
anova(cor.gamm0$lme,cor.gamm1$lme,cor.gamm2$lme)
```

```
##               Model df      AIC      BIC    logLik   Test   L.Ratio
## cor.gamm0$lme     1  4 1850.568 1865.616 -921.2841                 
## cor.gamm1$lme     2  5 1653.212 1672.022 -821.6058 1 vs 2 199.35667
## cor.gamm2$lme     3  6 1638.010 1660.582 -813.0049 2 vs 3  17.20174
##               p-value
## cor.gamm0$lme        
## cor.gamm1$lme  <.0001
## cor.gamm2$lme  <.0001
```

## Smoothing and Forecasting Poisson Counts with P-Splines: `MortalitySmooth`


@Camarda12 [Journal of Stat Software](http://www.jstatsoft.org/v50/i01/)


**Description:** 

  + Smoothing one- and two-dimensional Poisson counts with  P-splines specifically tailored to mortality data.
  
  + Extra-Poisson variation can be accounted as well as forecasting.
  
  + Collection of mortality data and a specific function for selecting those data by country, sex, age and years.



```r
library("MortalitySmooth")
## selected data
ages <- 50:100
years <- 1950:2006
death <- selectHMDdata("Sweden", "Deaths", "Females",
ages = ages, years = years)
exposure <- selectHMDdata("Sweden", "Exposures", "Females",
ages = ages, years = years)
## fit with BIC
fitBIC <- Mort2Dsmooth(x=ages, y=years, Z=death,
offset=log(exposure))
fitBIC
```

```
## Call:
## Mort2Dsmooth(x = ages, y = years, Z = death, offset = log(exposure))
## 
## Number of Observations              : 2907 
##                     of which x-axis : 51 
##                              y-axis : 57 
## Effective dimension                 : 47.1391 
## (Selected) smoothing parameters       
##                          over x-axis: 1000 
##                          over y-axis: 316.23 
## Bayesian Information Criterion (BIC): 4118.3
```

```r
summary(fitBIC)
```

```
## Call:
## Mort2Dsmooth(x = ages, y = years, Z = death, offset = log(exposure))
## 
## Number of Observations                      : 2907 
##                             of which x-axis : 51 
##                                      y-axis : 57 
## Effective dimension                         : 47.14 
## (Selected) smoothing parameters               
##                                  over x-axis: 1000 
##                                  over y-axis: 316.23 
## Bayesian Information Criterion (BIC)        : 4118.3 
## Akaike's Information Criterion (AIC)        : 3836.6 
## (Estimated) overdispersion parameter (psi^2): 1.31 
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -4.49794 -0.80886 -0.05639  0.73204  4.02792 
## 
## Settings and control:
##   x-axis: 13 B-splines of degree 3 - differences of order 2 
##   y-axis: 14 B-splines of degree 3 - differences of order 2 
##   convergence tolerance : 1.7578e-12
```

```r
## plot age 50 log death rates (1st row)
plot(years, log(death[1,]/exposure[1,]),
main="Mortality rates, log-scale.
Swedish females, age 50, 1950:2006")
lines(years, fitBIC$logmortality[1,], col=2, lwd=2)
```

<img src="R-jjseb3_files/figure-html/unnamed-chunk-76-1.png" style="display: block; margin: auto;" />

```r
## plot over age and years
## fitted log death rates from fitBIC
grid. <- expand.grid(list(ages=ages, years=years))
grid.$lmx <- c(fitBIC$logmortality)
levelplot(lmx ~ years * ages , grid.,
at=quantile(grid.$lmx, seq(0,1,length=10)),
col.regions=rainbow(9))
```

<img src="R-jjseb3_files/figure-html/unnamed-chunk-76-2.png" style="display: block; margin: auto;" />


\newpage






# References

