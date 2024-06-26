library(shiny)
library(dplyr)
library(readr)
library(ggplot2)
library(rvest)
library(DT)
library(RSelenium)


flight_data <- read.csv("flight_data.csv", stringsAsFactors = FALSE)
weather_data <- read.csv("weather_data.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  
  titlePanel("Flight and Weather Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      dateInput("input_date", "Select Date:", value = Sys.Date(), format = "yyyy-mm-dd"),
      selectInput("departure", "Departure:", choices = c("제주", "김포")),
      selectInput("arrival", "Arrival:", choices = c("김포", "제주")),
      actionButton("scrape_button", "Scrape Flight Data"),
      hr(),
      h4("Scraping Status"),
      verbatimTextOutput("scrape_status")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Flight Data", 
                 DTOutput("flight_table"),
                 plotOutput("flight_price_plot")),
        tabPanel("Weather Data", 
                 DTOutput("weather_table"),
                 plotOutput("weather_temperature_plot"))
      )
    )
  )
)

server <- function(input, output, session) {
  
  observe({
    updateSelectizeInput(session, "departure", choices = unique(flight_data$DepartureTime))
    updateSelectizeInput(session, "arrival", choices = unique(flight_data$ArrivalTime))
  })
  
  observeEvent(input$scrape_button, {

    scrapeFlightData()
    scrapeWeatherData()
    
    flight_data <<- read.csv("flight_data.csv", stringsAsFactors = FALSE)
    weather_data <<- read.csv("weather_data.csv", stringsAsFactors = FALSE)
    
  
  output$flight_table <- renderDT({
    flight_data <- read.csv("flight_data.csv", stringsAsFactors = FALSE)
    filtered_flight_data <- flight_data %>%
      filter(DepartureTime == input$departure, ArrivalTime == input$arrival)
    datatable(filtered_flight_data, options = list(pageLength = 10))
  })
  
  output$flight_price_plot <- renderPlot({
    filtered_flight_data <- flight_data %>%
      filter(DepartureTime == input$departure, ArrivalTime == input$arrival)
    ggplot(filtered_flight_data, aes(x = Airline, y = Price, fill = Airline)) +
      geom_boxplot() +
      labs(title = "Flight Price Distribution", x = "Airline", y = "Price") +
      theme_minimal()
  })
  
  output$weather_temperature_plot <- renderPlot({
    filtered_weather_data <- weather_data %>%
      filter(substr(Time, 1, 10) == as.character(input$selected_date))
    
    filtered_weather_data$Hour <- gsub("^.*\\s(\\d{2})시$", "\\1", filtered_weather_data$Time)
    
    ggplot(filtered_weather_data, aes(x = Hour, y = Temperature, group = 1)) +
      geom_line() +
      labs(title = "Temperature Changes", x = "Time (Hour)", y = "Temperature (°C)") +
      theme_minimal()
  })
  
}

shinyApp(ui = ui, server = server)
