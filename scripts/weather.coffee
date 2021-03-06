# Description:
#   Look up weather information
#
# Commands:
#
#   hubot weather <location> - look up weather at location (in google-understandable format)
#
# Configuration:
#
# HUBOT_WEATHER_APIKEY = forecast.io api key
module.exports = (robot) ->

  robot.respond /weather *(.+)/i, (msg) ->
    location = escape(msg.match[1])
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}"
    msg.http(url).get() (err, res, body) ->
      msg.send err if err
      try
        json = JSON.parse(body)
        lat = json.results[0].geometry.location.lat
        lng = json.results[0].geometry.location.lng
        msg.send "Forecast for #{json.results[0].formatted_address}:"
      catch error
        msg.send "Error parsing location"
        msg.send error
        return
      apikey = process.env.HUBOT_WEATHER_APIKEY
      forecasturl = "https://api.forecast.io/forecast/#{apikey}/#{lat},#{lng}"
      msg.http(forecasturl).get() (err, res, body) ->
        msg.send err if err
        try
          json = JSON.parse(body)
          msg.send "Currently: #{json.currently.summary}, #{json.currently.temperature} °F, feels like #{json.currently.apparentTemperature} °F"
          msg.send "Next hour: #{json.minutely.summary}"
          msg.send "Today: #{json.daily.data[0].summary} H: #{json.daily.data[0].temperatureMax} °F L: #{json.daily.data[0].temperatureMin} °F"
          msg.send "Tomorrow: #{json.daily.data[1].summary} H: #{json.daily.data[1].temperatureMax} °F L: #{json.daily.data[1].temperatureMin} °F"
          if json.alerts
            for alert in json.alerts
              msg.send "#{alert.title} - #{alert.uri}"
        catch error
          msg.send "Failed to retrieve forecast."
        