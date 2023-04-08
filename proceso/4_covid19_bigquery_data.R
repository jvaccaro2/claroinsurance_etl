library(bigrquery)

#ID del proyecto para el billing
billing_id <- "covidtrackingdata"

#Autorizacion de la cuenta (se hace solo una vez por sesion)
bq_auth(email = "juanevaccaro@gmail.com")


#Query a consultar
sql <- "
SELECT state
      ,state_fips_code
      ,SUM(confirmed_cases) confirmed_cases
      ,SUM(deaths) deaths
FROM `bigquery-public-data.covid19_usafacts.summary`
WHERE date = '2021-12-31'
GROUP BY state,state_fips_code
"

#Extraccion de la data
tb <- bq_project_query(billing_id, sql)
covid_data <- bq_table_download(tb)


print('Paso 4: Completado exitosamente! . . . . . . . ')