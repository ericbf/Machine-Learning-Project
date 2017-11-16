options(echo=TRUE)

require("randomForest")

args <- commandArgs(trailingOnly=TRUE)

if (args[1] == 2 || args[1] == 4) {
	require("Hmisc")
}

labelFile <- paste("TrainLabel", args[1], ".txt", sep="")
trainFile <- paste("TrainData", args[1], ".txt", sep="")
testFile <- paste("TestData", args[1], ".txt", sep="")

label <- factor(read.table(labelFile)[,1])

if (args[1] == 1) {
	train <- read.csv(trainFile, header=FALSE)
} else {
	train <- read.table(trainFile, na.strings="1.00000000000000e+99")
}

if (args[1] == 1 || args[1] == 4) {
	test <- read.csv(testFile, header=FALSE, na.strings="1000000000")
} else {
	test <- read.table(testFile, na.strings="1.00000000000000e+99")
}

if (args[1] == 2 || args[1] == 4) {
	train <- rfImpute(train[,1:length(train)], label)[2:(length(train) + 1)]

	for (i in 1:length(test)) {
		test[,i] <- impute(test[,i])
	}
}

forest <- randomForest(train[,1:length(train)], y=label, keep.tree=TRUE, xtest=test[,1:length(test)])

outputFile <- paste("FerreiraClassification", args[1], ".txt", sep="")

sink(outputFile)
as.matrix(unlist(forest["test"])[1:length(test[,1])])
sink()