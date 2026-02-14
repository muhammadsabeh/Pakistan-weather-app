# Pakistan Weather App (Python / Flask)

Simple Flask app to search for current weather in Pakistani cities using OpenWeatherMap.

Requirements
- Python 3.8+
- An OpenWeatherMap API key (free tier available at https://openweathermap.org/)

Setup

1. Create a virtual environment and install dependencies:

```bash
python -m venv .venv
.
# Windows PowerShell (activate):
.\.venv\Scripts\Activate.ps1
# or cmd.exe:
.\.venv\Scripts\activate.bat
pip install -r requirements.txt
```

2. Configure your API key (one of these options):

- Copy `.env.example` to `.env` and set `OPENWEATHER_API_KEY`.
- Or set an environment variable. Example (PowerShell, current session):

```powershell
$env:OPENWEATHER_API_KEY = "bd5e378503939ddaee76f12ad7a97608"
```

3. Run the app:

```bash
python app.py
```

4. Open http://127.0.0.1:5000 in your browser and search a Pakistani city (e.g., Lahore, Karachi).

Notes
- The app forces country code `,PK` when querying so results are for Pakistan.
- For production, disable `debug` and use a real WSGI server.
