
library(dplyr)
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
         tabsetPanel(type='tabs', 
		
           tabPanel("Prolific File", 
		# Input: Select a file ----
		fileInput("file1", "Choose CSV File (ie Prolific Export)",
			  multiple = FALSE,
			  accept = c("text/csv",
				     "text/comma-separated-values,text/plain",
				     ".csv")),
		tags$hr()
		
		),
		
	  tabPanel("Survey Data", 
		fileInput("file2", "Choose Survey Data File",
			  multiple = FALSE,
			  accept = c("text/csv",
				     "text/comma-separated-values,text/plain",
				     ".csv")),
	      textInput("prolific_id_field", "Column that contains Prolific ID in Survey Data", value="Prolific.ID"),

		radioButtons('qualtrics', "Is this a Qualtrics export?", 
			     c('Yes','No'), selected='Yes'),
	      tags$hr(),

	      # Input: Checkbox if file has header ----
	      checkboxInput("header", "Header", TRUE),

	      # Input: Select separator ----
	      radioButtons("sep", "Separator",
			   choices = c(Comma = ",",
				       Semicolon = ";",
				       Tab = "\t"),
			   selected = ","),

	      # Input: Select quotes ----
	      radioButtons("quote", "Quote",
			   choices = c(None = "",
				       "Double Quote" = '"',
				       "Single Quote" = "'"),
			   selected = '"'),

	      # Horizontal line ----
	      tags$hr(),
	      
		# Input: Select number of rows to display ----
		radioButtons("disp", "Display",
			     choices = c(Head = "head",
					 All = "all"),
			     selected = "head")
		

	      
	      ), # end survey data panel

	  tabPanel("Criteria",
	      checkboxGroupInput("include_status", "Submission Status (To Include):",
				     c(  "APPROVED" = "APPROVED",
					 "REJECTED" = "REJECTED",
					 "AWAITING REVIEW" = "AWAITING REVIEW",
					 "TIMED-OUT" = "TIMED-OUT",
					 "RETURNED" = "RETURNED"),
				 selected="AWAITING REVIEW"),
	      textOutput("statuses"), 

	      textInput("sections", "Mandatory Survey Sections (RegEx)", value="^Q1_|^Q6_|^Q10_|^Q12_|^Q4_"), 
	      sliderInput(inputId="time_quantile", 
			  label="Quantile of time taken, to cut off:", 
			  min=50, 
			  max=100,
			  ticks=FALSE,
			  value=90 )
		   ) 
	       ) # end tabset panel
	      ) # end sidebar panel
	      ,
		    
      # Main panel for displaying outputs ----
      mainPanel(
        
	  tabsetPanel(type="tabs",
		       tabPanel("Results", tableOutput("process")),
		       tabPanel("Prolific", tableOutput("contents")),
		       tabPanel("Survey Data", {
			    tableOutput("contents2")
				 }),
		       tabPanel("Codebook", tableOutput("metadata"))
      )
      
    )
))

# Define server logic to read selected file ----
server <- function(input, output) {
  qualtrics <- reactive({
	  req(input$file2)
	  if(input$qualtrics=="Yes"){
		  qual <- read_qualtrics_file(input$file2$datapath)
	  } else {
		  qual <- read.csv(input$file1$datapath,
				   header = input$header,
				   sep = input$sep,
				   quote = input$quote)

	  } 
	  qual
	  
  })
  
  prolific <- reactive({
	  # This belongs to the whole server function
	  # To work, it should be _called_ like prolific() inside rendering functions
    
    req(input$file1)
    
    prolific_export <- read_prolific_export(input$file1$datapath)
    include_logical <- prolific_export$status %in% input$include_status
    prolific_export <- prolific_export[include_logical, ]

    
    taken_too_much_time_q <- time_quantiles(prolific_export, cutoff=input$time_quantile)
    prolific_export[, 'too_slow'] <- taken_too_much_time_q$excl_logical
    prolific_export
    
  })

  output$contents <- renderTable({
	  df <- prolific()
	  if (input$disp == 'head'){
		  return(head(df))
	  } else {
		  return(df)
	  }
  })

  output$process <- renderTable({

        qual <- qualtrics()$data
	prol <- prolific()
	no_prolific_id <- qual[, input$prolific_id_field] == ""
	# Following is necessary because merge loses the id
	qual_temp <- qual
	qual_temp$participant_id <- qual_temp[, input$prolific_id_field]
	data_all <- merge(qual_temp[!no_prolific_id,], prol, by.x=input$prolific_id_field, by.y='participant_id')

	taken_too_much_time_q <- time_quantiles(data_all, cutoff=90)
	data_all[, 'too_slow'] <- taken_too_much_time_q$excl_logical
	important_sections <- grep(input$sections, colnames(data_all), val=T)
	section_skippers <- skipped_section(data=data_all, 
			    section_colnames=important_sections)
	data_all[, 'skipped_sections'] <- section_skippers$excl_logical
	data_all[, 'no_code'] <- data_all$entered_code == 'NOCODE'
	# filter(data_all,  too_slow | skipped_sections)[, c(input$prolific_id_field,'status', 'too_slow', 'skipped_sections')]
	data_all[, c(input$prolific_id_field,'status', 'too_slow', 'skipped_sections', 'no_code')]

  })


  output$contents2 <- renderTable({
	  df <- qualtrics()
	  return(df$data)
  })

  output$metadata <- renderTable({
	  if (input$qualtrics == 'Yes'){
	    df <- qualtrics()
	    return(df$codebook)
	  } else {
		  matrix(NA, 2, 2)
	  }
  })

  output$statuses <- renderText({ paste(collapse=", ", input$include_status) })

}
# Run the app ----
shinyApp(ui, server)
