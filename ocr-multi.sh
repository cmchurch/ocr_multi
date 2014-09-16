for i in *.pdf ; do 
  echo "Converting " $i 
  convert -background white -alpha remove -density 300 "$i" -depth 8 file-%04d.tiff
  for x in file-*.tiff; do
    #echo "Text Cleaning..." $x 
    #sh textcleaner -g -e stretch -f 25 -o 10 -u -s 1 -T -p 10 $x clean.tif
    echo "Scanning" $x 
    tesseract $x $x
    cat $x.txt >> ocr_output/$i.txt
    rm $x 
    rm $x.txt
  done
  echo $i " scanned.\n" >> ocr_output/log.log 
done


#now loop over all the scanned files and clean them (remove unnessary newlines, delete page numbers from OneNote, collapse hyphenated words
#remove all newlines that are not blank lines with perl in paragraph mode with regex
perl -p -i'.bak' -00 -lpe 'tr/\n/ /d' ocr_output/*.txt

#collapse all hypenated words with regex
perl -p -i -e 's/-\s//gm' ocr_output/*.txt

#if it exists, remove the quick notes page numbers from OneNote exported files
perl -p -i -e 's/Quick Notes Page [0-9]\n//gm' ocr_output/*.txt
