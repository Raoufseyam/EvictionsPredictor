/* 
* TODO: 1. Place the .txt data file and the dictionary file you downloaded in the work folder, or enter the full path to these files!
*       2. You may have to increase memory using the 'set mem' statement. It is commented out in the code bellow.
*
* If you have any questions or need assistance contact info@socialexplorer.com.
*/
clear all
///set mem 512m
set more off
infile using "/Users/arianna/Dropbox (MIT)/PHD/Fall_2018/Machine_Learning_API_222/Final Project/Final Project (Machine Learning)/Census_2000/R11930403.dct", using("/Users/arianna/Dropbox (MIT)/PHD/Fall_2018/Machine_Learning_API_222/Final Project/Final Project (Machine Learning)/Census_2000/R11930403_SL150.txt")


*Rename variables

rename T002_001 TotalPopulation
rename T002_002 Urban
rename T002_005 Rural
gen share_urban = Urban/TotalPopulation
drop Rural Urban

rename T003_001 PopulationDensity


rename T005_002 MalePopulation
gen share_male = MalePopulation/T005_001

rename T026_001 AverageHouseholdSize

rename T040_001 TotalPopulation25Plus

rename T040_002 Pop25Plus_LessHighSchool
rename T040_003 HighSchoolGraduate
rename T040_004 SomeCollege
rename T040_005 BachelorDegree
rename T040_006 MasterDegree
rename T040_007 ProfessionalDegree
rename T040_008 DoctorateDegree

gen share_Pop25Plus_LessHighSchool = Pop25Plus_LessHighSchool/TotalPopulation25Plus
gen share_HighSchoolGraduate = HighSchoolGraduate/TotalPopulation25Plus
gen share_SomeCollege        = SomeCollege/TotalPopulation25Plus
gen share_BachelorDegree     = BachelorDegree/TotalPopulation25Plus
gen share_MasterDegree       = MasterDegree/TotalPopulation25Plus
gen share_ProfessionalDegree = ProfessionalDegree/TotalPopulation25Plus
gen share_DoctorateDegree    = DoctorateDegree/TotalPopulation25Plus



*rename T074_001 MalePlus16
*rename T074_002 MaleEmployed
*rename T075_001 FemalePlus16
*rename T075_002 FemaleEmployed

rename T155_001 HousingUnits
gen HousingUnitsPerCapita = HousingUnits/TotalPopulation

rename T158_001 VacantHousingUnits
rename T158_002 VacantUnitsForRent
rename T158_003 VacantUnitsForSale
rename T158_004 VacantUnitsOther

rename T160_001 MedianYearStructureBuilt

rename T171_001 OwnerOccupiedHousingUnits
rename T171_002 MortgageHousingUnits
rename T171_003 MortgageOrEquity
rename T171_004 SecondMortgageOnly
rename T171_005 HomeEquityOnly
rename T171_006 BothSecondMortgageEquity
rename T171_007 NoSecondMortgageNoEquity
rename T171_008 HousingNoMortgage


gen share_MortgageHousingUnits = MortgageHousingUnits/OwnerOccupiedHousingUnits
gen share_MortgageOrEquity     = MortgageOrEquity/OwnerOccupiedHousingUnits


gen shareSecondMortgageOnly 			  = SecondMortgageOnly/MortgageOrEquity 
gen shareHomeEquityOnly     			  = HomeEquityOnly/MortgageOrEquity
gen shareBothSecondMortgageEquity     = BothSecondMortgageEquity /MortgageOrEquity 
gen shareNoSecondMortgageNoEquity     = NoSecondMortgageNoEquity /MortgageOrEquity 
gen shareHousingNoMortgage                = HousingNoMortgage /MortgageOrEquity 


gen GEOID = STATE+COUNTY+TRACT+BLKGRP

drop NAME QName AREALAND AREAWATR SUMLEV GEOCOMP REGION DIVISION FIPS COUNTY TRACT BLKGRP T002_003 T002_004 T003_002 T003_003 T005_001 T005_003 T008_001 T008_002 T008_003 T008_004 T008_005 T008_006 T008_007 T008_008 T008_009 T008_010 T008_011 T008_012 T008_013 T074_001 T074_002 T074_003 T075_001 T075_002 T075_003

*keep states
*keep if STATE == "45" | STATE == "51" | STATE == "08"  | STATE == "06" | STATE == "04" | STATE == "01" | STATE == "05"

sort GEOID
export delimited using "/Users/arianna/Dropbox (MIT)/PHD/Fall_2018/Machine_Learning_API_222/Final Project/Final Project (Machine Learning)/data/Census_2010.csv", nolabel replace
