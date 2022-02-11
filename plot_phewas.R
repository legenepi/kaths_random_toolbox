# This script generates a (png) plot from pheWAS data
#
# Requirements: R (tested on v3.4.1) and gcc (tested on version 6.3)
#
# Usage: Rscript plot_phewas.R <infile> <outfile prefix>
#
# The infile is a tab-delimited text file including the following columns:
# category = the phenotypic category
# phenotype = tested phenotype
# BETA = beta coefficient
# FDR = false discovery rate (if absent rename P value column "FDR")
# 
# Before running, must set mappings of categories to colours where indicated
# (line 33) in this script, and may need to alter output file options (line 54)

args <- commandArgs(T)

library(ggplot2)
library(ggrepel)
library(dplyr)

data <- read.table(args[1], sep="\t", header=T)

data$direction <- ifelse(data$BETA<0,"Negative","Positive")

data <- data[order(data$FDR),]
data$category <- ordered(data$category, levels=unique(data$category))
data <- data[order(data$category),]

data <- mutate(data, phenotype = factor(phenotype, phenotype))

# change the following line to your own categories/colours
cols <- c("Anthropometry" = "darkorange3", "Gastroenterology, hepatobiliary, colorectal" = "black", "Respiratory" = "orangered2", "Biological assays - FBC" = "steelblue4", "Cardiovascular" = "plum3", "Metabolic and endocrine" = "springgreen4", "Neurosciences" = "steelblue2", "Urology" = "darkorange1", "Musculoskeletal disease - rheumatology and orthopaedics" = "bisque4", "ENT and maxillofacial" = "thistle3", "Medication" = "grey46", "Operations and Procedures" = "khaki2", "Immunoinflammation and Skin" = "steelblue3", "Haematology" = "wheat4", "Eye" = "lightpink3")

shapes = c("Positive" = 24, "Negative" = 25)

main.plot <- function(data) {
p <- ggplot(data, aes(x = phenotype, y = -log10(FDR), color = category, fill = category)) +
theme_minimal() +
geom_point(aes(shape=direction), size = 3) +
scale_shape_manual(values = shapes) +
theme(axis.text.x = element_text(angle = 90, hjust=1, vjust=0.4)) +
ylab("-log10(FDR)") + xlab("Phenotype") +
scale_colour_manual(values=cols) +
scale_fill_manual(values=cols) +
scale_y_continuous(limits=c(2, max(-log10(data$FDR)))) +
guides(fill=guide_legend(title="Phenotypic Category", ncol=1, override.aes=list(shape=24)), col=guide_legend(title="Phenotypic Category", ncol=1), shape=guide_legend(title="Direction of Effect", ncol=1)) +
theme(plot.margin = unit(c(2,1,1,2), "cm")) +
theme(legend.position="right")
return(p)
}

# Change according to your requirements/preferences
#png(filename=paste(args[2],".png", sep=""), width=15, height=10, units='in', res = 300) # 1all
png(filename=paste(args[2],".png", sep=""), width=12, height=10, units='in', res = 300) # 2all
#png(filename=paste(args[2],".png", sep=""), width=11.5, height=7, units='in', res = 300) # 1b
#png(filename=paste(args[2],".png", sep=""), width=7, height=6, units='in', res = 300) #2b

main.plot(data)
dev.off()