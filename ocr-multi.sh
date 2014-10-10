#!/bin/bash 
#CHRISTOPHER M CHURCH
#ASSISTANT PROFESSOR
#DEPARTMENT OF HISTORY
#UNIVERSITY OF NEVADA, RENO

#INSTRUCTIONS
# This bash script will OCR scan either PDFs or PNGs and output the results to a like-named file.
# Make sure to run using "bash ocr-multi.sh" -- sh will throw an exception.


#--------------
#-----INIT-----
#-------------- 

#check for dependencies
type convert >/dev/null 2>&1 || { echo >&2 "Imagemagick is not installed.  Aborting."; exit 1; }
type tesseract >/dev/null 2>&1 || { echo >&2 "Tesseract is not installed.  Aborting."; exit 1;}


#get CLI arguments

if [ -n "$1" ]; then tesargs=$1; else tesargs=''; fi

#define timestamp function
timestamp() {
date +"%F_%T"
}

#set variables
start_time=$(timestamp)
output_dir=ocr_output_$start_time

#define scanning functions

convert_and_scan() {
  echo "Converting " $1 
  #convert each page of the pdf to tiff and then store the temp files in temp dir
  convert -background white -alpha remove -density 300 "$i" -depth 8 file-%04d.tiff 
  for x in file-*.tiff; do
	scan $x $1   
  done
  #clean up our temporary files
  rm -r file-*.tiff
}

scan() {
    x=$1
    echo "Scanning" $x 
    tesseract $tesargs $x $x
    cat $x.txt >> ./$output_dir/$2.txt
    rm $x.txt #remove temp file
}




#create temp directory if it doesn't exist
mkdir -p temp

#create ocr_output directory if it doesn't exist
mkdir -p $output_dir

#create log directory if it doesn't exist
mkdir -p log

#--------------
#-----OCR------
#--------------
#CONVERT PDFS TO TIFFs, OCR THEM, APPEND EACH PAGE'S OCR TO A SINGLE OUTPUT FILE
for i in *.pdf *.png *.PNG *.PDF; do 
  #if [[ ${i: -4} == ".pdf" ]]; then convert_and_scan $i; fi
  case ${i: -4} in
	.pdf|.PDF)
	    convert_and_scan $i
		;;
        .png|.PNG)
            scan $i $i
	    ;;
        *)
            echo "unknown."
	    ;;
  esac
  echo $(timestamp) ": "  $i " scanned.\n" >> log/log_$start_time.log 
done

#--------------
#----CLEAN-----
#-------------- 
#now loop over all the scanned files and clean them (remove unnessary newlines, delete page numbers from OneNote, collapse hyphenated words
#remove all newlines that are not blank lines with perl in paragraph mode with regex
perl -p -i'.bak' -00 -lpe 'tr/\n/ /d' $output_dir/*.txt

#collapse all hypenated words with regex
perl -p -i -e 's/-\s//gm' $output_dir/*.txt

#if it exists, remove the quick notes page numbers from OneNote exported files
perl -p -i -e 's/Quick Notes Page [0-9]\n//gm' $output_dir/*.txt
