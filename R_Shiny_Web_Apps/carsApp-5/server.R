## Load the "cars" data set
data(cars)

## Create the function to be excuted by shiny 
shinyServer(function(input, output) {
  
## Define an object called "main_plot" that will be drawn by the "renderPlot" function
  output$main_plot <- renderPlot({

## Specify the plot that will be generated
      hist(cars[,input$plot_var], breaks = input$nbins)
  })

## Define a second plot
  output$second_plot <- renderPlot({

## Specify the plot that will be generated
      boxplot(cars[,input$plot_var])
  })
  
})
