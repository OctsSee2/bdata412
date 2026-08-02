#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


library(shiny)
library(data.table)   # fast read/filter for large data
library(dplyr)
library(ggplot2)
library(scales)
library(DT)

library(readxl)       # read .xlsx
library(data.table)   # fast filtering/grouping for large data

# ---------------------------------------------------------------------------
# 1. LOAD DATA
# ---------------------------------------------------------------------------

DATA_PATH  <- "data/oews_data.xlsx"
SHEET_NAME <- NULL  

# read_excel is fine for ~400k rows but is single-threaded and can take
# 30-60+ seconds depending on machine. na = c(...) covers BLS's suppression
# codes so they come in as real NA rather than text.
oews_raw <- read_excel(
  DATA_PATH,
  sheet = SHEET_NAME,
  na = c("", "NA", "*", "**", "#")
)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white',
             xlab = 'Waiting time to next eruption (in mins)',
             main = 'Histogram of waiting times')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
