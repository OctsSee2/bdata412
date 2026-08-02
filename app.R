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

