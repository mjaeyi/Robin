#!/bin/bash

scriptFile=0

while getopts ":i:h" opt; 
do
        case $opt in
                i)
                        scriptFile=$OPTARG
                        ;;
                h)
			echo "Usage: ./plotgen.sh -i <filename>"
			echo "<filename> is the name of the script file to use"
                        exit 1
                        ;;
                \?)
                        echo "Invalid option: -$OPTARG" >&2
			echo "Usage: ./plotgen.sh -i <filename>"
                        exit 1
                        ;;
                :)
                        echo "Option -$OPTARG requires an argument." >&2
			echo "Usage: ./plotgen.sh -i <filename>"
                        exit 1
                        ;;
        esac
done

if [ $scriptFile == 0 ]
then
	echo "Needs to specify which script to use."
	echo "Usage: ./plotgen.sh -i <filename>"
	exit 1
fi

if [ ! -e $scriptFile ]
then
	echo "Input script file ["$scriptFile"] does not exist." >&2
	exit 1
fi

for dname in ../../oci/*/
do
	outname=${dname%?}
	outname=${outname##*/}
	if [ ! -e $dname/${outname}_risk.pdf ]
	then
		echo -e "In $dname, plot was not found."
		echo "Checking to see if $outname.csv exists..."
		if [ ! -e $dname/$outname.csv ]
		then
			echo -e "$outname.csv not found... skipping this folder.\n"
		else
			echo "$outname.csv found. Generating plot..."
			./ca125_plot_v0.1.R $dname$outname.csv
			echo -e "Plot generated.\n"
		fi
	fi
done

echo -e "\nFinish updating all patient folders.\n"
