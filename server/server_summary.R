# LOAD DATA --------------------------------------------------------------------------------------

load_data <- eventReactive(input$display, {
  loadData()
})

output$summary <- renderTable({
  load_data()
})

v_stats <- reactive({
  load_data() %>% 
    mutate(pcnt_stg = round((v_count / shot_count) * 100, 1),
           pcnt_cum = round(cummean(pcnt_stg), 1))
})

output$v_plot <- renderPlotly({
  
  input$display
  
  isolate({
    
    # Plot
    plot_ly(data = v_stats(),
            x    = ~id,
            y    = ~pcnt_stg,
            type = 'bar', 
            name = 'Stage') %>% 
    add_lines(y    = ~pcnt_cum, 
              name = 'Rolling Avg.') %>% 
    layout(title  = 'Percentage of Vs',
           xaxis  = list(title = 'Date & Stage Number'),
           yaxis  = list(title = 'Percent'),
           margin = list(b = 80, r = 80))
  
  })

})