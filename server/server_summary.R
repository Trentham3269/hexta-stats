# LOAD DATA --------------------------------------------------------------------------------------

load_data <- eventReactive(input$display, {
  loadData()
})

output$summary <- renderTable({
  load_data()
})