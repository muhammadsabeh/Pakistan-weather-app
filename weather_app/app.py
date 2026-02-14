from flask import Flask, render_template, request
import subprocess
import json

app = Flask(__name__)

# Dictionary of major Pakistani cities with their coordinates
PAKISTAN_CITIES = {
    "lahore": {"lat": 31.5204, "lon": 74.3587},
    "karachi": {"lat": 24.8607, "lon": 67.0011},
    "islamabad": {"lat": 33.6844, "lon": 73.0479},
    "peshawar": {"lat": 34.0151, "lon": 71.5249},
    "faisalabad": {"lat": 31.4181, "lon": 72.0788},
    "multan": {"lat": 30.2065, "lon": 71.4455},
    "hyderabad": {"lat": 25.3548, "lon": 68.3639},
    "quetta": {"lat": 30.1798, "lon": 66.9750},
    "rawalpindi": {"lat": 33.5793, "lon": 73.1496},
    "sialkot": {"lat": 32.4915, "lon": 74.5202},
}


def get_weather_via_curl(lat, lon, city_name):
    """Fetch weather using curl command to call Open-Meteo API"""
    try:
        cmd = f'curl -s "https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,weather_code,humidity,wind_speed_10m"'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        
        if result.returncode == 0:
            data = json.loads(result.stdout)
            current = data.get("current", {})
            
            # Weather code mapping (WMO codes)
            weather_descriptions = {
                0: "Clear sky",
                1: "Mainly clear", 2: "Partly cloudy", 3: "Overcast",
                45: "Foggy", 48: "Depositing rime fog",
                51: "Light drizzle", 53: "Moderate drizzle", 55: "Dense drizzle",
                61: "Slight rain", 63: "Moderate rain", 65: "Heavy rain",
                71: "Slight snow", 73: "Moderate snow", 75: "Heavy snow",
                80: "Slight rain showers", 81: "Moderate rain showers", 82: "Violent rain showers",
                85: "Slight snow showers", 86: "Heavy snow showers",
                95: "Thunderstorm", 96: "Thunderstorm with slight hail", 99: "Thunderstorm with heavy hail"
            }
            
            weather_code = current.get("weather_code", 0)
            description = weather_descriptions.get(weather_code, "Unknown")
            
            return {
                "city": f"{city_name}, Pakistan",
                "temp": round(current.get("temperature_2m", 0), 1),
                "description": description,
                "humidity": current.get("humidity", 0),
                "wind": round(current.get("wind_speed_10m", 0), 1),
                "icon": None
            }
        else:
            return None
    except Exception as e:
        raise Exception(f"Curl error: {str(e)}")


@app.route("/", methods=["GET", "POST"])
def index():
    weather = None
    error = None
    if request.method == "POST":
        city = request.form.get("city", "").strip()
        if not city:
            error = "Please enter a city name."
        else:
            city_lower = city.lower()
            if city_lower not in PAKISTAN_CITIES:
                available = ", ".join([c.capitalize() for c in PAKISTAN_CITIES.keys()])
                error = f"City not found. Available cities: {available}"
            else:
                try:
                    coords = PAKISTAN_CITIES[city_lower]
                    weather = get_weather_via_curl(coords["lat"], coords["lon"], city.capitalize())
                    if weather is None:
                        error = "Failed to fetch weather data. Please try again."
                except Exception as exc:
                    error = f"Error: {str(exc)}"

    return render_template("index.html", weather=weather, error=error)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
