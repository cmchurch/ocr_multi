#/!bin/bash
#call with the following params:
#1) infile
#2) outfile
#3) an int representing the number of times you want to erode
#example: bash erode.sh img.png out.png 5

command="convert $1 -write MPR:source -morphology close rectangle:4x4 -morphology erode square MPR:source -compose Lighten -composite"
for ((x=1;x<=$3;x++));do
command+=" -morphology erode square MPR:source -composite"
done
command+=" "$2
eval $command
echo "Output to "$2
