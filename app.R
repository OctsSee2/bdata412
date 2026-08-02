library(shiny)
library(ggplot2)

# some stuff to load the data from 2024-2025 (testing)
employment_data <- read.csv("./all_data_M_2025.csv")

ui <- fluidPage(
  titlePanel("Testing testing"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "choice_var",
        label = "Choose a column",
        choices = c(
          "Area" = "AREA",
          "Area title" = "AREA_TITLE",
          "Area type" = "AREA_TYPE",
          "Primary state" = "PRIM_STATE",
          "NAICS code" = "NAICS",
          "NAICS title" = "NAICS_TITLE",
          "something" = "I_GROUP",
          "something else" = "OWN_CODE",
          "another thing" = "OCC_CODE",
          "what" = "O_GROUP",
          "Total employment" = "TOT_EMP",
          "????" = "EMP_PRSE",
          "numbers" = "JOBS_1000",
          "words" = "LOC_QUOTIENT",
          "idk" = "PCT_TOTAL",
          "idk either" = "PCT_RPT",
          "so mean" = "H_MEAN",
          "also mean" = "A_MEAN",
          "still mean" = "MEAN_PRSE",
          "numbers & words" = "H_PCT10",
          "numbers & bigger words" = "H_PCT25",
          "the middle" = "H_MEDIAN",
          "numbers & even bigger words" = "H_PCT75",
          "number & biggest word" = "H_PCT90",
          "something another" = "A_PCT10",
          "something another (bigger)" = "A_PCT25",
          "something in the middle" = "A_MEDIAN",
          "something another (even bigger)" = "A_PCT75",
          "something another (biggest)" = "A_PCT90",
          "annual ?" = "ANNUAL",
          "hourly ?" = "HOURLY"
        )
      ),
      sliderInput(
        inputId = "bins",
        label = "Number of bins:",
        min = 1,
        max = 50,
        value = 30
      )
    ),
    mainPanel(
      plotOutput(outputId = "the_histogram_thing")
    )
  )
)

server <- function(input, output) {
  output$the_histogram_thing <- renderPlot({
    selected_data <- employment_data[[input$choice_var]]
    
    ggplot(employment_data, aes_string(x = input$choice_var)) +
      geom_histogram(bins = input$bins,
                     fill = "red", color = "black") +
      labs(title = paste("A graph for `", input$choice_var, "`")) +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)
