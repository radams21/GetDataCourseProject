==================================================================
Human Activity Recognition Using Smartphones Dataset
Version 1.0
Transformed for Getting and Cleaning Data Course Project
==================================================================

This README.txt describes the analyses performed for completion of the Course Project for the Johns Hopkins Getting and Cleaning Data Course offered via Coursera (November 6 - December 1, 2014). The original data is from the University of California-Irvine's (UCI) Human Activity Recognition (HAR) Using Smartphones Data Set (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones). This data was originally provided as a .zip file. 

According to its README.txt, the zipped folder contains the following files:
================================
- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

Additional files are included in the dataset but not used for this project.

Motivation for this Project:
================================
This project sought to transform a segregated, messy set of data files into a tidy dataset.

According to the course's lectures and notes, the prinicples of a tidy data set include:
- Each variable forms a column.
- Each observation forms a row.
- Each table/file stores data about one kind of observation.

Therefore, successful completion of this particular project meets the following criteria:
- Merges the training and the test sets to create one data set.
- Extracts only the measurements on the mean and standard deviation for each measurement. 
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names. 
- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Initial Data:
================================
The 561 "features" captured by this dataset represent measurements of 30 subjects participating in a study that used smartphones to record various movements as the individuals performed six specific activities (walking, walking upstairs, walking downstairs, sitting, standing, and laying). The data was initially divided into two segments: 70% was reserved for a training set while 30% was used for a test set. 

Data Extractions and Transformations:
================================
1.) Initally, the test data set and training data sets were kept separately. Subject id's and activity id's were added to each data set from their respective files. In order to facilitate the readability of each data set, the activity id's were replaced with descriptive activity names (ActivityName), as provided by activity_labels.txt. At this point, each data set had a table of 563 columns (SubjectID, ActivityName, and 561 features). The feature names were added using features.txt and feature_info.txt.

2.) Although the data sets initially had all 561 features recorded as separate columns, this violates the principles of a tidy data set as explicitly covered in the suggested reading for the course, Tidy Data (http://vita.had.co.nz/papers/tidy-data.pdf). Therefore, each data set's table was melted so that only four columns remained: SubjectID, ActivityName, MeasurementName, MeasurementValue. Note that turning columns into rows did not change any of the values of the measurements nor the number of data points; the table was merely reshaped to be longer and narrower.

3.) Once the data sets were reshaped, all of the data in the training set was merged with all of the data from the test set to create one large dataset. 

4.) After the data was merged, the 561 features were culled down to 79 features, which represented the average (mean) or standard deviation measurements. This was simply achieved by searching for "-mean" or "-std" in MeasurementName. 

5.) At this point, a tidy data set was achieved. However, there were multiple data points for the same MeasurementName for a single SubjectID and ActivityName. A second, independent tidy data set was created taking an average for each MeasurementName grouped by SubjectID and ActivityID. The summarized data points were called MeasurementAverage and are present in the final output, subject_activity_averages.txt.

Final Data:
================================
The final tab-delimited output file (subject_activity_averages.txt) uses 4 columns to reprsent the second tidy data set: SubjectID, ActivityName, MeasurementName, and MeasurementAverage. This data contains information from both the original training and test data sets. Only MeasurementNames  with "-mean" or "-std" were considered. The MeasurementValues were averaged for each MeasurementName for each SubjectID and ActivityName. 
