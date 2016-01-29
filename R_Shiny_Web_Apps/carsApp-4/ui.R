shinyUI(pageWithSidebar(
  
## Give the application a title
  headerPanel("My awesome plotting app"),
  
## Put the input controls in a sidebar 
  sidebarPanel(
    
  selectInput(inputId = "plot_var",
              label = "Variable to plot",
              choices = c("speed", "dist"),
              selected = "speed"),

  sliderInput(inputId = "nbins",
              label = "Number of bins",
              min=2,
              max=15,
              value=10,
              round=TRUE)
  ),

## Put the outout in the main panel
  mainPanel(

## Add tabs
    tabsetPanel(

      tabPanel(
        ## Give the panel a name
        h4("Plot of cars data"),
        ## Tell shiny what to plot - the "main_plot" object associated with "output" generated
        ## by the server.R file
        plotOutput(outputId = "main_plot")
      ),

      tabPanel(
        h4("Boxplot of cars data"),
        plotOutput(outputId = "second_plot")
      )
    )
  )
))
