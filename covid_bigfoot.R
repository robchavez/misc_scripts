library(tidyverse)
library(usmap)
library(cowplot)
library(rvest)
library(janitor)
library(openintro)


# code generated on 3/18/2020

df <- read_csv("https://covidtracking.com/api/states.csv")


# bar plots 
tbar <- ggplot(df, aes(reorder(df$state, df$total), total)) + 
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



# make it a map
ptotal <- plot_usmap(data = df, values = "total", lines = "gray50") +
  scale_fill_viridis_c(name = "total cases", option = 'viridis') + 
  theme(legend.position = "bottom") +
  ggtitle("COVID-19 total cases")

pdeaths <- plot_usmap(data = df, values = "death", lines = "gray50") +
  scale_fill_viridis_c(name = "deaths", option = 'viridis') + 
  theme(legend.position = "bottom") +
  ggtitle("COVID-19 deaths")




plot_grid(ptotal,tbar, ncol = 2)

plot_grid(pdeaths, dbar, ncol = 2)




## big foot -----------------------------------------------------------------


#read table to list
bf_data <- read_html("https://www.bfro.net/GDB/") %>%
  html_nodes(".countytbl") %>%
  html_table(fill = TRUE)

# parse state lists into single data frame
bf_df1 <- as.data.frame(bf_data[[1]])
bf_df2 <- as.data.frame(bf_data[[2]])
bf_df <- rbind(bf_df1, bf_df2)

# rename columns, coerce classes, and filter data frame
colnames(bf_df) <- bf_df[1,]
bf_df <- clean_names(bf_df)

bf_df$number_of_listings <- as.numeric(bf_df$number_of_listings)

bf_df <- bf_df %>% 
  filter(state != "State") %>% 
  arrange(desc(number_of_listings))


# plot arrangment 
ggplot(bf_df, aes(reorder(bf_df$state, bf_df$number_of_listings), number_of_listings)) + 
  geom_bar(stat = 'identity', fill = 'steelblue4') + 
  coord_flip() +
  theme_minimal()  +
  geom_hline(yintercept = 0) +
  labs(x=NULL, y = "number of listings", title = "Where is Bigfoot?")

# make it a map!
pbf <- plot_usmap(data = bf_df, values = "number_of_listings", lines = "gray50") +
  scale_fill_viridis_c(name = "Bigfoot sightings", option = 'viridis') + 
  theme(legend.position = "bottom") +
  ggtitle("Bigfoot sightings")


# plots
plot_grid(ptotal, pbf, ncol = 2)


# stats 
df2 <- df

df2$stateabb <- df2$state
df2$state <- abbr2state(df$state)
df3 <- left_join(df2, bf_df, by = "state")

#df3 <- df3 %>% filter(is.na(number_of_listings == FALSE))


options(scipen=999)

spear_r <- round(cor.test(df3$total, df3$number_of_listings, use = 'complete.obs', method = 'spearman')[[4]][[1]], digits = 3)
spear_p <- round(cor.test(df3$total, df3$number_of_listings, use = 'complete.obs', method = 'spearman')[[3]][[1]], digits = 3)
pear_r <- round(cor.test(df3$total, df3$number_of_listings, use = 'complete.obs', method = 'pearson')[[4]][[1]], digits = 3)
pear_p <- round(cor.test(df3$total, df3$number_of_listings, use = 'complete.obs', method = 'pearson')[[3]][[1]], digits = 6)

caption <- paste0("Spearman rho = ", spear_r, ", p = ", spear_p, "\n Pearson R = ", pear_r, ", p = ", round(pear_p,digits = 6))


ggplot(df3, aes(total,number_of_listings, label = stateabb)) + 
  geom_text() + 
  stat_smooth(method = 'lm', se = FALSE, color='steelblue4') +
  theme_minimal() +
  labs(title = "Relationship between COVID-19 cases and Bigfoot Sightings", caption = caption, x ="COVID-19 cases", y = "Bigfoot sightings")



