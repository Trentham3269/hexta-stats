shinyUI( 
    
  # # Include Google Analytics
  # tags$head(includeScript("www/google-analytics.js")),
    
  navbarPage(title = 'HEXTA Stats',
    
    tabPanel(
      title = 'Analyse',
      id    = 'input',
  
      sidebarLayout(
        
        sidebarPanel(width = 4,
      
          textInput(
            inputId = 'url',
            label   = 'Copy and paste web address of HEXTA plot'
          ),
          
          textInput(
            inputId     = 'sid',
            label       = 'Input SID',
            placeholder = '12345'
          ),
          
          dateInput(
            inputId = 'date',
            label   = 'Select date'
          ),
          
          numericInput(
            inputId = 'scenario',
            label   = 'Select scenario ID',
            value   = 1,
            min     = 1,
            step    = 1
          ),
          
          selectInput(
            inputId = 'range',
            label   = 'Select range',
            choices = c('Belmont', 'Cessnock', 'Gosford', 'Hornsby')
          ),
          
          radioButtons(
            inputId = 'distance',
            label   = 'Select imperial or metric distance',
            choices = c('Imperial', 'Metric'),
            inline  = TRUE
          ),
          
          conditionalPanel(condition = "input.distance == 'Imperial'",
            selectInput(
              inputId = 'yards',
              label   = 'Select distance in yards',
              choices = c('Please select', 300, 400, 500, 600, 700, 800, 900, 1000)
            ) # TODO: "please select a distance" plotly error message
          ),
          
          conditionalPanel(condition = "input.distance == 'Metric'",
            selectInput(
              inputId = 'metres',
              label    = 'Select distance in metres',
              choices  = c('Please select', 300, 400, 500, 600, 700, 800, 900)
            )
          ),
          
          numericInput(
            inputId = 'stage',
            label   = 'Select stage number',
            value   = 1,
            min     = 1, 
            step    = 1
          ),
          
          actionButton(
            inputId = 'analyse',
            label   = 'Analyse',
            class   = 'btn-primary'
          ), 
          br(),
          br(),
          actionButton(
            inputId = 'save',
            label   = 'Save'
          )
        
        ), 
        
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
            column(width = 7,
                   tableOutput(outputId = 'tbl')
            ),
            column(width = 5,
                   tableOutput(outputId = 'tbl_misc')
            )
          )
          
        )
        
      )
        
    ),
    
    tabPanel(
      title = 'Summary',
      id    = 'output',
      
      sidebarLayout(
        
        sidebarPanel(width = 4,
                     
          # dateRangeInput(inputId = 'date_range',
          #                label   = 'Select date range'),
          
          actionButton(inputId = 'display',
                       label   = 'Display',
                       class   = 'btn-primary')
                     
        ),
    
        # Data Table
        mainPanel(
          
          plotlyOutput(outputId = 'v_plot')
          
        )
      )
    )
  )
)