import scrapy
import re
import urllib
import json


class BerkeleyTimeSpider(scrapy.Spider):
    name = "berkeleytime"

    start_urls = [
        "https://www.berkeleytime.com/catalog/"
    ]

    def parse(self, response):
        # default strings are loaded into the base html file as an inline javascript
        default_string_el = response.xpath(".//script[contains(.,'defaultFilterString')]")
        if default_string_el:
            # scrape for general catalog + current sem filters
            filter_re = r'var defaultFilterString = \"(.*)\";'
            default_string_el = default_string_el[0].extract()
            default_filters = re.search(filter_re, default_string_el)

            try:
                default_filters = default_filters.group(1).split(",")
            except IndexError:
                raise Exception("Default filter strings not found.")

            filter_uri = "filter/?filters=" + "%2C".join(default_filters)
            catalog_url = response.url + filter_uri

            # no need for generator, just save the file
            catalog_response = urllib.urlopen(catalog_url).read()
            try:
                catalog_response = json.loads(catalog_response)
            except ValueError as e:
                print e
                raise Exception("Could not parse catalog response.")

            with open("bt_catalog.json", "w") as f:
                json.dump(catalog_response, f, indent=4)

            # scrape for course data (extra parse needed for units)
            for cr in catalog_response:
                # response.url is only berkeleytime.com
                course_id = cr["id"]
                course_url = response.urljoin("/catalog/course/" + str(course_id) + "/")
                print "Processing Course Url: {0}".format(course_url)
                yield scrapy.Request(course_url, callback=self.course_parse, meta={"cr": cr})

            # scrape for filter id's

            filter_div = response.xpath(".//div[@class='filter-list' and @id='req']")
            filter_li = filter_div.xpath(".//li[@class='searchable selectable filter']")

            filter_dict = {}

            category_re = r'data-category=\"(.*)\"\s'
            requirement_re = r'>(.*)<'
            id_re = r'id=\"(.*)\">'

            for fl in filter_li:
                fl = fl.extract()
                category = re.search(category_re, fl)
                requirement = re.search(requirement_re, fl)
                id = re.search(id_re, fl)

                try:
                    category = category.group(1)
                    requirement = requirement.group(1)
                    id = id.group(1)
                except IndexError:
                    raise Exception("Filter category or requirement or id not found.")

                filter_dict[requirement] = {"id": id, "category": category}

            # save the filter dictionary
            with open("bt_filter.json", 'w') as f:
                json.dump(filter_dict, f, indent=4)

    def course_parse(self, response):
        unit_el = response.xpath(".//span[@class='blocks units']")
        if unit_el:
            unit_el = unit_el[0].extract()
            unit_re = r'>(.*)<'

            unit = re.search(unit_re, unit_el)

            try:
                unit = unit.group(1)
            except IndexError:
                raise Exception("Unit not found for course.")

            response.meta["cr"]["unit"] = unit

            yield response.meta["cr"]
