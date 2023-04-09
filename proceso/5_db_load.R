library(RMariaDB)
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
con <- RMySQL::dbConnect(RMariaDB::MariaDB(),
                 host = host,
                 user = user,
                 password = password,
                 dbname = database,
                 port = port)

if(!exists("states_data")) stop('No se encuentra el archivo states_data (generado en el paso 1) para ser cargado a la BD')
if(!exists("states_ids")) stop('No se encuentra el archivo states_ids (generado en el paso 1) para ser cargado a la BD')
if(!exists("census_data")) stop('No se encuentra el archivo census_data (generado en el paso 2) para ser cargado a la BD')
if(!exists("unins_data")) stop('No se encuentra el archivo unins_data (generado en el paso 3) para ser cargado a la BD')
if(!exists("covid_data")) stop('No se encuentra el archivo covid_data (generado en el paso 4) para ser cargado a la BD')



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
aggregate_data <- dbGetQuery(con, statement = read_file('./sql_queries/aggregate_data.sql'))
dbWriteTable(conn = con,
             name = "aggregate_data",
             value = aggregate_data,
             overwrite = TRUE)


#Desconexion a la BD
dbDisconnect(con)

print('Paso 5: Completado exitosamente! . . . . . . . ')
