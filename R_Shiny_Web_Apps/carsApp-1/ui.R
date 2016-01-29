shinyUI(bootstrapPage(
  
  selectInput(inputId = "plot_var",
              label = "Variable to plot",
              choices = c("speed", "dist"),
              selected = "speed"),
    
## Tell shiny what to plot - the "main_plot" object associated with "output" generated
## by the server.R file
  plotOutput(outputId = "main_plot")
  
))

