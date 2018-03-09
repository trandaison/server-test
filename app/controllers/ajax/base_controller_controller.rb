require 'rest-client'
require 'parallel'
require 'net/http'
require 'json'

class Ajax::BaseControllerController < ApplicationController
  include Ajax::BaseControllerHelper

  def elevation
    end_point = "http://cm-stg.mapion.co.jp/geoapi/elev/json"
    ret = Parallel.map(segments, in_process: 2) do |segment|
      begin
        uri = URI.parse "#{end_point}?path=#{segment[:param]}&sample=#{segment[:samples]}&dtm=wgs"
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") {|http|
          http.open_timeout = 10
          http.read_timeout = 10
          http.get(uri.request_uri)
        }
        if response.code == "200"
          result = JSON.parse(response.body, symbolize_names: true)[:result].map do |res|
            {
              y: res[:elevation].to_f == -9999 ? 0 : res[:elevation].to_f,
              lat: res[:location][:lat].to_f,
              lng: res[:location][:lng].to_f
            }
          end
          result
        end
      rescue => e
        p e
      end
    end
    ret.flatten!
    render json: {data: ret}, status: 200
  end

  private
  def segments
    data = JSON.parse params[:latlngs], symbolize_names: true
    result = []
    data.each_with_index do |latlngA, index|
      if index < (data.size - 1)
        latlngB = data[index + 1]
        result << {
          param: "#{latlngA[:lng]},#{latlngA[:lat]}|#{latlngB[:lng]},#{latlngB[:lat]}",
          samples: samples(latlngA, latlngB)
        }
      end
    end
    result
  end

  def samples latlngA, latlngB
    length = distance latlngA, latlngB
    (length / 100).ceil
  end
end
