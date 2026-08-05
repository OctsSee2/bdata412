library(shiny)
library(dplyr)

library(sf)
library(leaflet)
library(viridis)

employment_data <- read.csv("./all_data_M_2025.csv") %>%
                    # ensure that FIPS and CBSA codes are strings, not integers
                    mutate(AREA = trimws(as.character(AREA)))

oews_state_shapes <- st_read("./shape-files/tl_2025_us_state.shp") %>%
                        st_transform(4326) %>%
                        select(STUSPS, NAME, STATEFP)
oews_cbsa_shapes <- st_read("./shape-files/tl_2025_us_cbsa.shp") %>%
                        st_transform(4326) %>%
                        select(MEMI, NAME, CBSAFP)

#state_joined_employment_data <- oews_state_shapes %>%
#                                  left_join(employment_data,
#                                            by = c("STATEFP" = "AREA"))
#cbsa_joined_employment_data <- oews_cbsa_shapes %>%
#                                  left_join(employment_data,
#                                            by = c("CBSAFP" = "AREA"))

get_numeric_filtered_df <- function(df_in, column_str_in) {
  df_in[[column_str_in]] <- as.numeric(gsub(",", "", df_in[[column_str_in]]))
  return(df_in[!is.na(df_in[[column_str_in]]), ])
}

get_named_vec_occupation_names <- function () {
  unique_occupations <- unique(employment_data[, c("OCC_TITLE", "OCC_CODE")])
  return(setNames(unique_occupations$OCC_CODE, unique_occupations$OCC_TITLE))
}

ui <- fluidPage(
    titlePanel("Choropleth testing"),

    sidebarLayout(
        sidebarPanel(
          selectInput(
            inputId = "occupation_type_choice",
            label = "Choose an Occupation Type",
            #choice = c("N/A" = "NA", get_named_vec_occupation_names())
            choice = get_named_vec_occupation_names()
          ),
          sliderInput("bins",
                      "Number of bins:",
                      min = 1,
                      max = 50,
                      value = 30)
        ),
        mainPanel(
          leafletOutput(outputId = "the_map", 
                        width = "100%", height = "750px")
        )
    )
)

server <- function(input, output) {
  target_column_str <- "A_MEAN"

  get_cleaned_numeric_df <- reactive({
    filtered_employment_data <- employment_data %>%
                                  filter(OCC_CODE == input$occupation_type_choice)
    state_joined_employment_data <- oews_state_shapes %>%
                                      left_join(filtered_employment_data,
                                                by = c("STATEFP" = "AREA"))
    return(get_numeric_filtered_df(state_joined_employment_data, target_column_str))
  })
  
  output$the_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      # center view on US
      setView(lng = -98.5795, lat = 39.8283, zoom = 4)
  })
  
  observe({
    cleaned_numeric_df <- get_cleaned_numeric_df()
    print("######## WHAT ############")
    print(summary(cleaned_numeric_df))
    print("######## WHAT ############")
    
    color_palette <- colorNumeric(
      palette = "viridis",
      domain = cleaned_numeric_df[[target_column_str]],
      na.color = "#ff0000"
    )
    
    leafletProxy(mapId = "the_map",
                 data = cleaned_numeric_df) %>%
      clearShapes() %>%
      clearControls() %>%
      addPolygons(
        fillColor = ~color_palette(get(target_column_str)),
        weight = 0.5,
        opacity = 1.0,
        color = "#ffffff",
        fillOpacity = 0.7,
        highlightOptions = highlightOptions(
          weight = 2.0,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        pal = color_palette,
        values = cleaned_numeric_df[[target_column_str]],
        opacity = 0.7,
        title = "Somethingsomethingsomething",
        position = "bottomright"
      )
  })
}

shinyApp(ui = ui, server = server)
