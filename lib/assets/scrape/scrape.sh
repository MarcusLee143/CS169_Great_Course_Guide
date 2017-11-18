#!/bin/bash

h=false
b=false

dt="$(date "+%Y-%m-%d_%H_%M_%S")"

while getopts ":h :b" o; do
    case "${o}" in
        h)
            h=true;;
        b)
			b=true;;
    esac
done

echo "============================"
echo "Scraping HKN: $h"
echo "Scraping Berkeleytime: $b"
echo "Date/Time: $dt"
echo "============================"

echo "Script starting in 3 seconds. Press CTRL+C to quit now."
sleep 1
sleep 1
sleep 1

echo "Created directory: scrape_$dt"
FILEDIR="run_$dt"
mkdir $FILEDIR

if $h; then
	echo "Starting HKN scrape"
	HKNFILE="hkn_data.json"
	HKNFILE1="hkn_courses.json"
	scrapy crawl hkn -o $HKNFILE
	echo "Moving HKN files"
	mv $HKNFILE $FILEDIR
	mv $HKNFILE1 $FILEDIR
	echo
fi

if $b; then
	echo "Starting Berkeleytime scrape"
	BTFILE="bt_data.json"
	BTFILE1="bt_catalog.json"
	BTFILE2="bt_filter.json"
	scrapy crawl berkeleytime -o $BTFILE
	echo "Moving Berkeleytime files"
	mv $BTFILE $FILEDIR
	mv $BTFILE1 $FILEDIR
	mv $BTFILE2 $FILEDIR
	echo
fi

echo "============================"
echo "SUMMARY"
echo "============================"

cd $FILEDIR

if $h; then
	echo "HKN Files:"
	ls hkn_*
	echo 
fi

if $b; then
	echo "Berkeleytime Files:"
	ls bt_*
	echo
fi

echo "Scraping done"