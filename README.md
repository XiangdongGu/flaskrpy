## Simple API Server For R User

We provide a simple Python Flask server for R users, who can easily deploy models or functions written in R to the server.

## How does it work?

A simple web server is started by Python Flask, which also starts an R process. The server translates any API call into R function and return the result in JSON format.

## Install

#### Install R package

```
devtools::install_github("xiangdonggu/flaskrpy")
```

#### Flask web app

We can simply create a new directory and put **app.py** and **.Rprofile** files there. **.Rprofile** runs initial pieces of R codes such as loading necessary packages when the R process is started. It can be modified to suit user's needs.

## Start the server

Go the directory that contains **app.py** and **.Rprofile**

```
python app.py
```

The server is up and running and we can now interact with it in R.

## Example

Below we illustrate how to deploy models to R and make API calls. The API can be called by any platform that supports web API call without the needs of R.

```
library(flaskrpy)
library(jsonlite)

# Build a random forest model, with transformation function
library(randomForest)

# We do not need to bin the variable, we just want to test
# if we can deploy the whole working environment with
# a lot of objects dependencies
cuts <- c(-Inf, 5.1, 5.8, 6.4, Inf)

trans <- function(data) {
  data$Sepal.Length <- cut(data$Sepal.Length, cuts)
  data
}

fit <- randomForest(Species~., data = trans(iris))

# prediction function for API to use, with dependencies
# on cuts, transform, fit
pred <- function(d) {
  d <- as.data.frame(d, stringsAsfactors = FALSE)
  response <- predict(fit, newdata = trans(d))
  list(prediction = response)
}

# We need to make pred function exposed, user should explicitly
# declare which functions can be exposed to API
pred <- api_expose(pred)

# Deploy necessary objects to API server
api_deploy(pred, fit, cuts, trans, model_name = "iristest",
           host = "http://127.0.0.1:5000")

# Call API in R
api_call(model = "iristest", func = "pred", req = iris[1:5, ],
         host = "http://127.0.0.1:5000")
```

We can also call the deployed model prediction API using CURL

```
curl -i -k -H "Content-Type: application/json" -X POST -d 
'[{"Sepal.Length":5.1,"Sepal.Width":3.5,"Petal.Length":1.4,
"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":4.9,
"Sepal.Width":3,"Petal.Length":1.4,"Petal.Width":0.2,
"Species":"setosa"},{"Sepal.Length":4.7,"Sepal.Width":3.2,
"Petal.Length":1.3,"Petal.Width":0.2,"Species":"setosa"},
{"Sepal.Length":4.6,"Sepal.Width":3.1,"Petal.Length":1.5,
"Petal.Width":0.2,"Species":"setosa"},{"Sepal.Length":5,
"Sepal.Width":3.6,"Petal.Length":1.4,"Petal.Width":0.2,
"Species":"setosa"}]' http://127.0.0.1:5000/r/iristest/pred
```
