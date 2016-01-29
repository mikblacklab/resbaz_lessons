shinyUI(bootstrapPage(
  
## Tell shiny what to plot - the "main_plot" object associated with "output" generated
## by the server.R file
  plotOutput(outputId = "main_plot")
  
))
