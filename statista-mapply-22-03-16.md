Some applications of the mapply function
========================================================
author: Martin Junge
date: 22-03-16
width: 1920
height: 1080

Overview
========================================================

- functional programming in R (recap)
  - https://github.com/mjunge-lsp/statista-apply/blob/master/statista-apply-21-02-12.md
- the apply family
  - apply
  - lapply
  - sapply
  - vapply
  - **mapply**
- Some applications from a medical data project

Functional programming in R
========================================================

- R as a *functional* and object-oriented programming language

"Everything that exists is an object.
Everything that happens is a function call."
— John Chambers


```r
`+`
```

```
function (e1, e2)  .Primitive("+")
```

```r
1 + 2
```

```
[1] 3
```

```r
`+`(1, 2)
```

```
[1] 3
```

apply instead of for-loops
========================================================

- apply functions make use of the nature of R as a functional language
- replace for-loops


```r
head(mtcars)
```

```
                   mpg cyl disp  hp drat    wt  qsec vs am gear carb
Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

```r
colmeans <- NULL
for (i in 1:ncol(mtcars))
{
  m <- mean(mtcars[, i])
  colmeans <- c(colmeans, m)
}
names(colmeans) <- names(mtcars)
colmeans
```

```
       mpg        cyl       disp         hp       drat         wt       qsec 
 20.090625   6.187500 230.721875 146.687500   3.596563   3.217250  17.848750 
        vs         am       gear       carb 
  0.437500   0.406250   3.687500   2.812500 
```


apply
========================================================

- most basic variant: `apply`


```r
head(mtcars)
```

```
                   mpg cyl disp  hp drat    wt  qsec vs am gear carb
Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

```r
apply(mtcars, MARGIN = 2, FUN = mean)
```

```
       mpg        cyl       disp         hp       drat         wt       qsec 
 20.090625   6.187500 230.721875 146.687500   3.596563   3.217250  17.848750 
        vs         am       gear       carb 
  0.437500   0.406250   3.687500   2.812500 
```

mapply /1
========================================================

The multivariate member of the apply function family


```r
a <- c(seq(1, 10, 2))
a
```

```
[1] 1 3 5 7 9
```

```r
b <- c(seq(20, 1, -4))
b
```

```
[1] 20 16 12  8  4
```

```r
mapply(`+`, x = a, y = b)
```

```
[1] 21 19 17 15 13
```

```r
a + b
```

```
[1] 21 19 17 15 13
```

mapply /2
========================================================


```r
library(ranger)
fit_grid <- expand.grid(n_trees = c(100, 500), rep = c(TRUE, FALSE))
fit_grid
```

```
  n_trees   rep
1     100  TRUE
2     500  TRUE
3     100 FALSE
4     500 FALSE
```

```r
mod_rf <- mapply(ranger, num.trees = fit_grid$n_trees, replace = fit_grid$rep,
                 MoreArgs = list(formula = as.factor(am) ~ ., data = mtcars), SIMPLIFY = FALSE)
```

mapply /3
========================================================


```r
str(mod_rf, max.level = 1)
```

```
List of 4
 $ :List of 14
  ..- attr(*, "class")= chr "ranger"
 $ :List of 14
  ..- attr(*, "class")= chr "ranger"
 $ :List of 14
  ..- attr(*, "class")= chr "ranger"
 $ :List of 14
  ..- attr(*, "class")= chr "ranger"
```

mapply /4
========================================================


```r
conf_mat_list <- lapply(mod_rf, function(x) x$confusion.matrix)
conf_mat_list
```

```
[[1]]
    predicted
true  0  1
   0 17  2
   1  2 11

[[2]]
    predicted
true  0  1
   0 17  2
   1  2 11

[[3]]
    predicted
true  0  1
   0 17  2
   1  2 11

[[4]]
    predicted
true  0  1
   0 17  2
   1  2 11
```
