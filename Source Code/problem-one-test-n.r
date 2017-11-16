args <- commandArgs(trailingOnly=TRUE)
require("randomForest")
options(echo=TRUE)

for (i in 1:5) {
	learnFile <- paste("Dataset ", args[1], " included ", i, ".txt", sep="")
	testFile <- paste("Dataset ", args[1], " excluded ", i, ".txt", sep="")

	train <- read.table(learnFile)
	test <- read.table(testFile)
	
	train.rf <- randomForest(train[,1:2], y=train[,3], keep.forest=TRUE, corr.bias=TRUE, xtest=test[,1:2], ytest=test[,3])

	mse <- mean(unlist(train.rf["mse"]))
	rsq <- mean(unlist(train.rf["rsq"]))

	print(paste("mse: ", mse, ", rsq: ", rsq, sep=""))
}
