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
          "Job total employment count" = "TOT_EMP",
          "Job employment PRSE" = "EMP_PRSE",
          "Jobs out of 1000" = "JOBS_1000",
          "Job common-ness value" = "LOC_QUOTIENT",
          "Job employment percentage from industry total" = "PCT_TOTAL",
          "Job business location percentage from industry" = "PCT_RPT",
          "Mean hourly wage" = "H_MEAN",
          "Mean annual wage" = "A_MEAN",
          "Mean wage PRSE" = "MEAN_PRSE",
          "Hourly wage 10th percentile" = "H_PCT10",
          "Hourly wage 25th percentile" = "H_PCT25",
          "Hourly wage median" = "H_MEDIAN",
          "Hourly wage 75th percentile" = "H_PCT75",
          "Hourly wage 90th percentile" = "H_PCT90",
          "Annual wage 10th percentile" = "A_PCT10",
          "Annual wage 25th percentile" = "A_PCT25",
          "Annual wage median" = "A_MEDIAN",
          "Annual wage 75th percentile" = "A_PCT75",
          "Annual wage 90th percentile" = "A_PCT90"
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
      plotOutput(outputId = "the_histogram_thing"),
      tableOutput(outputId = "the_debug_table")
    )
  )
)

server <- function(input, output) {
  output$the_histogram_thing <- renderPlot({
    target_column_str <- input$choice_var
    selected_data <- employment_data[[target_column_str]]
    comma_removed_data <- gsub(",", "", selected_data)
    numeric_data <- as.numeric(comma_removed_data)
    cleaned_numeric_data <- numeric_data[!is.na(numeric_data)]
    
    validate(
      need(length(cleaned_numeric_data) > 0,
           "There is no (valid) numeric data for this column !")
    )
    
    new_employment_data_df <- data.frame(the_value = cleaned_numeric_data)
    
    ggplot(new_employment_data_df, aes(x = the_value)) +
      geom_histogram(bins = input$bins,
                     fill = "red", color = "black") +
      labs(
        title = paste("A graph for `", target_column_str, "`"),
        x = target_column_str,
        y = "Count"
      ) +
      theme_minimal()
  })
  
  output$the_debug_table <- renderTable({
    head_n <- 10
    target_column_str <- input$choice_var
    selected_data <- employment_data[[target_column_str]]
    
    data.frame(
      Row_Index = 1:head_n,
      Raw_Value = head(selected_data, n = head_n)
    )
  })
}

shinyApp(ui = ui, server = server)
