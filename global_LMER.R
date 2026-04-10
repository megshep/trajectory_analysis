setwd("/Users/megsheppard/Desktop/trajectory/extract_ROI")

#load in relevant libraries
library(ggplot2)
library(dplyr)
library(lme4)

#read in the data
data <- read.csv("final_dataset.csv")

#creating variables as it'll be easier to put them into my code later on
age <- data$Age
vol <- data$total_vol
ctq <- data$CTQ_score
time <- data$Time
age_y <- data$Age_years
sex <- data$Sex
tcv <- data$TCV
rec <- data$Recruitment_Centre.y
subject <- data$ID

#visualising to make sure linear model is appropriate
ggplot(data, aes(vol, ctq, colour = age_y)) + geom_point()

#scale the data to standardise - this is needed as the scales were too different
#obviously only scaling the continuous variables
data$age_z <- scale(age)
data$ctq_z <- scale(ctq)
data$tcv_z <- scale(tcv)

#defining the model 
#outcome is total volume
#fixed effects are age, sex, ctq, tcv
#random effects are subject and recruitment centre
model <- lmer(total_vol ~ age + sex + ctq + tcv + (1|subject) + (1|rec), data = data)

#produce the output of the model
model

#load in library to produce p value
library(lmerTest)
model2 <- lmer(total_vol ~ age + sex + ctq + tcv + (1|subject) + (1|rec), data = data)
summary(model2)

#likelihood ratio test - this is optional but I'm doing belts and braces
#removing els from the model
model_reduced <- lmer(total_vol ~ age + sex + tcv + (1|subject) + (1|rec), data = data)
summary(model_reduced)

#compare the models - uses a chisquare test on likelihood differences
anova(model2, model_reduced)
