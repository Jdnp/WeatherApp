import 'package:flutter/material.dart';
import 'package:weather_app/Weather_Services.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService weatherService = WeatherService();
  String query = "London"; // Default Query
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  void fetchWeatherData() async {
    try {
      final data = await weatherService.fetchCurrentWeather(query);
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onSubmitted: (value) {
                setState(() {
                  query = value;
                });
                fetchWeatherData();
              },
              decoration: InputDecoration(
                labelText: 'Enter city,state or zip code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            weatherData == null
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      Text(
                        'City: ${weatherData!['name']}',
                        style: TextStyle(fontSize: 24),
                      ),
                      if (query.contains(','))
                        Text(
                          'State: ${query.split(',').length > 1 ? query.split(',')[1].trim() : 'N/A'}',
                          style: TextStyle(fontSize: 18),
                        ),
                      Text(
                        'Temperature: ${weatherData!['main']['temp']}°F',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Weather: ${weatherData!['weather'][0]['description']}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
            SizedBox(height: 20),
            Text('Current Weather: $query'),
          ],
        ),
      ),
    );
  }
}
