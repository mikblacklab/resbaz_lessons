## Load the "cars" data set
data(cars)
attach(cars)

## Create the function to be excuted by shiny 
shinyServer(function(input, output) {
  
## Define an object called "main_plot" that will be drawn by the "renderPlot" function
  output$main_plot <- renderPlot({

## Specify the plot that will be generated
      hist(speed)
  })
  
})
