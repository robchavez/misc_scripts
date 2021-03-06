#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# This shiny app is published online here:
#
#    https://robchavez.shinyapps.io/shiny/
#

#------------------------------------------------------------------------------------
library(tidyverse)
library(usmap)
library(cowplot)
library(lubridate)
library(shiny)

options(scipen=999)
shd <- read_csv("https://covidtracking.com/api/v1/states/daily.csv")

shd$date <- ymd(shd$date)

# per capita data (hard-coded to avoid dependencies)
state_pop <- rbind(cbind("AK",4903185),
                   cbind("AL",	731545),
                   cbind("AR",7278717),
                   cbind("AZ",	3017804),
                   cbind("CA",39512223),
                   cbind("CO",	5758736),
                   cbind("CT",3565287),
                   cbind("DE",	973764),
                   cbind("DC",705749),
                   cbind("FL",	21477737),
                   cbind("GA",10617423),
                   cbind("HI",	1415872),
                   cbind("ID",1787065),
                   cbind("IL",	12671821),
                   cbind("IN",6732219),
                   cbind("IA",	3155070),
                   cbind("KS",2913314),
                   cbind("KY",	4467673),
                   cbind("LA",4648794),
                   cbind("ME",	1344212),
                   cbind("MD",6045680),
                   cbind("MA",	6892503),
                   cbind("MI",9986857),
                   cbind("MN",	5639632),
                   cbind("MS",2976149),
                   cbind("MO",	6137428),
                   cbind("MT",1068778),
                   cbind("NE",	1934408),
                   cbind("NV",3080156),
                   cbind("NH",	1359711),
                   cbind("NJ",8882190),
                   cbind("NM",	2096829),
                   cbind("NY",19453561),
                   cbind("NC",	10488084),
                   cbind("ND",762062),
                   cbind("OH",	11689100),
                   cbind("OK",3956971),
                   cbind("OR",	4217737),
                   cbind("PA",12801989),
                   cbind("RI",	1059361),
                   cbind("SC",5148714),
                   cbind("SD",	884659),
                   cbind("TN",6829174),
                   cbind("TX",	28995881),
                   cbind("UT",3205958),
                   cbind("VT",	623989),
                   cbind("VA",8535519),
                   cbind("WA",	7614893),
                   cbind("WV",1792147),
                   cbind("WI",	5822434),
                   cbind("WY",578759),
                   cbind("PR",	3193694),
                   cbind("AS", 55641),
                   cbind("GU",	164229),
                   cbind("MP", 53883),
                   cbind("VI",	106405))


state_pop <- data.frame(state = state_pop[,1], pop = state_pop[,2],stringsAsFactors = F)

daily <- left_join(shd, state_pop)
daily$pop <- as.numeric(daily$pop )


daily$percent_pos <- (daily$positive/daily$posNeg)*100



daily$percap_pos <- ((daily$positive/daily$pop)*10000)
daily$mask <- daily$percap_pos /daily$percap_pos 


app_states <- unique(daily$state)

#---------------------------------------------------------------------------------


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("COVID-19 state information"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            
            selectInput("app_states", label = "select state",
                        choices = app_states),
            
            hr(),
            helpText("Data from:  https://covidtracking.com")
            , width = 2),
        
        # Create a spot for the barplot
        mainPanel(
            plotOutput("statePlot", height = 900, width = 1000 )  
        )
        
    )
)


# Define server logic required to draw a histogram
server <- function(input, output) {

    output$statePlot <- renderPlot({

        
        tmp_df <- daily %>% filter(state == input$app_states)
        tmp_df$percent_pos <- (tmp_df$positive/tmp_df$posNeg)*100

        
        map <- plot_usmap(data = tmp_df, values = "mask", color = "white") +
            theme(legend.position = "none") 
        
        perpos <- ggplot(tmp_df, aes(date,percent_pos)) + 
            geom_line(size=.7, linetype = 'solid', color="chartreuse3") + 
            labs(x = NULL, y = NULL, title = "Percent Postive Tests",
                 subtitle = paste0("today: ", round(tmp_df$percent_pos[1], digits = 2),"%")) +
            theme_bw() +
            theme( axis.text.x = element_text(angle = 45, hjust = 1))
        
        
        testdaily <- ggplot(tmp_df, aes(date,totalTestResultsIncrease)) + 
            geom_line(size=.7, linetype = 'solid', color="chartreuse3") + 
            geom_smooth(se = F, color = 'black', linetype="longdash", span=.3, size=.4) +            
            labs(x = NULL, y = NULL, title = "Number of Tests Per Day",
                 subtitle = paste0("today: ", tmp_df$totalTestResultsIncrease[1])) +
            theme_bw() +
            theme( axis.text.x = element_text(angle = 45, hjust = 1))
        
        posdaily <- ggplot(tmp_df, aes(date,positiveIncrease)) + 
            geom_line(size=.7, linetype = 'solid', color="blueviolet") +
            geom_smooth(se = F, color = 'black', linetype="longdash", span=.3, size=.4) +  
            labs(x = NULL, y = NULL, title = "Positive Cases Per Day",
                 subtitle = paste0("today: ", tmp_df$positiveIncrease[1])) +
            theme_bw() +
            theme( axis.text.x = element_text(angle = 45, hjust = 1))
       
        postot <- ggplot(tmp_df, aes(date,positive)) + 
            geom_line(size=.7, linetype = 'solid', color="blueviolet") + 
            labs(x = NULL, y = NULL, title = "Total Positive Cases",
                 subtitle = paste0("total: ", tmp_df$positive[1])) +
            theme_bw() +
            theme( axis.text.x = element_text(angle = 45, hjust = 1))
        
        deathdaily <- ggplot(tmp_df, aes(date,deathIncrease)) + 
            geom_line(size=.7, linetype = 'solid', color="firebrick3") +
            geom_smooth(se = F, color = 'black', linetype="longdash", span=.3, size=.4) +  
            labs(x = NULL, y = NULL, title = "Deaths Per Day",
                 subtitle = paste0("today: ", tmp_df$deathIncrease[1])) +
            theme_bw() +
            theme( axis.text.x = element_text(angle = 45, hjust = 1))
        
        deathtot <- ggplot(tmp_df, aes(date,death)) + 
            geom_line(size=.7, linetype = 'solid', color="firebrick3") + 
            labs(x = NULL, y = NULL, title = "Total Deaths",
                 subtitle = paste0("total: ", tmp_df$death[1])) + 
            theme_bw() +
            theme( axis.text.x = element_text(angle = 45, hjust = 1))
        
        
        # hospitalized
        
        hospdaily <- ggplot(tmp_df, aes(date,hospitalizedCurrently)) + 
            geom_line(size=.7, linetype = 'solid', color="slateblue4") + 
            geom_smooth(se = F, color = 'black', linetype="longdash", span=.3, size=.4) +  
            labs(x = NULL, y = NULL, title = "Hospitalized Currently", 
                 subtitle = paste0("today: ", tmp_df$hospitalizedCurrently[1])) +
            theme_bw() +
            theme( axis.text.x = element_text(angle = 45, hjust = 1))
        
        ICUdaily <- ggplot(tmp_df, aes(date,inIcuCurrently)) + 
            geom_line(size=.7, linetype = 'solid', color="slateblue4") + 
            geom_smooth(se = F, color = 'black', linetype="longdash", span=.3, size=.4) +  
            labs(x = NULL, y = NULL, title = "In ICU Currently (if available)",
                 subtitle = paste0("today: ", tmp_df$inIcuCurrently[1])) +
            theme_bw() +
            theme( axis.text.x = element_text(angle = 45, hjust = 1))

        
        g2 <- plot_grid(posdaily, postot, deathdaily, deathtot, testdaily, perpos, hospdaily, ICUdaily, nrow = 4)
        plot_grid(g2, map, nrow = 1)

    })
}

# Run the application 
shinyApp(ui = ui, server = server)
