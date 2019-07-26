require(dplyr, quietly = T, warn.conflicts = F)
require(ggplot2, quietly = T, warn.conflicts = F)
require(argparse, quietly = T, warn.conflicts = F)

parser <- ArgumentParser(description='Generate Virtual 4C plot from intrachromosomal reads')
parser$add_argument('-i', '--bedpe', type="character", help='input headerless bedpe file')
parser$add_argument('-r', '--region', type="character", help='viewpoint region chr:start-end')
parser$add_argument('-b', '--binsize', type="integer", help='binsize')
parser$add_argument('-d', '--distance', type="integer", help='distance from viewpoint for plot range')
parser$add_argument('-o', '--output', type="character", help='output filename')
parser$add_argument('-t', '--text-output', type="logical", help='weather to output the table used for plot generation, default=True', default = FALSE, nargs = '?', const = TRUE)

#parser$print_help()

args <- parser$parse_args()

filename <- args$bedpe
region <- args$region
binsize <- args$binsize
distance <- args$distance
outfile <- args$output
text_output <- args$text_output
#print(text_output)
#print(args)
#filename <- "/Volumes/abnousa/data/ucsd_cancer_copy2/MAPS_output/feather_output/GBM39_1.GBM39_2_current/GBM39_1.GBM39_2.chr7.long.intra.bedpe"
#region <- "chr7:55086326-55088453"
#binsize <- 10000
#distance <- 1500000

d <- read.csv(filename, sep = "\t", header = F)
chr <- strsplit(region, ":")[[1]][1]
start <- as.numeric(strsplit(strsplit(region, ":")[[1]][2], "-")[[1]][1])
end <- as.numeric(strsplit(strsplit(region, ":")[[1]][2], "-")[[1]][2])
if (start %/% binsize * binsize != end %/% binsize * binsize) {
  warning("start and end of region fall in different bins!")
}
warning("this script generates intrachromosomal virtual 4c plot")
viewpoint <- ((start + end) / 2) %/% binsize * binsize
d$midbin1 <- ((d$V2 + d$V3) / 2) %/% binsize * binsize
d$midbin2 <- ((d$V5 + d$V6) / 2) %/% binsize * binsize
d <- d[d$midbin1 == viewpoint | d$midbin2 == viewpoint,]
d$otherend <- ifelse(d$midbin1 == viewpoint, d$midbin2, d$midbin1)
dc <- d %>% count(otherend)
unit <- 1000
dc$dist <- (dc$otherend - viewpoint) / unit
if (text_output) {
	write.table(dc, paste0(outfile, "_dataframe.tsv"), sep = "\t", quote = F, row.names = F)
}
dc$color = "black"
dc[dc$otherend == viewpoint,]$color <- "red"
png(outfile)
ggplot(dc[dc$dist > -distance/unit & dc$dist < distance/unit & dc$dist != 0,], aes(x=dist, y=n, fill = color)) +
  geom_histogram(stat = "identity", binwidth = binsize) + 
  scale_fill_manual(values = c("black", "red")) +
  theme(axis.text.x = element_text(angle=45)) +
  #scale_x_continuous(breaks = seq(viewpoint - distance, viewpoint + distance, by = binsize * 20)) +
  scale_x_continuous(breaks = seq( -distance / unit, distance / unit, by = binsize * 20 / unit)) +
  ylab("read count") + xlab("distance from target bin (Kb)") + theme(legend.position = "none") + 
  theme(panel.background = element_rect(fill = "transparent") # bg of the panel
    , plot.background = element_rect(fill = "transparent", color = NA) # bg of the plot
    , panel.grid.major = element_blank() # get rid of major grid
    , panel.grid.minor = element_blank()
    , text = element_text(size=20))
dev.off()
