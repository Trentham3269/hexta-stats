shinyServer(function(input, output, session) {
  
  # URL INPUT --------------------------------------------------------------------------------------
  
  url <- eventReactive(input$analyse, {
    paste0(input$url, '?inch=1')
  })
  
  # YARDAGE INPUT ----------------------------------------------------------------------------------

  yards <- eventReactive(input$analyse, {
    switch(input$yards, 
           '300'  = 3,
           '400'  = 4,
           '500'  = 5,
           '600'  = 6,
           '700'  = 7,
           '800'  = 8,
           '900'  = 9,
           '1000' = 10)
  })
  
  # SCRAPE DATA ------------------------------------------------------------------------------------
  
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
    round(ext, 1)
  })
  
  # Extreme spread of elevation
  ext_elev <- reactive({
    min <- min(shots()$`Y (inch)`)
    max <- max(shots()$`Y (inch)`)
    ext <- abs(min) + max #TODO: test formula re: all shots above/below waterline
    round(ext, 1)
  })

  # Std dev of windage
  sd_wind <- reactive({
    round(sd(shots()$`X (inch)`), 1)
  })

  # Std dev of elevation
  sd_elev <- reactive({
    round(sd(shots()$`Y (inch)`), 1)
  })
  
  # MOA of extreme windage
  moa_ext_wind <- reactive({
    moa <- ext_wind() / yards()
    round(moa, 1)
  })
  
  # MOA of extreme elevation
  moa_ext_elev <- reactive({
    moa <- ext_elev() / yards()
    round(moa, 1)
  })
  
  # MOA of windage std. deviation
  moa_sd_wind <- reactive({
    moa <- sd_wind() / yards()
    round(moa, 1)
  })
  
  # MOA of elevation std. deviation
  moa_sd_elev <- reactive({
    moa <- sd_elev() / yards()
    round(moa, 1)
  })

  # V percentage
  v_prcnt <- reactive({
    v <- ifelse(shots()$Score %in% c('V', 'X', 'PIN'), 1, 0) #TODO: exclude non-converted sighters
    round(sum(v) / nrow(shots()) * 100, 1)
  })

  # X percetage of Vs
  x_prcnt <- reactive({
    v <- ifelse(shots()$Score %in% c('V', 'X', 'PIN'), 1, 0)
    x <- ifelse(shots()$Score %in% c('X', 'PIN'), 1, 0)
    round(sum(x) / sum(v) * 100, 1)
  })
  
  # OUTPUT -----------------------------------------------------------------------------------------
  
  output$tbl <- renderTable({
    df <- data_frame(
      `Extreme elevation spread (inch)` = ext_elev(),
      `Extreme elevation spread (MOA)`  = moa_ext_elev(),
      `Elevation std. deviation (inch)` = sd_elev(),
      `Elevation std. deviation (MOA)`  = moa_sd_elev(),
      `Extreme windage spread (inch)`   = ext_wind(),
      `Extreme windage spread (MOA)`    = moa_ext_wind(),
      `Windage std. deviation (inch)`   = sd_wind(),
      `Windage std. deviation (MOA)`    = moa_sd_wind(),
      `Proportion of V-bulls (%)`       = v_prcnt(),
      `Proportion of Vs in X-ring (%)`  = x_prcnt()
    )
    gather(df)
  })

}) 