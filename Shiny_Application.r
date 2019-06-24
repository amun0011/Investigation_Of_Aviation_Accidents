# Libraries
library(shiny)
library(shinydashboard)
library(plotly)

# Reading Dataframes
aircraft_makers_no_of_accidents_df <- read.delim("Aircraft_Makers_No_Of_Accidents.csv",header = TRUE, sep = ",", dec = ".")
Location_Wise_Accidents_df <- read.delim("Location_Wise_Accidents.csv",header = TRUE, sep = ",", dec = ".")
Reasons_For_Accidents_df <- read.delim("Reasons_For_Accidents.csv",header = TRUE, sep = ",", dec = ".")
Reasons_For_Accidents_df <- subset(Reasons_For_Accidents_df, ev_year != 1979)

# ui part of the application
# Use of Dashboard
ui <- dashboardPage(skin = "purple",
                    # Dashboard Header
                    dashboardHeader(title = "Aviation Accidents"),
                    # Dashboard sidebar
                    dashboardSidebar(
                      sidebarMenu(
                        # Menu items to choose from
                        menuItem("Accidents on Aircraft Makers", tabName = "acftmodel", icon = icon("acftmodel")),
                        menuItem("Accident Locations", tabName = "location", icon = icon("location")),
                        menuItem("Reasons for the Accidents", tabName = "reasons", icon = icon("reasons"))
                      )
                    ),
                    # Dashboard Body
                    dashboardBody(
                      tabItems(
                        tabItem(
                          tabName = "acftmodel",
                          fluidRow(
                            # Instruction manual Panel 1
                            box(
                              title = "Instructions", status = "warning", solidHeader = TRUE, collapsible = TRUE, width = 12,
                              p("1. Adjust the year range."),
                              p("2. Click on the legends of the bar graph to choose preferred aircraft maker."),
                              strong("3. Click on each bar of bar of the bar chart to get second level garph (hitmap)."),
                              p("4. Hover both on the bar chart and hitmap for the further details.")
                            ),
                            
                            # Sidebar input Panel 1
                            box(
                              title = "Inputs", status = "warning", solidHeader = TRUE, collapsible = TRUE, width = 12,
                              sliderInput("year", "Year", min(as.numeric(unique(aircraft_makers_no_of_accidents_df$ev_year))), max(as.numeric(unique(aircraft_makers_no_of_accidents_df$ev_year))), value = c(1948, 2017))
                            )),
                          
                          fluidRow(
                            # Output bar chart Panel 1
                            box(
                            title = "Bar Chart", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 12,
                            plotlyOutput("plot1", height = 350)
                            )
                          ),
                          
                          fluidRow(
                            # Output heatmap Panel 1
                            box(
                            title = "Heatmap", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 12,
                            plotlyOutput("plot2", height = 350)
                            )
                          )
                          
                          ),
                          
                          
                          tabItem(
                            tabName = "location",
                            fluidRow(
                              # Instruction manual Panel 2
                              box(
                                title = "Instructions", status = "warning", solidHeader = TRUE, collapsible = TRUE, width = 12,
                                p("1. Adjust the year range."),
                                strong("2. Click on each state of USA to get the second level garph (bar chart)."),
                                p("3. Hover both on the chloropleth map and bar chart for the further details."),
                                p("4. Click on the legends of the bar graph to choose preferred city.")
                              ),
                              # Sidebar input panel 2
                              box(
                                title = "Inputs", status = "warning", solidHeader = TRUE, collapsible = TRUE, width = 12,
                                sliderInput("year1", "Year", min(as.numeric(unique(Location_Wise_Accidents_df$ev_year))), max(as.numeric(unique(Location_Wise_Accidents_df$ev_year))), value = c(1974, 2017))
                              )
                            ),
                            fluidRow(
                              # Output Cholropleth map panel 2
                              box(
                              title = "Choropleth Maps", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 12,
                              plotlyOutput("plot3", height = 350)
                              )
                            ),
                            # Output bar chart panel 2
                            fluidRow(
                              box(
                              title = "Bar Chart", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 12,
                              plotlyOutput("plot4", height = 350)
                              )
                            )
                            
            
                          ),
                          tabItem(
                            tabName = "reasons",
                            fluidRow(
                            # Instruction manual Panel 3
                            box(
                                title = "Instructions", status = "warning", solidHeader = TRUE, collapsible = TRUE, width = 12,
                                p("1. Adjust the year range."),
                                p("2. Click on the legends of the line graph to choose preferred primary reasons."),
                                strong("3. Click on the each line of the line graph to get second level garph (area map)."),
                                p("4. Click on the legends of the area map to choose preferred secondary reasons."),
                                p("5. Hover both on the line graph and area map for the further details.")
                              ),
                            # Sidebar input panel 3
                            box(
                              title = "Inputs", status = "warning", solidHeader = TRUE, collapsible = TRUE, width = 12,
                              sliderInput("year2", "Year", min(as.numeric(unique(Reasons_For_Accidents_df$ev_year))), max(as.numeric(unique(Reasons_For_Accidents_df$ev_year))), value = c(2008, 2017))
                            )
                            ),
                            # Output line chart panel 3
                            fluidRow(
                              box(
                              title = "Line Chart", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 6,
                              plotlyOutput("plot5", height = 350)
                              ),
                              # Output radar chart panel 3
                              box(
                                title = "Radar Chart", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 6,
                                plotlyOutput("plot6", height = 350)
                              )
                            ),
                            # Output area chart panel 3
                            fluidRow(
                              box(
                              title = "Area Graph", status = "primary", solidHeader = TRUE, collapsible = TRUE, width = 12,
                              plotlyOutput("plot7", height = 350)
                              )
                            )
                          )
                        )
                    )
)

# Server part of the application
server <- function(input, output, session) {
  
  # Code for bar chart in Panel 1
  output$plot1 <- renderPlotly({
    aircraft_makers_subset <- subset(aircraft_makers_no_of_accidents_df, ev_year >= input$year[1] & ev_year <= input$year[2])
    aircraft_makers_subset <- aircraft_makers_subset %>%
      group_by(acft_make) %>%
      summarise(count=n())
    aircraft_makers_subset <- head(aircraft_makers_subset[order(aircraft_makers_subset$count, decreasing = TRUE), ],20)
    aircraft_makers_subset$acft_make <- as.character(aircraft_makers_subset$acft_make)
    plot_ly(aircraft_makers_subset, x = ~acft_make, y = ~count, color = ~acft_make, type = "bar", text = ~paste("<b>Aircraft Maker:</b> ", acft_make, '<br><b>No of Accidents:</b>', count)) %>% 
      layout(title = 'Total Number of Accidents for Aircraft Makers',
                       xaxis = list(title = 'Aircraft Maker'),
                       yaxis = list (title = 'No of Accidents'))
              })
  
  # Code for heatmap in Panel 1
  output$plot2 <- renderPlotly({
    mouse_event <- event_data("plotly_click")
    maker <- mouse_event[3]
    maker_model_subset <- subset(aircraft_makers_no_of_accidents_df, ev_year >= input$year[1] & ev_year <= input$year[2] & acft_make == maker$x)
    maker_model_subset <- maker_model_subset %>%
      group_by(acft_model, ev_year) %>%
      summarise(count=n())
    maker_model_subset <- maker_model_subset[order(maker_model_subset$ev_year, decreasing = TRUE), ]
    maker_model_subset <- subset(maker_model_subset, ev_year >= max(maker_model_subset$ev_year) - 10 & ev_year <= max(maker_model_subset$ev_year))
    maker_model_subset$acft_model <- as.character(maker_model_subset$acft_model)
    
    plot_title <- paste('Number of Accidents for Models for Maker:', maker$x, sep=" ")
    
    plot_ly(
      x = maker_model_subset$acft_model, y = as.character(maker_model_subset$ev_year),
      z = as.character(maker_model_subset$count), type = "heatmap",
      text = ~paste("<b>Aircraft Model:</b> ", maker_model_subset$acft_model,
                    "<b>Year:</b> ", maker_model_subset$ev_year,
                    '<br><b>No of Accidents:</b>', maker_model_subset$count)
    ) %>% 
      layout(title = plot_title,
             xaxis = list(title = 'Aircraft Model'),
             yaxis = list (title = 'No of Accidents'), showlegend = FALSE, showscale = FALSE)
    
  }) 
  
  
  
  # Code for choloropleth map in Panel 2
  output$plot3 <- renderPlotly({
    State_Wise_Accidents_subset <- subset(Location_Wise_Accidents_df, ev_year >= input$year1[1] & ev_year <= input$year1[2])
    State_Wise_Accidents_subset <- State_Wise_Accidents_subset %>%
      group_by(ev_state, ev_state_code) %>%
      summarise(count=n(), latitude = mean(latitude), longitude = mean(longitude))
    
    # give state boundaries a white border
    l <- list(color = toRGB("white"), width = 2)
    # specify some map projection/options
    g <- list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      showlakes = TRUE,
      lakecolor = toRGB('white')
    )
    
    plot_geo(State_Wise_Accidents_subset, locationmode = 'USA-states') %>%
      add_trace(
        z = ~count, text = ~paste("<b>State:</b> ", ev_state, '<br><b>No of Accidents:</b>', count), locations = ~ev_state_code,
        color = ~count, colors = 'Purples'
      ) %>%
      colorbar(title = "No of Accidents") %>%
      layout(
        title = 'US State-wise Accident Numbers',
        geo = g)
    
  })
  
  
  # Code for barchart in Panel 2
  output$plot4 <- renderPlotly({
    State_Wise_Accidents_subset <- subset(Location_Wise_Accidents_df, ev_year >= input$year1[1] & ev_year <= input$year1[2])
    State_Wise_Accidents_subset <- State_Wise_Accidents_subset %>%
      group_by(ev_state, ev_state_code) %>%
      summarise(count=n(), latitude = mean(latitude), longitude = mean(longitude))
    
    mouse_event <- event_data("plotly_click")
    #state <- mouse_event[2]$pointNumber + 1
    state_code <- State_Wise_Accidents_subset[mouse_event[2]$pointNumber + 1, ]$ev_state_code
    state_name <- State_Wise_Accidents_subset[mouse_event[2]$pointNumber + 1, ]$ev_state
    
    City_Wise_Accidents_subset <- subset(Location_Wise_Accidents_df, ev_year >= input$year1[1] & ev_year <= input$year1[2] & ev_state_code == state_code)
    City_Wise_Accidents_subset <- City_Wise_Accidents_subset %>%
      group_by(ev_city) %>%
      summarise(count=n())
    City_Wise_Accidents_subset <- head(City_Wise_Accidents_subset[order(City_Wise_Accidents_subset$count, decreasing = TRUE), ], 20)
    City_Wise_Accidents_subset$ev_city <- as.character(City_Wise_Accidents_subset$ev_city)
    
    plot_title <- paste('Number of Accidents in Cities in State:', state_name, sep=" ")
    
    plot_ly(City_Wise_Accidents_subset, x = ~ev_city, y = ~count, color = ~ev_city, type = "bar", text = ~paste("<b>City Name:</b> ", ev_city, '<br><b>No of Accidents:</b>', count)) %>% 
      layout(title = plot_title,
             xaxis = list(title = 'City Names'),
             yaxis = list (title = 'No of Accidents'))
    
  })
  
  # Code for line graph in Panel 3
  output$plot5 <- renderPlotly({
    Reasons_For_Accidents_df <- subset(Reasons_For_Accidents_df, ev_year >= input$year2[1] & ev_year <= input$year2[2])
    Reasons_For_Accidents_df <- Reasons_For_Accidents_df %>%
      group_by(prim_rsn, ev_year) %>%
      summarise(count=n())
    plot_ly(Reasons_For_Accidents_df, x = ~ev_year, y = ~count, text = ~paste("<b>Primary Reason:</b> ", prim_rsn, "<b>Year:</b> ", ev_year, '<br><b>No of Accidents:</b>', count), color = ~prim_rsn, type = 'scatter', mode = 'lines') %>% 
      layout(title = 'Number of Accidents for Primary Reasons',
             xaxis = list(title = 'Years'),
             yaxis = list (title = 'No of Accidents'))
  })
  
  
  # Code for radar chart in Panel 3
  output$plot6 <- renderPlotly({
    Reasons_For_Accidents_df <- subset(Reasons_For_Accidents_df, ev_year >= input$year2[1] & ev_year <= input$year2[2])
    
    Environment_Issues <- nrow(subset(Reasons_For_Accidents_df, prim_rsn == 'Environmental issues'))
    Aircraft_Issues <- nrow(subset(Reasons_For_Accidents_df, prim_rsn == 'Aircraft'))
    Crew_Issues <- nrow(subset(Reasons_For_Accidents_df, prim_rsn == 'Personnel issues'))
    Organizational_Issues <- nrow(subset(Reasons_For_Accidents_df, prim_rsn == 'Organizational issues'))
    Unknown_Reasons <- nrow(subset(Reasons_For_Accidents_df, prim_rsn == 'Not determined'))
    
    Total <- Environment_Issues + Aircraft_Issues + Crew_Issues + Organizational_Issues + Unknown_Reasons
    
    Environment_Issues_percentage <- round((Environment_Issues/Total) * 100)
    Aircraft_Issues_percentage <- round((Aircraft_Issues/Total) * 100)
    Crew_Issues_percentage <- round((Crew_Issues/Total) * 100)
    Organizational_Issues_percentage <- round((Organizational_Issues/Total) * 100)
    Unknown_Reasons_percentage <- round((Unknown_Reasons/Total) * 100)
    
    Vec <- c(Environment_Issues_percentage, Aircraft_Issues_percentage, Crew_Issues_percentage,
             Organizational_Issues_percentage, Unknown_Reasons_percentage, Environment_Issues_percentage)
    
    plot_ly(
      type = 'scatterpolar',
      r = Vec,
      theta = c('Envr Issues','Aircraft Issues','Personnel Issues', 'Org Issues', 'Not Determined', 'Envr Issues'),
      fill = 'toself'
    ) %>%
      layout(
        polar = list(
          radialaxis = list(
            visible = T,
            range = c(0,50)
          )
        ),
        showlegend = T
      ) %>% 
      layout(title = 'Percentage of Accidents for Primary Reasons')
  })
  
  # Code for area graph in Panel 3
  output$plot7 <- renderPlotly({
    Primary_Reasons_For_Accidents_df <- subset(Reasons_For_Accidents_df, ev_year >= input$year2[1] & ev_year <= input$year2[2])
    Primary_Reasons_For_Accidents_df <- Primary_Reasons_For_Accidents_df %>%
      group_by(prim_rsn) %>%
      summarise(count=n())
    
    mouse_event <- event_data("plotly_click")
    prim_rsn_1 <- Primary_Reasons_For_Accidents_df[mouse_event[1]$curveNumber + 1, ]$prim_rsn
    
    plot_title <- paste('Number of Accidents for Secondary Reasons under Primary Reason:', prim_rsn_1, sep=" ")
    
    Sec_Reasons_For_Accidents_df <- subset(Reasons_For_Accidents_df, ev_year >= input$year2[1] & ev_year <= input$year2[2] & ev_year != 1979 & prim_rsn == prim_rsn_1)
    Sec_Reasons_For_Accidents_df <- Sec_Reasons_For_Accidents_df %>%
      group_by(sec_rsn, ev_year) %>%
      summarise(count=n())
    plot_ly(x = ~Sec_Reasons_For_Accidents_df$ev_year, y = ~Sec_Reasons_For_Accidents_df$count, color = ~Sec_Reasons_For_Accidents_df$sec_rsn, text = ~paste("<b>Primary Reason:</b> ", prim_rsn_1, "<b>Secondary Reason:</b> ", Sec_Reasons_For_Accidents_df$sec_rsn,"<b>Year:</b> ", Sec_Reasons_For_Accidents_df$ev_year, '<br><b>No of Accidents:</b>', Sec_Reasons_For_Accidents_df$count),type = 'scatter', mode = 'lines', fill = 'tozeroy') %>% 
      layout(title = plot_title,
             xaxis = list(title = 'Years'),
             yaxis = list (title = 'No of Accidents'))
    
  })
  
  
  
}

# Combining ui and server
shinyApp(ui = ui, server = server)

