library(bigrquery)

#Validacion de variables de control
if(!exists("year")) year <- 2021
if(!exists("bigquery_covid")) bigquery_covid <-  "bigquery-public-data.covid19_usafacts.summary"


#ID del proyecto para el billing
billing_id <- "covidtrackingdata"

#Autorizacion de la cuenta (se hace solo una vez por sesion)
bq_auth(email = "juanevaccaro@gmail.com")


#Query a consultar
sql <- paste0("
SELECT state
      ,state_fips_code
      ,SUM(confirmed_cases) confirmed_cases
      ,SUM(deaths) deaths
FROM `",bigquery_covid,"`
WHERE date = '",year,"-12-31'
GROUP BY state,state_fips_code
"
)


#Extraccion de la data
tb <- bq_project_query(billing_id, sql)
covid_data <- bq_table_download(tb)

if(nrow(covid_data) == 0) stop('No hay registros de Covid-19 para el year seleccionado (la informacion es consultada a cierre del year)')

print('Paso 4: Completado exitosamente! . . . . . . . ')
