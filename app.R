# Libraries
library(shiny)
library(tidyverse)
library(leaflet)
library(reactable)
library(sp)
library(geosphere)
library(shinydashboard)
library("shinyWidgets")

# Relevant Data Streams
patt <- read_csv("dope dope dope.csv")

ZipCodes <- read.table("US.txt", sep="\t")
names(ZipCodes) <- c("CountryCode", "zip", "PlaceName", 
                     "AdminName1", "AdminCode1", "AdminName2", "AdminCode2", 
                     "AdminName3", "AdminCode3", "latitude", "longitude", "accuracy")

# Define UI for application
ui <- fluidPage(
    setBackgroundColor("lightgrey"),
    titlePanel(title=div(img(src="logo.png", height="25%", width="25%", align="center"))),
        div(style = "font-size: 14px; padding: 5px 30px; margin:0%",
            fluidRow(uiOutput("storeChoice"), uiOutput("zipChoice"), uiOutput("radiusChoice"))),
        div(style = "font-size: 14px; padding: 5px 30px; margin:0%",
            fluidRow(leafletOutput("mymap")), br(),
            fluidRow(reactableOutput("table"))))

# Define server logic
server <- function(input, output) {
    # inputs
    output$storeChoice <- renderUI({
        selectizeInput("storeChoice", "Choose a Store", unique(patt$location_name), selected = "Walmart", multiple = TRUE)
    })
    
    output$zipChoice <- renderUI({
        numericInput("zipChoice", "Enter your ZIP code", value = 30322, min = 10000, max = 99999)
    })
    
    output$radiusChoice <- renderUI({
        numericInput("radiusChoice", "How far do you want to search?", value = 30)
    })
    
    # reactive df
    df <- reactive({
        test <- patt %>% filter(!is.na(lon)) %>% filter(location_name %in% input$storeChoice)
        
        new <- distHaversine(SpatialPoints(ZipCodes[match(input$zipChoice, ZipCodes$zip), 11:10]),
                             SpatialPoints(test %>% select(lon, lat)))
        
        test <- left_join((test)[which(new < (input$radiusChoice)*1609.34), 1:9], test, by = "safegraph_place_id")
        
        pared <- new[new < (input$radiusChoice)*1609.34]
        
        test <- cbind(test, pared)
        
        test <- test %>% mutate("Distance" = `pared`/1609.34)
        })

    df2 <- reactive({
        details <- data.frame(df() %>% select(popularity_by_day) %>%
            mutate(popularity_by_day = str_sub(popularity_by_day, 2, -2)) %>%
            separate(popularity_by_day, into = c("blank", "no", "Mon", "no2", "Tues","no3", 
                                                 "Wed", "no4", "Thurs", "no5", "Fri","no6",  "Sat","no7",  'Sun')) %>% 
            select(!c("blank", "no", "no2", "no3", "no4", "no5","no6", "no7")))
    })
    
    # reactable
    output$table <- renderReactable({
        reactable(df() %>% select(location_name.x, street_address.x, expected_covid_vistors, Distance) %>%
                      mutate(Location = location_name.x) %>% mutate(Address = street_address.x) %>%
                      mutate("COVID Score" = round(expected_covid_vistors,0)) %>% 
                      mutate(Distance = round(Distance,1)) %>% 
                      select(Location, Address, `COVID Score`, Distance), 
                  outlined = TRUE,
                  striped = TRUE,
                  compact = TRUE,
                  columns = list(
                      Distance = colDef(format = colFormat(suffix = " mi")),
                      Location = colDef(cell = function(value, index) {
                          url <- paste("https://www.google.com/maps/search/", value, df()[index,"street_address.x"])
                          tags$a(href = url, target = "_blank", as.character(value))
                      }),
                      `COVID Score` = colDef(style = function(value) {
                          if (is.na(value)) {
                            color <- "yellow"
                          } else if (value > mean(df()$expected_covid_vistors, na.rm = T)) {
                              color <- "red"
                          } else if (value < mean(df()$expected_covid_vistors, na.rm = T)) {
                              color <- "green"
                          }
                          list(color = color, fontWeight = "bold")
                      }, sortNALast = T)),
                  details = function(index) {
                      plant_data <- df2()[index, ]
                      div(style = "padding: 16px", reactable(plant_data, outlined = TRUE)
                      )
                  }
                  )
    })
    
    # leaflet
    output$mymap <- renderLeaflet({
        leaflet() %>%
            setView(lng = mean(df()$lon), lat = mean(df()$lat), zoom = 10) %>%
            addTiles() %>%
            addCircleMarkers(lng = df()$lon, 
                             lat = df()$lat,
                             popup = paste(df()$location_name.x, df()$street_address.x, 
                                           df()$city.x, df()$region.x, sep = ", "),
                             radius = 5)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
