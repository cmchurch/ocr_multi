timestamp() {
date +"%F_%T"
}

#create temp directory if it doesn't exist
mkdir -p temp

#create ocr_output directory if it doesn't exist
mkdir -p ocr_output

for i in *.pdf ; do 
  echo "Converting " $i 
  convert -background white -alpha remove -density 300 "$i" -depth 8 temp/file-%04d.tiff #use this for any files that are not from google news (i.e. proquest)
  #convert -transparent white -density 300 "$i" -depth 8 file-%04d.tiff #use this for any files that are from google news and have a white border

  for x in file-*.tiff; do
    #echo "Text Cleaning..." $x 
    #sh textcleaner -g -e stretch -f 25 -o 10 -u -s 1 -T -p 10 $x clean.tif
    echo "Scanning" $x 
    tesseract -c "tessedit_write_images=T" $x temp/$x
    cat temp/$x.txt >> ocr_output/$i.txt
    #clean up our temporary files
    rm temp/$x 
    rm temp/$x.txt
    rm temp/tessinput.tif
  done
  echo $(timestamp) ": "  $i " scanned.\n" >> log.log 
done


#now loop over all the scanned files and clean them (remove unnessary newlines, delete page numbers from OneNote, collapse hyphenated words
#remove all newlines that are not blank lines with perl in paragraph mode with regex
perl -p -i'.bak' -00 -lpe 'tr/\n/ /d' ocr_output/*.txt

#collapse all hypenated words with regex
perl -p -i -e 's/-\s//gm' ocr_output/*.txt

#if it exists, remove the quick notes page numbers from OneNote exported files
perl -p -i -e 's/Quick Notes Page [0-9]\n//gm' ocr_output/*.txt
