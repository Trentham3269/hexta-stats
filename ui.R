shinyUI( 
    
  # # Include Google Analytics
  # tags$head(includeScript("www/google-analytics.js")),
    
  navbarPage(title = "HEXTA Stats",
    
    tabPanel(
      title = 'Analyse/Upload',
      id    = 'input',
  
      sidebarLayout(
        
        sidebarPanel(width = 4,
      
          textInput(inputId = 'url',
                    label   = 'Copy and paste web address of HEXTA plot'),
          
          dateInput(inputId = 'date',
                    label   = 'Select date'),
          
          radioButtons(inputId = 'range',
                       label   = 'Select imperial or metric distance',
                       choices = c('Imperial', 'Metric'),
                       inline  = TRUE),
          
            conditionalPanel(condition = "input.range == 'Imperial'",
              selectInput(inputId = 'yards',
                          label   = 'Select distance in yards',
                          choices = c(300, 400, 500, 600, 700, 800, 900, 1000))
            ),
          
            conditionalPanel(condition = "input.range == 'Metric'",
              selectInput(inputId = 'metres',
                         label    = 'Select distance in metres',
                         choices  = c(300, 400, 500, 600, 700, 800, 900))
            ),
          
          selectInput(inputId = 'barrel',
                      label   = 'Select barrel',
                      choices = c('Bartlein', 'Benchmark', 'Krieger', 'Maddco')), #TODO: Barrel ID
          
          selectInput(inputId = 'powder',
                      label   = 'Select powder type',
                      choices = c('BM8208', 'AR2206H', 'AR2208')),
          
          numericInput(inputId = 'weight',
                       label   = 'Input powder weight (grains)',
                       value   = 45.0,
                       step    = 0.1),
  
          actionButton(inputId = 'analyse',
                       label   = 'Analyse/Upload',
                       class   = 'btn-primary')
        
        ), 
        
        mainPanel(
          
          p('Custom stats to be calculated and uploaded to database')
          
        )
        
      )
        
    ),
    
    tabPanel(
      title = 'Summary',
      id    = 'output',
      
      sidebarLayout(
        
        sidebarPanel(width = 4,
                     
          dateRangeInput(inputId = 'date_range',
                         label   = 'Select date range'),
          
          actionButton(inputId = 'display',
                       label   = 'Display',
                       class   = 'btn-primary')
                     
        ),
    
        # Data Table
        mainPanel(
          
          p('Summary plots and statistics to be retrieved from database'),
          
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