library(tidyverse)
library(usmap)
library(cowplot)


# code generated on 3/18/2020
df <- read_csv("https://covidtracking.com/api/states.csv")


# bar plots 
tbar <- ggplot(df, aes(reorder(df$state, df$positive), positive)) + 
  geom_bar(stat = 'identity', fill='steelblue4') + 
  coord_flip() +
  theme_minimal()  +
  geom_hline(yintercept = 0) +
  labs(x=NULL, y = "total cases", title = "COVID-19 total cases")


df$death_nona <- ifelse(is.na(df$death) == TRUE, 0, df$death)
dbar <- ggplot(df, aes(reorder(df$state, df$death_nona), death_nona)) + 
  geom_bar(stat = 'identity', fill = 'steelblue4') + 
  coord_flip() +
  theme_minimal()  +
  geom_hline(yintercept = 0) +
  labs(x=NULL, y = "deaths", title = "COVID-19 deaths")

# calculate log values
df$log_deaths <- log(df$death)
df$log_total <- log(df$positive)





# per capita data (hard coded to avoid dependencies and speed)
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
                   cbind("AS", 0),
                   cbind("GU",	0 ),
                   cbind("MP", 0),
                   cbind("VI",	0))


state_pop <- data.frame(state = state_pop[,1], pop = state_pop[,2],stringsAsFactors = F)


df <- left_join(df, state_pop) 

df$pop <- as.numeric(df$pop)

df$percapita_cases <- (df$positive/df$pop) *100000

df$percapita_deaths <- (df$death/df$pop) *100000

# ------------------------------------------------------------------
# create per capita plots
pcap_total <- plot_usmap(data = df, values = "percapita_cases", lines = "gray50") +
  scale_fill_viridis_c(name = "per capita cases", option = 'viridis') + 
  theme(legend.position = "bottom") +
  ggtitle("Per capita COVID-19 total cases per 100,000 people")

pcap_deaths <- plot_usmap(data = df, values = "percapita_deaths", lines = "gray50") +
  scale_fill_viridis_c(name = "per capita cases", option = 'viridis') + 
  theme(legend.position = "bottom") +
  ggtitle("Per capita COVID-19 total deaths per 100,000 people")


# create total cases maps
ptotal <- plot_usmap(data = df, values = "total", lines = "gray50") +
  scale_fill_viridis_c(name = "total cases", option = 'viridis') + 
  theme(legend.position = "bottom") +
  ggtitle("COVID-19 total cases")

ptotal_log <- plot_usmap(data = df, values = "log_total", lines = "gray50") +
  scale_fill_viridis_c(name = "log total cases", option = 'viridis') + 
  theme(legend.position = "bottom") +
  ggtitle("COVID-19 total cases (log values)")

plot_total_maps <- plot_grid(ptotal, pcap_total, ptotal_log, ncol = 1)


# create deaths maps
pdeaths <- plot_usmap(data = df, values = "death", lines = "gray50") +
  scale_fill_viridis_c(name = "deaths", option = 'viridis') + 
  theme(legend.position = "bottom") +
  ggtitle("COVID-19 deaths")


pdeaths_log <- plot_usmap(data = df, values = "log_deaths", lines = "gray50") +
  scale_fill_viridis_c(name = "deaths", option = 'viridis') + 
  theme(legend.position = "bottom") +
  ggtitle("COVID-19 deaths (log values)")

plot_death_maps <- plot_grid(pdeaths, pcap_deaths, pdeaths_log, ncol = 1)



# plot total cases maps
plot_grid(plot_total_maps, tbar, ncol = 2 )

# plot death maps
plot_grid(plot_death_maps,dbar, ncol = 2 )




