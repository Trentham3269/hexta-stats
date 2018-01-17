shinyUI( 
    
  # # Include Google Analytics
  # tags$head(includeScript("www/google-analytics.js")),
    
  navbarPage(title = "HEXTA Stats",
    
    tabPanel(
      title = 'Analyse/Upload',
      id    = 'input',
  
      sidebarLayout(
        
        sidebarPanel(width = 12,
      
          textInput(inputId = 'url',
                    label   = 'Copy and paste web address of HEXTA plot to analyse'),
          
          selectInput(inputId = 'yards',
                      label   = 'Choose yardage for MOA calc',
                      choices = c(300, 400, 500, 600, 700, 800, 900, 1000),
                      width   = '10%'),
  
          actionButton(inputId = 'analyse',
                       label   = 'Analyse',
                       class   = 'btn-primary')
        
        ), 
        
        mainPanel(
          
        )
        
      )
        
    ),
    
    tabPanel(
      title = 'Summary',
      id    = 'output',
      
      sidebarLayout(
        
        sidebarPanel(width = 3
                     
        ),
    
        # Data Table
        mainPanel(
          verbatimTextOutput(outputId = 'txt'),
          br(),
          fluidRow(
            column(width = 12,
              withSpinner(
                plotlyOutput(outputId = 'elev_plot'),
                type = getOption("spinner.type", default = 7)
              )
            )
          ),
          br(),
          fluidRow(
            column(width = 8,
              tableOutput(outputId = 'tbl')
            ),
            column(width = 4,
              tableOutput(outputId = 'tbl_misc')
            )
          )
        )
      )
    )
  )
)