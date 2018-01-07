shinyUI( 
  
  fluidPage(
    
    # # Include Google Analytics
    # tags$head(includeScript("www/google-analytics.js")),
    
    h2(titlePanel("HEXTA Stats Summary")),
    br(),
    
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
    
      # Data Table
      mainPanel( 
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