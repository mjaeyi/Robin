#!/usr/bin/env Rscript

library(ggplot2)
library(TTR)

args <- commandArgs(TRUE)
fn = args[1]

fname = strsplit(fn, split='.', fixed=TRUE)
pname = strsplit(fname[[1]][1], split='/', fixed=TRUE)
patient = pname[[1]][5]

t <- read.csv(fn, head=TRUE)

#Stores the days needed for moving average
Days <- c(t[2:nrow(t), c("Days")])
simpMA <- SMA(t[,c("CA125")], n=2)
weightMA <- WMA(t[,c("CA125")], n=2, wts = 1:2)


#Set Colors
first <- 0
pos <- 0
neg <- 0
oall <- 0
count <- 0
low <- .15
high <- .30
d <- .2
perC <- NA
ovC <- c(NA, NA, NA)


risk <- character(nrow(t))
for (i in 1:nrow(t)) {
  count <- count + 1

  #Places very first CA125 value into risk category by ranges 22 to 35 U/mL 
  #Otherwise, does percent change calculations
  if (first == 0) {
		if (t[i, "CA125"] <= 22) {
		  risk[i] <- "Normal"
		}
		else if (t[i, "CA125"] >= 35) {
		  risk[i] <- "Elevated"
		}
		else {
		  risk[i] <- "Intermediate"
		}
		first <- 1
  }
  else {
		temp <- ((t[i, "CA125"] - weightMA[i]) / t[i, "CA125"])
		perC <- c(perC, temp)
		
		#Checks if there is a postive or negative change
		if (temp < 0) {
		  change <- 1
		  neg <- neg + abs(temp)
		  temp <- abs(temp)
		}
		else {
		  change <- 0
		  pos <- pos + abs(temp)
		  temp <- abs(temp)
		}
	  
	    #Waits until there is at least 4 values before doing overall 
		#positive or negative change correction.
		if (pos > neg && count >= 4) {
		  oall <- ((pos - neg) / pos)
		  ovC <- c(ovC, oall)
		}
		if (neg > pos && count >= 4) {
		  oall <- ((pos - neg) / neg)
		  ovC <- c(ovC, oall)
		}
		
		temp <- abs(temp)
	  
	    #If CA125 has a small change, risk category stays the same as previously chosen.
		#If CA125 has a very large positive change, immediately changes to "Elevated" risk.
		#If CA125 has a intermediate change, risk category will move one level based on 
		#positive or negative change.
		if (temp <= low || (change == 1 && temp  < high)) {
			risk[i] <- risk[i-1]
		}
		else if (temp >= high) {
			  if (change == 1 && risk[i-1] == "Elevated") {
				risk[i] <- "Intermediate"
			  }
			  else if (change == 1 && risk[i-1] == "Intermediate") {
				risk[i] <- "Normal"
			  }
			  else if (change == 1 && risk[i-1] == "Normal") {
				risk[i] <- "Normal"
			  }
			  
			  if (change == 0) {
				risk[i] <- "Elevated"
			  }
		}
		else {
			  if (change == 0) {
					if (risk[i-1] == "Normal") {
					  risk[i] <- "Intermediate"
					}
					else if (risk[i-1] == "Intermediate") {
					  risk[i] <- "Elevated"
					}
					else if (risk[i-1] == "Elevated") {
					  risk[i] <- "Elevated"
					}
			  }
		}
		
		#Calculates overall positive or negative change to correct for
		#series of small positive or negative changes that creates a 
		#trend not detected by above logic.
		if (oall >= d) {
			  if (risk[i] == "Normal") {
				risk[i] <- "Intermediate"
			  }
			  else if (risk[i] == "Intermediate") {
				risk[i] <- "Elevated"
			  }
		}
		else if (oall <= -d) {
			  if (risk[i] == "Elevated") {
				risk[i] <- "Intermediate"
			  }
			  else if (risk[i] == "Intermediate") {
				risk[i] <- "Normal"
			  }
		}
  }
}

#Stores the statistics for a particular patient
stats <- data.frame("CA125"=t$CA125, "MA"=simpMA, "Weighted MA"=weightMA, "Change"=perC, "Overall Change"=ovC)

t$Risk <- c(risk)

mycolours <- c("Normal" = "green", "Intermediate" = "orange", "Elevated" = "red")

pdf(paste(fname[[1]][1],"_risk.pdf", sep =""))

#Plotting using GGplot
ggplot() + geom_line(data=t, aes(y = CA125, x = Days)) + geom_point(data=t, aes(y = CA125, x = Days, colour = Risk), size =3) + 
scale_color_manual("Risk", values = mycolours) +
geom_hline(aes(yintercept=35), color = "red", size = 2, alpha = .4) +
geom_hline(aes(yintercept=22), color = "green", size = 2, alpha = .4) +
ggtitle(paste("Risk Assessment: Ovarian Cancer using CA125", patient, sep = " "))
