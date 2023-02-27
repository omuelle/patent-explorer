# Body --------------------------------------------------------------------
body <- dashboardBody(
  # CSS to set colors and spacing
  tags$head(tags$style(
    HTML('
      .irs-bar {
        border-top-color: #007a92 !important;
        border-bottom-color: #007a92 !important;
        background: #007a92 !important;
      }
      .irs-bar-edge {
        border-color: #007a92 !important;
        background: #007a92 !important;
      }
      .irs-from, .irs-to, .irs-single {
        background: #007a92 !important;
      }
      .item {
        background:  #007a92 !important;
        color: white !important;
      }
      .selectize-dropdown-content .active {
        background:  #007a92 !important;
        color: white !important;
      }
      .nav-tabs-custom .nav-tabs li.active {
        border-top-color: #007a92;
      }
      .skin-blue .main-header .logo {
        background-color: #007a92;
      }
      .skin-blue .main-header .logo:hover {
        background-color: #007a92;
      }
      .skin-blue .main-header .navbar {
        background-color: #66b0c2;
      }
      .skin-blue .main-header .navbar .sidebar-toggle:hover{
        background-color: #007a92;
      }
      .sidebar {
      color: #000000;
      }
      .skin-blue .main-sidebar {
      background-color: #F2F2F2
      }
      .skin-blue .content {
      background-color: #F2F2F2
      }
      .skin-blue .content-wrapper {
      background-color: #F2F2F2
      }
      .sidebar .shiny-input-container {
      margin-bottom: 5px;
      }
      .wrapper {
      background-color: #F2F2F2
      }
      ')
    )),
  fluidRow(
    tabBox(
      id = "tabs",
      width = 12,
      tabPanel("Introduction",
               value = "introduction",
               div(
                 h1("KOF Patent Explorer (Beta Version V1)"),
                 p("Welcome to the KOF Patent Explorer. This tool lets you map and visualize inventive and innovative activity around the globe. The explorer relies on geocoded inventor addresses from nine large patent offices. You can explore the data at country or city level, select time ranges and technologies.
                 The map shows the number of first patent filings and collaborative patents by country and cities. Collaborative patents are patens that have been developed together with inventors from other countries.
                 The Collaboration Plots allow you to inspect the number of collaborations in a more detailed way."),
                 h2("Data Sources"),
                 p("The patent explorer draws on a comprehensive dataset with geographic coordinates for inventor locations in 18.8 million patent documents for more than 30 years. The geocoded data are further allocated to the corresponding countries and cities. When the address information was missing in the original patent document, we imputed it by using information from subsequent filings in the patent family. The dataset can be used to study patenting activity at a fine-grained geographic level without creating bias towards the traditional, established patent offices."),
                 h2("Contributors"),
                 p("Dr. Florian Seliger,", a(href = "mailto:seliger@kof.ethz.ch", "seliger@kof.ethz.ch")),
                 p("Jan Kozak"),
                 p("Prof. Dr. Gaétan de Rassenfosse"),
                 p("Oliver Müller"),
                 p("The Patent Explorer relies on code for the Global Patent Explore project (", a(href = "gpxp.org", "gpxp.org"), ") provided by Daniel Hain from Aalborg University. Further contributors are:"),
                 p("Roman Jurowetzki, Tobias Buchmann, Patrick Wolf, and Paul Simmering"))
      ),
      tabPanel(
        "Map",
        value = "map",
        tags$style(type = "text/css", "#map {height: calc(100vh - 130px) !important;}"),
        leafletOutput("map")
      ),
      tabPanel(
        "Collaboration Plot",
        style='height: 800px',
        fluidRow(
          style='padding-left: 20px; padding-right: 20px',
          column(
            style='margin-top: 10px',
            width = 3,
            uiOutput("collaboration_geo"),
            offset = 0
          ),
          column(
            style='margin-top: 20px',
            width = 9,
            plotOutput("collab_plot"),
            offset = 0
          )
        )
      ),
      tabPanel("Data",
               value = "data",
               DT::DTOutput("nodes_df")
      )
    )
  )
)
