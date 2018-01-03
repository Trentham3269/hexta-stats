shinyServer(function(input, output, session) {
  
  # URL --------------------------------------------------------------------------------------------
  
  url <- eventReactive(input$analyse, {
    paste0(input$url, '?inch=1')
  })
  
  # DATA -------------------------------------------------------------------------------------------
  
  # Scrape shots table as list
  shots_scrape <- reactive({
    url() %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="shots-grid"]/table') %>%
      html_table(fill = T)
  })
  
  # Extract dataframe from list
  shots <- reactive({
    shots_scrape()[[1]]
  })
  
  # STATS ------------------------------------------------------------------------------------------
  
  # Extreme spread of windage 
  ext_wind <- reactive({
    min <- min(shots()$`X (inch)`)
    max <- max(shots()$`X (inch)`)
    ext <- abs(min) + max #TODO: test formula re: all shots on one side of target
    paste0(round(ext, 1), " inch")
  })
  
  # Extreme spread of elevation
  ext_elev <- reactive({
    min <- min(shots()$`Y (inch)`)
    max <- max(shots()$`Y (inch)`)
    ext <- abs(min) + max #TODO: test formula re: all shots above/below waterline
    paste0(round(ext, 1), " inch")
  })

  # Std dev of windage
  sd_wind <- reactive({
    paste0(round(sd(shots()$`X (inch)`), 1), " inch")
  })

  # Std dev of elevation
  sd_elev <- reactive({
    paste0(round(sd(shots()$`Y (inch)`), 1), " inch")
  })

  # V percentage
  v_prcnt <- reactive({
    v <- ifelse(shots()$Score %in% c('V', 'X', 'PIN'), 1, 0) #TODO: exclude non-converted sighters
    paste0(round(sum(v) / nrow(shots()) * 100, 1), "%")
  })

  # X percetage of Vs
  x_prcnt <- reactive({
    v <- ifelse(shots()$Score %in% c('V', 'X', 'PIN'), 1, 0)
    x <- ifelse(shots()$Score %in% c('X', 'PIN'), 1, 0)
    paste0(round(sum(x) / sum(v) * 100, 1), "%")
  })
  
  # OUTPUT -----------------------------------------------------------------------------------------
  
  output$tbl <- renderTable({
    df <- data_frame(
      `Extreme elevation spread`      = ext_elev(),
      `Elevation std. deviation`      = sd_elev(),
      `Extreme windage spread`        = ext_wind(),
      `Windage std. deviation`        = sd_wind(),
      `Percentage of shots in V-bull` = v_prcnt(),
      `Percentage of Vs in X-ring`    = x_prcnt()
    )
    gather(df)
  })

}) 