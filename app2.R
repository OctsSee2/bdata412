#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(dplyr)

library(sf)
library(leaflet)


oews_state_shapes <- st_read("./shape-files/tl_2025_us_state.shp") %>%
                        st_transform(4326) %>%
                        select(STUSPS, NAME, STATEFP)
oews_cbsa_shapes <- st_read("./shape-files/tl_2025_us_cbsa.shp") %>%
                        st_transform(4326) %>%
                        select(MEMI, NAME, CBSAFP)

print("######## STATE ########")
print(head(oews_state_shapes))
print("######## CBSA  ########")
print(head(oews_cbsa_shapes))

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
