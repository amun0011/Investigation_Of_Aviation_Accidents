# Reading events.txt
events_df <- read.delim("events.txt",header = TRUE, sep = ",", dec = ".")
events_df <- events_df[events_df$ev_type == 'ACC', ]

# Getting only years and months columns from events.txt
events_reqd_df <- subset(events_df, select = c(ev_id, ev_year, ev_month))

# injury.txt
injury_df <- read.delim("injury.txt",header = TRUE, sep = ",", dec = ".")
View(injury_df)

#Selecting only event id, jnjury level and number of persons injured
injury_reqd_df <- subset(injury_df, select = c(ev_id, injury_level, inj_person_count))
library(sqldf)
# Getting only Fatal Injuries into injury_high_df
injury_fatal_df_1 <- aircraft_envt_seq_df <- sqldf("
  SELECT d1.ev_id, d1.injury_level, d1.inj_person_count
  FROM injury_reqd_df d1
  WHERE d1.injury_level LIKE '%FATL%'
")
# Getting the sum of total high injuries
injury_fatal_df <- aircraft_envt_seq_df <- sqldf("
  SELECT d1.ev_id,  SUM(d1.inj_person_count) AS 'total_fatal_injury'
  FROM injury_fatal_df_1 d1
  GROUP BY d1.ev_id
")
# Getting only Total Injuries into injury_high_df
injury_totl_df_1 <- aircraft_envt_seq_df <- sqldf("
  SELECT d1.ev_id, d1.injury_level, d1.inj_person_count
  FROM injury_reqd_df d1
  WHERE d1.injury_level LIKE '%TOTL%'
")
# Getting the sum of total high injuries
injury_totl_df <- aircraft_envt_seq_df <- sqldf("
  SELECT d1.ev_id,  SUM(d1.inj_person_count) AS 'total_injury'
  FROM injury_totl_df_1 d1
  GROUP BY d1.ev_id
")
#Joining injury_fatal_df and injury_totl_df on event id and finding fatality rate
fatality_rate_df <- merge(injury_fatal_df, injury_totl_df, by = "ev_id")
fatality_rate_df$fatality_rate <- 
  round((fatality_rate_df$total_fatal_injury/fatality_rate_df$total_injury) * 100, digits = 2)
fatality_rate_df <- subset(fatality_rate_df, select = c(ev_id, fatality_rate))

# Join Findings_reqd_df, events_reqd_df and aircraft_df
fatality_rate_df_temp <- merge(fatality_rate_df, events_reqd_df, by = "ev_id")
fatality_rate_df_final <- merge(fatality_rate_df_temp, aircraft_df, by = "ev_id")
fatality_rate_df_final <- subset(fatality_rate_df_final, 
                                 select = c(ev_id, fatality_rate, ev_year, ev_month))
write.csv(fatality_rate_df_final, file = "Fatality_Rate.csv")

View(fatality_rate_df_final[is.na(fatality_rate_df_final$fatality_rate), ])

Accident_Occurence_df <- read.csv(file="Accident_Occurence_Events.csv", header=TRUE, sep=",")

# Join Findings_reqd_df, events_reqd_df and aircraft_df
fatality_predict_df_temp <- merge(Accident_Occurence_df, fatality_rate_df_final, by = "ev_id")
fatality_predict_df_final <- merge(fatality_predict_df_temp, aircraft_df, by = "ev_id")

fatality_predict_df_final <- subset(fatality_predict_df_final, 
        select = c(ev_id, Occurrence_Code, code_iaids, damage, acft_make, acft_model, acft_series,
                   acft_serial_no, cert_max_gr_wt, fatality_rate))

fatality_predict_df_final$code_iaids <- as.numeric(fatality_predict_df_final$code_iaids)
fatality_predict_df_final$damage <- as.numeric(fatality_predict_df_final$damage)
fatality_predict_df_final$acft_make <- as.numeric(fatality_predict_df_final$acft_make)
fatality_predict_df_final$acft_model <- as.numeric(fatality_predict_df_final$acft_model)
fatality_predict_df_final$acft_series <- as.numeric(fatality_predict_df_final$acft_series)
fatality_predict_df_final$acft_serial_no <- as.numeric(fatality_predict_df_final$acft_serial_no)

colnames(fatality_predict_df_final)[colSums(is.na(fatality_predict_df_final)) > 0]
fatality_predict_df_final[is.na(fatality_predict_df_final[,9]), 9] <- mean(fatality_predict_df_final[,9], na.rm = TRUE)

# Selecting Training and Test dataset
Training_df <- fatality_predict_df_final[!is.na(fatality_predict_df_final$fatality_rate),]
Test_df <- fatality_predict_df_final[is.na(fatality_predict_df_final$fatality_rate),]
#Applying Lasso on Training_df
library(glmnet)
xmat <- model.matrix(fatality_rate ~ ., data = subset(Training_df, select = -c(ev_id)))[, -1]
cv.lasso <- cv.glmnet(xmat, Training_df$fatality_rate, alpha = 1)
plot(cv.lasso)

#Name of the best predictors
bestlam <- cv.lasso$lambda.1se
fit.lasso <- glmnet(xmat, Training_df$fatality_rate, alpha = 1)
predict(fit.lasso, s = bestlam, type = "coefficients")[1:7, ]

#Building Linear Model and Doing the Prediction
model <- lm(fatality_rate ~ ., data = subset(Training_df, select = -c(ev_id, code_iaids)))
predicted_fatality_rate <- predict(model, Test_df)

predicted_fatality_rate <- as.data.frame(predicted_fatality_rate)

Test_df <- cbind(Test_df, predicted_fatality_rate)
Test_df <- subset(Test_df, select = -c(fatality_rate))
Test_df$predicted_fatality_rate <- round(Test_df$predicted_fatality_rate, digits = 2)
colnames(Test_df)[colnames(Test_df)=="predicted_fatality_rate"] <- "fatality_rate"

fatality_predict_df_final_1 <- rbind(Training_df, Test_df)

fatality_predict_df_final <- subset(fatality_predict_df_final_1, select = c(ev_id, fatality_rate))
fatality_rate_df_final <- merge(fatality_rate_df_final, fatality_predict_df_final, by = "ev_id")
#fatality_rate_df_final  <- subset(fatality_predict_df_final, select = -c("fatality_rate.x"))
colnames(fatality_rate_df_final)[colnames(fatality_rate_df_final)=="fatality_rate.y"] <- "fatality_rate"

fatality_rate_df <- aircraft_envt_seq_df <- sqldf("
  SELECT d1.ev_id,  d1.ev_year, d1.ev_month, AVG(d1.fatality_rate) AS 'fatality_rate'
  FROM fatality_rate_df_final d1
  GROUP BY d1.ev_id, d1.ev_year, d1.ev_month
")


length(fatality_rate_df[is.na(fatality_rate_df$fatality_rate),])

fatality_rate_df <- fatality_rate_df[!is.na(fatality_rate_df$fatality_rate),]

fatality_rate_df$fatality_rate <- round(fatality_rate_df$fatality_rate, digits = 2)

ggplot(fatality_rate_df, aes(x=fatality_rate)) +
  geom_histogram()

unique(fatality_rate_df$ev_year)

require(ggplot2)
ggplot(data = fatality_rate_df, aes(x=ev_year, y=fatality_rate)) + 
  geom_boxplot(aes(fill=ev_month)) +
  facet_wrap( ~ ev_month, scales="free") +
  theme_solarized() +
  theme(plot.background = element_rect(fill = 'light yellow')) +
  theme(panel.background = element_rect(fill = 'light blue')) +
  theme(panel.grid.major = element_line(color = 'white')) +
  theme(panel.grid.minor = element_line(color = 'white')) +
  scale_y_continuous(name = "Fatality Rate", limits = c(0,120)) +
  xlab("Years")

ggplot(data = fatality_rate_df, aes(y=fatality_rate)) + 
  geom_boxplot(aes(fill=ev_year)) +
  facet_wrap( ~ ev_year, scales="free") +
  theme_solarized() +
  theme(plot.background = element_rect(fill = 'light yellow')) +
  theme(panel.background = element_rect(fill = 'light blue')) +
  theme(panel.grid.major = element_line(color = 'white')) +
  theme(panel.grid.minor = element_line(color = 'white')) +
  scale_y_continuous(name = "Fatality Rate (%)", limits = c(0,120)) +
  theme(axis.text.x = element_blank()) +
  scale_fill_continuous(name = "Years") +
  ggtitle("Year-Wise Box Plots for Fatality Rates")
  #scale_x_discrete(name = "Month", limits = c(1,12))

ggplot(data = fatality_rate_df) + 
  geom_point(mapping = aes(X = ev_month, y=fatality_rate, fill=ev_month)) +
  facet_wrap( ~ ev_year, scales="free")


fatality_freq_df <- sqldf("
  SELECT COUNT(*) AS fatality_count, d1.ev_month, d1.ev_year
  FROM fatality_rate_df_final d1
  GROUP BY d1.ev_year, d1.ev_month
")

fatality_rate_df
fatality_rate_df[fatality_rate_df$ev_year == 1979, ]
