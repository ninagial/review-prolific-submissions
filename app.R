
library(shiny)
library(devtools)
load_all("process_prolific")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Process a Prolific Export"),

    sidebarLayout(
      
      # Sidebar panel for inputs ----
      sidebarPanel(
        
        # Input: Select a file ----
        fileInput("file1", "Choose CSV File",
                  multiple = FALSE,
                  accept = c("text/csv",
                             "text/comma-separated-values,text/plain",
                             ".csv")),
        
        # Horizontal line ----
        tags$hr(),
        
               
        # Input: Select number of rows to display ----
        radioButtons("disp", "Display",
                     choices = c(Head = "head",
                                 All = "all"),
                     selected = "head"),
        
      checkboxGroupInput("include_status", "Submission Status (To Include):",
			     c(  "APPROVED" = "APPROVED",
			         "REJECTED" = "REJECTED",
			         "AWAITING REVIEW" = "AWAITING REVIEW",
				 "TIMED-OUT" = "TIMED-OUT",
				 "RETURNED" = "RETURNED")),
      textOutput("statuses"), 

      tags$hr(),

      sliderInput(inputId="time_quantile", 
		  label="Quantile of time taken, to cut off:", 
		  min=70, 
		  max=100,
                  ticks=FALSE,
                  value=90 )
      ), # end sidebar panel
      
		    
      # Main panel for displaying outputs ----
      mainPanel(
        
        # Output: Data file ----
	tags$h2("Original Data"),
        tableOutput("contents"),

	tags$h2("Participants that took too much time"),
	tableOutput("time_taken")
      )
      
    )
)

# Define server logic to read selected file ----
server <- function(input, output) {
  
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    
    req(input$file1)
    
    prolific_export <- read_prolific_export(input$file1$datapath)
    include_logical <- prolific_export$status %in% input$include_status
    prolific_export <- prolific_export[include_logical, ]

    if(input$disp == "head") {
      return(head(prolific_export))
    }
    else {
      return(prolific_export)
    }
    
  })

  output$statuses <- renderText({ paste(collapse=", ", input$include_status) })

}
# Run the app ----
shinyApp(ui, server)
