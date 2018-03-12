require 'rest-client'
require 'parallel'
require 'net/http'
require 'json'

class Ajax::BaseControllerController < ApplicationController
  include Ajax::BaseControllerHelper
  END_POINT = "http://cm-stg.mapion.co.jp/geoapi/elev/json".freeze

  def elevation
    ret = Parallel.map_with_index(segments, in_process: 2) do |segment, i|
      begin
        uri = URI.parse "#{END_POINT}?path=#{segment[:param]}&sample=#{segment[:samples]}&dtm=wgs"
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
          http.open_timeout = 10
          http.read_timeout = 10
          http.get(uri.request_uri)
        end
        if response.code == "200"
          body = JSON.parse(response.body, symbolize_names: true)
          body[:result].shift unless i == 0
          body[:result]
        end
      rescue => e
        p e
      end
    end
    ret.flatten!
    distance = 0
    ret.map! do |item|
      distance += item[:distance].to_f
      {
        y: item[:elevation].to_f == -9999 ? 0 : item[:elevation].to_f,
        x: distance,
        lat: item[:location][:lat].to_f,
        lng: item[:location][:lng].to_f,
      }
    end
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
