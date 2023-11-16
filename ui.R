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
