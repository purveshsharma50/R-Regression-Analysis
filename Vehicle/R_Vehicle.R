

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(tidyverse)
library(car)
library(leaps)
library(olsrr)
library(qqplotr)
library(alr3)
library(glmnet)
```
```{r, message=FALSE}
library(readr)
epa_data_Sharma <- read_csv("~/Documents/TXST Study Material/Regression Analysis/Assignments/final Exam/epa_data_Sharma.csv")
```
The provided dataset contains information about Cars, it contains name of manufacturer, model info, year and more details about Engine such as transmission type, milege.


# section a.

in this section a complete regression is performed on all the variables such as "year", "Diesel", "Automatic", "FrontWheel", "Displacement". we have also included other terms such as year:Diesel, year:Automatic, year:FrontWheel, year:displacement.
it is observed in summary that "Diesel is the most insignificant variable with P-value of 0.8777" and "year:Diesel also shows 0.905 as a P-value" which is not supporting the model.
for overall model we got R-squared:  0.5481,	Adjusted R-squared:  0.544  p-value: < 2.2e-16

we have also performed other analysis with the backword elimination and we found that if we get all the significant values still "R2 value" is not increasing. It shows multicolinearity.

```{r}
model= lm(mpg_overall~ (year*Diesel + year*Automatic + year*FrontWheel + year*displacement), data=epa_data_Sharma)
par(mfrow=c(2,2))
summary(model)
modeladj.r2 = summary(model)$adj.r.squared
plot(model)
anova(model)
influenceIndexPlot(model)
```
```{r}
model2= lm(mpg_overall~year+Diesel+Automatic + FrontWheel + displacement, data=epa_data_Sharma)
par(mfrow=c(2,2))
summary(model2)
model2adj.r2 = summary(model2)$adj.r.squared
plot(model2)
```
```{r}
model3= lm(mpg_overall~year+Diesel+ FrontWheel + displacement, data=epa_data_Sharma)
par(mfrow=c(2,2))
summary(model3)
model3adj.r2 = summary(model3)$adj.r.squared
plot(model3)
```
```{r}
model4= lm(mpg_overall~( year*Automatic + year*FrontWheel + year*displacement), data=epa_data_Sharma)
par(mfrow=c(2,2))
summary(model4)
model4adj.r2 = summary(model4)$adj.r.squared
plot(model4)
```

With the vif values we can tell there is high multicolinearity.

```{r}
vif(model)
```
#section b.

In this section we are supposed to determine the best predictors so the VIF can be improved. Here, we performed the stepwise selection and forward selection with multicolinearity table to understand the relation between the predictors. Results with R square and other parameters are mentioned below. we have also selected the graphical representation for the "adj R squre" and "BIC" which shows the similar results to stepwise and forward selection method.


```{r}
regsubsets(mpg_overall~ (year*Diesel + year*Automatic + year*FrontWheel + year*displacement), data=epa_data_Sharma, nbest = 3) -> all.models 
summary(all.models) -> summ
summ
```
```{r}
dataset = epa_data_Sharma
model.full = lm(mpg_overall~ (year*Diesel + year*Automatic + year*FrontWheel + year*displacement), data = dataset)
ols_step_forward_p(model.full)
ols_step_both_p(model.full )
```

```{r}
 notquiteall.models =regsubsets(mpg_overall~ (year*Diesel + year*Automatic + year*FrontWheel + year*displacement), data=epa_data_Sharma, nbest = 1 ) 
plot(notquiteall.models)
```
```{r}
plot(notquiteall.models, scale = "adjr2")
```
```{r}
reg1<-model$residuals
plot(reg1)
```
# section c

In this section lasso Regression is performed. Lasso is similar to Ridge,the ridge estimator is found by solving
a slightly modified version of the normal equations,but lasso is computationally more intensive.
Lasso regression has the advantage of yielding a sparse solution, in which many parameters are equal to zero. It provides better accuracy as well.
For lasso regression, the alpha value is 1.


```{r}
model.lasso = lm(mpg_overall~ (year*Diesel + year*Automatic + year*FrontWheel + year*displacement), data = epa_data_Sharma)
X = model.matrix(model.lasso)
ks = c(0,10^seq(-3,2, length.out = 1000))
lasso.cv = glmnet::cv.glmnet(X, epa_data_Sharma$mpg_overall, alpha = 1, lambda = ks, nfolds = 5, standardize = TRUE )
beta.lasso = coef(lasso.cv, s = "lambda.min")[-2]
plot(lasso.cv, xlab = "log(k)")
beta.lasso
```
```{r}
X <- model.matrix(model.lasso)
p.lasso = length(beta.lasso)
y = epa_data_Sharma$mpg_overall
yhat.lasso = X%*%beta.lasso
n = length(y)
adjr2 = 1- (sum((y - yhat.lasso)^2)/ (n-p.lasso))/var(y)->lasso.adjr2
adjr2
```

#Section D.

Here is the chart comparision of results in Adj R-square for different models and Lasso model.
with lasso we got-  Adj R-Square 53.10%
and with our first model we got  54.4%
we can conclude that there is multicolinearity which affects adj r square.


```{r}
results = data.frame(modeladj.r2, model2adj.r2,model3adj.r2, model4adj.r2,lasso.adjr2)
round(results,3)
```


