library(shiny)
library(dplyr)

library(sf)
library(leaflet)
library(viridis)

employment_data <- read.csv("./all_data_M_2025.csv", colClasses = c("AREA" = "character"))

state_employment_data <- employment_data %>%
                          filter(AREA_TYPE == 2)
cbsa_employment_data <- employment_data %>%
                          filter(AREA_TYPE == 4 | AREA_TYPE == 5)


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
            choices = get_named_vec_occupation_names()
          ),
          selectInput(
            inputId = "agg_type_choice",
            label = "Choose an aggregation type",
            choices = c("Mean", "Median", "Max", "Min", "Test")
          )
        ),
        mainPanel(
          leafletOutput(outputId = "the_map", 
                        width = "100%", height = "750px")
        )
    )
)

server <- function(input, output) {
  target_column_str <- "A_MEAN"

  get_cleaned_agged_df <- reactive({
    filtered_employment_data <- state_employment_data %>%
                                  filter(OCC_CODE == input$occupation_type_choice) %>%
                                  mutate(!!target_column_str := as.numeric(gsub(",", "", .data[[target_column_str]]))) %>%
                                  group_by(AREA) %>%
                                  summarize(
                                    !!target_column_str := switch(
                                      input$agg_type_choice,
                                      "Mean" = mean(.data[[target_column_str]], na.rm = TRUE),
                                      "Median" = median(.data[[target_column_str]], na.rm = TRUE),
                                      "Max" = max(.data[[target_column_str]], na.rm = TRUE),
                                      "Min" = min(.data[[target_column_str]], na.rm = TRUE),
                                      "Test" = 1.0
                                    ),
                                    .groups = "drop"
                                  )

    state_joined_employment_data <- oews_state_shapes %>%
                                      left_join(filtered_employment_data,
                                                by = c("STATEFP" = "AREA"))
    return(state_joined_employment_data)
  })
  
  output$the_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      # center view on US
      setView(lng = -98.5795, lat = 39.8283, zoom = 4)
  })
  
  observe({
    cleaned_agged_df <- get_cleaned_agged_df()

    #vals <- cleaned_agged_df[[target_column_str]]
    color_palette <- colorNumeric(
      palette = "viridis",
      domain = #if (all(is.na(vals))) c(0, 1) else vals,
              cleaned_agged_df[[target_column_str]],
      na.color = "#ff0000"
    )
    
    leafletProxy(mapId = "the_map",
                 data = cleaned_agged_df) %>%
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
        ),
        label = ~paste0(NAME, ": ", round(get(target_column_str), 2)),
        labelOptions = labelOptions(
          style = list("font-weight" = "normal",
                       "padding" = "3px 8px"),
          textSize = "13px",
          direction = "auto"
        )
      ) %>%
      addLegend(
        pal = color_palette,
        values = cleaned_agged_df[[target_column_str]],
        opacity = 0.7,
        title = "Somethingsomethingsomething",
        position = "bottomright"
      )
  })
}

shinyApp(ui = ui, server = server)
