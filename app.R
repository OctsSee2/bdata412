library(shiny)

# some stuff to load the data from 2024-2025 (testing)
employment_data <- read.csv("./all_data_M_2025.csv")

ui <- fluidPage(
  titlePanel("Testing testing"),
  tableOutput("head_of_table")
)

server <- function(input, output) {
  output$head_of_table <- renderTable({
    head(employment_data, n=10)
  })
}

#ui <- fluidPage(
#    titlePanel("Testing employment data from 2024-2025"),
#
#    # Sidebar with a slider input for number of bins 
#    sidebarLayout(
#        sidebarPanel(
#            sliderInput("bins",
#                        "Number of bins:",
#                        min = 1,
#                        max = 50,
#                        value = 30)
#        ),

#        mainPanel(
#           plotOutput("distPlot")
#        )
#    )
#)

#server <- function(input, output) {
#    output$distPlot <- renderPlot({
#        # generate bins based on input$bins from ui.R
#        x    <- employment_data[, 2]
#        bins <- seq(min(x), max(x), length.out = input$bins + 1)

#        # draw the histogram with the specified number of bins
#        hist(x, breaks = bins, col = 'darkgray', border = 'white',
#             xlab = 'Something ????',
#             main = 'Histogram of something ????')
#    })
#}

shinyApp(ui = ui, server = server)
