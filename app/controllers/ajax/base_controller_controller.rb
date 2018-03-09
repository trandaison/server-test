require 'rest-client'
class Ajax::BaseControllerController < ApplicationController
  include Ajax::BaseControllerHelper
  def elevation
    result = []
    segments.each_with_index do |segment, i|
      k = samples segment[:latlngA], segment[:latlngB]
      response = RestClient.get("http://cm-stg.mapion.co.jp/geoapi/elev/json?path=#{segment[:param]}&sample=#{k}&dtm=tky&island=0")
      body = JSON.parse response.body, symbolize_names: true
      data = body[:result].map do |point|
        {
          y: point[:elevation].to_f,
          lat: point[:location][:lat].to_f,
          lng: point[:location][:lng].to_f
        }
      end
      data.pop unless i == (segments.size - 1)
      result.concat data
    end
    render json: {data: result}, status: 200
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
          latlngA: latlngA,
          latlngB: latlngB,
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
