# run_analysis.R

# requires library(ddplyr)
# install package if necessary
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")};library(dplyr)

############################
# Overview of this code:
############################
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names. 
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

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
# the row indicies in the x and y files are used to map measurements (x) with activities (y)
# annotation did not use 'merge', which would rearrange the original order of the activity ids
y_test_data <- read.table(y_test_file, header=F)
names(y_test_data) <- "ActivityID"
ordered_activity_ids = as.vector(t(unique(arrange(y_test_data, ActivityID)["ActivityID"])))
y_test_data$ActivityName = mapvalues(as.vector(t(y_test_data["ActivityID"])), from=ordered_activity_ids, to=ordered_activity_names)
test_data <- cbind(y_test_data, x_test_data)
test_data <- test_data[2:ncol(test_data)]
rm(x_test_data)
rm(y_test_data)

# add subjects to test data
subject_test_data <- read.table(subject_test_file, header=F, sep=" ")
names(subject_test_data) <- c("SubjectID")
test_data <- cbind(subject_test_data, test_data)
rm(subject_test_data)

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
y_train_data <- read.table(y_train_file, header=F)
names(y_train_data) <- "ActivityID"
ordered_activity_ids = as.vector(t(unique(arrange(y_train_data, ActivityID)["ActivityID"])))
y_train_data$ActivityName = mapvalues(as.vector(t(y_train_data["ActivityID"])), from=ordered_activity_ids, to=ordered_activity_names)
train_data <- cbind(y_train_data, x_train_data)
train_data <- train_data[,2:ncol(train_data)]
rm(x_train_data)
rm(y_train_data)

# add subjects to train data
subject_train_data <- read.table(subject_train_file, header=F, sep=" ")
names(subject_train_data) <- c("SubjectID")
train_data <- cbind(subject_train_data, train_data)
rm(subject_train_data)

# merge the training and the test sets to create one data set
tidy_data <- rbind(test_data, train_data)
rm(train_data)
rm(test_data)

# extract only the measurements on the mean and standard deviation
tidy_data <- cbind(tidy_data[,c(1:2)], tidy_data[, grepl("-mean|std", names(tidy_data), ignore.case=T)])

# create a second, independent tidy data set with the average of each variable
#   for each activity and each subject
second_tidy_data <- tbl_df(tidy_data) 
by_subject_activity <- second_tidy_data %>% 
    group_by(SubjectID, ActivityName) %>%
    summarise_each(funs(mean))
write.table(by_subject_activity, file="subject_activity_averages.txt", row.name=FALSE, quote=FALSE, sep="\t")
