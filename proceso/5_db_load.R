library(RMySQL)
library(DBI)
library(readr)
library(odbc)

#Datos de conexion a la BD
host <- "claroinsuranceetl.cfsklmiqxlr2.us-east-1.rds.amazonaws.com"
user <- "admin"
password <- "vp.int.neg.2022"
database <- "claroinsuranceetl"
port <- 3306

#Conexion usando RMySQL (Esta conexion usa la version MySQL C API instalada en sistema)
con <- RMySQL::dbConnect(RMySQL::MySQL(),
                 host = host,
                 user = user,
                 password = password,
                 dbname = database,
                 port = port)


#Lista de objetos creados en pasos anteriores
objects_list <- list(states_data = states_data,
                     states_ids = states_ids,
                     census_data = census_data,
                     unins_data = unins_data,
                     covid_data = covid_data)

#Loop para crear las tablas en la BD
for(i in 1:length(objects_list)){
  
  dbWriteTable(conn = con,
               name = names(objects_list[i]),
               value = objects_list[[i]],
               overwrite = TRUE)
  
}

#Ejecucion del query aggregate_data.sql (Este crea la tabla aggregate_data que contiene la informacion consolidada del resto de las tablas)
query_exec <- dbGetQuery(con, statement = read_file('./sql_queries/aggregate_data.sql'))


print('Paso 5: Completado exitosamente! . . . . . . . ')
