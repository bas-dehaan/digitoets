#
# Created by: B.M. de Haan
# Used to analyse data from a school servey about digital examination
# Github: https://github.com/bas-dehaan/digitoets
#

library(shiny)


# Define UI for application
shinyUI(fluidPage(

    # Application title
    titlePanel("Uitslag enquête"),

    # Sidebar with the input for the data selection
    sidebarLayout(
        sidebarPanel(
            # Data is loading message
            tags$head(tags$style(type="text/css", "
                #loading {
                    position: fixed;
                    top: 0px;
                    left: 0px;
                    width: 100%;
                    padding: 5px 0px 5px 0px;
                    text-align: center;
                    font-weight: bold;
                    font-size: 100%;
                    color: #000000;
                    background-color: #CCFF66;
                    z-index: 105;
                }"
            )),
            conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                             tags$div("Data wordt geladen, een ogenblik geduld...",
                                      id="loading")),
            
            # Select course program
            checkboxGroupInput("opleiding", 
                h4("Opleiding"), 
                choices = list("BML-R"  = 1, 
                               "BML-MD" = 2, 
                               "C"      = 3,
                               "CT"     = 4,
                               "BIN"    = 5,
                               "DSLS"   = 6
                               ),
                selected = 1:6
            ),
            # Select course year
            checkboxGroupInput("jaar", 
                h4("Leerjaar"), 
                choices = list("Jaar 1" = 1, 
                               "Jaar 2" = 2, 
                               "Jaar 3" = 3,
                               "Jaar 4" = 4
                               ),
                selected = 1:4
            ),
            submitButton("Update selectie", icon("refresh")),
            br(),
            br(),
            a("Source code @ GitHub", href="https://github.com/bas-dehaan/digitoets/tree/corona")
        ),


        # Show the statistics of the selected data
        mainPanel(
            textOutput("responses"),
            plotOutput("ervaring"),
            plotOutput("beoordeling"),
            plotOutput("voorbereiding"),
            plotOutput("tentamen1"),
            plotOutput("tentamen2"),
            plotOutput("tentamen3"),
            plotOutput("tentamen4"),
            plotOutput("tentamen5"),
            plotOutput("nabespreking")
        )
    )
))
