library(dplyr)
library(tidyr)

url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if (!file.exists("dataset.zip")) {
  download.file(url, "dataset.zip")
}
unzip("dataset.zip")

archiveName <- "./UCI HAR Dataset"

trainFiles <- list.files(file.path(archiveName, "train"), recursive = FALSE, pattern = "*.txt")
#testFiles <- list.files(file.path(archiveName, "test"), recursive = FALSE, pattern = "*.txt")

# prepare output dirs
if (!dir.exists("merged")) {
  dir.create("merged")
}
if (!dir.exists("tidy")) {
  dir.create("tidy")
} 

#select mean and std features
featFile <- file.path(archiveName, "features.txt")
feat <- read.table(featFile)

# read activity labels
actFile <- file.path(archiveName, "activity_labels.txt")
act <- read.table(actFile)

l <- grep("-mean|-std", feat[,2], ignore.case = TRUE)

subject <- file.path(archiveName, "train", "subject_train.txt")
X <- file.path(archiveName, "train", "X_train.txt")
y <- file.path(archiveName, "train", "y_train.txt")

train <- read.table(subject)
test <- read.table(gsub("train", "test", subject))
subject_merged <- rbind(train, test)
names(subject_merged) <- c("subject_id")

train <- read.table(y)
test <- read.table(gsub("train", "test", y))
y_merged <- rbind(train, test)
y_act <- sapply(y_merged, function(i){ act[i, 2] })[, 1]
y_merged <- cbind(y_merged, y_act)
names(y_merged) <- c("Activity_ID", "Activity")

train <- read.table(X)
test <- read.table(gsub("train", "test", X))
merged <- rbind(train, test)
names(merged) <- feat$V2

merged <- merged[, l]
merged <- cbind(y_merged, merged)
merged <- cbind(subject_merged, merged)
write.table(merged, file = "merged/X_merge.txt", row.name = FALSE)

final <- tbl_df(merged) %>% group_by(subject_id, Activity) %>% summarise_each(funs(mean))

# series of column names transformation to make them more "descriptive"
pre <- names(final)
post <- gsub("Acc", ".Acceleration.", pre)
post <- gsub("Gyro", ".Gyroscope.", post)
post <- gsub("()", "", post, fixed=TRUE)
post <- gsub("-mean", ".mean", post, fixed=TRUE)
post <- gsub("-std", ".std", post, fixed=TRUE)
post <- gsub("Mag", "Magnitude", post, fixed=TRUE)
post <- gsub("Jerk", "Jerk.", post, fixed=TRUE)
post <- gsub("tB", "time.B", post, fixed=TRUE)
post <- gsub("fB", "frequency.B", post, fixed=TRUE)
post <- gsub("tG", "time.G", post, fixed=TRUE)
post <- gsub("fG", "frequency.G", post, fixed=TRUE)
post <- gsub("..", ".", post, fixed=TRUE)
post <- gsub("-X", ".X.axis", post, fixed=TRUE)
post <- gsub("-Y", ".Y.axis", post, fixed=TRUE)
post <- gsub("-Z", ".Z.axis", post, fixed=TRUE)

names(final) <- post

write.table(final, file = "tidy/dataset.txt", row.name = FALSE)
