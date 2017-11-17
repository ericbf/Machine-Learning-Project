args <- commandArgs(trailingOnly=TRUE)
library(randomForest)

options(echo=TRUE)

knownsFile <- paste("Dataset ", args[1], " knowns.txt", sep="")
unknownsFile <- paste("Dataset ", args[1], " unknowns.txt", sep="")

knowns <- read.table(knownsFile)
unknowns <- read.table(unknownsFile)

forest <- randomForest(knowns[,1:2], y=knowns[,3], corr.bias=TRUE, xtest=unknowns[,1:2])

outFile <- paste("FerreiraMissingResult", args[1], ".txt", sep="")

sink(outFile)
write.table(forest$test$predicted, col.names=FALSE, row.names=FALSE)
sink()
