#!/usr/bin/env ruby
# coding: utf-8
require 'yaml'
require 'optparse'
require 'logger'
require_relative 'amazon'

class BookInfo
  def initialize
    @log = Logger.new($stderr)
    @log.level = Logger::WARN
  end

  def run
    parse_options

    input = $stdin
    output = $stdout
    attrs = [:isbn, :author, :manufacturer, :title, :image_uri]
    isbn_list = input.read.split.map(&:to_i)

    amazon = Amazon.new(read_config)
    write_header(output, attrs) if @header
    amazon.each_books(isbn_list) do |info|
      @log.info "Fetched: #{info[:isbn]}"
      write_row(output, attrs, info)
    end
  end

  def parse_options
    opt = OptionParser.new
    opt.on('-v', '--verbose') { @log.level = Logger::INFO }
    opt.on('--header') { @header = true }
    opt.parse!(ARGV)
  end

  def read_config
    YAML.load(IO.read(File.dirname(__FILE__) + '/config.yml'))
  end

  def write_header(output, attrs)
    output.puts attrs.join("\t")
  end

  def write_row(output, attrs, info)
    output.puts info.values_at(*attrs).join("\t")
  end
end

BookInfo.new.run
