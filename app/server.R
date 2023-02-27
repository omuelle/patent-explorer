# Server ------------------------------------------------------------------
server <- function(input, output, session) {

  nodes <- reactive({
    
    tech <- input$technology_by
    aggr <- tolower(input$aggregate_by)
    if(aggr == "country") {
      nodes <- data_country
    } else {
      nodes <- data_city %>% filter(country == input$selected_country)
    }
    
    nodes <- nodes %>% filter(priority_year >= input$year_range[1], priority_year <= input$year_range[2])
      
    if(tech %in% sectors) {
      nodes <- nodes %>% filter(techn_sector == tech)
    } else if(tech %in% fields) {
      nodes <- nodes %>% filter(techn_field == tech)
    } else {
      nodes <- nodes %>% filter(techn_field == "" & techn_sector == "")
    }
      
    nodes <- nodes %>%
      group_by_at(aggr) %>%
      summarise(count = sum(count), collaborations = sum(collaborations), lon = lon[1], lat = lat[1])
    
    validate(need(nrow(nodes) > 0, error_no_data))
    nodes
  })

  # Create map. Not reactive, to avoid redrawing
  output$map <- renderLeaflet({
    leaflet(
      data = data_country,
      options = leafletOptions(worldCopyJump = TRUE)
    ) %>%
      setView(lng = mean_lon, lat = mean_lat, zoom = default_zoom_country) %>%
      # Provider Tiles can be changed easily
      # See http://leaflet-extras.github.io/leaflet-providers/preview/index.html
      addProviderTiles(
        providers$OpenStreetMap.Mapnik,
        options = providerTileOptions(
          noWrap = FALSE,
          maxZoom = max_zoom,
          minZoom = min_zoom
        )
      )
  })

  observe({
    req(nodes())
    req(input$min_count)
    
    # Observe currently opened tab so markers are drawn when map comes into focus
    input$tabs

    nodes <- nodes() %>% filter_at(vars(input$variable_by), all_vars(. >= input$min_count))
    validate(need(nrow(nodes) > 0, error_no_data))
    
    # Compute radius
    min_radius <- if(input$aggregate_by == "Country") node_radius_min_country else node_radius_min_city
    max_radius <- if(input$aggregate_by == "Country") node_radius_max_country else node_radius_max_city
    node_values <- nodes %>% select(input$variable_by) %>% pull()
    min_value <- min(node_values)
    max_value <- max(node_values)
    radius <- (node_values - min_value) / (max_value - min_value) * (max_radius - min_radius) + min_radius
    
    if(input$aggregate_by == "Country") {
      popups <- nodes$country
    } else if(input$aggregate_by == "City") {
      popups <- nodes$city
    }
    
    # Create popups
    popups <- popups %>% paste0("<b>", ., "</b>")
    popups <- popups %>% paste0(
      "<br>",
      paste0(input$year_range[1], "-", input$year_range[2]),
      if(input$technology_by=="All") "" else paste0("<br>", input$technology_by),
      "<br><br>",
      "Patents: ", markThousands(nodes$count),
      "<br>",
      "Collaborative patents: ", markThousands(nodes$collaborations)
    )
    popups <- paste0("<p>", popups, "</p>")
    
    # By using a proxy, the map can be modified in place and isn't redrawn
    leafletProxy("map", data = nodes) %>%
      clearMarkers() %>%
      addCircleMarkers(
        ~ lon,
        ~ lat,
        # stroke = FALSE,
        fillColor = '#a8322d',
        fillOpacity = 0.3,
        radius = radius,
        popup = popups,
        stroke = T,
        weight = 24,
        color = '#a8322d',
        opacity = 0
      )
  })

  # Fly to selected Country
  observe({
    if(input$aggregate_by == "City") {
      country_geo <- data_country %>% filter(country == input$selected_country)
      leafletProxy("map") %>% flyTo(lng = country_geo$lon[1], lat = country_geo$lat[1], zoom = default_zoom_city)
    }
  })

  # Fly to Country overview
  observe({
    if(input$aggregate_by == "Country") {
      leafletProxy("map") %>% flyTo(lng = mean_lon, lat = mean_lat, zoom = default_zoom_country)
    }
  })

  output$nodes_df <- DT::renderDT({
    req(nodes())
    output_df <- nodes() %>% select(-lon, -lat) %>% rename(patents = count, "collaborative patents" = collaborations)
    names(output_df) <- map_chr(names(output_df), upFirst)
    datatable(
      output_df,
      selection = "none",
      rownames = FALSE,
      options = list(pageLength = 25)) %>% formatRound(2:3, digits = 0)
  })

  
  output$collaboration_geo <- renderUI({
    if(input$aggregate_by == "City") {
      choices <- data_coll_city %>% filter(country == input$selected_country) %>% pull(city) %>% unique()
      selectizeInput('geo_collab', 'City', choices = choices, multiple = F, selected = "Zürich", options= list(maxOptions = choices %>% length()))
    } else {
      choices <- data_coll_country$country %>% unique()
      selectizeInput('geo_collab', 'Country', choices = choices, multiple = F, selected = "Switzerland", options= list(maxOptions = choices %>% length()))
    }
  })
  
  output$min_count_slider <- renderUI({
    sliderInput(
      inputId = "min_count",
      label = paste("Minimum patent count displayed in map"),
      min = 1,
      step = 10,
      round = 1,
      max = 500,
      value = if(is.null(input$min_count)) 1 else input$min_count,
      width = '100%')
  })


  collab_plot_df <- reactive({
    req(input$geo_collab)

    if(input$aggregate_by == "Country") {
      df <- data_coll_country %>% filter(country == input$geo_collab)
    }
    else if(input$aggregate_by == "City") {
      df <- data_coll_city %>% filter(country == input$selected_country) %>% filter(city == input$geo_collab)
    }
    df <- df %>% filter(priority_year >= input$year_range[1], priority_year <= input$year_range[2])
    
    tech <- input$technology_by
    if(tech %in% sectors) {
      df <- df %>% filter(techn_sector == tech)
    } else if(tech %in% fields) {
      df <- df %>% filter(techn_field == tech)
    } else {
      df <- df %>% filter(techn_field == "" & techn_sector == "")
    }
    
    df <- df %>% group_by(country_) %>% summarise(collaborations = sum(count)) %>% arrange(desc(collaborations)) %>% slice(1:20)
    
    validate(need(nrow(df) > 0, error_no_data))
    df
  })

  collab_plot_title <- reactive({
    req(collab_plot_df())
    req(input$geo_collab)
    
    prefix <- if(collab_plot_df() %>% nrow() == 20) "Top 20 international collaboration partners of " else "International collaboration partners of "
    paste0(prefix, input$geo_collab)
  })
  
  collab_plot_subtitle <- reactive({
    req(collab_plot_df())
    paste0(if(input$technology_by!="All") paste0(input$technology_by, ", ") else "", input$year_range[1], "-", input$year_range[2])
  })
                        
  output$collab_plot <- renderPlot({
      req(collab_plot_df())
      req(collab_plot_title())
      
      df <- collab_plot_df()
      ggplot(df, aes(x = reorder(country_, collaborations), y = collaborations)) + 
        geom_bar(stat = "identity", fill = "#007a92") +
        coord_flip(ylim = c(0, max(df$collaborations)*1.1)) +
        labs(title = collab_plot_title(), y="Number of collaborative patents", subtitle = collab_plot_subtitle()) +
        geom_text(data = df,
                  aes(x = reorder(country_, collaborations), y = collaborations + max(df$collaborations)*0.01, label = map_chr(df$collaborations, markThousands)),
                  hjust = "left", size = 4.3) +
        theme(text = element_text(size=16),
              plot.title = element_text(size = 18, margin = margin(t = 0, r = 0, b = 5, l = 0)),
              plot.subtitle = element_text(size = 16, margin = margin(t = 0, r = 0, b = 20, l = 0)),
              axis.title.x = element_text(size = 16, margin = margin(t = 20, r = 0, b = 0, l = 0)),
              axis.title.y = element_blank(),
              panel.border = element_blank(),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              panel.background = element_blank(),
              legend.position="none")
    },
    height = function() { 
      req(collab_plot_df())
      130 + collab_plot_df() %>% nrow() * 30
    }
  )
}

