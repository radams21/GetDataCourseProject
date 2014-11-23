# run_analysis.R

# requires library(ddplyr)
# install package if necessary
if("plyr" %in% rownames(installed.packages()) == FALSE) {install.packages("plyr")};library(plyr)
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")};library(dplyr)
if("reshape2" %in% rownames(installed.packages()) == FALSE) {install.packages("reshape2")};library(reshape2)

############################
# Overview of this code:
############################
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names. 
# From the data set in step 4, creates a second, independent tidy data set with the 
#   average of each variable (measurement) for each activity and each subject.

# Load data
data_dir <- "UCI\ HAR\ Dataset"
zip_filename <- "getdata-projectfiles-UCI HAR Dataset.zip"
if(! file.exists(data_dir) && file.exists(zip_filename)) {
    unzip(zip_filename)
}

############################
# Merges the training and the test sets to create one data set.
############################

# read in feature list
feature_file <- paste(data_dir, "features.txt", sep="/")
feature_table <- read.table(feature_file, header=F, sep=" ")
names(feature_table) <- c("FeatureID","FeatureName")
feature_list <- feature_table$FeatureName

# read in activity labels
activity_label_file <- paste(data_dir, "activity_labels.txt", sep="/")
activity_table <- read.table(activity_label_file, header=F, sep=" ")
names(activity_table) <- c("ActivityID", "ActivityName")
ordered_activity_names = as.vector(t(arrange(activity_table, ActivityID)["ActivityName"]))

# set up names of test files
x_test_file <- paste(data_dir, "X_test.txt", sep="/test/")
y_test_file <- paste(data_dir, "Y_test.txt", sep="/test/")
subject_test_file <- paste(data_dir, "subject_test.txt", sep="/test/")

# read data and annotate features (column)
x_test_data <- read.table(x_test_file, header=F)
names(x_test_data) <- feature_list

# add activities to test data and annotate
# the row indicies in the x and y files map measurements (x) with activities (y)
# annotation does not use 'merge()', which would rearrange the original order of the activity ids
# annotation replaces "ActivityID" with "ActivityName"
y_test_data <- read.table(y_test_file, header=F)
names(y_test_data) <- "ActivityID"
test_data <- cbind(y_test_data, x_test_data)
test_data$ActivityID <- factor(test_data$ActivityID, labels=ordered_activity_names)
names(test_data)[1] = "ActivityName"
rm(x_test_data)
rm(y_test_data)

# add subjects to test data
subject_test_data <- read.table(subject_test_file, header=F, sep=" ")
names(subject_test_data) <- c("SubjectID")
test_data <- cbind(subject_test_data, test_data)
rm(subject_test_data)

# tidy test data
# melt data frame to have 4 columns: SubjectID, ActivityName, MeasurementName, MeasurementValue
test_data <- melt(test_data, id.vars=c("SubjectID", "ActivityName"), variable.name="MeasurementName", value.name="MeasurementValue")

# set up names of train files
x_train_file <- paste(data_dir, "X_train.txt", sep="/train/")
y_train_file <- paste(data_dir, "Y_train.txt", sep="/train/")
subject_train_file <- paste(data_dir, "subject_train.txt", sep="/train/")

# read data and annotate features (column)
x_train_data <- read.table(x_train_file, header=F)
names(x_train_data) <- feature_list

# add activities to train data and annotate
# the row indicies in the x and y files are used to map measurements (x) with activities (y)
# annotation did not use 'merge', which would rearrange the original order of the activity ids
# annotation replaces "ActivityID" with "ActivityName"
y_train_data <- read.table(y_train_file, header=F)
names(y_train_data) <- "ActivityID"
train_data <- cbind(y_train_data, x_train_data)
train_data$ActivityID <- factor(train_data$ActivityID, labels=ordered_activity_names)
names(train_data)[1] = "ActivityName"
rm(x_train_data)
rm(y_train_data)

# add subjects to train data
subject_train_data <- read.table(subject_train_file, header=F, sep=" ")
names(subject_train_data) <- c("SubjectID")
train_data <- cbind(subject_train_data, train_data)
rm(subject_train_data)

# tidy train data
# melt data frame to have 4 columns: SubjectID, ActivityName, MeasurementName, MeasurementValue
train_data <- melt(train_data, id.vars=c("SubjectID", "ActivityName"), variable.name="MeasurementName", value.name="MeasurementValue")

# merge the training and the test sets to create one data set
all_data <- rbind(test_data, train_data)
rm(train_data)
rm(test_data)

# extract only the measurements on the mean and standard deviation
tidy_data <- all_data[grepl("-mean|std", all_data$MeasurementName, ignore.case=T),]

# create a second, independent tidy data set with the average of each variable
#   for each activity and each subject
second_tidy_data <- tbl_df(tidy_data) 
by_subject_activity <- second_tidy_data %>% 
    group_by(SubjectID, ActivityName, MeasurementName) %>%
    summarise_each(funs(mean),matches("Value"))
names(by_subject_activity)[4] = "MeasurementAverage"

# write second tidy data set to txt file
write.table(by_subject_activity, file="subject_activity_averages.txt", row.name=FALSE, quote=FALSE, sep="\t")

