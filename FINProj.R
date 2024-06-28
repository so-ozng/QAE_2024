install.packages("future")
install.packages("promises")
install.packages("quarto")
library(future)
library(promises)
plan(multisession)

library(shiny)
library(dplyr)
library(readr)
library(ggplot2)
library(rvest)
library(DT)
library(RSelenium)

# Read initial data
flight_data <- read.csv("flight_data_origin.csv", stringsAsFactors = FALSE)
weather_data <- read.csv("weather_data_origin.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel("Flight and Weather Dashboard"),
  sidebarLayout(
    sidebarPanel(
      dateInput("input_date", "Select Date:", value = Sys.Date(), format = "yyyy-mm-dd"),
      selectInput("departure_input", "Departure:", choices = c("제주", "김포")),
      selectInput("arrival_input", "Arrival:", choices = c("김포", "제주")),
      actionButton("scrape_button", "Search"),
      hr(),
      textOutput("updateTime")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Flight Data", 
                 DTOutput("flight_table")),
        tabPanel("Weather Data", 
                 DTOutput("weather_table"),
                 fluidRow(column(12, hr())),
                 plotOutput("weather_temperature_plot"))
      )
    )
  )
)

server <- function(input, output, session) {
  
  # 초기 데이터
  output$flight_table <- renderDT({
    datatable(flight_data, options = list(pageLength = 7))
  })
  
  output$weather_table <- renderDT({
    datatable(weather_data, options = list(pageLength = 7))
  })
  
  output$weather_temperature_plot <- renderPlot({
    filtered_weather_data <- weather_data %>%
      filter(substr(Time, 1, 10) == as.character(input$input_date))
    
    filtered_weather_data$Hour <- gsub("^.*\\s(\\d{2})시$", "\\1", filtered_weather_data$Time)
    
    ggplot(filtered_weather_data, aes(x = as.numeric(Hour), y = Temperature, group = 1)) +
      geom_line(color = "lightgreen", size = 1.5) +
      geom_point(color = "skyblue", size = 3) +
      scale_x_continuous(breaks = seq(0, 23, by = 1)) +
      labs(title = "Temperature Changes", x = "Hour of the Day", y = "Temperature (°C)") +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
        axis.title.x = element_text(size = 15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"),
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12)
      )
  })
  
  observeEvent(input$scrape_button, {
    
    future({
      scrapeFlightData()  
      scrapeWeatherData()  
    }) %...>% {
      flight_data <<- read.csv("flight_data.csv", stringsAsFactors = FALSE)
      weather_data <<- read.csv("weather_data.csv", stringsAsFactors = FALSE)
    } %...!% {
      print("Error in scraping data")
    }
    
    output$updateTime <- renderText({paste("업데이트 시간:", Sys.time())})
    
    ## flight data
    output$flight_table <- renderDT({
      datatable(flight_data, options = list(pageLength = 7))
    })
    
    ## weather data    
    output$weather_table <- renderDT({
      datatable(weather_data, options = list(pageLength = 7))
    })
    
    output$weather_temperature_plot <- renderPlot({
      filtered_weather_data <- weather_data %>%
        filter(substr(Time, 1, 10) == as.character(input$input_date))
      
      filtered_weather_data$Hour <- gsub("^.*\\s(\\d{2})시$", "\\1", filtered_weather_data$Time)
      
      ggplot(filtered_weather_data, aes(x = as.numeric(Hour), y = Temperature, group = 1)) +
        geom_line(color = "lightgreen", size = 1.5) +
        geom_point(color = "skyblue", size = 3) +
        scale_x_continuous(breaks = seq(0, 23, by = 1)) +
        labs(title = "Temperature Changes", x = "Time (Hour)", y = "Temperature (°C)") +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
          axis.title.x = element_text(size = 15, face = "bold"),
          axis.title.y = element_text(size = 15, face = "bold"),
          axis.text.x = element_text(size = 12),
          axis.text.y = element_text(size = 12)
        )
    })
  })
}

shinyApp(ui = ui, server = server)

