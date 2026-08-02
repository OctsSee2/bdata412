library(shiny)
library(ggplot2)
library(dplyr)

# some stuff to load the data from 2024-2025 (testing)
employment_data <- read.csv("./all_data_M_2025.csv")

get_named_vec_area_names <- function() {
  unique_areas <- unique(employment_data[, c("AREA_TITLE", "AREA")])
  return(setNames(unique_areas$AREA, unique_areas$AREA_TITLE))
}

ui <- fluidPage(
  titlePanel("Testing testing"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "column_choice",
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
      selectInput(
        inputId = "area_choice",
        label = "Choose an Area",
        choices = c("N/A" = "NA", get_named_vec_area_names())
      ),
      selectInput(
        inputId = "area_type_choice",
        label = "Choose an Area Type",
        choices = c(
          "N/A" = "NA",
          "Entire US" = 1,
          "States" = 2,
          "US Territories" = 3,
          "Metro areas" = 4,
          "Non-metro areas" = 5
        )
      ),
      selectInput(
        inputId = "primary_state_choice",
        label = "Choose a Primary State",
        choices = c(
          "N/A" = "NA",
          "Entire US" = "US",
          "Alabama" = "AL",
          "Alaska" = "AK",
          "Arizona" = "AZ",
          "Arkansas" = "AR",
          "California" = "CA",
          "Colorado" = "CO",
          "Connecticut" = "CT",
          "Delaware" = "DE",
          "D.C." = "DC",
          "Florida" = "FL",
          "Georgia" = "GA",
            "Guam" = "GU",
          "Hawaii" = "HI",
          "Idaho" = "ID",
          "Illinois" = "IL",
          "Iowa" = "IA",
          "Kansas" = "KA",
          "Kentucky" = "KY",
          "Louisiana" = "LA",
          "Maine" = "ME",
          "Maryland" = "MD",
          "Massachusetts" = "MA",
          "Michigan" = "MI",
          "Minnesota" = "MN",
          "Mississippi" = "MS",
          "Missouri" = "MO",
          "Montana" = "MT",
          "Nebraska" = "NE",
          "Nevada" = "NV",
          "New Hampshire" = "NH",
          "New Jersey" = "NJ",
          "New Mexico" = "NM",
          "New York" = "NY",
          "North Carolina" = "NC",
          "North Dakota" = "ND",
          "Ohio" = "OH",
          "Oklahoma" = "OK",
          "Oregon" = "OR",
          "Pennsylvania" = "PA",
          "Puerto Rico" = "PR",
          "Rhode Island" = "RI",
          "South Carolina" = "SC",
          "Tennessee" = "TN",
          "Texas" = "TX",
          "Utah" = "UT",
          "Vermont" = "VT",
          "Virginia" = "VA",
          "Virgin Islands" = "VI",
          "Washington" = "WA",
          "West Virginia" = "WV",
          "Wisconsin" = "WI",
          "Wyoming" = "WY"
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
      fluidRow(
        column(
          12,
          plotOutput(outputId = "the_histogram_thing")
        )
      ),
      fluidRow(
        column(
          6,
          tableOutput(outputId = "the_debug_table")
        ),
        column(
          6,
          verbatimTextOutput("the_stat_summary")
        )
      )
    )
  )
)

apply_multi_filter_data <- function (df_in, conds_in) {
  for (col_in in names(conds_in)) {
    val_in <- conds_in[[col_in]]
    if (val_in != "NA") {
      df_in <- df_in %>% filter(.data[[col_in]] == val_in)
    }
  }
  return(df_in)
}


clean_column_data <- function(df_in, column_str_in) {
  selected_data <- df_in[[column_str_in]]
  comma_removed_data <- gsub(",", "", selected_data)
  numeric_data <- as.numeric(comma_removed_data)
  
  return(numeric_data[!is.na(numeric_data)])
}

server <- function(input, output) {
  get_cleaned_numeric_data <- reactive({
    filtered_data <- apply_multi_filter_data(
      employment_data,
      list(
        AREA = input$area_choice,
        AREA_TYPE = input$area_type_choice,
        PRIM_STATE = input$primary_state_choice
      ))
    return(clean_column_data(filtered_data, input$column_choice))
  })
  
  output$the_histogram_thing <- renderPlot({
    target_column_str <- input$column_choice
    cleaned_numeric_data <- get_cleaned_numeric_data()
    
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
    target_column_str <- input$column_choice
    selected_data <- employment_data[[target_column_str]]
    
    data.frame(
      Row_Index = 1:head_n,
      Raw_Value = head(selected_data, n = head_n)
    )
  })
  
  output$the_stat_summary <- renderPrint({
    target_column_str <- input$column_choice
    cleaned_numeric_data <- get_cleaned_numeric_data()

    print_width <- 15
    data_count <- length(cleaned_numeric_data)
    data_mean <- mean(cleaned_numeric_data)
    data_median <- median(cleaned_numeric_data)
    data_max <- max(cleaned_numeric_data)
    data_min <- min(cleaned_numeric_data)
    data_q25 <- quantile(cleaned_numeric_data, 0.25)
    data_q75 <- quantile(cleaned_numeric_data, 0.75)
    
    int_format_str <- sprintf("%%-%ds %%d\n", print_width)
    dbl_format_str <- sprintf("%%-%ds %%.2f\n", print_width)
    
    cat(sprintf(int_format_str, "Count:", data_count))
    cat(sprintf(dbl_format_str, "Min:", data_min))
    cat(sprintf(dbl_format_str, "Q1. (25%):", data_q25))
    cat(sprintf(dbl_format_str, "Median:", data_median))
    cat(sprintf(dbl_format_str, "Mean:", data_mean))
    cat(sprintf(dbl_format_str, "Q3. (75%):", data_q75))
    cat(sprintf(dbl_format_str, "Max:", data_max))
  })
}

shinyApp(ui = ui, server = server)
