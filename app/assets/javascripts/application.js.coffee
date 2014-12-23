# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require bootstrap
#= require leaflet
#= require leaflet.markercluster



@populateMarkers = ->
  markers.clearLayers()

  area_number = $('#area_number').val()
  crime_code = $('#crime_code').val()

  $.getJSON('/incidents.json', {area_number, crime_code}).done (incidents) ->
    popup = L.popup()

    icon = L.icon {iconUrl, shadowUrl}

    for i in incidents when i.latitute? and i.longitude?
      (->
        incident = i
        marker = L.marker([incident.latitute, incident.longitude], {icon})
        markers.addLayer(marker).addTo(map).on 'click', (e) ->
          popup.setLatLng(e.latlng)
            .setContent("<p>#{incident.location}<br><a href=\"/incidents/#{incident.id}\" target=\"_blank\">Open in new page</a></p>")
            .openOn(map);
      )()


ready = ->
  $('form select').on 'change', populateMarkers


$(document).ready ready
$(document).on 'page:load', ready
