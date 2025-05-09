library(tidyverse)

grid <- read_table("fvcom_grd.dat", skip = 2, col_names=F) %>%
  rename(node = X1, lon= X2, lat = X3)

# Lat Long
interestPoints <- list(
  "Genessee river mouth" = c(43.236374, -77.527306),
  "Niagara river mouth" = c(43.266306, -79.070994),
  "North shore" = c(43.871564, -78.620636),
  "Lake Center " = c(43.576411, -77.719210),
  "Watertown bay" = c(43.907540, -76.140153)
  )

nodes <- c()
for (name in names(interestPoints)) {
  x <- interestPoints[[name]]
  distx <- sqrt((x[1] - grid$lat)^2 + (x[2] - grid$lon)^2)
  node <- grid$node[which(distx == min(distx))]
  nodes <- append(nodes, node)
}