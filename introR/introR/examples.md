# Some examples of data analysis using **R**
Dae-Jin Lee  
<dlee@bcamath.org>  



------------------------------------------------

# The Forbes 2000 Ranking of the World's Biggest Companies (Year 2004)

The data handling and manipulation techniques explained will be illustrated by means of a data set of 2000 world leading companies, the Forbes 2000 list for the year 2004 collected by Forbes Magazine. This list is originally available from `www.forbes.com`

Here we show a subset of the data set:


 rank  name                  country          category                 sales   profits    assets   marketvalue
-----  --------------------  ---------------  ---------------------  -------  --------  --------  ------------
    1  Citigroup             United States    Banking                  94.71     17.85   1264.03        255.30
    2  General Electric      United States    Conglomerates           134.19     15.59    626.93        328.54
    3  American Intl Group   United States    Insurance                76.66      6.46    647.66        194.87
    4  ExxonMobil            United States    Oil & gas operations    222.88     20.96    166.99        277.02
    5  BP                    United Kingdom   Oil & gas operations    232.57     10.27    177.57        173.54
    6  Bank of America       United States    Banking                  49.01     10.81    736.45        117.55

The data consists of 2000 observations on the following 8 variables.
    
  * `rank`: the ranking of the company.
  * `name`: the name of the company.
  * `country`: a factor giving the country the company is situated in.
  * `category`: a factor describing the products the company produces.
  * `sales`: the amount of sales of the company in billion USD.
  * `profits`: the profit of the company in billion USD. 
  * `assets`: the assets of the company in billion USD.
  * `marketvalue`: the market value of the company in billion USD.
    
## Types of variables

`R` output


```
## 'data.frame':	2000 obs. of  8 variables:
##  $ rank       : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ name       : chr  "Citigroup" "General Electric" "American Intl Group" "ExxonMobil" ...
##  $ country    : Factor w/ 61 levels "Africa","Australia",..: 60 60 60 60 56 60 56 28 60 60 ...
##  $ category   : Factor w/ 27 levels "Aerospace & defense",..: 2 6 16 19 19 2 2 8 9 20 ...
##  $ sales      : num  94.7 134.2 76.7 222.9 232.6 ...
##  $ profits    : num  17.85 15.59 6.46 20.96 10.27 ...
##  $ assets     : num  1264 627 648 167 178 ...
##  $ marketvalue: num  255 329 195 277 174 ...
```

## Factor levels

Nominal measurements are represented by factor variables in `R`, such as the country of the company or the category of the business segment.

A factor in `R` is divided into levels



How many countries are on the top 2000 ranking?

`R` output



```
## [1] 61
```

Which countries?

`R` output


```
##  [1] "Africa"                       "Australia"                   
##  [3] "Australia/ United Kingdom"    "Austria"                     
##  [5] "Bahamas"                      "Belgium"                     
##  [7] "Bermuda"                      "Brazil"                      
##  [9] "Canada"                       "Cayman Islands"              
## [11] "Chile"                        "China"                       
## [13] "Czech Republic"               "Denmark"                     
## [15] "Finland"                      "France"                      
## [17] "France/ United Kingdom"       "Germany"                     
## [19] "Greece"                       "Hong Kong/China"             
## [21] "Hungary"                      "India"                       
## [23] "Indonesia"                    "Ireland"                     
## [25] "Islands"                      "Israel"                      
## [27] "Italy"                        "Japan"                       
## [29] "Jordan"                       "Kong/China"                  
## [31] "Korea"                        "Liberia"                     
## [33] "Luxembourg"                   "Malaysia"                    
## [35] "Mexico"                       "Netherlands"                 
## [37] "Netherlands/ United Kingdom"  "New Zealand"                 
## [39] "Norway"                       "Pakistan"                    
## [41] "Panama/ United Kingdom"       "Peru"                        
## [43] "Philippines"                  "Poland"                      
## [45] "Portugal"                     "Russia"                      
## [47] "Singapore"                    "South Africa"                
## [49] "South Korea"                  "Spain"                       
## [51] "Sweden"                       "Switzerland"                 
## [53] "Taiwan"                       "Thailand"                    
## [55] "Turkey"                       "United Kingdom"              
## [57] "United Kingdom/ Australia"    "United Kingdom/ Netherlands" 
## [59] "United Kingdom/ South Africa" "United States"               
## [61] "Venezuela"
```

And in the top 20?

`R` output


```
## [1] "France"                      "Japan"                      
## [3] "Netherlands"                 "Netherlands/ United Kingdom"
## [5] "Switzerland"                 "United Kingdom"             
## [7] "United States"
```

As a simple summary statistic, the frequencies of the levels of such a factor variable can be found from


```
## 
##                      France                       Japan 
##                           2                           1 
##                 Netherlands Netherlands/ United Kingdom 
##                           1                           1 
##                 Switzerland              United Kingdom 
##                           1                           3 
##               United States 
##                          11
```


Which type of companies?


```
##  [1] "Aerospace & defense"              "Banking"                         
##  [3] "Business services & supplies"     "Capital goods"                   
##  [5] "Chemicals"                        "Conglomerates"                   
##  [7] "Construction"                     "Consumer durables"               
##  [9] "Diversified financials"           "Drugs & biotechnology"           
## [11] "Food drink & tobacco"             "Food markets"                    
## [13] "Health care equipment & services" "Hotels restaurants & leisure"    
## [15] "Household & personal products"    "Insurance"                       
## [17] "Materials"                        "Media"                           
## [19] "Oil & gas operations"             "Retailing"                       
## [21] "Semiconductors"                   "Software & services"             
## [23] "Technology hardware & equipment"  "Telecommunications services"     
## [25] "Trading companies"                "Transportation"                  
## [27] "Utilities"
```

How many of each category?


```
## 
##              Aerospace & defense                          Banking 
##                               19                              313 
##     Business services & supplies                    Capital goods 
##                               70                               53 
##                        Chemicals                    Conglomerates 
##                               50                               31 
##                     Construction                Consumer durables 
##                               79                               74 
##           Diversified financials            Drugs & biotechnology 
##                              158                               45 
##             Food drink & tobacco                     Food markets 
##                               83                               33 
## Health care equipment & services     Hotels restaurants & leisure 
##                               65                               37 
##    Household & personal products                        Insurance 
##                               44                              112 
##                        Materials                            Media 
##                               97                               61 
##             Oil & gas operations                        Retailing 
##                               90                               88 
##                   Semiconductors              Software & services 
##                               26                               31 
##  Technology hardware & equipment      Telecommunications services 
##                               59                               67 
##                Trading companies                   Transportation 
##                               25                               80 
##                        Utilities 
##                              110
```

A simple summary statistics such as the mean, median, quantiles and range can be found from continuous variables such as `sales`

`R` output


```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   0.010   2.018   4.365   9.697   9.548 256.300
```

## Simple Graphics

**Chambers et al. (1983)**, "there is no statistical tool that is as powerful as a well chosen graph"


Histograms and boxplots

![](examples_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

Scatterplots to visualize the relationship betwen variables


![](examples_files/figure-html/unnamed-chunk-11-1.png)<!-- -->

## Cool Graphics

Using the `ggplot2` library

![](examples_files/figure-html/unnamed-chunk-12-1.png)<!-- -->![](examples_files/figure-html/unnamed-chunk-12-2.png)<!-- -->![](examples_files/figure-html/unnamed-chunk-12-3.png)<!-- -->![](examples_files/figure-html/unnamed-chunk-12-4.png)<!-- -->


![](examples_files/figure-html/unnamed-chunk-13-1.png)<!-- -->

## Graphics by factor

Boxplots of the logarithms of the market value for four selected countries, the width of the boxes is proportional to the square roots of the number of companies.

![](examples_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

Scatterplots by country

![](examples_files/figure-html/. -1.png)<!-- -->

<!-- ## Questions -->


<!--   1. Calculate the median profit for the companies in the US and the median profit for the companies in the UK, France and Germany. -->
<!--   2. Find all German companies with negative profit. -->
<!--   3. To which business category do most of the Bermuda island companies belong? -->
<!--   4. For the 50 companies in the Forbes data set with the highest profits, plot sales against assets (or some suitable transformation of each variable), labelling each point with the appropriate country name which may need to be abbreviated (using abbreviate) to avoid making the plot look too "messy". -->
<!--   5. Find the average value of sales for the companies in each country in the Forbes data set, and find the number of companies in each country with profits above 5 billion US dollars. -->

 
-----------------------------------------


# Malignant Melanoma in the USA

Fisher and Belle (1993) report mortality rates due to malignant melanoma of the skin for white males during the period 1950-1969, for each state on the US mainland. 



                        mortality   latitude   longitude  ocean 
---------------------  ----------  ---------  ----------  ------
Alabama                       219       33.0        87.0  yes   
Arizona                       160       34.5       112.0  no    
Arkansas                      170       35.0        92.5  no    
California                    182       37.5       119.5  yes   
Colorado                      149       39.0       105.5  no    
Connecticut                   159       41.8        72.8  yes   
Delaware                      200       39.0        75.5  yes   
District of Columbia          177       39.0        77.0  no    
Florida                       197       28.0        82.0  yes   
Georgia                       214       33.0        83.5  yes   
Idaho                         116       44.5       114.0  no    
Illinois                      124       40.0        89.5  no    
Indiana                       128       40.2        86.2  no    
Iowa                          128       42.2        93.8  no    
Kansas                        166       38.5        98.5  no    
Kentucky                      147       37.8        85.0  no    
Louisiana                     190       31.2        91.8  yes   
Maine                         117       45.2        69.0  yes   
Maryland                      162       39.0        76.5  yes   
Massachusetts                 143       42.2        71.8  yes   
Michigan                      117       43.5        84.5  no    
Minnesota                     116       46.0        94.5  no    
Mississippi                   207       32.8        90.0  yes   
Missouri                      131       38.5        92.0  no    
Montana                       109       47.0       110.5  no    
Nebraska                      122       41.5        99.5  no    
Nevada                        191       39.0       117.0  no    
New Hampshire                 129       43.8        71.5  yes   
New Jersey                    159       40.2        74.5  yes   
New Mexico                    141       35.0       106.0  no    
New York                      152       43.0        75.5  yes   
North Carolina                199       35.5        79.5  yes   
North Dakota                  115       47.5       100.5  no    
Ohio                          131       40.2        82.8  no    
Oklahoma                      182       35.5        97.2  no    
Oregon                        136       44.0       120.5  yes   
Pennsylvania                  132       40.8        77.8  no    
Rhode Island                  137       41.8        71.5  yes   
South Carolina                178       33.8        81.0  yes   
South Dakota                   86       44.8       100.0  no    
Tennessee                     186       36.0        86.2  no    
Texas                         229       31.5        98.0  yes   
Utah                          142       39.5       111.5  no    
Vermont                       153       44.0        72.5  yes   
Virginia                      166       37.5        78.5  yes   
Washington                    117       47.5       121.0  yes   
West Virginia                 136       38.8        80.8  no    
Wisconsin                     110       44.5        90.2  no    
Wyoming                       134       43.0       107.5  no    

A data consists of 48 observations on the following 5 variables.

  * `mortality`: number of white males died due to malignant melanoma 1950-1969 per one million inhabitants.

  * `latitude`: latitude of the geographic centre of the state.

  * `longitude`: longitude of the geographic centre of each state.

  * `ocean`: a binary variable indicating contiguity to an ocean at levels `no` or `yes`.


## Plotting mortality rates



Let us plot mortality rates in 

<img src="examples_files/figure-html/unnamed-chunk-17-1.png" style="display: block; margin: auto;" /><img src="examples_files/figure-html/unnamed-chunk-17-2.png" style="display: block; margin: auto;" />

Malignant melanoma mortality rates by contiguity to an ocean

<img src="examples_files/figure-html/unnamed-chunk-18-1.png" style="display: block; margin: auto;" />

Histograms can often be misleading for displaying distributions because of their dependence on the number of classes chosen. An alternative is to formally estimate the density function of a variable and then plot the resulting estimate.

The estimated densities of malignant melanoma mortality rates by contiguity to an ocean looks like this:

<img src="examples_files/figure-html/unnamed-chunk-19-1.png" style="display: block; margin: auto;" />


Now we might move on to look at how mortality rates are related to the geographic location of a state as represented by the latitude and longitude of the centre of the state. 

<img src="examples_files/figure-html/unnamed-chunk-20-1.png" style="display: block; margin: auto;" />

## Mapping mortality rates

The data contains the longitude and latitude of the centroids 

<img src="examples_files/figure-html/unnamed-chunk-21-1.png" style="display: block; margin: auto;" />


<img src="examples_files/figure-html/unnamed-chunk-22-1.png" style="display: block; margin: auto;" />

<img src="examples_files/figure-html/unnamed-chunk-23-1.png" style="display: block; margin: auto;" />

<img src="examples_files/figure-html/unnamed-chunk-24-1.png" style="display: block; margin: auto;" />


# Drug Adverse Event Discovery

We can use some statistical techniques (unsupervised classification) to identify which drugs are associated with which adverse events. 

<!-- # Specifically, machine learning can help us to create clusters based on gender, age, outcome of adverse event, route drug was administered, purpose the drug was used for, body mass index, etc. This can help for quickly discovering hidden associations between drugs and adverse events. -->
<!-- #  -->
<!-- # Clustering is a non-supervised learning technique which has wide applications. Some examples where clustering is commonly applied are market segmentation, social network analytics, and astronomical data analysis. Clustering is grouping of data into sub-groups so that objects within a cluster have high similarity in comparison to other objects in that cluster, but are very dissimilar to objects in other classes. -->
<!-- #  -->
<!-- # Here, we will see how we can use hierarchical clustering to identify drug adverse events. -->




<!-- In the table shown below, the data base looks like: -->

<!-- ``` -->
<!--     Route=ORAL, Age=60s, Sex=M, Outc_code=OT, Indi_pt=RHEUMATOID ARTHRITIS and Pt=VASCULITIC RASH + some noise -->
<!--     Route=TOPICAL, Age=early 20s, Sex=F, Outc_code=HO, Indi_pt=URINARY TRACT INFECTION and Pt=VOMITING + some noise -->
<!--     Route=INTRAVENOUS, Age=about 5, Sex=F, Outc_code=LT, Indi_pt=TONSILLITIS and Pt=VOMITING + some noise -->
<!--     Route=OPHTHALMIC, Age=early 50s, Sex=F, Outc_code=DE, Indi_pt=Senile osteoporosis and Pt=Sepsis + some noise -->
<!-- ``` -->

The data loooks like this (this is a simulated database):


  X  Route          Age  Sex   Outc_cod   Indi_pt                   Pt              
---  ------------  ----  ----  ---------  ------------------------  ----------------
  1  ORAL            63  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
  2  ORAL            66  F     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
  3  ORAL            66  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
  4  ORAL            57  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
  5  ORAL            66  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
  6  ORAL            66  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
  7  ORAL            64  M     HO         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
  8  ORAL            56  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
  9  ORAL            66  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 10  ORAL            66  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 11  ORAL            52  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 12  ORAL            66  F     LT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 13  ORAL            59  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 14  ORAL            61  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 15  ORAL            66  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 16  ORAL            66  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 17  ORAL            48  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 18  ORAL            60  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 19  ORAL            62  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 20  ORAL            60  M     OT         RHEUMATOID ARTHRITIS      VASCULITIC RASH 
 21  ORAL            18  F     HO         URINARY TRACT INFECTION   VOMITING        
 22  TOPICAL         15  F     OT         URINARY TRACT INFECTION   VOMITING        
 23  TOPICAL         14  F     HO         URINARY TRACT INFECTION   VOMITING        
 24  TOPICAL         17  F     HO         URINARY TRACT INFECTION   VOMITING        
 25  TOPICAL         17  M     HO         URINARY TRACT INFECTION   VOMITING        
 26  TOPICAL         17  F     LT         URINARY TRACT INFECTION   VOMITING        
 27  TOPICAL         18  F     HO         URINARY TRACT INFECTION   VOMITING        
 28  TOPICAL         17  F     HO         URINARY TRACT INFECTION   VOMITING        
 29  TOPICAL         24  M     HO         URINARY TRACT INFECTION   VOMITING        
 30  TOPICAL         17  F     HO         URINARY TRACT INFECTION   VOMITING        
 31  TOPICAL         20  F     OT         URINARY TRACT INFECTION   VOMITING        
 32  TOPICAL         17  F     HO         URINARY TRACT INFECTION   VOMITING        
 33  TOPICAL         17  F     HO         URINARY TRACT INFECTION   VOMITING        
 34  INTRAVENOUS      5  F     LT         TONSILLITIS               VOMITING        
 35  INTRAVENOUS      6  M     LT         TONSILLITIS               VOMITING        
 36  INTRAVENOUS      7  F     LT         TONSILLITIS               VOMITING        
 37  INTRAVENOUS      8  F     HO         TONSILLITIS               VOMITING        
 38  INTRAVENOUS      5  F     LT         TONSILLITIS               VOMITING        
 39  INTRAVENOUS      4  M     LT         TONSILLITIS               VOMITING        
 40  INTRAVENOUS      6  F     LT         TONSILLITIS               VOMITING        
 41  INTRAVENOUS      7  F     LT         TONSILLITIS               VOMITING        
 42  INTRAVENOUS      8  F     OT         TONSILLITIS               VOMITING        
 43  INTRAVENOUS      5  F     LT         TONSILLITIS               VOMITING        
 44  INTRAVENOUS      4  M     LT         TONSILLITIS               VOMITING        
 45  INTRAVENOUS      7  F     OT         TONSILLITIS               VOMITING        
 46  INTRAVENOUS      5  F     LT         TONSILLITIS               VOMITING        
 47  INTRAVENOUS      6  F     LT         TONSILLITIS               VOMITING        
 48  INTRAVENOUS      4  F     LT         TONSILLITIS               VOMITING        
 49  OPHTHALMIC      45  F     DE         Senile osteoporosis       Sepsis          
 50  OPHTHALMIC      43  F     DE         Senile osteoporosis       Sepsis          
 51  OPHTHALMIC      44  F     LT         Senile osteoporosis       Sepsis          
 52  OPHTHALMIC      42  F     DE         Senile osteoporosis       Sepsis          
 53  ORAL            40  F     DE         Senile osteoporosis       Sepsis          
 54  OPHTHALMIC      45  F     DE         Senile osteoporosis       Sepsis          
 55  OPHTHALMIC      48  F     DE         Senile osteoporosis       Sepsis          
 56  OPHTHALMIC      40  F     HO         Senile osteoporosis       Sepsis          
 57  OPHTHALMIC      42  F     DE         Senile osteoporosis       Sepsis          
 58  ORAL            45  F     DE         Senile osteoporosis       Sepsis          
 59  OPHTHALMIC      44  F     DE         Senile osteoporosis       Sepsis          
 60  OPHTHALMIC      43  F     DE         Senile osteoporosis       Sepsis          
 61  OPHTHALMIC      45  F     OT         Senile osteoporosis       Sepsis          
 62  OPHTHALMIC      46  F     DE         Senile osteoporosis       Sepsis          
 63  OPHTHALMIC      47  F     DE         Senile osteoporosis       Sepsis          
 64  OPHTHALMIC      45  F     DE         Senile osteoporosis       Sepsis          
 65  OPHTHALMIC      48  F     DE         Senile osteoporosis       Sepsis          
 66  OPHTHALMIC      49  F     DE         Senile osteoporosis       Sepsis          
 67  OPHTHALMIC      45  F     DE         Senile osteoporosis       Sepsis          
 68  OPHTHALMIC      44  F     DE         Senile osteoporosis       Sepsis          
 69  OPHTHALMIC      43  F     DE         Senile osteoporosis       Sepsis          
 70  OPHTHALMIC      45  F     OT         Senile osteoporosis       Sepsis          
 71  OPHTHALMIC      46  F     DE         Senile osteoporosis       Sepsis          
 72  OPHTHALMIC      47  F     DE         Senile osteoporosis       Sepsis          

![](examples_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

 cluster   Number_of_observations
--------  -----------------------
       1                       20
       2                       13
       3                       15
       4                       24

![](examples_files/figure-html/unnamed-chunk-27-2.png)<!-- -->

Attribute                   cluster1               cluster2                  cluster3      cluster4            
--------------------------  ---------------------  ------------------------  ------------  --------------------
Age                         61.8                   17.54                     5.8           44.62               
Route                       1                      21                        34            49                  
Sex                         ORAL                   TOPICAL                   INTRAVENOUS   OPHTHALMIC          
Outcome Code                M                      F                         F             F                   
Indication preferred term   OT                     HO                        LT            DE                  
Adverse event               RHEUMATOID ARTHRITIS   URINARY TRACT INFECTION   TONSILLITIS   Senile osteoporosis 



