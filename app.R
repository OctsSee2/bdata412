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

#  col_types = "text" forces every column to be read as character,
oews_raw <- read_excel(
  DATA_PATH,
  sheet = SHEET_NAME,
  col_types = "text",
  na = c("", "NA", "*", "**", "#", "~")
)


# Convert to data.table for fast filtering/grouping downstream
oews <- as.data.table(oews_raw)

# Standardize column names to lowercase (in case source file has mixed case)
names(oews) <- tolower(names(oews))

# Make sure key numeric columns are actually numeric (BLS files sometimes
# store suppressed values as text like "*")
num_cols <- c("tot_emp", "emp_prse", "jobs_1000", "loc_quotient", "pct_total",
              "pct_rpt", "h_mean", "a_mean", "mean_prse",
              "h_pct10", "h_pct25", "h_median", "h_pct75", "h_pct90",
              "a_pct10", "a_pct25", "a_median", "a_pct75", "a_pct90")
num_cols <- intersect(num_cols, names(oews))
oews[, (num_cols) := lapply(.SD, as.numeric), .SDcols = num_cols]

# annual / hourly are TRUE/blank flag columns -- convert from text to logical
flag_cols <- intersect(c("annual", "hourly"), names(oews))
if (length(flag_cols) > 0) {
  oews[, (flag_cols) := lapply(.SD, function(x) toupper(x) == "TRUE"), .SDcols = flag_cols]
}

# Pre-compute choice lists once (fast dropdowns instead of scanning 400k rows
# every render)
state_choices    <- sort(unique(oews$area_title[oews$area_type == 2]))
industry_choices <- sort(unique(oews$naics_title))
ogroup_choices   <- sort(unique(oews$o_group))
owncode_choices  <- sort(unique(oews$own_code))

# Ownership type: map raw codes to human-readable labels
own_labels <- c(
  "1"    = "Federal Government",
  "2"    = "State Government",
  "3"    = "Local Government",
  "5"    = "Private",
  "123"  = "Federal, State, and Local Government",
  "235"  = "Private, State, and Local Government",
  "35"   = "Private and Local Government",
  "57"   = "Private, Local Govt. Gambling (NAICS 71) & Casino Hotels (NAICS 72)",
  "58"   = "Private plus State and Local Government Hospitals",
  "59"   = "Private and Postal Service",
  "1235" = "Federal, State, Local Government, and Private Sector (All Ownerships)"
)

owncode_present <- sort(unique(as.character(oews$own_code)))
# Falls back to the raw code itself if a code isn't in the lookup above.
owncode_choices <- setNames(
  owncode_present,
  ifelse(owncode_present %in% names(own_labels),
         own_labels[owncode_present],
         owncode_present)
)



# ---------------------------------------------------------------------------
# 2. UI
# ---------------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("OEWS Occupational Employment & Wage Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      selectInput(
        "state", "State / Area:",
        choices = c("All (U.S. National)" = "all", state_choices),
        selected = "all"
      ),
      
      selectizeInput(
        "industry", "Industry (NAICS):",
        choices = c("All Industries" = "all", industry_choices),
        selected = "all",
        options = list(maxOptions = 2000)
      ),
      
      selectInput(
        "ogroup", "Occupation level:",
        choices = c("All" = "all", ogroup_choices),
        selected = "detailed"
      ),
      
      selectInput(
        "owncode", "Ownership type:",
        choices = c("All" = "all", owncode_choices),
        selected = "all"
      ),
      
      radioButtons(
        "wage_type", "Wage measure:",
        choices = c("Annual mean" = "a_mean",
                    "Annual median" = "a_median",
                    "Hourly mean" = "h_mean",
                    "Hourly median" = "h_median"),
        selected = "a_mean"
      ),
      
      sliderInput("top_n", "Number of occupations to show:",
                  min = 5, max = 40, value = 15),
      
      hr(),
      helpText(paste0("Full dataset: 413,528 rows. ",
                      "Filters below narrow it before plotting for speed.")),
      textOutput("row_count")
    ),
    
    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel(
          "Top Occupations by Employment",
          plotOutput("empBarPlot", height = "600px")
        ),
        tabPanel(
          "Wage Distribution",
          plotOutput("wageHist", height = "450px"),
          sliderInput("bins", "Number of bins:", min = 5, max = 100, value = 40)
        ),
        tabPanel(
          "Employment vs. Wage",
          plotOutput("scatterPlot", height = "550px")
        ),
        tabPanel(
          "Data Table",
          DTOutput("dataTable")
        )
      )
    )
  )
)

# ---------------------------------------------------------------------------
# 3. SERVER
# ---------------------------------------------------------------------------
server <- function(input, output, session) {
  
  # Reactive: filtered subset based on sidebar inputs.
  filtered_data <- reactive({
    d <- oews
    
    if (input$state != "all") {
      d <- d[d$area_title == input$state, ]
    } else {
      # default to national totals if no state chosen, to avoid double counting
      d <- d[d$area_type == 1, ]
    }
    
    if (input$industry != "all") {
      d <- d[d$naics_title == input$industry, ]
    }
    
    if (input$ogroup != "all") {
      d <- d[d$o_group == input$ogroup, ]
    }
    
    if (input$owncode != "all") {
      d <- d[d$own_code == input$owncode, ]
    }
    
    d
  })
  
  output$row_count <- renderText({
    paste0("Rows after filtering: ", format(nrow(filtered_data()), big.mark = ","))
  })
  
  # --- Plot 1: Top N occupations by total employment -----------------------
  output$empBarPlot <- renderPlot({
    d <- filtered_data()
    validate(need(nrow(d) > 0, "No data for this combination of filters."))
    
    top_occ <- d %>%
      filter(!is.na(tot_emp)) %>%
      arrange(desc(tot_emp)) %>%
      distinct(occ_title, .keep_all = TRUE) %>%
      slice_head(n = input$top_n)
    
    validate(need(nrow(top_occ) > 0, "No employment data available for this selection."))
    
    ggplot(top_occ, aes(x = reorder(occ_title, tot_emp), y = tot_emp)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      scale_y_continuous(labels = comma) +
      labs(
        title = paste("Top", input$top_n, "Occupations by Total Employment"),
        x = NULL,
        y = "Total Employment"
      ) +
      theme_minimal(base_size = 13)
  })
  
  # --- Plot 2: Wage distribution histogram ----------------------------------
  output$wageHist <- renderPlot({
    d <- filtered_data()
    wage_col <- input$wage_type
    x <- d[[wage_col]]
    x <- x[!is.na(x)]
    
    validate(need(length(x) > 0, "No wage data available for this selection."))
    
    ggplot(data.frame(wage = x), aes(x = wage)) +
      geom_histogram(bins = input$bins, fill = "darkorange", color = "white") +
      scale_x_continuous(labels = comma) +
      labs(
        title = paste("Distribution of", names(which(
          c("a_mean" = "Annual Mean", "a_median" = "Annual Median",
            "h_mean" = "Hourly Mean", "h_median" = "Hourly Median") == wage_col
        ))),
        x = "Wage",
        y = "Count of Occupations"
      ) +
      theme_minimal(base_size = 13)
  })
  
  # --- Plot 3: Employment vs wage scatter -----------------------------------
  output$scatterPlot <- renderPlot({
    d <- filtered_data()
    wage_col <- input$wage_type
    
    d2 <- d %>%
      filter(!is.na(tot_emp), !is.na(.data[[wage_col]]))
    
    validate(need(nrow(d2) > 0, "No data available for this selection."))
    
    ggplot(d2, aes(x = .data[[wage_col]], y = tot_emp)) +
      geom_point(alpha = 0.5, color = "purple") +
      scale_x_continuous(labels = comma) +
      scale_y_log10(labels = comma) +
      labs(
        title = "Employment vs. Wage (log scale on employment)",
        x = paste(wage_col, "wage"),
        y = "Total Employment (log scale)"
      ) +
      theme_minimal(base_size = 13)
  })
  
  # --- Data table ------------------------------------------------------------
  output$dataTable <- renderDT({
    d <- filtered_data() %>%
      mutate(own_label = ifelse(as.character(own_code) %in% names(own_labels),
                                own_labels[as.character(own_code)],
                                as.character(own_code)))
    
    datatable(
      d %>% select(area_title, naics_title, occ_title, o_group,
                   ownership = own_label,
                   tot_emp, h_mean, a_mean, a_median),
      options = list(pageLength = 15, scrollX = TRUE)
    )
  })
}
# ---------------------------------------------------------------------------
# 4. RUN
# ---------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
