# Machine Learning with CARET
Rob Chavez  
July 6, 2016  



## What is CARET?

The caret package (short for Classification And REgression Training) is a set of functions that attempt to streamline the process for creating predictive models in R. The package contains tools for:

* data splitting
* pre-processing
* feature selection
* model tuning using resampling
* variable importance estimation

Here is a quick analysis of Young's cocaine data using CARET.

## Loading and splitting the data


```r
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(caret)

# Load data 
cocaineData_frontiers <- read.delim("C:/Users/Samantha/Google Drive/data/cocaineData_frontiers.txt")
cocaineData_frontiers <- cocaineData_frontiers[,-1]
cocaineData_frontiers$DIAGNOSIS <- as.factor(cocaineData_frontiers$DIAGNOSIS)

# Set random seed for reproducability
set.seed(10) 

# Split data
trainIndex <- createDataPartition(cocaineData_frontiers$DIAGNOSIS, p = .5,  
                                  list = FALSE,
                                  times = 1)

cocaineTrain <- cocaineData_frontiers[ trainIndex,] # Training set
cocaineTest  <- cocaineData_frontiers[-trainIndex,] # Testing set
```

## Classification Modeling 
Let's look at the performance of different models when trying to classify the 'DIAGNOSIS' variable using linear logistic regression, a support vector machine, and a random forest model. For each model, the data set will be trained using leave-one-out-cross-validation in the training data and the final model accuracies will be tested against the holdout sample. 

### Linear Model

```r
# Generalized Linear Model 
glm_model <- train(DIAGNOSIS ~ ., 
                   data = cocaineTrain,
                   method='glm',
                   trControl = trainControl(method = "loocv"),
                   preProc = c("center"))

# Print training model accuracy
glm_model$results[1,2:3][1]
```

```
##    Accuracy
## 1 0.6071429
```

```r
# Calculate performance in holdout sample
glm_predict <- predict(glm_model,cocaineTest)
confusionMatrix(glm_predict,cocaineTest$DIAGNOSIS)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction  0  1
##          0  8  4
##          1  3 11
##                                           
##                Accuracy : 0.7308          
##                  95% CI : (0.5221, 0.8843)
##     No Information Rate : 0.5769          
##     P-Value [Acc > NIR] : 0.08019         
##                                           
##                   Kappa : 0.4551          
##  Mcnemar's Test P-Value : 1.00000         
##                                           
##             Sensitivity : 0.7273          
##             Specificity : 0.7333          
##          Pos Pred Value : 0.6667          
##          Neg Pred Value : 0.7857          
##              Prevalence : 0.4231          
##          Detection Rate : 0.3077          
##    Detection Prevalence : 0.4615          
##       Balanced Accuracy : 0.7303          
##                                           
##        'Positive' Class : 0               
## 
```

### Elastic net

```r
# glmnet 
glmnet_model <- train(DIAGNOSIS ~ ., 
                  data = cocaineTrain,
                  method='glmnet',
                  preProc = c("center"),
                  trControl = trainControl(method = "LOOCV"))

glmnet_predict <- predict(glmnet_model,cocaineTest)
postResample(glmnet_predict,cocaineTest$DIAGNOSIS)
```

```
##  Accuracy     Kappa 
## 0.8076923 0.6107784
```

```r
confusionMatrix(glmnet_predict,cocaineTest$DIAGNOSIS)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction  0  1
##          0  9  3
##          1  2 12
##                                           
##                Accuracy : 0.8077          
##                  95% CI : (0.6065, 0.9345)
##     No Information Rate : 0.5769          
##     P-Value [Acc > NIR] : 0.01199         
##                                           
##                   Kappa : 0.6108          
##  Mcnemar's Test P-Value : 1.00000         
##                                           
##             Sensitivity : 0.8182          
##             Specificity : 0.8000          
##          Pos Pred Value : 0.7500          
##          Neg Pred Value : 0.8571          
##              Prevalence : 0.4231          
##          Detection Rate : 0.3462          
##    Detection Prevalence : 0.4615          
##       Balanced Accuracy : 0.8091          
##                                           
##        'Positive' Class : 0               
## 
```

### SVM

```r
# SVM
svm_model <- train(DIAGNOSIS ~ ., 
                  data = cocaineTrain,
                  method='svmLinear',
                  preProc = c("center"),
                  trControl = trainControl(method = "loocv"))

# Print training model accuracy
svm_model$results[1,2:3][1]
```

```
##    Accuracy
## 1 0.7857143
```

```r
# Calculate performance in holdout sample
svm_predict <- predict(svm_model,cocaineTest)
confusionMatrix(svm_predict,cocaineTest$DIAGNOSIS)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction  0  1
##          0  9  4
##          1  2 11
##                                           
##                Accuracy : 0.7692          
##                  95% CI : (0.5635, 0.9103)
##     No Information Rate : 0.5769          
##     P-Value [Acc > NIR] : 0.03403         
##                                           
##                   Kappa : 0.5385          
##  Mcnemar's Test P-Value : 0.68309         
##                                           
##             Sensitivity : 0.8182          
##             Specificity : 0.7333          
##          Pos Pred Value : 0.6923          
##          Neg Pred Value : 0.8462          
##              Prevalence : 0.4231          
##          Detection Rate : 0.3462          
##    Detection Prevalence : 0.5000          
##       Balanced Accuracy : 0.7758          
##                                           
##        'Positive' Class : 0               
## 
```

### Random Forrest

```r
rf_model <- train(DIAGNOSIS ~ ., 
                  data = cocaineTrain,
                  method='rf',
                  preProc = c("center"),
                  trControl = trainControl(method = "LOOCV"))

# Print training model accuracy
rf_model$results[1,2:3][1]
```

```
##    Accuracy
## 1 0.8214286
```

```r
# Calculate performance in holdout sample
rf_predict <- predict(rf_model,cocaineTest)
confusionMatrix(rf_predict,cocaineTest$DIAGNOSIS)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction  0  1
##          0 10  3
##          1  1 12
##                                           
##                Accuracy : 0.8462          
##                  95% CI : (0.6513, 0.9564)
##     No Information Rate : 0.5769          
##     P-Value [Acc > NIR] : 0.003411        
##                                           
##                   Kappa : 0.6923          
##  Mcnemar's Test P-Value : 0.617075        
##                                           
##             Sensitivity : 0.9091          
##             Specificity : 0.8000          
##          Pos Pred Value : 0.7692          
##          Neg Pred Value : 0.9231          
##              Prevalence : 0.4231          
##          Detection Rate : 0.3846          
##    Detection Prevalence : 0.5000          
##       Balanced Accuracy : 0.8545          
##                                           
##        'Positive' Class : 0               
## 
```


### Comparing each model
Now let's compare the performance of each of the models above. Printed in the output below is a table of their percent accuracies in both the training and holdout data sets as well as the difference between them. Random forest wins this time, but don't read into that too much. 

```r
accuracy_train <- c(glm_model$results[1,2:3][1],glmnet_model$results[1,2:3][2],svm_model$results[1,2:3][1],rf_model$results[1,2:3][1])
accuracy_holdout <- c(confusionMatrix(glm_predict,cocaineTest$DIAGNOSIS)$overall[1],confusionMatrix(glmnet_predict,cocaineTest$DIAGNOSIS)$overall[1],confusionMatrix(svm_predict,cocaineTest$DIAGNOSIS)$overall[1],confusionMatrix(rf_predict,cocaineTest$DIAGNOSIS)$overall[1])

mod_name <- c("Linear","Elastic Net","SVM","Random Forest")
difference <- as.numeric(accuracy_holdout) - as.numeric(accuracy_train)
data.frame(cbind(mod_name,accuracy_train,accuracy_holdout,difference))
```

```
##        mod_name accuracy_train accuracy_holdout  difference
## 1        Linear      0.6071429        0.7307692   0.1236264
## 2   Elastic Net      0.8571429        0.8076923 -0.04945055
## 3           SVM      0.7857143        0.7692308 -0.01648352
## 4 Random Forest      0.8214286        0.8461538  0.02472527
```

## Regression Modeling 
Now, let's do the same thing again except this time we will be trying to predict a continuous variable 'IMT_COMM_errors'.


### Linear Model

```r
# Dummy code factor
cocaineTest$DIAGNOSIS <- as.numeric(cocaineTest$DIAGNOSIS)
cocaineTrain$DIAGNOSIS <- as.numeric(cocaineTrain$DIAGNOSIS)

# Linear Model 
glm_model <- train(IMT_COMM_errors ~ ., 
                   data = cocaineTrain,
                   method='lm',
                   trControl = trainControl(method = "loocv"),
                   preProc = c("center")) 

# Print training model accuracy
glm_model$results[1,2:3][1] 
```

```
##       RMSE
## 1 6.274548
```

```r
# Calculate performance in holdout sample
glm_predict <- predict(glm_model,cocaineTest) 
postResample(glm_predict,cocaineTest$DIAGNOSIS)
```

```
##       RMSE   Rsquared 
## 28.9969943  0.3653032
```

### Elastic net

```r
# glmnet 
glmnet_model <- train(IMT_COMM_errors ~ ., 
                  data = cocaineTrain,
                  method='glmnet',
                  preProc = c("center"),
                  trControl = trainControl(method = "LOOCV")) 

glmnet_predict <- predict(glmnet_model,cocaineTest)
postResample(glmnet_predict,cocaineTest$DIAGNOSIS)
```

```
##       RMSE   Rsquared 
## 28.7145202  0.3445652
```

### SVM

```r
# SVM
svm_model <- train(IMT_COMM_errors ~ ., 
                  data = cocaineTrain,
                  method='svmLinear',
                  preProc = c("center"),
                  trControl = trainControl(method = "loocv"))

# Print training model accuracy
svm_model$results[1,2:3][1]
```

```
##       RMSE
## 1 4.718838
```

```r
# Calculate performance in holdout sample
svm_predict <- predict(svm_model,cocaineTest)
postResample(svm_predict,cocaineTest$DIAGNOSIS)
```

```
##       RMSE   Rsquared 
## 29.3738897  0.3767763
```

### Random Forrest

```r
rf_model <- train(IMT_COMM_errors ~ ., 
                  data = cocaineTrain,
                  method='rf',
                  preProc = c("center"),
                  trControl = trainControl(method = "LOOCV"))

# Print training model accuracy
rf_model$results[1,2:3][1]
```

```
##       RMSE
## 1 12.64356
```

```r
# Calculate performance in holdout sample
rf_predict <- predict(rf_model,cocaineTest)
postResample(rf_predict,cocaineTest$DIAGNOSIS)
```

```
##       RMSE   Rsquared 
## 28.3108854  0.4151549
```

### Comparing each model
Again, we can now compare the performance of each of the models above. Printed in the output below is a table of their root-mean-squared-error (RMSE) in both the training and holdout data sets, the as the difference between training and holdout RMSE, and the coefficient of determination for each model in the holdout sample. Random forest wins again, but again this won't always be true.  

```r
RMSE_train <- c(glm_model$results[1,2:3][1],glmnet_model$results[1,2:3][2],svm_model$results[1,2:3][1],rf_model$results[1,2:3][1])
RMSE_holdout <- c(postResample(glm_predict,cocaineTest$DIAGNOSIS)[1],postResample(glmnet_predict,cocaineTest$DIAGNOSIS)[1],postResample(svm_predict,cocaineTest$DIAGNOSIS)[1],postResample(rf_predict,cocaineTest$DIAGNOSIS)[1])
Rsquared_holdout <- c(postResample(glm_predict,cocaineTest$DIAGNOSIS)[2],postResample(glmnet_predict,cocaineTest$DIAGNOSIS)[2],postResample(svm_predict,cocaineTest$DIAGNOSIS)[2],postResample(rf_predict,cocaineTest$DIAGNOSIS)[2])

mod_name <- c("Linear","Elastic Net","SVM","Random Forest")
difference <- as.numeric(RMSE_holdout) - as.numeric(RMSE_train)
data.frame(cbind(mod_name,RMSE_train,RMSE_holdout,difference,Rsquared_holdout))
```

```
##        mod_name RMSE_train RMSE_holdout difference Rsquared_holdout
## 1        Linear   6.274548     28.99699   22.72245        0.3653032
## 2   Elastic Net   8.307031     28.71452   20.40749        0.3445652
## 3           SVM   4.718838     29.37389   24.65505        0.3767763
## 4 Random Forest   12.64356     28.31089   15.66733        0.4151549
```

## Conclusions
CARET is a simple and helpful way to implement machine learning in R that I would highly recommend. I didn't go into detail about  preprocessing (e.g. mean-centering) or model tuning here, but there are a bunch of really helpful features in CARET that make these steps easy as well.  



