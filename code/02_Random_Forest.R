####################################
#####      Random Forest      ######
####################################

library (tree)
library(randomForest)

######################   Import Data   ######################################
## @users, please change file path
file_path <- "C:/Users/raouf/Dropbox/Evictions Predictor/"

# Read the data file
EvictionsCensusCombined_2010 <- read.csv(paste(file_path, '/data/EvictionsCensusCombined_2010_allstates_2category.csv', sep = "")) 
out_of_sample <- read.csv(paste(file_path, '/data/out_of_sample.csv', sep = "")) 


############## splitting the data into training and test sets################
set.seed(222)
train               <- sample(1:nrow(EvictionsCensusCombined_2010), 
                              round(nrow(EvictionsCensusCombined_2010) * 0.8))
train               <- sort(train)
test                <- which(!(seq(nrow(EvictionsCensusCombined_2010)) %in% train))


##################### Traim Model ###########################################

############# Candidate 0: Fitting Classification Tree ######################
#treeTarget = tree(Target~.-GEOID,data = data.frame(EvictionsCensusCombined_2010[train,]))
#summary(treeTarget)
#plot(treeTarget)
#text(treeTarget ,pretty =0)

#predict
#treeTarget_preds   <- predict(treeTarget,
#                              EvictionsCensusCombined_2010[test,],
#                              type = "class")

#error rate
error_rate_func   <- function(predictions, true_vals) {
  error_rate      <- mean(as.numeric(predictions != true_vals))
  
  return(error_rate)
}

#error_rate_func(treeTarget_preds, EvictionsCensusCombined_2010[test,"Target"])

#error rate for training data 0.24 and for test data is 0.24

#prune tree
#set.seed(222)
#cv_treeTarget  <- cv.tree(treeTarget,
#                             FUN = prune.misclass)
#names(cv_treeTarget)
#cv_treeTarget

# plot the error as a function of size and k
#par(mfrow =c(1,2))
#plot(cv_treeTarget$size ,cv_treeTarget$dev ,type="b")
#plot(cv_treeTarget$k ,cv_treeTarget$dev ,type="b")

#opt_indx          <- which.min(cv_treeTarget$dev)
#opt_size          <- cv_treeTarget$size[opt_indx]

#print(opt_size)

# prune the tree using prune.misclass()

#pruned_treeTarget  <- prune.misclass(treeTarget,
#                                        best = opt_size)

#old_par             <- list(oma = c(0,0,0,0), 
#                            mar = c(5.1, 4.1, 4.1, 2.1),
#                            mfrow = c(1,1))

#par(old_par)
#plot(pruned_treeTarget)
#text(pruned_treeTarget, pretty = 0)

# check performance
#pruned_treeTarget_preds          <- predict(pruned_treeTarget,
#                                 EvictionsCensusCombined_2010[test,],
#                                 type = "class")
#error_rate_func(pruned_treeTarget_preds, EvictionsCensusCombined_2010[test,"Target"])


############# Candidate 1: Random Forest #####################################
set.seed(222)
rfTarget <- randomForest(Target~.-GEOID,data = data.frame(EvictionsCensusCombined_2010[train,]))

#predict
rfTarget_preds  <- predict(rfTarget,
                           EvictionsCensusCombined_2010[test,],
                           type = "class")

rfTarget

varImpPlot(rfTarget,type=2)

#variable importance
important <- data.frame(importance(rfTarget))
plot(important)

#error rate
error_rate_func(rfTarget_preds, EvictionsCensusCombined_2010[test,"Target"])
##0.1888186



######################   Prediction   ##############################################
#predict
rfTarget_final  <- predict(rfTarget,
                           out_of_sample,
                           type = "class")

prediction_with_RF <- data.frame(out_of_sample$GEOID, rfTarget_final)

colnames(prediction_with_RF) <- c("GEOID","Prediction")


#turn on if you want to export map data without having to run the model
prediction_with_RF <- read.csv(paste(file_path, '/data/prediction_with_RF.csv', sep = "")) 

#export dataframe with true outcome and geoid for map
estimation_outcome <- subset(EvictionsCensusCombined_2010, select = c("GEOID","Target"))

#create a skeleton combining the total GEOID's from both files
keeps <- "GEOID"
estimation_outcome_map <- estimation_outcome[ , keeps, drop = FALSE]
prediction_with_RF_map <- prediction_with_RF[ , keeps, drop = FALSE]


#skeleton including GEOIDS of both the true and prediction Eviction categories
GEOID_skeleton <- rbind(estimation_outcome_map, prediction_with_RF_map)

#merge prediction outcome to skeleton
data_map <- merge(GEOID_skeleton, prediction_with_RF, by="GEOID", all=TRUE)
#values missing are the ones from the estimation outcome, which we will merge after
colSums(is.na(data_map))

#flag variable indicating that it is the prediction outcome and not the estimation
#data map should always have 149,056 observations
data_map$Pred <- NA
as.numeric(data_map$Pred)
data_map$Pred[is.na(data_map$Prediction)] <- 0
data_map$Pred[is.na(data_map$Pred)] <- 1

data_map<- merge(data_map, estimation_outcome, by="GEOID", all=TRUE)
colSums(is.na(data_map))
dim(data_map)

library(stringr)
data_map$GEOID <- str_pad(data_map$GEOID, width=12, side="left", pad=0)

######################   export   ###################################################
#out of sample prediction
write.csv (prediction_with_RF, "C:/Users/raouf/Dropbox/Evictions Predictor/data/prediction_with_RF_out_of_sample.csv", row.names=FALSE)
write.csv(data_map,"/Users/raouf/Dropbox/Evictions Predictor/data/estimation_outcome_map.csv", row.names=FALSE)
