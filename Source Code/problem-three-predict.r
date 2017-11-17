library(randomForest)

options(echo=TRUE)

train <- read.table("MultLabelTrainData.txt")
label <- read.table("MultLabelTrainLabel.txt")
test <- read.table("MultLabelTestData.txt")

result <- matrix(data=NA,nrow=length(test[,1]),ncol=length(label))

for (i in 1:length(label)) {
	forest <- randomForest(train, y=factor(label[,i]), xtest=test)
	result[,i] <- forest$test$predicted
	result[,i] <- result[,i] - 1
}

sink("FerreiraMultLabelClassification.txt")
write.table(result, row.names=FALSE, col.names=FALSE)
sink()
