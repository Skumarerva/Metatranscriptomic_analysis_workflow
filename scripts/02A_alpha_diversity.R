## Figure 1
## Alpha diversity
## Tumor vs Normal comparison

## Import previously created biom file for each of the sites


## Same codes applies to both sites and other variables

source("./01_scripts/import_biom.R")


library(lme4)
library(sdamr)
library(afex)
library(broom.mixed)
library(data.table)
library(DT)
library(webshot)



## OTUS Richness

all_metrics2 <- adiv_table(biom, adiv = c("OTUs"), trans = "none")


all <- all_metrics2

p1 <- ggboxplot(
  all,
  x = "Group",
  y = ".diversity",
  add = "boxplot",
  fill = "Group"
)

p1 <- p1 +
  geom_jitter(color = "black",
              size = 0.4,
              alpha = 0.9) +
  theme_ipsum() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 10),
    axis.text.x = element_text(angle = 90)
  ) +
  xlab("Tumor status") + ylab("Observed Otus")
p1 <- p1 + theme(legend.text = element_text(size = 5))
p1 <- p1 + theme(panel.background = element_rect(colour = "black"))

p1 <- p1 + ylim(0, 20)
p1 <- p1 + theme_classic()

p1 <- p1 + theme(
  plot.title = element_text(
    color = "black",
    size = 14,
    face = "bold"
  ),
  plot.subtitle = element_text(
    color = "grey",
    size = 13,
    face = "bold.italic"
  ),
  axis.title.x = element_blank(),
  axis.title.y = element_text(
    color = "black",
    size = 15,
    face = "bold"
  ),
  legend.text = element_text(size = 6),
  legend.title = element_text(size = 15),
  axis.text.x = element_text(size = 15, angle = 0, face = "bold"),
  axis.text.y = element_text(size = 15, angle = 0, face = "bold"),
  axis.line.x = element_line(color = "black", size = 0.5),
  axis.line.y = element_line(color = "black", size = 0.5),
  panel.border = element_rect(
    colour = "black",
    fill = NA,
    linewidth = 1
  )
) + scale_x_discrete(labels = c("N" = "Normal", "T" = "Tumor"))

## Color blind friendly palette

p1 <- p1 + scale_fill_brewer(palette = "Dark2", guide = "none")



### Mixed level analysis Richness adjusting for read depth - same code applies to inverse simpson and both sites

read_counts <- read.csv("./00_raw_data/ReadCounts.csv", header = TRUE)

read_counts <- read_counts[grep("Site1", read_counts$site), grep("sample|non", colnames(read_counts))]

colnames(read_counts)[grep("nonhuman", colnames(read_counts))] <- "Counts"

all_metrics2 <- merge(
  all_metrics2,
  read_counts,
  by.x = ".sample",
  by.y = "samples",
  all.x = TRUE
)


mod <- afex::lmer_alt(.diversity ~ Group + Counts + (1 |
                                                       Pt_ID), data = all_metrics2)
summary(mod)
results <- anova(mod)



## Inverse simpson

all_metrics2 <- adiv_table(biom, adiv = c("InvSimpson"), trans = "none")


all_metrics2 <- merge(
  all_metrics2,
  read_counts,
  by.x = ".sample",
  by.y = "samples",
  all.x = TRUE
)





all <- all_metrics2

p3 <- ggboxplot(
  all,
  x = "Group",
  y = ".diversity",
  add = "boxplot",
  fill = "Group"
)

p3 <- p3 +
  geom_jitter(color = "black",
              size = 0.4,
              alpha = 0.9) +
  theme_ipsum() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 10),
    axis.text.x = element_text(angle = 90)
  ) + ylab("Inverse Simpson-Evenness")
p3 <- p3 + theme(legend.text = element_text(size = 5))
p3 <- p3 + theme(panel.background = element_rect(colour = "black"))

p3 <- p3 + ylim(0, 10)
p3 <- p3 + theme_classic()
p3 <- p3 + theme(
  plot.title = element_text(
    color = "black",
    size = 14,
    face = "bold"
  ),
  plot.subtitle = element_text(
    color = "grey",
    size = 13,
    face = "bold.italic"
  ),
  axis.title.x = element_blank(),
  axis.title.y = element_text(
    color = "black",
    size = 15,
    face = "bold"
  ),
  legend.text = element_text(size = 6),
  legend.title = element_text(size = 15),
  axis.text.x = element_text(size = 15, angle = 0, face = "bold"),
  axis.text.y = element_text(size = 15, angle = 0, face = "bold"),
  axis.line.x = element_line(color = "black", size = 0.5),
  axis.line.y = element_line(color = "black", size = 0.5),
  panel.border = element_rect(
    colour = "black",
    fill = NA,
    linewidth = 1
  )
)
p3 <- p3 + scale_x_discrete(labels = c("N" = "Normal", "T" = "Tumor"))



p3 <- p3  + scale_fill_brewer(palette = "Dark2", guide = "none")




## Mixed levels Inverse simpson

mod <- afex::lmer_alt(.diversity ~ Group + Counts + (1 |
                                                       Pt_ID), data = all_metrics2)
summary(mod)
results <- anova(mod)

# ────────────────────────────────────────────────────────────────────────────────────────────────────
# Save the results 
# ────────────────────────────────────────────────────────────────────────────────────────────────────


set.seed(123)

pdf("./03_plots/Alpha/TN.pdf")

ggarrange(p1, p3, ncol = 2, common.legend = TRUE)

dev.off()

