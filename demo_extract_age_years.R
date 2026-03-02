setwd("/Users/megsheppard/Desktop/trajectory")

library(dplyr)
library(stringr)

# Read data in with one file that has everything except Age, and one csv that has the age information in with associated IDs
target <- read.csv("demographics_minus_age.csv", stringsAsFactors = FALSE)
ages   <- read.csv("imagen_demographics_final.csv", stringsAsFactors = FALSE)

# Ensure IDs are character (they're stored in Excel as numbers so this is a necessary step)
target$Subject_ID <- as.character(target$Subject_ID)
ages$Subject_ID   <- as.character(ages$Subject_ID)

#create a new variable called merged_years from the target dataset
merged_years <- target %>%
  mutate(
    #removes the _FU2 and _FU3 from the IDs to align them all to the same ID code/participant
    baseID = str_remove(Subject_ID, "_FU2|_FU3"),
    #creates a new temporary column called 'visit' which checks the ID and if it contains  _FU2 or _FU3, it adds it into this column, if not adds in BL
    visit = case_when(
      str_detect(Subject_ID, "_FU2") ~ "FU2",
      str_detect(Subject_ID, "_FU3") ~ "FU3",
      TRUE ~ "BL"
    )
  ) %>%
#this joins only the age column that aligns with the Subject_ID to prevent bringing along sex, recruitment centre, CTQ or TCV
  left_join(
    ages %>% select(Subject_ID,
                    Age_BL_Years,
                    Age_FU2_Years,
                    Age_FU3_Years),
#matches baseID (from target dataset) with SubjectID (from ages)   
  by = c("baseID" = "Subject_ID")
  ) %>%
#this uses the visit column to select the correct age and creates one clean column with Age_Years
  mutate(
    Age_Years = case_when(
      visit == "BL"  ~ Age_BL_Years,
      visit == "FU2" ~ Age_FU2_Years,
      visit == "FU3" ~ Age_FU3_Years
    )
  ) %>%
#removes the helper columns that were temporarily added, e.g., the visit column.
  select(-baseID, -visit,
         -Age_BL_Years, -Age_FU2_Years, -Age_FU3_Years)

# Write new output file including the new column created with Age_Years to this new and final demographics csv
write.csv(merged_years,
          "demographics_with_age_years.csv",
          row.names = FALSE)
