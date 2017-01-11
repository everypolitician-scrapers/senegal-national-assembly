#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  h2 = noko.xpath('//h2[span[@id="Liste_des_d.C3.A9put.C3.A9s"]]')
  h2.xpath('following-sibling::h2 | following-sibling::h3').slice_before { |e| e.name == 'h2' }.first.each do |h3|
    h3.xpath('following-sibling::ul[1]/li').each do |li|
      name, party = li.text.tidy.split(/,\s+/, 2)
      data = {
        name:     name,
        party:    party,
        wikiname: li.xpath('.//a[not(@class="new")]/@title').text,
        term:     2012,
        type:     h3.xpath('span[1]').text,
        source:   url,
      }
      # puts data[:name]
      ScraperWiki.save_sqlite(%i(name party term), data)
    end
  end
end

scrape_list('https://fr.wikipedia.org/wiki/Liste_des_d%C3%A9put%C3%A9s_du_S%C3%A9n%C3%A9gal_%C3%A9lus_en_2012')
