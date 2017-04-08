library(jsonlite)

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

fromJSON(
  content(
    POST(
      "http://127.0.0.1:5000/r/mtcars/pred",
      body = toJSON(mtcars)
    ),
    "text")
)

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

saveRDS(list(pred = pred, fit = fit, trasnform = transform),
        file = "rdsfiles/iris.rds")

fromJSON(
  content(
    POST(
      "http://127.0.0.1:5000/r/iris/pred",
      body = toJSON(iris)
    ),
    "text")
)

