#### LIBRERIAS -----------------------------------------------------------------

library(readxl)
library(tidyr)
library(dplyr)

#### OBTENCION DE DATA ----------------------------------------------------------------------

#Descarga archivo en un archivo temporal
temp <- tempfile()
url <- "https://aspe.hhs.gov/sites/default/files/migrated_legacy_files//200111/aspe-uninsured-estimates-by-state.xlsx"
download.file(url,temp, mode="wb")

data <-  read_excel(temp,sheet = "All Uninsured (#)")

#Transformacion de data
data <- select(data,c("State Name",colnames(data[grepl("Age ",colnames(data))])))
unins_data <- data %>%
  pivot_longer(cols = -c("State Name"),
               names_to = c("Age")) %>%
  `colnames<-`(c("state", "age", "unins_population"))
unins_data <- unins_data[!c(unins_data$state == 'US Total'),]



#Creacion de totales en age
tmp <- unins_data %>%
  dplyr::group_by(state) %>%
  dplyr::summarise(unins_population = sum(unins_population))
tmp$age <- 'TOTAL'
unins_data <- rbind(unins_data,tmp)


print('Paso 3: Completado exitosamente! . . . . . . . ')
