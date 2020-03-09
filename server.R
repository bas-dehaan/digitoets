#
# Created by: B.M. de Haan
# Used to analyse data from a school servey about digital examination
# Github: https://github.com/bas-dehaan/digitoets
#

library(shiny)
library(readxl)
library(ggplot2)

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
    output$responses = renderText({
        # Select data according to the input$opleiding and input$jaar selection
        dataselect = subset(rawdata, `Welke opleiding volg je?` %in% input$opleiding & `In welk leerjaar zit je momenteel?` %in% input$jaar)
        # Count the number of responses
        total_responses = nrow(rawdata)
        num_responses = nrow(dataselect)
        paste(num_responses, "van de", total_responses, "reacties geselecteerd")
    })
    
    output$ervaring = renderPlot({
        # Select data according to the input$opleiding and input$jaar selection
        dataselect = subset(rawdata, `Welke opleiding volg je?` %in% input$opleiding & `In welk leerjaar zit je momenteel?` %in% input$jaar)
        # Count the number of responses
        num_responses = nrow(dataselect)

        # Calculate and print the % of experience with digitoetses
        exp_w_digitoets = round((nrow(dataselect[dataselect[3] == "Ja", ])/num_responses)*100, 1)
        exp_df = data.frame(
            group=c("Ervaring", "Geen ervaring"), 
            value=c(exp_w_digitoets, 100-exp_w_digitoets)
        )
        pie(exp_df$value, labels = paste0(exp_df$group, " - ", exp_df$value, "%"), main = "Ervaring met digitaal toetsen")
    })
    
})
