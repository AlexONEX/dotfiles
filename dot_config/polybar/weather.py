import requests
import json

# Script to automatically get the current city
city = ""
try:
    city = requests.get("http://ip-api.com/json").json()["city"]
except:
    city = "Ciudad de Buenos Aires"

api_key = "76c37aca22b3abee4f068749eb0eacb9"
units = "metric" # {imperial or metric}
temperature_unit = "C" # Units of measurement. That will be showed in UI. Does not affect on API.

icons_list = {
    "01d": "", # Clear sky day.
    "01n": "望", # Clear sky night.
    "02d": "", # Few clouds day.
    "02n": "", # Few clouds night.
    "03d": "", # Scattered clouds day.
    "03n": "", # Scattered clouds night.
    "04d": "", # Broken clouds day.
    "04n": "", # Broken clouds night.
    "09d": "歹", # Shower rain day.
    "09n": "歹", # Shower rain night.
    "10d": "", # Rain day.
    "10n": "", # Rain night
    "11d": "", # Thunderstorm day.
    "11n": "", # Thunderstorm night
    "13d": "", # Snow day. Snowflake alternative: 
    "13n": "", # Snow night. Snowflake alternative: 
    "50d": "", # Mist day.
    "50n": "", # Mist night.
}

atmophere_icons_list = {
    701: "", # Mist
    711: "", # Smoke
    721: "", # Haze
    731: "", # Dust (Sand / dust whirls)
    741: "", # Fog
    751: "", # Sand
    761: "", # Dust
    762: "", # Ash
    771: "", # Squalls
    781: ""  # Tornado
}

def main():
    try:
        url = ('http://api.openweathermap.org/data/2.5/weather?q={}&units={}&appid={}').format(city, units, api_key)
        result = requests.get(url)
        if(result.status_code == requests.codes['ok']):
                weather = result.json()

                # Get info from array
                id = int(weather['weather'][0]['id'])
                group = weather['weather'][0]['main'].capitalize()
                icon = weather['weather'][0]['icon'].capitalize()
                temp = int(float(weather['main']['temp']))

                # Load another icons for Atmosphere group
                if(group == "Atmosphere"):
                    return atmophere_icons_list[id] + '{}°{}'.format(temp, temperature_unit)

                return icons_list[icon] + '  {}°{}'.format(temp, temperature_unit)
        else:
            return "" # Return reload icon
    except:
        return "" # Return reload icon

if __name__ == "__main__":
	print(main())
