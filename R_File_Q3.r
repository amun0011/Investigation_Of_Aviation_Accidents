# Reading events.txt
events_df <- read.delim("events.txt",header = TRUE, sep = ",", dec = ".")
events_df <- events_df[events_df$ev_type == 'ACC', ]
events_df <- events_df[events_df$ev_country == 'USA', ]

events_df_final <- subset(events_df, select = c(ev_id, ev_year, ev_month, ev_time, 
                                                     ev_city, ev_state, ev_site_zipcode,
                                                     latitude, longitude))
events_df_final[, c(2,3,7,8,9)] <- sapply(events_df_final[, c(2,3,7,8,9)], as.numeric)

View(events_df_final[is.na(events_df_final$latitude), ])

# Reading US states data
states_df <- read.delim("states.txt",header = TRUE, sep = ",", dec = ".")

events_df_final_temp <- sqldf("
  SELECT d1.ev_id, d1.ev_year, d1.ev_month, d1.ev_time, d1.ev_city,
  d2.name AS ev_state, d1.ev_site_zipcode, d1.latitude, d1.longitude
  FROM events_df_final d1 JOIN states_df d2
  ON d1.ev_state = d2.state
")

library(zipcode)
data(zipcode)
View(zipcode)

events_df_final_1 <- sqldf("
  SELECT d1.ev_id, d1.ev_year, d1.ev_month, d1.ev_time, d2.city as ev_city,
  d1.ev_state, d2.zip as ev_zip, d2.latitude, d2.longitude
  FROM events_df_final_temp d1 JOIN zipcode d2
  ON d1.ev_site_zipcode = d2.zip
")

write.csv(events_df_final_1, file = "Accident_Places.csv")

events_df_final_2 <- sqldf("
  SELECT COUNT(*) AS accident_no, AVG(d1.latitude) AS latitude, AVG(d1.longitude) AS longitude, 
  d1.ev_state
  FROM events_df_final_1 d1
  WHERE d1.ev_state NOT LIKE '%ALASKA%'
  GROUP BY d1.ev_state
")



pal <- colorNumeric(
  palette = c("blue", "black", "purple", "green", "red"),
  domain = events_df_final_2$accident_no
)

tag.map.title <- tags$style(HTML("
  .leaflet-control.map-title { 
    transform: translate(-50%,20%);
    position: fixed !important;
    left: 50%;
    text-align: center;
    padding-left: 10px; 
    padding-right: 10px; 
    background: rgba(255,255,255,0.75);
    font-weight: bold;
    font-size: 28px;
  }
"))
title <- tags$div(
  tag.map.title, HTML("USA State-Wise Trends in Aviation Accidents (1979 - 2017)")
) 
qpal <- colorQuantile(c("blue", "black", "purple", "green", "red"), events_df_final_2$accident_no, n = 5)

leaflet(events_df_final_2) %>% 
  addTiles() %>%
  addCircles(lng = ~longitude, 
             lat = ~latitude, 
             weight = 1, 
             radius = ~ accident_no * 1e2, 
             popup = ~ as.character(ev_state),
             label = ~ as.character(accident_no),
             #color = ~pal(accident_no)
             color = ~qpal(accident_no)
             ) %>%
  addLegend("topright", pal = qpal, values = ~accident_no,
            title = "Accidents Occurred (%)",
            labFormat = labelFormat(prefix = " "),
            opacity = 1
  ) %>%
  addControl(title, position = "topleft", className="map-title") 

events_df_final_3 <- sqldf("
  SELECT COUNT(*) AS accident_no, d1.ev_year, d1.ev_state
  FROM events_df_final_1 d1
  WHERE d1.ev_state NOT LIKE '%ALASKA%'
  GROUP BY d1.ev_state, d1.ev_year
")

Q1 <- sqldf("
  SELECT *
  FROM events_df_final_3 d1
  WHERE d1.ev_year BETWEEN 2002 AND 2005
")
Q1$Quarter <- "2002 - 2005"

Q1 <- sqldf("
  SELECT SUM(accident_no) As accident_no, ev_state, Quarter
  FROM Q1 d1
  GROUP BY d1.Quarter, d1.ev_state
")

Q2 <- sqldf("
  SELECT *
  FROM events_df_final_3 d1
  WHERE d1.ev_year BETWEEN 2006 AND 2009
")
Q2$Quarter <- "2006 - 2009"

Q2 <- sqldf("
  SELECT SUM(accident_no) As accident_no, ev_state, Quarter
  FROM Q2 d1
  GROUP BY d1.Quarter, d1.ev_state
")

Q3 <- sqldf("
  SELECT *
  FROM events_df_final_3 d1
  WHERE d1.ev_year BETWEEN 2010 AND 2013
")
Q3$Quarter <- "2010 - 2013"

Q3 <- sqldf("
  SELECT SUM(accident_no) As accident_no, ev_state, Quarter
  FROM Q3 d1
  GROUP BY d1.Quarter, d1.ev_state
")

Q4 <- sqldf("
  SELECT *
  FROM events_df_final_3 d1
  WHERE d1.ev_year BETWEEN 2014 AND 2017
")
Q4$Quarter <- "2014 - 2017"

Q4 <- sqldf("
  SELECT SUM(accident_no) As accident_no, ev_state, Quarter
  FROM Q4 d1
  GROUP BY d1.Quarter, d1.ev_state
")

events_df_final_5 <- rbind(Q1, Q2, Q3, Q4)



ggplot(events_df_final_5, aes(x=ev_state, y=accident_no, fill=ev_state)) + 
  geom_bar(stat="identity") +
  facet_wrap(~Quarter) + 
  theme(legend.position="none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7)) +
  scale_y_continuous(name = "Number of Accidents", limits = c(0,150)) +
  scale_x_discrete(name = "USA States") +
  ggtitle("Year-Wise Trends in Accidents in USA States") +
  theme(plot.background = element_rect(fill = 'light yellow')) +
  theme(panel.background = element_rect(fill = 'light blue')) +
  theme(panel.grid.major = element_line(color = 'white')) +
  theme(panel.grid.minor = element_line(color = 'white')) +
  theme(legend.position="none") +
  geom_text(aes(label=accident_no), vjust=0, size =3)

events_df_final_4 <- events_df_final_3[events_df_final_3$ev_year > 2013, ]

ggplot(events_df_final_4, aes(x=ev_state, y=accident_no, fill=ev_state)) + 
  geom_bar(stat="identity") +
  facet_wrap(~ev_year) + 
  theme(legend.position="none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7)) +
  scale_y_continuous(name = "Number of Accidents", limits = c(0,150)) +
  scale_x_discrete(name = "USA States") +
  ggtitle("Year-Wise Trends in Accidents in USA States") +
  theme(plot.background = element_rect(fill = 'light yellow')) +
  theme(panel.background = element_rect(fill = 'light blue')) +
  theme(panel.grid.major = element_line(color = 'white')) +
  theme(panel.grid.minor = element_line(color = 'white')) +
  theme(legend.position="none") +
  geom_text(aes(label=accident_no), vjust=0, size =4)