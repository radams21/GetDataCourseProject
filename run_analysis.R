# run_analysis.R

# requires library(ddplyr), library(plyr), and library(reshape2)
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

############################
# Function: set_up_file_names
############################
# takes 3 arguments: a main data directory, a list of sub directories, and a list of file types
# returns a table of data files for each sub directory (columns) and file type (rows)
# systematizes file names from sub directories (test, train) and file types (X, Y, subject)
set_up_file_names<-function(data_dir, sub_dirs, file_types) {  
    
    # create data structures to hold the names of files for each data set
    all_file_types <- rep(file_types, length(sub_dirs))
    all_file_names <- as.data.frame(matrix(all_file_types, ncol = length(sub_dirs)), 
                                   row.names=file_types, stringsAsFactors = F)
    names(all_file_names) <- sub_dirs
    
    for(i in 1:ncol(all_file_names)) {        
        sub_dir = sub_dirs[i]
        for(j in 1:nrow(all_file_names)) {
            file_type = file_types[j]
            filename =  paste(file_type, "_", sub_dir, ".txt", sep="")
            full_dir_name = paste(data_dir, sub_dir, sep="/")
            all_file_names[j,i] = paste(full_dir_name, filename, sep="/")
        }
    }
    all_file_names
}

############################
# Function: check_data_exists
############################
# takes 2 arguments: name of the data directory and the name of the zipped file
# if the data directory doesn't exist, we check if the zipped file exists
# if the zipped file exists, the file is unzipped
check_data_exists <- function(data_dir, zip_filename) {
    if(! file.exists(data_dir) && file.exists(zip_filename)) {
        unzip(zip_filename)
    }
}

############################
# Function: get_features
############################
# takes 1 argument: name of feature file
# returns vector of feature names (ordered by feature number)
get_features <- function(feature_file) {
    feature_table <- read.table(feature_file, header=F, sep=" ")
    names(feature_table) <- c("FeatureID","FeatureName")
    feature_names <- feature_table$FeatureName
    feature_names
}

############################
# Function: get_activities
############################
# takes 1 argument: name of labeled activity file
# returns vector of activity names (ordered by activity number)
get_activities <- function(activity_file) {
    activity_table <- read.table(activity_file, header=F, sep=" ")
    names(activity_table) <- c("ActivityID", "ActivityName")
    activity_names = as.vector(t(arrange(activity_table, ActivityID)["ActivityName"]))
    activity_names
}

############################
# Function: annotate_data_set
############################
# takes 3 arguments: table of file names, list of feature names, list of activity names
# returns a list of tables (one table per data set)
# uses descriptive activity names to name the activities in the data set
# appropriately labels the data set with descriptive variable names. 
annotate_data_set <- function(all_file_names, feature_names, activity_names) {
    
    # get the data tables for each data set
    for(data_set in 1:ncol(all_file_names)) {
        
        # read data (X file) and annotate features as column names
        measurements <- read.table(all_file_names["X", data_set])
        names(measurements) <- feature_names
        
        # read activity info (Y file) for this data set
        activity_info <- read.table(all_file_names["Y", data_set], header=F)
        names(activity_info) <- "ActivityID"
        
        # add activity info to measurements for this data set
        # the row indicies in the x and y files map measurements (x) with activities (y)
        data_table <- cbind(activity_info, measurements)
        
        # annotation does not use 'merge()', which would rearrange the original order of the activity ids
        # annotation replaces "ActivityID" with "ActivityName"
        data_table$ActivityID <- factor(data_table$ActivityID, labels=activity_names)
        names(data_table)[1] = "ActivityName"
        
        # read subject info (subject file) for this data set
        subject_test_data <- read.table((all_file_names["subject", data_set]), header=F, sep=" ")
        names(subject_test_data) <- c("SubjectID")
        data_table <- cbind(subject_test_data, data_table)
        
        # clean up intermediate tables
        rm(measurements)
        rm(activity_info)
        rm(subject_test_data)
        
        # tidy this data set
        # melt data frame to have 4 columns: SubjectID, ActivityName, MeasurementName, MeasurementValue
        data_table <- melt(data_table, id.vars=c("SubjectID", "ActivityName"), 
                           variable.name="MeasurementName", value.name="MeasurementValue")
        
        # save data table to the list of annotated data sets
        if(length(data_table_list) == 0) {
            data_table_list <- list(data_table)
        } else {
            data_table_list[[length(data_table_list)+1]] <- data_table
        }
    } 
    data_table_list  
}

############################
# Load data
############################
data_dir <- "UCI\ HAR\ Dataset"
zip_filename <- "getdata-projectfiles-UCI HAR Dataset.zip"
check_data_exists(data_dir, zip_filename)

# indicate which sub-directories (data sets) to consider
sub_dirs = c("test", "train")

# indicate which types of files to consider for data sets
file_types = c("X", "Y", "subject")

# read in feature list
feature_file <- paste(data_dir, "features.txt", sep="/")
feature_names <- get_features(feature_file)

# read in activity labels
activity_label_file <- paste(data_dir, "activity_labels.txt", sep="/")
activity_names <- get_activities(activity_label_file)

# each data set's table will be added to an overall list
data_table_list = list()

# get the file names for all data sets
all_file_names <- set_up_file_names(data_dir, sub_dirs, file_types)

###############################
# Annotate the data sets
###############################
data_table_list = annotate_data_set(all_file_names, feature_names, activity_names)

###############################
# Merge the data sets (training and the test sets) to create one data set
###############################
all_data = data_table_list[[1]]
for(i in 2:length(data_table_list)) {
    all_data <- rbind(all_data, data_table_list[[i]])   
}

# clean up intermediate data structures
rm(data_table_list)

############################
# Extract only the measurements on the mean and standard deviation
############################
tidy_data <- all_data[grepl("-mean|std", all_data$MeasurementName, ignore.case=T),]

# clean up intermediate data structures
rm(all_data)

############################
# Create a second, independent tidy data set with the average of each variable
#   for each activity and each subject
############################
second_tidy_data <- tbl_df(tidy_data) 
by_subject_activity <- second_tidy_data %>% 
    group_by(SubjectID, ActivityName, MeasurementName) %>%
    summarise_each(funs(mean),matches("Value"))
names(by_subject_activity)[4] = "MeasurementAverage"

# write second tidy data set to txt file
write.table(by_subject_activity, file="subject_activity_averages.txt", row.name=FALSE, quote=FALSE, sep="\t")

