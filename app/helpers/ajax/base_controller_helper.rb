module Ajax::BaseControllerHelper
  def distance latlng1, latlng2
    r = 6371000 # Earth radius
    rad = Math::PI / 180
    lat1 = latlng1[:lat] * rad
    lat2 = latlng2[:lat] * rad
    sinDLat = Math.sin((latlng2[:lat] - latlng1[:lat]) * rad / 2)
    sinDLng = Math.sin((latlng2[:lng] - latlng1[:lng]) * rad / 2)
    a = sinDLat * sinDLat + Math.cos(lat1) * Math.cos(lat2) * sinDLng * sinDLng
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    r * c
  end
end
