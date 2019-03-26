####################################
#####      Final Project      ######
####################################
#this file takes the 

#########################################################
##Administrative##
#########################################################
library(dplyr)
library(plyr)

## @users please change this line to your 
file_path <- "C:/Users/raouf/Dropbox/Evictions Predictor/"

#########################################################
##Merge data##
#this sections takes the individual files for all the cities
#and merges them together. 

#top 20 States rankes in terms of evictions ion 2016
#Florida
#North Carolina
#California
#South Carolina
#Tennessee
#Colorado

#Ohio
#Georgia
#Virginia
#New York
#Michigan
#Indiana
#Pennsylvania
#Illinois

#Oklahoma
#Missouri
#Massachusetts
#Wisconsin
#Connecticut

#
#########################################################
# top 20 states
#block_groups_FL <- read.csv(paste(file_path,"FL/block-groups.csv", sep=""))
#block_groups_NC<- read.csv(paste(file_path, "NC/block-groups.csv", sep=""))
#block_groups_CA<- read.csv(paste(file_path, "CA/block-groups.csv", sep=""))
#block_groups_SC<- read.csv(paste(file_path, "SC/block-groups.csv", sep=""))
#block_groups_TN<- read.csv(paste(file_path, "TN/block-groups.csv", sep=""))
#block_groups_CO<- read.csv(paste(file_path, "CO/block-groups.csv", sep=""))
#block_groups_OH<- read.csv(paste(file_path, "OH/block-groups.csv", sep=""))
#block_groups_GA<- read.csv(paste(file_path, "GA/block-groups.csv", sep=""))
#block_groups_VA<- read.csv(paste(file_path, "VA/block-groups.csv", sep=""))
#block_groups_NY<- read.csv(paste(file_path, "NY/block-groups.csv", sep=""))
#block_groups_MI<- read.csv(paste(file_path, "MI/block-groups.csv", sep=""))
#block_groups_IN<- read.csv(paste(file_path, "IN/block-groups.csv", sep=""))
#block_groups_PA<- read.csv(paste(file_path, "PA/block-groups.csv", sep=""))
#block_groups_IL<- read.csv(paste(file_path, "IL/block-groups.csv", sep=""))
#block_groups_OK<- read.csv(paste(file_path, "OK/block-groups.csv", sep=""))
#block_groups_MI<- read.csv(paste(file_path, "MI/block-groups.csv", sep=""))
#block_groups_MA<- read.csv(paste(file_path, "MA/block-groups.csv", sep=""))
#block_groups_WI<- read.csv(paste(file_path, "WI/block-groups.csv", sep=""))
#block_groups_CT<- read.csv(paste(file_path, "CT/block-groups.csv", sep=""))
#block_groups_TX<- read.csv(paste(file_path, "TX/block-groups.csv", sep=""))



#block_groups_merge <-rbind(block_groups_FL,
#                           block_groups_NC,
#                           block_groups_CA,
#                           block_groups_SC,
#                           block_groups_TN,
#                           block_groups_CO,
#                           block_groups_OH,
#                           block_groups_GA,
#                           block_groups_VA,
#                           block_groups_NY,
#                           block_groups_MI,
#                           block_groups_IN,
#                           block_groups_PA,
#                           block_groups_IL,
#                           block_groups_OK,
#                           block_groups_MI,
#                           block_groups_MA,
#                           block_groups_WI,
#                           block_groups_CT,
#                           block_groups_TX)


#all states
block_groups_merge <- read.csv(paste(file_path,"All_States/block-groups.csv", sep=""))



#########################################################
##Clean data##
#this section cleans the outcome and also cleans the predictors
#########################################################

## this line improts the combined data for virginia and south carolina. 

          ####SECTION 1 | CLEANING OUTCOME####

# (1) creating ave_evictions_2000_2016
# taking average of evictions by block level
block_groups_merge <- block_groups_merge[,c("GEOID","evictions")] %>%
  dplyr::group_by(GEOID) %>%
  dplyr::summarise(ave_evictions_2000_2016 = mean(evictions, na.rm = TRUE)) %>%
  dplyr::right_join(block_groups_merge, by = "GEOID") %>%
  ungroup()


# (2) taking subset from 2010 to 2016
block_groups_merge_2010_2016 <- subset(block_groups_merge, year>2009)


# (3) creating ave_evictions_2010_2016
# taking average of evictions by block level
block_groups_merge_2010_2016 <- block_groups_merge_2010_2016[,c("GEOID","evictions")] %>%
  dplyr::group_by(GEOID) %>%
  dplyr::summarise(ave_evictions_2010_2016 = mean(evictions, na.rm = TRUE)) %>%
  dplyr::right_join(block_groups_merge_2010_2016, by = "GEOID") %>%
  ungroup()


####SECTION 2 | CLEANING PREDICTORS####
colnames(block_groups_merge_2010_2016)

block_groups_merge_2010_2016 <- block_groups_merge_2010_2016[c("GEOID", "ave_evictions_2010_2016", "year", "name","parent.location", "population", "poverty.rate", "renter.occupied.households", "pct.renter.occupied", "median.gross.rent", "median.household.income" , "median.property.value","rent.burden" ,"pct.white","pct.af.am" , "pct.hispanic","pct.am.ind" ,"pct.asian","pct.nh.pi", "pct.multiple" ,"pct.other" )]

#creating dummy variables for the county

# for (i in sort(unique(block_groups_merge_2010_2016$parent.location))) {
#   block_groups_merge_2010_2016[,paste("county_", i, sep = "")] <- as.numeric(block_groups_merge_2010_2016$parent.location == i)
#}

#drop parent location which we substituted for dummmies above. 
block_groups_merge_2010_2016 <- block_groups_merge_2010_2016[-c(5)]
  
#block_groups_merge_2010_2016 = subset(block_groups_merge_2010_2016, select = -c(GEOID,year, median.gross.rent) )

#check thhat we dont have missing values
colSums(is.na(block_groups_merge_2010_2016))

#create mean rent for the block using years from 2010 to 2016
mean_rent_block <- aggregate(median.gross.rent ~ GEOID, FUN = mean, data = block_groups_merge_2010_2016)

#rename column as median_rent_imputed
colnames(mean_rent_block)[colnames(mean_rent_block)=="median.gross.rent"] <- "median_rent_imputed"

  
#rent went from 261757 missing values to 130431.
#now join the median_rent_imputed variable back to our dataframe
block_groups_merge_2010_2016 <- join(block_groups_merge_2010_2016, mean_rent_block, by='GEOID', type='left', match='all')

# (3) take subset for Data Set (2010, 2016)
block_groups_merge_2010 <- subset(block_groups_merge_2010_2016, year==2010)

#Merge the census variables
Census2010 <- read.csv(paste(file_path, "data/Census_2010.csv", sep=""))
EvictionsCensusCombined_2010 <- merge(block_groups_merge_2010, Census2010 ,by="GEOID")

#############
#ADDED THIS TO DEAL WITH MISSING VALUES EXCEPT IN THE OUTCOME
#replace missing values with the mean of the column
replace_missing=function(x){
  x<-as.numeric(as.character(x)) #first convert each column into numeric if it is from factor
  x[is.na(x)] =mean(x, na.rm=TRUE) #convert the item with NA to median value from the column
  x #display the column
}

EvictionsCensusCombined_2010[,5:67]=data.frame(apply(EvictionsCensusCombined_2010[,5:67],2,replace_missing))
colSums(is.na(EvictionsCensusCombined_2010))

#############


###create out of sample and export
out_of_sample <- subset(EvictionsCensusCombined_2010, is.na(EvictionsCensusCombined_2010$ave_evictions_2010_2016))

#what variables are being dropeed here? Make a note!
# drop "STATE", "name", "ave_evictions_2010_2016", "year"
out_of_sample <- out_of_sample[c(-2,-3,-4,-22)]
#drop all missing values
out_of_sample <- na.omit(out_of_sample)
write.csv (out_of_sample, "C:/Users/raouf/Dropbox/Evictions Predictor/data/out_of_sample.csv", row.names=FALSE)


#block_groups_merge_2016 <- subset(block_groups_merge_2010_2016, year==2016)



#########################################################

#OUTCOME 1: share of evictions/total population
EvictionsCensusCombined_2010$share_evictions <- EvictionsCensusCombined_2010$ave_evictions_2010_2016 / EvictionsCensusCombined_2010$population

#drop all missing values
EvictionsCensusCombined_2010 <- na.omit(EvictionsCensusCombined_2010)

#OUTCOME 2: share of evictions/renter.occupied.households
#EvictionsCensusCombined_2010$share_rent_evictions <- EvictionsCensusCombined_2010$ave_evictions_2010_2016 / EvictionsCensusCombined_2010$renter.occupied.households


hist(EvictionsCensusCombined_2010$share_evictions)
mean(EvictionsCensusCombined_2010$share_evictions)

###Tranform outcome into four categories

# EvictionsCensusCombined_2010$Target <- with(EvictionsCensusCombined_2010, factor(
#  findInterval(share_evictions, c(-Inf,
#                       quantile(share_evictions, probs=c(0.25, .5, .75)), Inf)), 
#  labels=c("Low Eviction","Medium Eviction","High Eviction","Extremely High")
# ))


#Drop population observations when 0
EvictionsCensusCombined_2010$population[EvictionsCensusCombined_2010$population == 0] <- NA

#calculate Descriptive stats at the state level before dichotomizing outcome
library(tidyverse)
EvictionsCensusCombined_2010 %>% 
  group_by(GEOID) %>% 
  summarise(sum= sum(EvictionsCensusCombined_2010$ave_evictions_2010_2016))

#replace states from 0 - 9 with a 0 infront
library(stringr)
EvictionsCensusCombined_2010$GEOID <- str_pad(EvictionsCensusCombined_2010$GEOID, width=12, side="left", pad=0)

#take the mean of average evictions 
means <- aggregate(EvictionsCensusCombined_2010[, 2], list(EvictionsCensusCombined_2010$GEOID), sum)

#creates a state variable taking only the firdt two digits of GEOID
means$state <- substr(means$Group.1, 0, 2)

#sort to see the highest evicting states
datNewagg <- aggregate (means$x, by = means[c('state')], FUN = sum)


###Tranform outcome into two categories

EvictionsCensusCombined_2010$Target <- with(EvictionsCensusCombined_2010, factor(
  findInterval(share_evictions, c(-Inf,
                       quantile(share_evictions, probs=c(.5)), Inf)),
                        labels=c("Low Eviction","High Eviction")
 ))



table(EvictionsCensusCombined_2010$Target)
colnames(EvictionsCensusCombined_2010)

drop_variables <- c("share_evictions","STATE", "name", "ave_evictions_2010_2016", "year")
EvictionsCensusCombined_2010 <- EvictionsCensusCombined_2010[ , !(names(EvictionsCensusCombined_2010) %in% drop_variables)]



#all states
write.csv (EvictionsCensusCombined_2010, "Users/raouf/Dropbox/Evictions Predictor/EvictionsCensusCombined_2010_allstates_2category.csv", row.names=FALSE)
