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
                selected = c(1,2,3,4,5,6)
            ),
            # Select course year
            checkboxGroupInput("jaar", 
                h4("Leerjaar"), 
                choices = list("Jaar 1" = 1, 
                               "Jaar 2" = 2, 
                               "Jaar 3" = 3,
                               "Jaar 4" = 4
                               ),
                selected = c(1,2,3,4)
            ),
            br(),
            br(),
            a("Source code @ GitHub", href="https://github.com/bas-dehaan/digitoets")
        ),


        # Show the statistics of the selected data
        mainPanel(
            textOutput("responses"),
            plotOutput("ervaring"),
            plotOutput("beoordeling")
        )
    )
))
