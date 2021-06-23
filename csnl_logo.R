library(tidyverse)
library(ggforce)

# Some data in radial form
rad <- data.frame(r = seq(0, 7, by = 0.1), a = seq(0, 7, by = 0.1))

# Create a transformation
radial <- radial_trans(c(0, 1), c(0, 5.9))

# Get data in x, y
cart <- radial$transform(rad$r, rad$a)

# Have a look 
ggplot() +
  geom_path(aes(x = x, y = y), data = cart, color = 'forestgreen', size=1) +
  geom_curve(aes(x = 1.2, y = 0, xend = 5, yend = 1.1), curvature = .28, color='forestgreen', size=1) +
  geom_curve(aes(x = 5, y = 1.1, xend = 3.6, yend = 6), curvature = .5, color='forestgreen', size=1) +
  
  #central
  geom_curve(aes(x = 0, y = 6.4, xend = 1, yend = 2.5), curvature = -.3, color='forestgreen') +
  geom_curve(aes(x = -.8, y = 6.2, xend = 0.2, yend = 2.5), curvature = -.3, color='forestgreen') +

   #STS
  geom_curve(aes(x = -3.5, y = 0, xend = 0, yend = -2), curvature = .3, color='forestgreen') +
  geom_curve(aes(x = -3, y = 1, xend = 0, yend = -1), curvature = .3, color='forestgreen') +

 # parital
  geom_curve(aes(x = -3, y = 3, xend = -2, yend = 4), curvature = -.3, color='forestgreen') +
  
  geom_curve(aes(x = -.3, y = .5, xend = -.4, yend = 2), curvature = -.3, color='forestgreen') +
  geom_curve(aes(x = -.3, y = .5, xend = -1.5, yend = 1), curvature = .3, color='forestgreen') +

  #front
  geom_curve(aes(x = 2, y = .5, xend = 4, yend = 1), curvature = .3, color='forestgreen') +
  geom_curve(aes(x = 4.5, y = 4, xend = 3, yend = 3), curvature = .3, color='forestgreen') +
  geom_curve(aes(x = 4.5, y = 4, xend = 3, yend = 4.8), curvature = -.2, color='forestgreen') +
  coord_cartesian(ylim = c(-3.5,7), xlim = c(-5.5,6)) +
  annotate("text", x =4 , y = -1.5, label = "The Computational \nSocial Neuroscience Lab", size = 5.5) +
  annotate("text", x =4 , y = -2.5, label = "at University of Oregon", color = "forestgreen",  size = 3.5) +
  theme_void()
  
  