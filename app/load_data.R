
load("data/data_country.RData")
load("data/data_city.RData")
load("data/data_coll_city.RData")
load("data/data_coll_country.RData")

# Define constants -------------------------------------------------
year_min <- data_country$priority_year %>% min()
year_max <- data_country$priority_year %>% max()

countries <- data_country$country %>% unique() %>% sort()

mean_lon <- data_country$lon %>% mean(na.rm = TRUE)
mean_lat <- data_country$lat %>% mean(na.rm = TRUE)

fields <- sort(unique(data_country$techn_field))
sectors <- sort(unique(data_country$techn_sector))

tech_hierarchy <- list(
  "All" = c("All"),
  "Electrical engineering"=c("Electrical engineering"),
  "Instruments"=c("Instruments"),
  "Chemistry"=c("Chemistry"),
  "Mechanical engineering"=c("Mechanical engineering"),
  "Other fields"=c("Other fields"),
  "Electrical engineering" = c("Electrical machinery, apparatus, energy",
                               "Audio-visual technology", "Telecommunications", "Digital communication", 
                               "Basic communication processes", "Computer technology", "IT methods for management", "Semiconductors"),
  "Instruments" = c("Optics", "Measurement", "Analysis of biological material", "Control", "Medical technology"),
  "Chemistry" = c("Organic fine chemistry", "Biotechnology", "Pharmaceuticals", "Macromolecular chemistry, polymers", "Food chemistry", "Basic materials chemistry", "Materials, metallurgy", "Surface technology, coating", "Micro-structural and nano-technology", "Chemical engineering", "Environmental technology"),
  "Mechanical engineering" = c("Handling", "Machine tools", "Engines, pumps, turbines", "Textile and paper machines", "Other special machines", "Thermal processes and apparatus", "Mechanical elements", "Transport"),
  "Other fields" = c("Furniture, games", "Other consumer goods", "Civil engineering"))

