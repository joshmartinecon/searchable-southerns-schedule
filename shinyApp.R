
library(shiny)
library(dplyr)
library(stringr)
library(rsconnect)

##### Define UI #####
ui <- fluidPage(
  # Application title
  titlePanel("Searchable SEA 2023 Schedule"),
  
  # Author information
  tags$div("Created by ", 
           tags$a("Joshua C. Martin", href = "https://joshmartinecon.github.io/")),
  
  # Updated
  tags$div(paste("Updated: 2023-11-15")),
  
  # More Info
  tags$div(paste("Confused? See"),
           tags$a("here", href = "https://github.com/joshmartinecon/searchable-southerns-schedule")),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    sidebarPanel(
      # Add an input: Text input for keyword in Journal
      textInput("keyword",
                "Include keywords (separate by comma for multiple):",
                value = ""),
      textInput("ex_keyword",
                "Exclude keywords (separate by comma for multiple):",
                value = ""),
    ),
    
    # Show a table of the filtered data
    mainPanel(
      tableOutput("filtered_data")
    )
  )
)

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

##### Run the app #####
shinyApp(ui = ui, server = server)
