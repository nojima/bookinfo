#!/usr/bin/env ruby
# coding: utf-8
require 'uri'
require 'open-uri'
require 'digest/hmac'
require 'rexml/document'

class Amazon
  # config として与えられた key, secret, assoc_tag を指定して初期化する
  def initialize(config)
    @key = config["key"]
    @secret = config["secret"]
    @assoc_tag = config["assoc_tag"]
  end

  # 指定された ISBN の本の情報を取得する
  def each_books(isbn_list)
    max_request_isbn_count = 10

    isbn_list.each_slice(max_request_isbn_count) do |isbns|
      uri = signed_uri(@key, @secret,
              Service: "AWSECommerceService",
              Version: "2010-11-01",
              Operation: "ItemLookup",
              IdType: "ISBN",
              ResponseGroup: "Small,Images",
              ItemId: isbns.join(','),
              SearchIndex: "Books",
              AssociateTag: @assoc_tag)

      open(uri) do |result|
        xml = result.read
        doc = REXML::Document.new(xml)
        index = 0
        doc.elements.each("/ItemLookupResponse/Items/Item") do |item|
          info = { isbn: isbns[index] }
          [:author, :manufacturer, :title].each do |attr|
            info[attr] = get_text_if_exists(item, "ItemAttributes/#{attr.capitalize}")
          end
          info[:image_uri] = get_text_if_exists(item, "LargeImage/URL")
          yield info
          index += 1
        end
      end
    end
    self
  end

  def get_text_if_exists(item, selector)
    e = item.elements[selector]
    e && e.text && e.text.gsub("\t", " ")
  end

  # Amazon API 用に URI escape を行う
  def escape(str)
    URI.escape(str, /[^A-Za-z0-9\-_.~]/)
  end

  # 署名された URI を返す
  def signed_uri(access_key, secret_key, params)
    request_uri = '/onca/xml'
    endpoint = 'ecs.amazonaws.jp'

    params[:AWSAccessKeyId] = access_key
    params[:Timestamp] = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
    canonical = params.map{|k, v| "#{k}=#{escape(v)}"}.sort.join('&')
    str = "GET\n" + endpoint + "\n" + request_uri + "\n" + canonical
    sig = escape(Digest::HMAC.base64digest(str, secret_key, Digest::SHA256))
    "http://#{endpoint}#{request_uri}?#{canonical}&Signature=#{sig}"
  end
end
