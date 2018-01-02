shinyServer(function(input, output) {
  
  # URL --------------------------------------------------------------------------------------------
  
  url <- eventReactive(input$analyse, {
    paste0(input$url, '?inch=1')
  })
  
  # DATA -------------------------------------------------------------------------------------------
  
  # Scrape summary table as list
  table_scrape <- reactive({
    url() %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="w0"]') %>%
      html_table(fill = T)
  })

  # Dataframe
  table <- reactive({
    table_scrape()[[1]]
  })

  # Clean X and Y extreme spread and change type to numeric
  x_num <- reactive({
    x_char <- table()$X2[[10]]
    # as.numeric(gsub(pattern = " inch", replacement = "", x = x_char))
  })
  y_num <- reactive({
    y_char <- table()$X2[[11]]
    # as.numeric(gsub(pattern = " inch", replacement = "", x = y_char))
  })
  
  # --------------------------------------------------------------------------------------------------

  # Scrape shots table as list
  shots_scrape <- reactive({
    url() %>%
      read_html() %>%
      html_nodes(xpath = '//*[@id="shots-grid"]/table') %>%
      html_table(fill = T)
  })
  
  shots <- reactive({
    shots_scrape()[[1]]
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
    v <- ifelse(shots()$Score %in% c('V', 'X', 'PIN'), 1, 0)
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
      `Extreme elevation spread` = y_num(),
      `Elevation std. deviation` = sd_elev(),
      `Extreme windage spread` = x_num(),
      `Windage std. deviation` = sd_wind(),
      `Percentage of shots in V-bull` = v_prcnt(),
      `Percentage of Vs in X-ring` = x_prcnt()
    )
    gather(df)
  })
  
  # DOWNLOAD ---------------------------------------------------------------------------------------

}) 