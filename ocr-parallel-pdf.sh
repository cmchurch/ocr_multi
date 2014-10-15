#!/bin/bash 
#params $infile $page

#Check for Dependencies
type convert >/dev/null 2>&1 || { echo >&2 "Imagemagick is not installed. apt-get install imagemagick"; exit 1; }
type tesseract >/dev/null 2>&1 || { echo >&2 "Tesseract is not installed.  apt-get install tesseract-ocr"; exit 1;}
type pdfinfo >/dev/null 2>&1 || { echo >&2 "Pdfinfo is not installed. apt-get install poppler-utils."; exit 1;}
type parallel >/dev/null 2>&1 || { echo >&2 "GNU Parallel is not installed. apt-get install parallel"; exit 1;}


#Function definitions
convert_and_scan() {
        infile="$1"
        page="$2"
        outdir="$3"
        outfile="$infile"_"$page"_temp
        convert -background white -alpha remove -density 300 "$infile[$page]" -depth 8 "$outfile".tiff
        tesseract -l fra  "$outfile".tiff "$outdir"/"$outfile"
        rm "$outfile".tiff
}


export -f convert_and_scan

mkdir ocr_output



#main loop
for pdf in *.pdf; do
  numpages=$(pdfinfo "$pdf" 2>/dev/null | grep Pages | cut -d ":" -f 2)
  numpages=$((numpages--))
  pdf_out=$pdf"_out"
  mkdir "$pdf_out"
  parallel --gnu convert_and_scan ::: $pdf ::: $(seq 0 $numpages) ::: $pdf_out
  for txt in $pdf_out/*.txt; do
        cat $txt >> ocr_output/$pdf.txt
  done
done

