
library(shiny)
library(dplyr)
library(stringr)
library(rsconnect)

##### Define server #####

server <- function(input, output) {
  # Reactive expression to filter and sort data based on inputs
  filtered_data <- reactive({
    data_filtered <- read.csv("southerns 2023 schedule.csv")
    
    # Concatenate all columns into a single character vector
    all_text <- apply(data_filtered, 1, paste, collapse = " ")
    
    if (input$keyword != "") {
      keywords <- trimws(unlist(strsplit(input$keyword, ",")))
      data_filtered <- data_filtered[Reduce(`|`, lapply(keywords, function(k) grepl(k, all_text))), ]
    }
    
    if (input$ex_keyword != "") {
      ex_keywords <- trimws(unlist(strsplit(input$ex_keyword, ",")))
      data_filtered <- data_filtered[!Reduce(`|`, lapply(ex_keywords, function(k) grepl(k, all_text))), ]
    }
    
    data_filtered
  })
  
  # Render the table output for filtered data
  output$filtered_data <- renderTable({
    filtered_data()
  })
}
