library(bigrquery)

#Validacion de variables de control

if(!exists("bigquery_states")) bigquery_states <-  "bigquery-public-data.geo_us_boundaries.states"


#ID del proyecto para el billing
billing_id <- "covidtrackingdata"

#Autorizacion de la cuenta (se hace solo una vez por sesion)
bq_auth(email = "juanevaccaro@gmail.com")


#Query a consultar
sql <- paste0("SELECT * FROM `",bigquery_states,"`")

#Extraccion de la data
tb <- bq_project_query(billing_id, sql)
states_data <- bq_table_download(tb)
states_ids <- select(states_data,geo_id,state,state_name)


print('Paso 1: Completado exitosamente! . . . . . . . ')
