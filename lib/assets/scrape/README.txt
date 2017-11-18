To use the scraper, simply run ./scrape.sh with the following options

	-h : scrapes HKN's course survey guide for all the ratings

	-b : scrapes Berkeleytime's course catalog and the associated courses for units

Each run will create a new directory with the following format: run_<datetime>/
and will store all files generated from the scrape in said directory

Examples:
To scrape only HKN:
	./scrape.sh -h
To scrape only Berkeleytime:
	./scrape.sh -b
To scrape both HKN and Berkeleytime:
	./scrape.sh -h -b

