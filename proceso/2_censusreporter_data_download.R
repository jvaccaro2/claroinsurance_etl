
#### LIBRERIAS -----------------------------------------------------------------

library(readxl)
library(tidyr)
library(dplyr)


#Variables del nombre del archivo (El nombre del archivo es necesario, dado que el zip descargado contiene una subcarpeta con el mismo titulo del nombre del archivo)
name <- "acs2021_1yr_B01001_04000US24"
file <- paste0(name,'.xlsx')


#### OBTENCION DE DATA ----------------------------------------------------------------------

#Descarga archivo en un archivo temporal
temp_zip <- paste0(tempfile(),".zip")
url <- "https://api.dokku.censusreporter.org/1.0/data/download/acs2021_1yr?table_ids=B01001&geo_ids=040|01000US&format=xlsx"
download.file(url,temp_zip, mode="wb")


#Extraer archivos del zip en un directorio temporal
temp_dir <- tempdir()
unzip(temp_zip, exdir = temp_dir)



#Construir la ruta del archivo y leer la data del archivo de excel
path <- file.path(temp_dir, name, file)
data <- read_excel(path)


#Eliminar la conexión a la ruta temporal
unlink(temp_dir, recursive = TRUE)
dir.create(tempdir())

#### TRANSFORMACION DE DATA ----------------------------------------------------------------------

#Construir los nombres de columnas
data$B01001[1:2] <- c("state","variable")
data[1,which(is.na(data[1,]))] <- data[1,which(is.na(data[1,]))-1]
colnames(data) <- c("age",paste0(data[1,],'_',data[2,])[-1])

#Adecua data para separar columnas de genero y edad
data <- data[-c(1:2),]
male_pos <- grep('Male:',data$age)
female_pos <- grep('Female:',data$age)
data$sex <- c('TOTAL',rep('Male',female_pos-male_pos),rep('Female',nrow(data)-female_pos+1))
data$age[data$age %in% c('Total:','Male:','Female:')] <- 'TOTAL'

#Transformar la data en formato long (esto para que la data mantenga el mismo formato que al descargarla por el API)
census_data <- data %>%
  pivot_longer(cols = -c(age, sex), 
               names_to = c("state", ".value"), 
               names_sep = "_")

census_data <- census_data %>% 
  select(state,sex,age,Value,Error) %>%
  `colnames<-`(c("state", "sex", "age", "population", "error")) %>%
  dplyr::mutate(population = as.numeric(population)
               ,error = as.numeric(error))


print('Paso 2: Completado exitosamente! . . . . . . . ')