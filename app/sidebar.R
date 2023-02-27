# Sidebar -----------------------------------------------------------------
sidebar <- dashboardSidebar(
  # CSS to set colors
  tags$head(
    tags$style(HTML("
                    .not-full .item {
                    background: #3C8DBC !important;
                    color: white !important;
                    }
                    .selectize-dropdown-content .active {
                    background: #3C8DBC !important;
                    color: white !important;
                    }
                    .dropdown-shinyWidgets {
                    background: #e5e5e5;
                    }
                    #apply {
                    background: #3C8DBC !important;
                    color: white !important;
                    }
                    "))
    ),
  div(
    id = "inputs",
    sliderInput(
      round = TRUE,
      step = 1,
      inputId = "year_range",
      label = "Year of issue (range)",
      min = year_min,
      max = year_max,
      value = c(year_min, year_max),
      sep = "",
      width = '100%'
    ),
    radioButtons(
      inputId = "aggregate_by",
      label = "Geography",
      choices = c("Country", "City"),
      selected = "Country",
      inline = TRUE
    ),
    conditionalPanel(
      condition = "input.aggregate_by == 'City'",
      selectInput(
        inputId = "selected_country",
        label = "Country",
        choices = countries,
        selected = "Switzerland",
        width = '100%')
    ),
    selectInput(
      inputId="technology_by",
      label="Technology field",
      choices=tech_hierarchy,
      selected = "All",
      width = '100%'
    ),
    radioButtons(
      inputId = "variable_by",
      label = "Variable in map",
      choices = list(Patents="count", "Collaborative patents"="collaborations"),
      selected = "count",
      inline = TRUE
    ),
    uiOutput("min_count_slider")
  ),
  width = 300
)
