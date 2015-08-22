library(reshape2)

filename <- "getdata-projectfiles-UCI HAR Dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename)
} 
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


# Load Activity & Features Information
ActivityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
ActivityLabels[,2] <- as.character(ActivityLabels[,2])
Features <- read.table("UCI HAR Dataset/Features.txt")
Features[,2] <- as.character(Features[,2])

# Extracts only the measurements on the mean and standard deviation for each measurement. 
DesiredFeatures <- grep(".*mean.*|.*std.*", Features[,2])
DesiredFeatures.names <- Features[DesiredFeatures,2]
DesiredFeatures.names = gsub('-mean', 'Mean', DesiredFeatures.names)
DesiredFeatures.names = gsub('-std', 'Std', DesiredFeatures.names)
DesiredFeatures.names <- gsub('[-()]', '', DesiredFeatures.names)


# Load all data sets from Train & Test directories
train <- read.table("UCI HAR Dataset/train/X_train.txt")[DesiredFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[DesiredFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Combine data sets with labels
AllData <- rbind(train, test)
colnames(AllData) <- c("subject", "activity", DesiredFeatures.names)

# Creating factors
AllData$activity <- factor(AllData$activity, levels = ActivityLabels[,1], labels = ActivityLabels[,2])
AllData$subject <- as.factor(AllData$subject)

AllData.melted <- melt(AllData, id = c("subject", "activity"))
AllData.mean <- dcast(AllData.melted, subject + activity ~ variable, mean)

write.table(AllData.mean, "clean_data_mean.txt", row.names = FALSE, quote = FALSE)