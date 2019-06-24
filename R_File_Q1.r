# Reading aircraft.txt
aircraft_data_df <- read.delim("aircraft.txt",header = TRUE, sep = ",", dec = ".")

# Filtering data for Aircraft category
aircraft_df <- aircraft_data_df[aircraft_data_df$acft_category == 'AIR ', ]

# Reading Data Dictionary
data_dictionary_df <- read.delim("eADMSPUB_DataDictionary.txt",header = TRUE, sep = ",", dec = ".")

# Reading events.txt
events_df <- read.delim("events.txt",header = TRUE, sep = ",", dec = ".")
events_df <- events_df[events_df$ev_type == 'ACC', ]

# Findings.txt
Findings_df <- read.delim("Findings.txt",header = TRUE, sep = ",", dec = ".")

# Getting only years and months columns from events.txt
events_reqd_df <- subset(events_df, select = c(ev_id, ev_year, ev_month))

# Getting findings description from Findings.txt
Findings_reqd_df <- subset(Findings_df, select = c(ev_id, finding_description))

# Separating levels of air accident causes
library(dplyr)
library(tidyr)
Findings_reqd_df <- Findings_reqd_df %>%
  separate(finding_description, c("main_reason", "detailed_reason", "sub_reason_2", "sub_reason_3", "sub_reason_4", "sub_reason_5"), "-")
# Selection only mainreason and deailed reason columns
Findings_reqd_df <- subset(Findings_reqd_df, select = c(ev_id, main_reason, detailed_reason))
# Removing trailing spaces
Findings_reqd_df$main_reason <- trimws(Findings_reqd_df$main_reason, which = c("both", "left", "right"))
Findings_reqd_df$detailed_reason <- trimws(Findings_reqd_df$detailed_reason, which = c("both", "left", "right"))

library(sqldf)
library(RSQLite)
accident_causes_df <- sqldf("
  SELECT d1.ev_id, d1.main_reason, d1.detailed_reason, d2.ev_year, d2.ev_month
  FROM Findings_reqd_df d1 JOIN events_reqd_df d2 JOIN aircraft_df
  ON d1.ev_id = d2.ev_id
  AND d2.ev_id = d3.ev_id
")

# Join Findings_reqd_df, events_reqd_df and aircraft_df
accident_causes_df <- merge(Findings_reqd_df, events_reqd_df, by = "ev_id")
accident_causes_final <- merge(accident_causes_df, aircraft_df, by = "ev_id")
accident_causes_final <- subset(accident_causes_final, 
                                select = c(ev_id, main_reason, detailed_reason, ev_year, ev_month))

# Remove the rows with causes not determined
accident_causes_final <- accident_causes_final[accident_causes_final$main_reason != 'Not determined', ]

# Plots
library(shiny)
library(ggplot2)
library(tidyverse)
library(ggthemes)
library(leaflet)
library(cowplot)

par(mfrow = c(2,2))
# Plot Main Reasons
ggplot(data = accident_causes_final, aes(x=main_reason, origin = 0))  + 
  geom_bar(fill ='dark blue', width = 0.2) + 
  theme_solarized() +
  theme(plot.background = element_rect(fill = 'light yellow')) +
  theme(panel.background = element_rect(fill = 'light blue')) +
  theme(panel.grid.major = element_line(color = 'white')) +
  theme(panel.grid.minor = element_line(color = 'white')) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_y_continuous(name = "Number of Accidents", limits = c(0,15000)) +
  scale_x_discrete(name = "Main Causes") +
  ggtitle("Main Causes of Accidents (2008-17)")

# Plot Secondary Reasons
# Plot Main Reasons
ggplot(data = accident_causes_final, aes(x=detailed_reason, origin = 0))  + 
  geom_bar(fill ='dark blue', width = 0.3) + 
  theme_solarized() +
  theme(plot.background = element_rect(fill = 'light yellow')) +
  theme(panel.background = element_rect(fill = 'light blue')) +
  theme(panel.grid.major = element_line(color = 'white')) +
  theme(panel.grid.minor = element_line(color = 'white')) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_y_continuous(name = "Number of Accidents", limits = c(0,8000)) +
  scale_x_discrete(name = "Specific Causes") +
  ggtitle("Specific Causes of Accidents (2008-17)")

plot_grid(plot1, plot2, labels = "AUTO")

# Trend Over time

library(dplyr)
library(tidyr)     
accident_causes_reason_cnt <- accident_causes_final %>% group_by(ev_year, main_reason) %>% 
  summarise(No_of_accidents = length(main_reason))
accident_causes_reason_cnt <- 
  accident_causes_reason_cnt[accident_causes_reason_cnt$ev_year != 1979, ]

accident_causes_reason_cnt <- as.data.frame(accident_causes_reason_cnt)
accident_causes_reason_cnt$ev_year <- as.character(accident_causes_reason_cnt$ev_year)
accident_causes_reason_cnt$main_reason <- as.factor(accident_causes_reason_cnt$main_reason)

ggplot(accident_causes_reason_cnt, aes(x=ev_year, y=No_of_accidents, fill=ev_year)) + 
  geom_bar(aes(x=ev_year, y=No_of_accidents, fill=ev_year), stat="identity") +
  #geom_smooth(data = accident_causes_reason_cnt, method = 'lm', se = FALSE, size = 1, span = 0.2) +
  facet_wrap(~main_reason) +
  theme_solarized() +
  theme(plot.background = element_rect(fill = 'light yellow')) +
  theme(panel.background = element_rect(fill = 'light blue')) +
  theme(panel.grid.major = element_line(color = 'white')) +
  theme(panel.grid.minor = element_line(color = 'white')) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_y_continuous(name = "Number of Accidents", limits = c(0,1700)) +
  scale_x_discrete(name = "Years") +
  geom_text(aes(label=No_of_accidents), vjust=0, size =4) +
  ggtitle("Year-Wise Trends in Accident Causes") +
  scale_fill_discrete(name = "Years") 



