#### DESCRIPCION GENERAL -----------------------------------------

"ESTE SCRIPT CONTROLA TODA LA EJECUCION DE DESCARGA DE ARCHIVOS PARA EL CASO DE ESTUDIO DE ETL
LAS ETAPAS DEL PROCESO SE DESARROLLARON EN SCRIPTS SEPARADOS PARA FACILITAR SU USO Y LEGIBILIDAD,
CADA SCRIPT DEBE ESTAR CONTENIDO DENTRO DE LA SUBCARPETA 'proceso' EN LA MISMA CARPETA QUE MASTER.R  
"

  #Cambio de directorio para facilitar la ejecucion de los sources
  dir <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dir)

  
#### 1) OBTENCION DE DATA DE US STATES -----------------------------------------

"Este paso realiza una consulta en Google BigQuery para obtener una tabla con la informacion de estados
e informacion necesaria para la elaboracion del mapa, la ejecucion del source devuelve:

      -states_data: objeto con informacion de poligonos de US states para el dibujo del mapa.
      -states_id: objeto con informacion de nombre, abreviacion, y codigo de US states.
"

  source("./proceso/1_statesid_bigquery_data.R")



#### 2) OBTENCION DE DATA DEL US CENSUS BUREAU -----------------------------------------

"Este paso obtiene informacion del Americnan Comunity Census para el 2021 (acs2021_1yr),
Se elaboraron dos scripta alternativos para obtener la informacion, uno mediante el uso del API de US Census Bureau,
y otro mediante descarga directa de censusreporter.org; ambos procesos generan el mismo output. La ejecucion del source devuelve:

      -census_data: objeto con la informacion de poblacion del censo acs2021_1yr, separado por US States, sexo, y rangos de edad.
"

  #Solo es necesario ejecutar uno
  source("./proceso/2_census_data_api_download.R") #Para descargar usando el API
  #source("./2_censusreporter_data_download.R") #Para descarga directa de censusreporter



#### 3) OBTENCION DE DATA DE ASPE ------------------------------------------------

"Este paso obtiene la informacion de poblacion sin asegurar desde aspe.hhs.gov, de acuerdo a la pagina oficial esta informacion
tambien se obtuvo a traves del Americnan Comunity Census para el 2021. La ejecucion devuelve:

      -unins_data: objeto con la informacion de poblacion sin asegurar por rango de edad
"

  source("./proceso/3_aspe_data_download.R")



#### 4) OBTENCION DE DATA DE COVID-19 ---------------------------------------------

"Este paso realiza una consulta en Google BigQuery para obtener la informacion de afectados por covid-19 en cada US state para el 2021,
la consulta se realiza en el repositorio 'bigquery-public-data.covid19_usafacts'. La ejecucion devuelve:

      -covid_data: objeto con la informacion de poblacion afectada por covid por cada US State
"

  source("./proceso/4_covid19_bigquery_data.R")



#### 5) CARGA DE DATOS EN AWS MYSQL DATABASE -----------------------------------------

"Este paso toma el objeto final junto a todos los objetos previos y los inserta en tablas por separado dentro de una
base de datos MySQL remota ubicada en AWS.
"

  source("./proceso/5_db_load.R")



#LOS SIGUIENTES SCRIPTS CUMPLEN LA UNICA FUNCION DE LA VISUALIZACION DEL MAPA  
  
#### 6) ARCHIVO RDATA -----------------------------------------
  
  "Este paso genera el archivo necesario para la ejecucion del dashboard interactivo
"
  
  source("./proceso/6_app_data.R")
  
#### 8) VISUALIZACION DEL MAPA -----------------------------------------

"Este paso ejecuta un dashboard interactivo para la visualizacion de la informacion sobre un mapa
"

  source("./map_app/app.R")


