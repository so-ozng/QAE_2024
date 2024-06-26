library(rvest)
library(RSelenium)


# 날씨 데이터 웹스크래핑
scrapeWeatherData <- function() {

  driver <- rsDriver(browser = "firefox", port = 4220L, chromever=NULL)
  remDr <- driver$client
  
  remDr$navigate("https://weather.naver.com/")
  
  ## 위치 선택
  Address <- remDr$findElement(using = 'css selector', '._cnSearchPopup ')
  Address$clickElement()
  Sys.sleep(2)
  Address_input <- remDr$findElement(using = 'css selector', '.interest_form_input')
  Address_input$sendKeysToElement(list("제주시 용담이동"))
  Sys.sleep(5)
  Address_select <- remDr$findElement(using = 'css selector', '.interest_result_list')
  Address_select$clickElement()
  
  ## 시간, 온도 및 날씨 데이터 스크래핑
  time_elements <- remDr$findElements(using = 'css selector', '._cnItemTime')
  ymdt_values <- unlist(lapply(time_elements, function(x) { x$getElementAttribute("data-ymdt") }))
  
  times <- sapply(ymdt_values, function(ymdt) {
    date_part <- substr(ymdt, 1, 8)
    hour_part <- substr(ymdt, 9, 10)
    formatted_time <- paste0(substr(date_part, 1, 4), "-", substr(date_part, 5, 6), "-", substr(date_part, 7, 8), " ", hour_part, "시")
    return(formatted_time)
  })
  
  temperatures <- unlist(lapply(time_elements, function(x) { x$getElementAttribute("data-tmpr") }))
  weather <- unlist(lapply(time_elements, function(x) { x$getElementAttribute("data-wetr-txt") }))
  
  rain_prob_elements <- remDr$findElements(using = 'css selector', 'td.data span.unit_value em')
  rain_probs <- unlist(lapply(rain_prob_elements, function(x) { x$getElementText() }))
  
  weather_data_list <- list()
  for (i in 1:length(times)) {
    weather_data_list[[i]] <- data.frame(
      Time = times[i],
      Temperature = temperatures[i],
      Weather = weather[i],
      Rain_Probability = rain_probs[i],
      stringsAsFactors = FALSE
    )
  }
  
  weather_data <- do.call(rbind, weather_data_list)
  write.csv(weather_data, "weather_data.csv", row.names = FALSE)
  

  remDr$close()
  remDr$closeServer()
  driver$server$stop()
}

scrapeWeatherData()