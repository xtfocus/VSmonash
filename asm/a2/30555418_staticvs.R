require(ggplot2)

dat <- read.csv('assignment-02-data-formated.csv')
str(dat)

# value: Subtract % and convert to numeric
dat$value <- as.numeric((sub('%', '', dat$value)))
str(dat)

# Sort the latitudes
site.lat <- unique(dat[c('location', 'latitude')])
site_order <- order(site.lat$latitude)
site.lat <- site.lat[site_order,]

dat$location <- factor(dat$location, levels = site.lat$location)
plot1 <- ggplot(dat, aes(year, value)) + geom_point(size=1) + facet_grid(coralType~location)
plot2 <- plot1 + geom_smooth(aes(group = 1),
                             method = "lm",
                             color = "green",
                             formula = y~ poly(x, 2),
                             size = 0.6,
                             se = FALSE)

plot3 <- plot2 + theme_bw() +
  scale_x_continuous("Year") +
  scale_y_continuous("Bleaching percentage") +
  theme(legend.position = "top", legend.direction = "horizontal")
plot3


