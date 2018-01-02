shinyUI( 
  
  fluidPage(
    
    # Apply free bootswatch theme
    theme = shinytheme("flatly"),
    
    # # Include Google Analytics
    # tags$head(includeScript("www/google-analytics.js")),
    
    h2(titlePanel("")),
    h3(titlePanel("")),
    br(),
    
    sidebarLayout(

      sidebarPanel(width = 4,
                   

        
        p(paste("Data is current as at", format(Sys.Date(), "%d.%m.%Y")))
      ),
      
      # Data Table
      mainPanel( 
           
      )
      
    ) 
    
  )
  
)