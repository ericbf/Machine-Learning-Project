args <- commandArgs(trailingOnly=TRUE)
require("randomForest")
options(echo=TRUE)

knownsFile <- paste("Dataset ", args[1], " knowns.txt", sep="")
unknownsFile <- paste("Dataset ", args[1], " unknowns.txt", sep="")

knowns <- read.table(knownsFile)
unknowns <- read.table(unknownsFile)

forest <- randomForest(knowns[,1:2], y=knowns[,3], keep.forest=TRUE, corr.bias=TRUE, xtest=unknowns[,1:2])

outFile <- paste("FerreiraMissingResult", args[1], ".txt", sep="")

sink(outFile)
as.matrix(unlist(forest["test"]))
sink()
