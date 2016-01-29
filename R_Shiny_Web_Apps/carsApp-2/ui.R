shinyUI(pageWithSidebar(
  
## Give the application a title
  headerPanel("My awesome plotting app"),
  
## Put the input controls in a sidebar 
  sidebarPanel(
    
  selectInput(inputId = "plot_var",
              label = "Variable to plot",
              choices = c("speed", "dist"),
              selected = "speed")
  ),

## Put the outout in the main panel
  mainPanel(

    ## Give the panel a name
    h4("Plot of cars data"),
    
    ## Tell shiny what to plot - the "main_plot" object associated with "output" generated
    ## by the server.R file
    plotOutput(outputId = "main_plot")
  )
))
