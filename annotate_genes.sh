#!/bin/bash

# This script annotates a bed file containing hg38 coordinates with overlapping gene name(s)
# Usage:  ./annotate_genes.sh <input_file> <output_file>
# Input is tab-separated with three columns chr<chromosome_number>, <start_position>, <end_position> (no header)

curl -s "http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/refGene.txt.gz" | gunzip -c | cut -f3,5,6,13 | sort-bed - > genes.bed

export HEADER='Chr\tStart\tEnd\tGene'

cat <(echo -e $HEADER) <(awk 'NR>1 {print $1"\t"$2"\t"$3}' $1 | bedmap --echo --echo-map-id-uniq - genes.bed | sed 's/|/\t/') > genes.temp

awk 'FNR==NR{a[$1,$2,$3]=$4;next} { print $0, a[$1,$2,$3]}' genes.temp $1 > $2

rm -f genes.temp
