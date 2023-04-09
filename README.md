# claroinsurance_etl
Caso de estudio de ETL para Claro Insurance:

Este caso de estudio involucra la elaboración de un proceso ETL para la extracción, transformación y carga de datos poblacionales para US States, junto a datos de población sin asegurar, y casos Covid-19. El framework utilizado en este proceso es el conjunto de librerias del lenguaje de programación R, para una carga final hacia una base de datos MySQL alojada en AWS-RDS.

Los conjuntos de datos son extraidos de: US Census Bureau (data poblacional), ASPE (población sin asegurar), y Google BigQuery (datos Covid-19 y poligonos de mapa), y el workflow del proceso se describe en el siguiente diagrama:
![ETL Diagram](https://github.com/jvaccaro2/claroinsurance_etl/blob/main/etl_diagram.png?raw=true)

Adicionalmente para la visualización de los datos, se elaboró un pequeño dashboard web-app bajo el framework de R/Shiny, el cual contiene un mapa interactivo con los datos principales y la tabla del conjunto de datos obtenido al final del proceso.

Link para el dashboard: https://jvaccaro.shinyapps.io/map_app

Dashboard Interactivo
![ETL Diagram](https://github.com/jvaccaro2/claroinsurance_etl/blob/main/mapa_interactivo.PNG?raw=true)
