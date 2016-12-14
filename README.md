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

********************************************************************************************************************************
*                                                                                                                              *
*                                                        Known Bugs                                                            *
*                                                                                                                              *
********************************************************************************************************************************
Current Bugs:

There are 2 conditions to move risk categories. The first is a percent difference between the observed value and its moving 
average value and exceeding a certain threshold. The second is an overall comparison of the amount of positive change vs 
negative change. The bug is in the second condition:

There are some cases where patients had very large drops in the negative direction. This moves the risk category to normal as
expected but as the observed values start increasing again, the overall comparison causes the values to not move up a risk 
category if a positive percent difference is found due to the very large amount of negative change.

Solution:

1) The algorithm can be changed to incorporate the sliding window in moving averages (n=1,2,3,4,...). This should allow one to drop
the second condition when calculating risk categories. 

OR

2) When the risk category returns back to normal, you can reset the values for the second criteria. So only hold the amount of 
positive vs negative change until the risk returns to normal and restart this process. So when positive changes occur, it will
correctly change risk categories.

********************************************************************************************************************************
*                                                                                                                              *
*                                                   Algorithm Improvement                                                      *
*                                                                                                                              *
********************************************************************************************************************************
Currently threshold are set based on the limited number of patient profiles obtained. Therefore these threshold values can be
determined by data. More patient profiles can be assessed and utilize machine learning to pick the most optimal threshold values.
