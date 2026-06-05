setwd("/Users/megsheppard/Desktop/trajectory/extract_ROI")

#load in relevant libraries
library(ggplot2)
library(dplyr)
library(lme4)
library(lmerTest)
library(effects)

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
age <- data$age_z <- scale(age)
ctq <- data$ctq_z <- scale(ctq)
tcv <- data$tcv_z <- scale(tcv)

#defining the model 
#outcome is total volume
#fixed effects are age, sex, ctq, tcv
#random effects are subject and recruitment centre
model <- lmer(total_vol ~ age + sex + ctq + tcv + (1|subject) + (1|rec), data = data)

#produce the output of the model
model

#likelihood ratio test - this is optional but I'm doing belts and braces
#removing els from the model
model_reduced <- lmer(total_vol ~ age + sex + tcv + (1|subject) + (1|rec), data = data)
summary(model_reduced)

#compare the models - uses a chisquare test on likelihood differences
anova(model, model_reduced)

#running the interaction term between age and ELS to see how ELS influences trajectories of amygdala volume 
itrct <- lmer(total_vol ~ age*ctq + sex + tcv + (1|subject) + (1|rec), data = data)
summary(itrct)

##
#Now we need to check a polynomial model to ensure that we're not missing nuance in the model

poly_mod <- lmer( total_vol ~ (age + I(age^2))*ctq + sex + tcv + (1|subject) + (1|rec), data = data)
summary(poly_mod)

##
#Need to start thinking about how to visualise the data now
library(effects)

#a quick and dirty plot to think about the best way to accurately visualise
plot(Effect(c("age", "ctq"), itrct))

##define a variable which separates my CTQ scores into quantiles based on their scores to help plot it 
eff <- Effect( c("age", "CTQ_score"), itrct, xlevels = list( ctq = quantile(data$CTQ_score, probs = c(0.1, 0.91, 0.98, 1), na.rm = TRUE) ) ) 

#plot
plot(eff)
