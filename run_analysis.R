library(dplyr)

url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(url, "dataset.zip")
unzip("dataset.zip")
archiveName <- "./UCI HAR Dataset"

trainFiles <- list.files(archiveName, recursive = TRUE, pattern = "*train.txt")
testFiles <- list.files(archiveName, recursive = TRUE, pattern = "*test.txt")

#select mean and std features
featFile <- file.path(archiveName, "features.txt")
feat <- read.table(featFile)

l <- grep("mean|std", feat[,2], ignore.case = TRUE)

# now, merge the datasets



