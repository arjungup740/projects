import scrapy


class QuotesSpider(scrapy.Spider):
    name = "quotes" # identifies the spider -- must be unique within a project

    def start_requests(self): 
        # must return an iterable of Requests which the spider will begin to crawl from
        # subsequent requests will be generated successively from these initial requests
        urls = [
            'http://quotes.toscrape.com/page/1/',
            'http://quotes.toscrape.com/page/2/',
        ]
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)

    def parse(self, response):
        # a method that will be called to handled the response downloaded for each request made
        page = response.url.split("/")[-2] # this is grabbing the page number
        filename = 'quotes-%s.html' % page # this is a sprintf basically, passing the page number to the filename
        with open(filename, 'wb') as f:
            f.write(response.body)
        self.log('Saved file %s' % filename)