package.list <- c('tidyverse', 'XML', 'xml2', 'rvest', 'httr', 'jsonlite', 'telegram.bot', 'taskscheduleR', 'gmailr', 'tuber', 'leaflet', 'knitr', 'kableExtra', 'readxl', 'writexl', 'DT', 'RSelenium', 'curl', 'seleniumPipes', 'glue', 'flexdashboard', 'RCurl', 'KeyboardSimulator')

not.found.packages <- package.list[!package.list %in% installed.packages()[,1]]
install.packages(not.found.packages)

library(rvest)
library(RSelenium)


# 항공 데이터 웹스크래핑
scrapeFlightData <- function() {

  driver <- rsDriver(browser = "firefox", port = 4221L, chromever=NULL)
  remDr <- driver$client
  
  remDr$navigate("https://flight.naver.com/flights/")
  
  ## 출발지 선택
  one_way <- remDr$findElement(using = 'css selector', '.searchBox_Tab__3RZhS:nth-child(2) .searchBox_text__RMGxG')
  one_way$clickElement()
  Sys.sleep(5)
  departure_box <- remDr$findElement(using = 'css selector', '.select_code__IVa3P')
  departure_box$clickElement()
  departure_input <- remDr$findElement(using = 'css selector', 'input.autocomplete_input__qbYlb')
  departure_input$sendKeysToElement(list("제주"))
  Sys.sleep(2)
  departure <- remDr$findElement(using = "css selector", "a.autocomplete_search_item__8Wqp5")
  departure$clickElement()
  
  ## 도착지 선택
  Sys.sleep(5)
  arrival_box <- remDr$findElement(using = 'css selector', '.end .select_code__IVa3P')
  arrival_box$clickElement()
  arrival_input <- remDr$findElement(using = 'css selector', 'input.autocomplete_input__qbYlb')
  arrival_input$sendKeysToElement(list("김포"))
  Sys.sleep(2)
  destination <- remDr$findElement(using = "css selector", "a.autocomplete_search_item__8Wqp5")
  destination$clickElement()
  
  ## 날짜 선택
  Sys.sleep(5)
  date_input <- remDr$findElement(using = 'css selector', '.select_Date__Potbp')
  date_input$clickElement()
  date_to_select <- remDr$findElement(using = 'css selector', '.today')
  date_to_select$clickElement()
  
  Sys.sleep(5)
  search <- remDr$findElement(using = 'css selector', '.searchBox_search__dgK4Z')
  search$clickElement()
  
  ## 항공권 데이터 스크래핑
  Sys.sleep(5) 
  page_source <- remDr$getPageSource()[[1]]
  res <- read_html(page_source)
  
  flight_data_list <- list()
  flights <- res %>% html_nodes(".domestic_Flight__8bR_b")
  
  for (flight in flights) {
    airline <- flight %>% html_node(".airline_name__0Tw5w") %>% html_text(trim = TRUE)
    departure_time <- flight %>% html_node(xpath = "(.//b[@class='route_time__xWu7a'])[1]") %>% html_text(trim = TRUE)
    arrival_time <- flight %>% html_node(xpath = "(.//b[@class='route_time__xWu7a'])[2]") %>% html_text(trim = TRUE)
    price <- flight %>% html_node(".domestic_num__ShOub") %>% html_text(trim = TRUE)
    logo_url <- flight %>% html_node(".airline_logos__Nv1aD img") %>% html_attr("src")
    
    ## 이미지 다운로드
    if (!is.null(logo_url)) {
      download.file(logo_url, destfile = paste0("logo_", gsub(" ", "_", airline), ".png"), mode = 'wb')
    }
    
    flight_data_list[[length(flight_data_list) + 1]] <- data.frame(
      Airline = airline,
      DepartureTime = departure_time,
      ArrivalTime = arrival_time,
      Price = price,
      LogoURL = logo_url,
      stringsAsFactors = FALSE
    )
  }
  
  flight_data <- do.call(rbind, flight_data_list)
  write.csv(flight_data, "flight_data.csv", row.names = FALSE)
  

  remDr$close()
  remDr$closeServer()
  driver$server$stop()
}

scrapeFlightData()
