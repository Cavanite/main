import requests

API_KEY = 'https://api.openweathermap.org/data/2.5/weather?lat=44.34&lon=10.99&appid={API key}'

def get_weather(location):
    url = f'http://api.openweathermap.org/data/2.5/weather?q={location}&appid={API_KEY}'
    response = requests.get(url)
    if response.status_code == 200:
        weather_data = response.json()
        return weather_data
    else:
        return None


def display_weather(weather_data):
    if weather_data is not None:
        main_weather = weather_data['weather'][0]['main']
        description = weather_data['weather'][0]['description']
        temperature = weather_data['main']['temp']
        humidity = weather_data['main']['humidity']
        print(f"Weather: {main_weather} ({description})")
        print(f"Temperature: {temperature} K")
        print(f"Humidity: {humidity}%")
    else:
        print("Unable to retrieve weather information.")

def main():
    location = input("Enter a location: ")
    weather_data = get_weather(location)
    display_weather(weather_data)

if __name__ == '__main__':
    main()
