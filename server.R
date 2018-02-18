shinyServer(function(input, output, session) {
  
  # READ DATA --------------------------------------------------------------------------------------
  
  icfra_yds_inch <- read_csv('./data/icfra_yds_inch.csv') # TODO: build df in code with data_frame
  
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
  
  # DATA MUNGING -----------------------------------------------------------------------------------
  
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
  
  # Remove sighters for centre calcs
  shots_excl <- reactive({
    filter(shots(), !shots()$`#` %in% c('A', 'B'))
  })
  
  # Munge hh:mm:ss for time calcs
  shots_time <- reactive({
    df             <- shots()
    df$`Shot time` <- paste0("00:", df$`Shot time`)
    df$`Shot lag`  <- lag(df$`Shot time`, default = "00:00:00")
    df$`Shot time` <- hms(df$`Shot time`)
    df$`Shot lag`  <- hms(df$`Shot lag`)
    df$`Shot diff` <- df$`Shot time` - df$`Shot lag`
    df$`Shot secs` <- period_to_seconds(df$`Shot diff`)
    
    # Print dataframe
    df
  })
  
  # Scrape stage details
  deets_scrape <- reactive({
    url() %>%
      read_html() %>%
      html_nodes(xpath = '/html/body/div/div/header/h1/text()')
  })
    
  # Extract object from list
  deets <- reactive({
    as.character(deets_scrape()[1])
  })
  
  # Filter icfra target dimensions based on distance input
  icfra_yds_inch_fltr <- reactive({
    filter(icfra_yds_inch, icfra_yds_inch$Distance == input$yards)
  })
  
  # STATS ------------------------------------------------------------------------------------------
  
  # Extreme spread of windage 
  ext_wind <- reactive({
    min <- min(shots_excl()$`X (inch)`)
    max <- max(shots_excl()$`X (inch)`)
    ext <- abs(min) + max #TODO: test formula re: all shots on one side of target
    round(ext, 1)
  })
  
  # Extreme spread of elevation
  ext_elev <- reactive({
    min <- min(shots_excl()$`Y (inch)`)
    max <- max(shots_excl()$`Y (inch)`)
    ext <- abs(min) + max #TODO: test formula re: all shots above/below waterline
    round(ext, 1)
  })

  # Std dev of windage
  sd_wind <- reactive({
    round(sd(shots_excl()$`X (inch)`), 1)
  })

  # Std dev of elevation
  sd_elev <- reactive({
    round(sd(shots_excl()$`Y (inch)`), 1)
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
  
  # Extreme windage / std deviation windage (inches)
  ext_sd_wind <- reactive({
    round(ext_wind() / sd_wind(), 1)
  })
  
  # Extreme elevation / std deviation elevation (inches)
  ext_sd_elev <- reactive({
    round(ext_elev() / sd_elev(), 1)
  })

  # Extreme windage / std deviation windage (MOA)
  moa_ext_sd_wind <- reactive({
    round(moa_ext_wind() / moa_sd_wind(), 1)
  })
  
  # Extreme elevation / std deviation elevation (MOA)
  moa_ext_sd_elev <- reactive({
    round(moa_ext_elev() / moa_sd_elev(), 1)
  })
  
  # Shots in stage
  shots_tot <- reactive({
    nrow(shots_excl())
  })
  
  # V count 
  v_cnt <- reactive({
    v <- ifelse(shots_excl()$Score %in% c('V', 'X', 'PIN'), 1, 0) 
    sum(v)
  })
  
  # V percentage
  v_prcnt <- reactive({
    round(v_cnt() / shots_tot() * 100, 1)
  })
  
  # X count
  x_cnt <- reactive({
    x <- ifelse(shots_excl()$Score %in% c('X', 'PIN'), 1, 0)
    sum(x)
  })

  # X percetage of Vs
  x_prcnt <- reactive({
    round(x_cnt() / v_cnt() * 100, 1)
  })
  
  # Minimum shot duration
  shot_min <- reactive({
    min(shots_time()$`Shot secs`[2:nrow(shots_time())])
  })
  
  # Maximum shot duration
  shot_max <- reactive({
    max(shots_time()$`Shot secs`[2:nrow(shots_time())])
  })
  
  # Average shot duration
  shot_avg <- reactive({
    round(period_to_seconds(shots_time()$`Shot time`[nrow(shots_time())]) / nrow(shots_time()), 0)
  })
  
  # Elevation distribution
  elev <- reactive({
    abs(shots_excl()$`Y (inch)`)
  })
  
  elev_dist <- reactive({
    out <- vector("list", length(elev()))
    for (i in seq_along(elev())){
      if (elev()[[i]] <= icfra_yds_inch_fltr()$sX / 2){
        out[[i]] <- 'Within Super V (X)'
      } else if (elev()[[i]] <= icfra_yds_inch_fltr()$cV / 2){
        out[[i]] <-'Within Centre (V)'
      } else if (elev()[[i]] <= icfra_yds_inch_fltr()$b5 / 2){
        out[[i]] <- 'Within Bullseye (5)'
      } else if (elev()[[i]] <= icfra_yds_inch_fltr()$i4 / 2){
        out[[i]] <- 'Within Inner (4)'
      } else if (elev()[[i]] <= icfra_yds_inch_fltr()$m3 / 2){
        out[[i]] <- 'Within Magpie (3)'
      } else if (elev()[[i]] <= icfra_yds_inch_fltr()$o2 / 2){
        out[[i]] <- 'Within Outer (2)'
      } else {
        out[[i]] <- 'Within rest of target (1)'
      }
    }
    out
  })
  
  # OUTPUT -----------------------------------------------------------------------------------------
  
  output$txt <- renderText({
    deets()
  })
  
  output$tbl <- renderTable({
    
    # Stats expressed in inches
    df_inch <- data_frame(
      `Extreme elevation spread`           = ext_elev(),
      `Elevation std. deviation`           = sd_elev(),
      `Extreme elevation / std. deviation` = ext_sd_elev(),
      `Extreme windage spread`             = ext_wind(),
      `Windage std. deviation`             = sd_wind(),
      `Extreme wind / std. deviation`      = ext_sd_wind()
    )
    
    # Stats expressed in MOA
    df_moa <- data_frame(
      `Extreme elevation spread`           = moa_ext_elev(),
      `Elevation std. deviation`           = moa_sd_elev(),
      `Extreme elevation / std. deviation` = moa_ext_sd_elev(),
      `Extreme windage spread`             = moa_ext_wind(),
      `Windage std. deviation`             = moa_sd_wind(),
      `Extreme wind / std. deviation`      = moa_ext_sd_wind()
    )
    
    # Gather both tables to long format
    df_inch <- gather(df_inch)
    df_moa  <- gather(df_moa)
    
    # Join tables
    df_join <- left_join(df_inch, df_moa, by = "key")
    
    # Change column names
    colnames(df_join) <- c("Group statistics", "Inches", "MOA")
    
    # Print dataframe
    df_join
  })
  
  output$tbl_misc <- renderTable({
    df <- data_frame(
      `Proportion of Vs`      = paste0(v_prcnt(), "%"),
      `Proportion of Vs in X` = paste0(x_prcnt(), "%"), 
      `Avg. shot duration`    = paste(shot_avg(), " secs"),
      `Min. shot duration`    = paste0(shot_min(), " secs"),
      `Max. shot duration`    = paste0(shot_max(), " secs")
    )
    df <- gather(df)
    colnames(df) <- c("Misc. statistics", "Value")
    df
  })
  
  x_order <- reactive({
    
    c('Within Super V (X)', 'Within Centre (V)', 'Within Bullseye (5)', 'Within Inner (4)',
      'Within Magpie (3)', 'Within Outer (2)', 'Within rest of target (1)')
    
  })
  
  # Data for elevation plot
  df_grp <- reactive({
  
    df <- data_frame(Category = as.character(elev_dist()))
    
    df %>%
      group_by(Category) %>%
      summarise(Count = n()) %>% 
      ungroup() %>% 
      mutate(Percent = round((Count / sum(Count)) * 100, 1)) %>% 
      slice(match(x_order(), Category)) %>% 
      mutate(Cum_Percent = cumsum(Percent)) ->
    df_grp 
    
   })
  
  output$elev_plot <- renderPlotly({
    
    input$analyse
    
    isolate({
      
      # Plot
      plot_ly(data = df_grp(),
              x    = ~Category,
              y    = ~Cum_Percent,
              type = 'bar') %>% 
      layout(title  = 'Elevation Distribution by Ring',
             xaxis  = list(title = "", categoryorder = "array", categoryarray = x_order()),
             yaxis  = list(title = "Percent"),
             margin = list(b = 80, r = 80))
      
    })
      
  })
  
  # LOCAL FILE SAVE --------------------------------------------------------------------------------
  
  # Whenever a field is filled, aggregate all ui inputs
  summary_data <- reactive({
    
    # UI input data
    data <- data_frame(
      sid      = input$sid,
      data     = input$date,
      scenario = input$scenario,
      range    = input$range,
      distance = input$distance,
      yards    = input$yards,
      metres   = input$metres
    )
    
    data2 <- data_frame(
      v_count    = v_cnt(),
      x_count    = x_cnt(),
      shot_count = shots_tot()
    )
    
    # df_grp() %>% 
    #   select(Category, Count) %>%
    #   spread(key = Category, value = Count) ->
    # data3
    
    # Bind data
    bind_cols(data, data2)
    
  })
  
  # When the Save button is clicked, save the form data
  observeEvent(input$save, {
    saveData(summary_data())
  })

  # LOAD DATA --------------------------------------------------------------------------------------
  
  load_data <- eventReactive(input$display, {
    loadData()
  })
  
  output$summary <- renderTable({
    load_data()
  })
  
}) 