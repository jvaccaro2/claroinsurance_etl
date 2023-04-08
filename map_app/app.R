library(shiny)
library(shinyWidgets)
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


#### CARGA DE DATA -------------------------------------------------------

load("./map_app/data.RData")


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

runApp(shinyApp(ui, server))
