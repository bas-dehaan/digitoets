#
# Created by: B.M. de Haan
# Used to analyse data from a school servey about digital examination
# Github: https://github.com/bas-dehaan/digitoets
#

library(shiny)
library(openxlsx)
library(tidyverse)
library(RColorBrewer)
library(gridExtra)

# Read the exceldata and omit column 1:5 (metadata)
rawdata = read.xlsx('./rawdata.xlsx')[6:31]
names = c("opleiding", "jaar", "ervaring", paste0("Q",4:26))
names(rawdata) = names



# Make the data machine-readable
# Study program names
rawdata$opleiding[rawdata$opleiding == "BML-Research"]          = 1
rawdata$opleiding[rawdata$opleiding == "BML-Diagnostiek"]       = 2
rawdata$opleiding[rawdata$opleiding == "Chemie"]                = 3
rawdata$opleiding[rawdata$opleiding == "Chemische Technologie"] = 4
rawdata$opleiding[rawdata$opleiding == "Bioinformatica"]        = 5
rawdata$opleiding[rawdata$opleiding == "Master Datascience"]    = 6
# Study years
rawdata$jaar[rawdata$jaar == "Leerjaar 1"] = 1
rawdata$jaar[rawdata$jaar == "Leerjaar 2"] = 2
rawdata$jaar[rawdata$jaar == "Leerjaar 3"] = 3
rawdata$jaar[rawdata$jaar == "Leerjaar 4"] = 4
# Experience with digiexamnination
rawdata$ervaring[rawdata$ervaring == "Ja"]  = TRUE
rawdata$ervaring[rawdata$ervaring == "Nee"] = FALSE

## Sadly Shinny does not updata functions which are outside of the shinnyServer()

# dataload = function(erv = TRUE){
#     if(!erv){
#         dataselect = subset(rawdata,
#                             subset = `opleiding` %in% input$opleiding & `jaar` %in% input$jaar)
#     }else{
#         dataselect = subset(rawdata,
#                             subset = `opleiding` %in% input$opleiding & `jaar` %in% input$jaar & `ervaring` == TRUE)
#     }
# }

# Define server logic
shinyServer(function(input, output) {
    output$responses = renderText({
        # Select data according to the input$opleiding and input$jaar selection
        dataselect = subset(rawdata, `opleiding` %in% input$opleiding & `jaar` %in% input$jaar)
        # Count the number of responses
        total_responses = nrow(rawdata)
        num_responses = nrow(dataselect)
        paste(num_responses, "van de", total_responses, "reacties geselecteerd")
    })
    
    output$ervaring = renderPlot({
        ## Yes, I had to repeat this every time becouse R cannot exchange variables between
        ## multiple output$***, <<- instead of <- or = is only an option of the input is fixed.
        dataselect = subset(rawdata,
                            subset = `opleiding` %in% input$opleiding & `jaar` %in% input$jaar)
        
        num_responses = nrow(dataselect)

        # Calculate and print the % of experience with digitoetses
        exp_w_digitoets = round((nrow(dataselect[dataselect[3] == TRUE, ])/num_responses)*100, 1)
        exp_df = data.frame(
            group=c("Ervaring", "Geen ervaring"), 
            value=c(exp_w_digitoets, 100-exp_w_digitoets)
        )
        pie(exp_df$value,
            labels = paste0(exp_df$group, " - ", exp_df$value, "%"),
            main = "Ervaring met digitaal toetsen"
        )
    })
    output$beoordeling = renderPlot({
        dataselect = subset(rawdata,
                            subset = `opleiding` %in% input$opleiding & `jaar` %in% input$jaar & `ervaring` == TRUE)
        
        ## This opperation could most likely be done using a for() loop, but IDK
        
        # Processing of digi-exams
        df1 = data.frame(Var1 = 1:10)
        df2 = as.data.frame(table(dataselect[4]))
        
        # Merge the df's
        df_digi = merge(df1, df2, by = "Var1", all.x = TRUE)
        df_digi[is.na(df_digi)] = 0
        df_digi$Var1 = as.factor(df_digi$Var1)
        
        # Compute percentages
        df_digi$fraction = df_digi$Freq / sum(df_digi$Freq)
        # Compute the cumulative percentages (top of each rectangle)
        df_digi$ymax = cumsum(df_digi$fraction)
        # Compute the bottom of each rectangle
        df_digi$ymin = c(0, head(df_digi$ymax, n=-1))
        # Compute label position
        df_digi$labelPosition = (df_digi$ymax + df_digi$ymin) / 2
        # Compute a good label
        df_digi$label = paste0("Score: ", df_digi$Var1, "\n", round(df_digi$fraction*100, 2), "%")
        
        # Make the plot
        p = ggplot(df_digi, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=Var1)) +
            geom_rect() +
            geom_label( x=3.5, aes(y=labelPosition, label=label), size=2) +
            scale_fill_brewer(palette="RdYlGn") +
            coord_polar(theta="y") +
            xlim(c(2, 4)) +
            theme_void() +
            theme(legend.position = "none")
        
        digiplot = grid.arrange(p,
                                top=textGrob("Digitaal", vjust=3.5, gp = gpar(cex = 2)),
                                bottom=textGrob(paste("Gemiddelde:", round(colMeans(dataselect[4]), 2)),
                                                vjust = -5
                                )
        )
        
        
        # Operation of paper-exams
        df1 = data.frame(Var1 = 1:10)
        df2 = as.data.frame(table(dataselect[5]))
        
        # Merge the df's
        df_paper = merge(df1, df2, by = "Var1", all.x = TRUE)
        df_paper[is.na(df_paper)] = 0
        df_paper$Var1 = as.factor(df_paper$Var1)
        # Compute percentages
        df_paper$fraction = df_paper$Freq / sum(df_paper$Freq)
        # Compute the cumulative percentages (top of each rectangle)
        df_paper$ymax = cumsum(df_paper$fraction)
        # Compute the bottom of each rectangle
        df_paper$ymin = c(0, head(df_paper$ymax, n=-1))
        # Compute label position
        df_paper$labelPosition = (df_paper$ymax + df_paper$ymin) / 2
        # Compute a good label
        df_paper$label = paste0("Score: ", df_paper$Var1, "\n", round(df_paper$fraction*100, 2), "%")
        
        
        
        # Make the plot
        p = ggplot(df_paper, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=Var1)) +
            geom_rect() +
            geom_label(x=3.5, aes(y=labelPosition, label=label), size=2) +
            scale_fill_brewer(palette="RdYlGn") +
            coord_polar(theta="y") +
            xlim(c(2, 4)) +
            theme_void() +
            theme(legend.position = "none")
        
        paperplot = grid.arrange(p,
                                 top=textGrob("Papier", vjust=3.5, gp = gpar(cex = 2)),
                                 bottom=textGrob(paste("Gemiddelde:", round(colMeans(dataselect[5]), 2)),
                                                 vjust = -5
                                 )
        )
        
        grid.arrange(digiplot, paperplot ,nrow=1, ncol=2)
        
    })
    
})
