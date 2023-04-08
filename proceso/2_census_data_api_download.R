
#### LIBRERIAS -----------------------------------------------------------------

library(tidycensus)
library(tidyverse)
library(stringr)
library(dplyr)


#### API KEY -------------------------------------------------------------------

census_api_key("b890a27034fa0b4e383bad1657a6b3c1411a95d0")


#### HELPER FUNCTIONS ----------------------------------------------------------

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}


#### OBTENCION DE DATA ----------------------------------------------------------------------

#Lista de tablas disponibles
vars <- load_variables(2021, "acs5", cache = TRUE)

#Creacion de vector contentivo de todas las tablas del segmento B01001 (SEX BY AGE)
variables_vec <- c(paste0("B01001_0",substrRight(paste0("0",1:49),2)))


#Adecuacion del objeto vars para obtener las categorias por cada tabla del segmento
vars0 <- dplyr::filter(vars,name %in% variables_vec)
vars0 <- vars0 %>%
         dplyr::mutate(tmp = str_replace_all(label,pattern = "Estimate!!Total:",replacement = ""),
                       tmp = str_replace_all(tmp,pattern = "!!",replacement = ""),
                       sex = str_split(tmp,pattern = ":",simplify = TRUE)[,1],
                       age = str_split(tmp,pattern = ":",simplify = TRUE)[,2],
                       tmp = NULL)
vars0$sex[vars0$sex == ''] <- 'TOTAL'
vars0$age[vars0$age == ''] <- 'TOTAL'



#Consulta de data
data <- get_acs(
  geography = "state",
  variables = variables_vec,
  year = 2021,
  output = "tidy",
  survey = "acs1"
)

#Cruzar con vars0 para obtener nombres de categorias
census_data <- data %>%
         dplyr::left_join(select(vars0,name,sex,age),by = c("variable" = "name")) %>%
         dplyr::select(NAME,sex,age,estimate,moe) %>%
         `colnames<-`(c("state", "sex", "age", "population", "error"))



print('Paso 2: Completado exitosamente! . . . . . . . ')