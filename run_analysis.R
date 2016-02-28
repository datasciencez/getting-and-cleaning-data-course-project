library(dplyr)
library(data.table)
library(tidyr)

path <- "c:/Users/Acer/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset"
# Read the subject files using read.table
dataSubjectTrain <- tbl_df(read.table(file.path(path, "train", "subject_train.txt")))
dataSubjectTest  <- tbl_df(read.table(file.path(path, "test" , "subject_test.txt" )))

# Read the activity files using read.table
dataActivityTrain <- tbl_df(read.table(file.path(path, "train", "y_train.txt")))
dataActivityTest  <- tbl_df(read.table(file.path(path, "test" , "y_test.txt" )))

# Read the data files using read.table
dataTrain <- tbl_df(read.table(file.path(path, "train", "X_train.txt" )))
dataTest  <- tbl_df(read.table(file.path(path, "test" , "X_test.txt" )))

# Merge the training and the test sets by row binding and rename variables "subject" and "activityNum"
alldataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
setnames(alldataSubject, "V1", "subject")
alldataActivity<- rbind(dataActivityTrain, dataActivityTest)
setnames(alldataActivity, "V1", "activityNum")

# Combine the training and test files by row binding
data <- rbind(dataTrain, dataTest)

# Name variables using the features.txt file
dataFeatures <- tbl_df(read.table(file.path(path, "features.txt")))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
colnames(data) <- dataFeatures$featureName

# Set column names for activity labels
activityLabels<- tbl_df(read.table(file.path(path, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))

# Merge columns using column binding
alldataSubjAct<- cbind(alldataSubject, alldataActivity)
data <- cbind(alldataSubjAct, data)

# Read "features.txt" and extract only the mean and standard deviation
dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",dataFeatures$featureName,value=TRUE)

# Take only measurements for mean and standard deviation and add "subject","activityNum"

dataFeaturesMeanStd <- union(c("subject","activityNum"), dataFeaturesMeanStd)
data<- subset(data,select=dataFeaturesMeanStd) 

# Enter name of activity into data
data <- merge(activityLabels, data , by="activityNum", all.x=TRUE)
data$activityName <- as.character(data$activityName)

# Create data with variable means sorted by subject and Activity
data$activityName <- as.character(data$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = data, mean) 
data<- tbl_df(arrange(dataAggr,subject,activityName))


names(data)<-gsub("std()", "SD", names(data))
names(data)<-gsub("mean()", "MEAN", names(data))
names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))

write.table(data, "Tidy.txt", row.name=FALSE)

