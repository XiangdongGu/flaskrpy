library(jsonlite)
library(flaskrpy)
host <- "http://127.0.0.1:5000"

# Random normal generation
d <- list(n = 10, mean = 1, sd = 40)

f <- function(d) {
  do.call(rnorm, d)
}

saveRDS(list(f = f), "rdsfiles/test.rds")

library(httr)
fromJSON(
  content(POST(
    "http://127.0.0.1:5000/r/test/f",
    body = toJSON(d)),
    "text")
)

# randomforest prediction---------------
fit <- lm(mpg~cyl+disp, data = mtcars)
d <- mtcars[1:10, ]
pred <- function(d) {
  d <- as.data.frame(d, stringsAsFactors = FALSE)
  list(pred = predict(fit, newdata = d))
}
saveRDS(list(fit = fit, pred = pred), file = "rdsfiles/mtcars.rds")

api_call("mtcars", "pred", mtcars)

# Random forest model-----
library(randomForest)
transform <- function(data) {
  data$Sepal.Length <- data$Sepal.Length + 100
  data
}

fit <- randomForest(Species~., data = transform(iris))

pred <- function(d) {
  d <- as.data.frame(d, stringsAsFactors = FALSE)
  predict(fit, transform(d))
}

pred <- api_expose(pred)

api_deploy(transform, fit, pred, model_name = "iris", host = host)

api_call("iris", "pred", iris[1:90, ], host = host)

# deploy from R--------------
myfit <- lm(qsec~disp + hp, data = mtcars)
mypred <- function(d) {
  d <- as.data.frame(d)
  list(pred = predict(myfit, d))
}
# mypred <- api_expose(mypred)
api_deploy(myfit, mypred, model_name = "test_myapi", host = host)

api_call("test_myapi", "mypred", mtcars, host = host)



