library(dplyr)

url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#download.file(url, "dataset.zip")
#unzip("dataset.zip")
archiveName <- "./UCI HAR Dataset"

trainFiles <- list.files(file.path(archiveName, "train"), recursive = FALSE, pattern = "*.txt")
#testFiles <- list.files(file.path(archiveName, "test"), recursive = FALSE, pattern = "*.txt")

# prepare output dir
if (!file.exists("merged")) {
  dir.create("merged")
} 

#select mean and std features
featFile <- file.path(archiveName, "features.txt")
feat <- read.table(featFile)

l <- grep("mean|std", feat[,2], ignore.case = TRUE)

subject <- file.path(archiveName, "train", "subject_train.txt")
X <- file.path(archiveName, "train", "X_train.txt")
y <- file.path(archiveName, "train", "y_train.txt")

train <- read.table(subject)
test <- read.table(gsub("train", "test", subject))
subject_merged <- rbind(train, test)

train <- read.table(y)
test <- read.table(gsub("train", "test", y))
y_merged <- rbind(train, test)

train <- read.table(X)
test <- read.table(gsub("train", "test", X))
merged <- rbind(train, test)
names(merged) <- feat$V2
merged <- merged[, l]
merged <- cbind(y_merged, merged)
merged <- cbind(subject_merged, merged)
write.table(merged, file = "merged/X_merge.txt", row.name = FALSE)

