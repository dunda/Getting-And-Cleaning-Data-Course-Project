library(reshape2)
setwd("./UCI HAR Dataset")
## load in raw data
features <- read.table("features.txt",header=F)
xfeatures <- grepl("[Mm]ean|[Ss]td", features[,2])

activity_labels <- read.table("./activity_labels.txt", header=F, col.names = c("activityId","activityType"))

subject_train <- read.table("./train/subject_train.txt", header=F, col.names = "subjectId")
x_train <- read.table("./train/x_train.txt",header=F,col.names=features[,2])
y_train <- read.table("./train/y_train.txt",header=F,col.names="activityId")

## Merge Data Sets

train <- cbind(y_train,subject_train,x_train[,xfeatures])

subject_test <- read.table("./test/subject_test.txt",header=F,col.names="subjectId")
x_test <- read.table("./test/x_test.txt",header=F,col.names=features[,2])
y_test <- read.table("./test/y_test.txt",header=F,col.names="activityId")

test <- cbind(y_test,subject_test,x_test[,xfeatures])

data <- rbind(train,test)

fdata <- merge(activity_labels,data,by="activityId",all.x=T)
fdata <- fdata[,names(fdata) != "activityId"]

# need to clean up names here
names(fdata) <- gsub('\\(|\\)',"",names(fdata), perl = TRUE)
# Make syntactically valid names
names(fdata) <- make.names(names(fdata))
# Make clearer names
names(fdata) <- gsub('Acc',"Acceleration",names(fdata))
names(fdata) <- gsub('GyroJerk',"AngularAcceleration",names(fdata))
names(fdata) <- gsub('Gyro',"AngularSpeed",names(fdata))
names(fdata) <- gsub('Mag',"Magnitude",names(fdata))
names(fdata) <- gsub('^t',"TimeDomain.",names(fdata))
names(fdata) <- gsub('^f',"FrequencyDomain.",names(fdata))
names(fdata) <- gsub('\\.mean',".Mean",names(fdata))
names(fdata) <- gsub('\\.std',".StandardDeviation",names(fdata))
names(fdata) <- gsub('Freq\\.',"Frequency.",names(fdata))
names(fdata) <- gsub('Freq$',"Frequency",names(fdata))

mdata <- melt(fdata, id=c("subjectId", "activityType"))
tidyMeans<-dcast(mdata, subjectId + activityType~variable, mean) 
write.table(tidyMeans, "../tidyMeans.txt", row.names = F, sep="\t")

