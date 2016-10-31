````{sh}
********************************************************************************************************************************
*                                                                                                                              *
*                                         Risk Plot for Ovarian Cancer using CA125                                             *
*                                                                                                                              *
********************************************************************************************************************************
The R script will take in a csv file that contains CA125 and a time point.

EXAMPLE: DAYS,CA125
         1,12
         366,23
         450,30

Then it will calculate a risk category (Normal, Intermediate, Elevated) for each of the data points based on the relative 
change in the CA125 values. The algorithm works by looking at the percent change of weighted moving averages between
each of the data points. Finally, a line plot is generated with each data point color coded by their risk.

********************************************************************************************************************************
*                                                                                                                              *
*                                                    Running the code                                                          *
*                                                                                                                              *
********************************************************************************************************************************
The R script usage: ./Robin.R <filename of csv>

The risk.sh bash script will allow the user to run multiple plots in a given directory of patient folders and checks if a plot 
already exists. If so, it will skip that patient folder and move onto the next. If a plot doesn't exist, it checks to see if 
a csv data file is found. If not, it will skip the patient folder.

The Bash script usage: ./risk.sh -i <Rscript name>
