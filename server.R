#
# Created by: B.M. de Haan
# Used to analyse data from a school servey about digital examination
# Github: https://github.com/bas-dehaan/digitoets
#

library(shiny)
library(readxl)

# Read the exceldata and omit column 1:5 (metadata)
rawdata = read_xlsx('./rawdata.xlsx')[6:31]

# Make the data machine-readable
# Study program
rawdata[1][rawdata[1] == "BML-Research"] = 1
rawdata[1][rawdata[1] == "BML-Diagnostiek"] = 2
rawdata[1][rawdata[1] == "Chemie"] = 3
rawdata[1][rawdata[1] == "Chemische Technologie"] = 4
rawdata[1][rawdata[1] == "Bioinformatica"] = 5
rawdata[1][rawdata[1] == "Master Datascience"] = 6
# Study year
rawdata[2][rawdata[2] == "Leerjaar 1"] = 1
rawdata[2][rawdata[2] == "Leerjaar 2"] = 2
rawdata[2][rawdata[2] == "Leerjaar 3"] = 3
rawdata[2][rawdata[2] == "Leerjaar 4"] = 4


# Define server logic
shinyServer(function(input, output) {
    output$selected_opleiding = renderText({
        paste("opleiding", input$opleiding)
    })
    output$selected_jaar = renderText({
        paste0(input$jaar, "e jaar")
    })
    output$test = renderTable(rownames = TRUE, {
        subset(rawdata, `Welke opleiding volg je?` %in% input$opleiding & `In welk leerjaar zit je momenteel?` %in% input$jaar)
    })
    
})
