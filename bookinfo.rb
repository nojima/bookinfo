#!/usr/bin/env ruby
# coding: utf-8
require 'yaml'
require 'pp'
require_relative 'amazon'

class BookInfo
  def read_config
    config = YAML.load(IO.read(File.dirname(__FILE__) + '/config.yml'))
  end

  def run
    amazon = Amazon.new(read_config)
    isbn_list = [9784944178216, 9784101050157, 9784894711631]

    amazon.each_books(isbn_list) do |info|
      pp info
    end
  end
end

BookInfo.new.run
