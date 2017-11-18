import scrapy
import json
import re


class HKNSpider(scrapy.Spider):
    name = "hkn"

    start_urls = [
        "https://hkn.eecs.berkeley.edu/coursesurveys/chartinfo"
    ]

    def parse(self, response):
        data = json.loads(response.body)

        with open("hkn_courses.json", "w") as f:
            json.dump(data, f, indent=4)

        types = {"ee_courses": "EE", "cs_courses": "CS"}
        course_dict = {}
        base_url = "https://hkn.eecs.berkeley.edu"

        for t in types:
            for course in data[t]:
                course_name = types[t] + course["name"]
                course_url = base_url + course["link"]
                course_dict[course_name] = {"url": course_url}
                if course_url:
                    print "Processing Course Url: {0}".format(course_url)
                    yield scrapy.Request(course_url, callback=self.course_parse, meta={"cn": course_name})

    def course_parse(self, response):
        table_id = "\'ratings\'"
        table = response.xpath(".//table[@id=" + table_id + "]")

        col_headers = ["Sections", "Instructor", "Teaching Effectiveness", "How worthwhile was this course?"]
        stop = "Overall Rating"

        if len(table) == 1:
            table = table[0]
            sem_dict = {}
            sem_re = re.compile("[Fall, Spring, Summer]+\s+\d{4}")
            denominator = 7
            labels = ["Teaching Effectiveness", "How worthwhile was this course?"]
            denominator_str = "/ 7"

            sem = None
            instructor = None
            point_list = []
            for rt in table.xpath(".//text()").extract():
                rt = rt.strip()
                if rt:
                    if rt == stop:
                        break
                    elif sem_re.match(rt):
                        sem = rt
                        sem_dict[sem] = {}
                    else:
                        if sem in sem_dict:
                            if rt not in col_headers:
                                if rt != denominator_str:
                                    try:
                                        point_list.append(float(rt))
                                    except ValueError:
                                        if point_list and instructor:
                                            sem_dict[sem][instructor] = point_list
                                        instructor = rt
                                        point_list = []

            yield {"course": response.meta["cn"], "semesters": sem_dict, "denominator": denominator, "labels": labels}
