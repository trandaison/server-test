var app = new Vue({
  el: '#app',
  data: {},
  mounted: () => {
    const LAT = lat || 35.68949391611575, LNG = lng || 139.6917173266411, Z = z || 16;
    const DEFAULT_POS = new L.LatLng(lat, lng);
    var map = L.map('map', {
      zoomControl: false,
      scrollWheelZoom: 'center',
      doubleClickZoom: 'center',
      zoomAnimation: false,
      attributionControl: false
    }).setView(DEFAULT_POS, Z);
    L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
      maxZoom: 19,
      minZoom: 6,
      id: 'mapbox.streets',
    }).addTo(map);
  },
});
