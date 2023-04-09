#### LIBRERIAS -----------------------------------------------------------------

library(readxl)
library(tidyr)
library(dplyr)
library(RCurl)

#Validacion de variables de control

if(!exists("year")) year <- 2021


#### OBTENCION DE DATA ----------------------------------------------------------------------

#Descarga archivo en un archivo temporal
temp <- tempfile()
url <- paste0("https://aspe.hhs.gov/sites/default/files/documents/b9a5a69a7e4b8c081e9122383fc07bea/uninsured-estimates-state-eligibility-",year,".xlsx")
url2 <- paste0("https://aspe.hhs.gov/sites/default/files/documents/51d2cc81e2516c11e35d4773b839605b/state-level-",year,".xlsx")

if(url.exists(url)) download.file(url,temp, mode="wb")
if(url.exists(url2)) download.file(url2,temp, mode="wb")
if(!url.exists(url) & !url.exists(url2)) stop('No se encuentra archivo para el year seleccionado')

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
