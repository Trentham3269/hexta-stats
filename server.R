shinyServer(function(input, output, session) {
  
  # Analyse tab
  
  source('./server/server_analyse.R', local = TRUE)
  
  # Summary tab

  source('./server/server_summary.R', local = TRUE)
  
}) 