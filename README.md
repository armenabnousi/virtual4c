# R script for creating vritual 4C plot for a given viewpoint from a bedpe file (binned V4C)

Run `Rscript create_virtual_4c_plot.R -h` for help.

Example run command:
```
Rscript create_virtual_4c_plot.R -t -i input_bedpe.bedpe -o output.png -d 10000 -r chr2:123456-123890 -d 1000000
```

This script generates a virtual 4C plot from a bedpe file for a given viewpoint. The bedpe file does not need to be binned, but the script accepts a bin width argument and performs the binning. If the start and end points of the viewpoint are in different bins, the viewpoint will be the bin containing the middle of the input range (you will also have a warning when this happens).
The arguments are:
* **-i** : input bedpe file
* **-r**: viewpoint region in form of *chr:start-end*.
* **-b**: bin width used to perform the binning. Distances are computed for each bin and the final V4C is from binned data.
* **-d**: the distance from the viewpoint that should be considered for plot generation. If the distance is *d* and the viewpoint bin is *v*, then the bins that will be plotted are within *(v-d, v+d)* range.
* **-o**: name of the output file. Output plot is in png format.
* **-t**: You likely would want to use this flag. If this flag is used, in addition to the output png file and tab-separated file containing the processed data used for plot generation will also be output. This file has the same name as the output png file with a "*_dataframe.tsv*" suffix. This will allow you to regenerate the plot based on your formatting preferences for publication. Note that -t does not accept additional arguments. By default this table will not be generated.

