# Patent explorer
# R Shiny app
# Contact: Paul Simmering, paul.simmering@gmail.com

library(shiny) # Essential
library(shinydashboard) # For layout
library(leaflet) # Draw a map
library(tidyverse) # Utility
library(DT) # Customizable table outputs
library(scales)

# Load order matters
source("settings.R")
source("utils.R")
source("load_data.R")
source("sidebar.R")
source("body.R")
source("ui.R")
source("server.R")
