library(shiny)
library(shinyWidgets)
library(shinydashboardPlus)
library(bslib)
library(bs4Dash)
library(leaflet)
library(reactable)
library(dplyr)
library(RMySQL)
library(DBI)
library(sf)
library(wk)
library(bigrquery)
library(reactablefmtr)
library(waiter)


#### CREACION DE OBJETOS -------------------------------------------------------

#### 1) CREACION DEL MAPA -------------------------------------------------------


#Conexion usando RMySQL (Esta conexion usa la version MySQL C API instalada en sistema)
con <- RMySQL::dbConnect(RMySQL::MySQL(),
                         host = "claroinsuranceetl.cfsklmiqxlr2.us-east-1.rds.amazonaws.com",
                         user = "admin",
                         password = "vp.int.neg.2022",
                         dbname = "claroinsuranceetl",
                         port = 3306)


#Datos de la tabla
table_data <- dbGetQuery(con,"SELECT * FROM claroinsuranceetl.aggregate_data")


#Datos geojson de US States
states <- geojsonio::geojson_read("https://rstudio.github.io/leaflet/json/us-states.geojson", what = "sp") %>% st_as_sf(wkt = c('polygons'))


#Desconexion a la BD
dbDisconnect(con)


#Creacion del objeto sf para el mapa
map_data0 <- states %>%
  dplyr::inner_join(table_data[,-c(1)], by = c("name"="state_name")) %>%
  dplyr::select(state,name,id,colnames(table_data[,-c(1,3)]),geometry) %>%
  dplyr::mutate(labs = paste0('(',state,') ',name,': ',round(population/1000000,1),'M pop.'),
                pops = paste0("<h4><b>(",state,") ",name,'</b></h4>',
                              "Population:  <b>",population,"</b><br>",
                              "Male Population %: <b>", round(ratio_male_pop*100,2),"</b><br>",
                              "Female Population %: <b>", round(ratio_female_pop*100,2),"</b><br>",
                              "Uninsured 19-64yr: <b>", round(unins_19_64yr,0),"</b><br>",
                              "Covid Cases: <b>", round(covid_cases,0),"</b><br>",
                              "Covid Deaths: <b>", round(covid_deaths,0),"</b><br>")) #%>%
  #st_as_sf(wkt = c('state_geom'))


#Inicializacion del mapa
map <- leaflet(map_data0, options = leafletOptions(preferCanvas = TRUE)) %>%
  addProviderTiles("CartoDB", group = "Carto")


#Creacion de vector para loop sobre el mapa
groups <- c("population","unins_19_64yr","covid_cases","covid_deaths")
colors <- c("Purples","Greens","Blues","Reds")


#Loop para agregar capas al mapa
for(i in 1:length(groups)){
  
  map_data0$col <- map_data0[,c(groups[i])][[1]]
  
  pal <- colorNumeric(palette = colors[i], n = 5,
                      domain = log(map_data0$col))
  
  map <- map %>%
    addPolygons(data = map_data0,
                layerId = ~col,
                fillOpacity = 0.75,
                stroke = TRUE,
                smoothFactor = 0.5,
                color = "grey50",
                weight = 1,
                opacity = 0.25,
                fillColor = ~pal(log(col)),
                label = ~labs,
                popup = ~pops,
                group = groups[i],
                highlight = highlightOptions(weight = 3, color = "blue",bringToFront = TRUE))
}

#Opciones de control sobre el mapa
map <- map %>%
  addLayersControl(overlayGroups = groups,
                   options = layersControlOptions(collapsed = FALSE)) %>%
  hideGroup(groups[-1])


#### 2) CREACION DE LA TABLA -------------------------------------------------------
table_data[,c(12:18)] <- round(table_data[,c(12:18)]*100,2)
table_data <- table_data %>% arrange(desc(population))

colnames(table_data) <- c('ID'
                          ,'State'
                          ,'State_Name'
                          ,'Population'
                          ,'Male_Population'
                          ,'Female_Population'
                          ,'18-64yr_Population'
                          ,'Uninsured_Population'
                          ,'Uninsured_19-64yr Pop.'
                          ,'Covid-19_Cases'
                          ,'Covid-19_Deaths'
                          ,'Male_Pop.%'
                          ,'Female_Pop.%'
                          ,'Male/Female_Pop.%'
                          ,'Unins._Pop %'
                          ,'Unins._19-64yr Pop.%'
                          ,'Covid Cases_Pop.%'
                          ,'Covid Deaths_Pop.%')

table_data$ID <- NULL

ratio_def <- colDef(format = colFormat(separators = TRUE, digits = 1)
                    ,minWidth = 80) 

table <- reactable(table_data
                   ,compact = TRUE
                   ,bordered = FALSE
                   ,highlight = TRUE
                   ,outlined = FALSE
                   ,resizable = TRUE
                   ,wrap = FALSE
                   ,defaultPageSize = 60
                   ,height = 550
                   ,defaultColDef = colDef(
                     html = TRUE,
                     header = function(value){gsub("_", "<br>", value, fixed = TRUE)},
                     align = "center",
                     minWidth = 120,
                     format = colFormat(separators = TRUE, digits = 0),
                     headerStyle = list(background = "#f7f7f8")
                   )
                   ,columns = list(
                     State = colDef(sticky = "left",
                                    style = list(borderRight = "1px solid #eee"),
                                    headerStyle = list(borderRight = "1px solid #eee")),
                     Population = colDef(cell = data_bars(table_data
                                                          ,number_fmt = scales::number_format()
                                                          ,force_outside = c(0,20000000)
                                                          ,fill_color = "orange")
                                         ,minWidth = 150)
                     ,`Covid-19_Deaths` = colDef(style = list(borderRight = "1px solid #eee"))
                     ,`Male_Pop.%` = ratio_def
                     ,`Female_Pop.%` = ratio_def
                     ,`Male/Female_Pop.%` = ratio_def
                     ,`Unins._Pop %` = ratio_def
                     ,`Unins._19-64yr Pop.%` = ratio_def
                     ,`Covid Cases_Pop.%` = ratio_def
                     ,`Covid Deaths_Pop.%` = ratio_def
                   )
                   ,columnGroups = list(
                     colGroup(name = 'Estados', columns = c("State","State_Name")),
                     colGroup(name = "Datos Poblacionales", columns = c('Population'
                                                                        ,'Male_Population'
                                                                        ,'Female_Population'
                                                                        ,'18-64yr_Population'
                                                                        ,'Uninsured_Population'
                                                                        ,'Uninsured_19-64yr Pop.'
                                                                        ,'Covid-19_Cases'
                                                                        ,'Covid-19_Deaths')),
                     colGroup(name = "Ratios (%)", columns = c('Male_Pop.%'
                                                               ,'Female_Pop.%'
                                                               ,'Male/Female_Pop.%'
                                                               ,'Unins._Pop %'
                                                               ,'Unins._19-64yr Pop.%'
                                                               ,'Covid Cases_Pop.%'
                                                               ,'Covid Deaths_Pop.%'))
                   ))



rm(con,map_data0,dbsummary,ratio_def,states_data,table_data,tb)


#### TEMA Y ESTILOS ------------------------------------------------------------

#CSS styling
main_css <- ".navbar.navbar-default {background: linear-gradient(13deg, rgba(24,87,120,1) 0%, rgba(28,121,148,1) 44%, rgba(68,193,230,1) 100%);}
             .navbar-default .navbar-nav > li > a:hover, .navbar-default .navbar-nav > li > a:focus {background-color: #33AFCD; color: #FFC0CB;}"

#THEME
my_theme <- bs_theme(version = 5
                     ,font_scale = 1.5
                     ,`enable-gradients` = TRUE
                     ,`enable-shadows` = TRUE
                     ,bootswatch = "cerulean")

title_style <- "color: #989898; letter-spacing: 5px; border-bottom: 1px solid #DEDDDD;"

#### UI ------------------------------------------------------------------------

ui <- fluidPage(
  use_waiter(),
  waiter_preloader(
    html = spin_loaders(24),
    color = "#185778"
  ),
  tags$head(tags$style(HTML(main_css))),
  
  navbarPage('Claro Insurance ETL Map Visualization',
             id = 'explorer_tab-nav',
             fluid = TRUE,
             theme = my_theme,
             collapsible = TRUE,
             header = tagList(
               useShinydashboardPlus(),
               useBs4Dash()
             ),
             #Intro tab UI
             tabPanel("",
                      fluidRow(h1('Population Data Map',align = 'center', style = title_style)),
                      br(),
                      h6('Este mapa muestra el resultado del caso de estudio proceso ETL:'),
                      br(),
                      tags$div(
                        tags$ul(
                          tags$li(HTML("<b>Extracci&oacuten:</b> La data obtenida corresponde al a&ntildeo 2021 y se obtiene de las siguientes fuentes: Censo: US Census Bureau, Poblaci&oacuten sin asegurar: ASPE, Casos Covid-19: Google BigQuery"))
                        )
                      ),
                      tags$div(
                        tags$ul(
                          tags$li(HTML("<b>Transformaci&oacuten:</b> La data descargada es manipulada y transformada a traves de diversas librerias en R (dplyr, tidyr, tidiverse, enter otras) y SQL"))
                        )
                      ),
                      tags$div(
                        tags$ul(
                          tags$li(HTML("<b>Carga:</b> Los resultados finales son cargados en una base de datos MySQL remota en AWS, y consultados para mostrar el mapa y la tabla interactiva."))
                        )
                      ),
                      br(),
                      fluidRow(column(width = 7,h6('Mapa interactivo',align = 'left',style = title_style),leafletOutput('map',height = 550)),
                               column(width = 5,h6('Tabla de datos',align = 'left',style = title_style),reactableOutput('table'))
                      )
                      
             )
             
  ))


#### SERVER --------------------------------------------------------------------

server <- function(input, output, session) {

  #Render del mapa
  output$map <- renderLeaflet(map %>% setView(-98.02571924293795, 39.524632719517655, zoom = 4))
  
  #Render de la tabla
  output$table <- renderReactable(table)

}

shinyApp(ui, server)
