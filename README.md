# Investigation_Of_Aviation_Accidents
Investigation Of Aviation Accidents through Data Visualization
# Project Description
The project first aims to explore NTSB Data for Aviation Accidents and tries to answer below questions related to the dataset.
1. What are the causes of aviation accidents? Is there any visible change in causes over time?
2. Trend in accidents with high casualty rates over time?
3. What are major accident prone zones?
Then this project seeks to do an interactive visualization on the same NTSB Data for Aviation Accidents and tell a story on aviation accidents happened so far and different factors majorly affecting these accidents.

# Data set
## Raw Data Set
File Name: aircraft.txt 
Description: Have the details of the air transports (aircrafts, helicopters, balloons etc.) involved in the accident. 
Size: 80982 rows x 93 columns 

File Name: eADMSPUB_DataDictionary.txt 
Description: Have the descriptions of all the columns of all other data files.  
Size: 4574 rows x 13 columns 

File Name: Findings.txt 
Description: Have data related to NTSB findings on different causes of air accidents. 
Size: 37315 rows x 13 columns 

File Name: events.txt 
Description: Have the causes of the events of air accidents. 
Size: 79805 rows x 71 columns 

File Name: injury.txt 
Description: Have the casualty information of the accidents. 
Size: 450174 rows x 7 columns 

File Name: dt_events.txt 
Description: Also have the causes of the events of air accidents. 
Size: 327706 rows x 5 columns 

File Name: Occurrences.txt 
Description: Have occurrence of events during the flight phase. 
Size: 140334 rows x 8 columns 

File Name: states.txt 
Description: Have the names and zip codes of the states of USA. 
Size: 51 rows x 3 columns 

## Derived Data Set
File Name: Aircraft_Makers_No_Of_Accidents.csv 
Description: Contains year-wise accident information for different aircraft maker companies and their respective models involved into accidents. 
Size: 23204 rows x 5 columns 

File Name: Location_Wise_Accidents.csv 
Description: Contains year-wise locations details such as country, state, city, zip, geocode etc. information for different accidents. 
Size: 21717 rows x 10 columns 

File Name: Reasons_For_Accidents.csv 
Description: Contains year-wise primary, secondary reasons for different air crashes. 
Size: 31613 rows x 9 columns 

# Environment
Technologies Used: R 3.5.1, Tableau 
Tools Used: RStudio, Shiny, Tableau Public 
Libraries: Shiny, ggplot2, plotly 
O/S: Windows 7 

# Run Manual for Shiny App
1.	At first, the shiny application needs to be downloaded from the Moodle, unzipped saved somewhere in the desktop computer.
2.	Within the unzipped folder we will have 3 aforesaid input files and one shiny application. We should keep them within the same folder.
3.	The shiny app should be opened from the same unzipped folder and opened in RStudio. The working directory in RStudio should also be set to the same unzipped folder location.
4.	The shiny app is now ready to run and it should be run from RStudio by clicking green ‘Run App’ button in RStudio.
5.	Once the app starts running, it will open a shiny dashboard panel with three options. The ‘Accidents on Aircraft Makers’ option guides us to the panel for visualizing the accident data linked to different aircraft makers and their respective models. The ‘Accident Locations’ option guides us to the panel for visualizing the accident data linked to different locations of accident. ‘Reasons for the Accidents’ option guides us to the panel for visualizing the accident data linked to different reasons for accidents.
6. If we click on to ‘Accidents on Aircraft Makers’, we go to the respective tab where slider input for a year range and a bar graph appears, showing top 20 aircraft makers involved in accidents against the number of accidents for the aircrafts from these makers. We can select the preferable year range from this slider input and accordingly the bar graph updates itself. From the legend of the bar graph we can select or deselect any maker. If we hover on each bar, the details are shown for that particular bar. If we now click on a bar for a particular maker, a heatmap appears below showing the year-wise accident trends of all models for that maker with that specific year range. For our convenience, we only show the trend for the last 10 years for the specified year range. Hovering on the heatmap shows the number of accidents occurred for that particular model for the given year on Y axis.
7.	If we click on to ‘Accident Locations’, we move to the respective tab where slider input for a year range and a cloropleth map appears, showing different US states (As the location data only for US is available here) as accident prone zones with the respective number of accidents occurred during that time period. We can select the preferable year range from this slider input and accordingly the map updates itself. If we hover mouse pointer on each state, respective accident details appears. The color density in line with the legend on the right hand side shows how worse the state is as an accident prone zone. If we click each state, a bar graph appears below showing the cities with their respective number of accident within the given time period. Hovering our mouse on each bar of the bar graph shows the details of the accidents. We can also select or deselect the cities from the legend of the bar graph.
8.	If we click on to ‘Reasons for the Accidents’, we move to the respective tab where a slider input (which we can adjust as we want) for a year range and two charts appear. The first one is a line chart showing the year-wise trends in the number of accidents for five primary reasons and second one is the proportion of the accidents for the same five reasons within a radar chart. From the line graph, we can select or deselect our preferred reasons from the legend. We can select the preferable year range from this slider input and accordingly these two charts update themselves. If we hover mouse pointer on the lines of the line graph, we get the respective details of the accidents. If we click in each line, an area map appears below showing the year-wise accident details of the secondary reasons under those primary reasons. If we hover mouse pointer on the area graph, respective accident details comes up. We can also choose our preferred secondary reason from the legend.
