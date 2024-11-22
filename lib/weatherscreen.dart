import 'package:flutter/material.dart';
import 'package:weather_app/weather_service.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  final WeatherService weatherService = WeatherService();
  String query = "London";
  Map<String, dynamic>? weatherData;
  List<dynamic>? forecastData;
  bool isLoading = false;
  String? errorMessage;
  late AnimationController _controller;
  late Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fetchWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await weatherService.fetchCurrentWeather(query);
      final forecast = await weatherService.fetchForecast(query);
      setState(() {
        weatherData = data;
        forecastData = forecast['list'];
        isLoading = false;
        _controller.forward(from: 0); // Start animation
      });
      _animateBackground(data['main']['temp']);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _animateBackground(double temperature) {
    Color startColor = temperature > 70 ? Colors.orange[200]! : Colors.blue[200]!;
    Color endColor = temperature > 70 ? Colors.orange[400]! : Colors.blue[400]!;
    _backgroundColor = ColorTween(begin: startColor, end: endColor).animate(_controller);
    _controller.forward();
  }

  Widget _buildWeatherDetails() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      return Center(
        child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 18)),
      );
    } else if (weatherData == null) {
      return const Center(child: Text('Enter a city to get started!', style: TextStyle(fontSize: 18)));
    }

    final weather = weatherData!;
    return FadeTransition(
      opacity: _controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weather['name'],
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Image.network(
                'https://openweathermap.org/img/wn/${weather['weather'][0]['icon']}@2x.png',
                width: 100,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather['main']['temp']}°F',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    weather['weather'][0]['description'].toUpperCase(),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWeatherExtras(weather),
          const SizedBox(height: 20),
          const Text('5-Day Forecast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          _buildForecastCards(),
        ],
      ),
    );
  }

  Widget _buildWeatherExtras(Map<String, dynamic> weather) {
    final sunrise = DateTime.fromMillisecondsSinceEpoch(weather['sys']['sunrise'] * 1000);
    final sunset = DateTime.fromMillisecondsSinceEpoch(weather['sys']['sunset'] * 1000);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow('Humidity', '${weather['main']['humidity']}%'),
            _buildDetailRow('Wind Speed', '${weather['wind']['speed']} mph'),
            _buildDetailRow('Pressure', '${weather['main']['pressure']} hPa'),
            _buildDetailRow('Sunrise', DateFormat.jm().format(sunrise)),
            _buildDetailRow('Sunset', DateFormat.jm().format(sunset)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildForecastCards() {
    if (forecastData == null) return const SizedBox();
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastData!.length,
        itemBuilder: (context, index) {
          final forecast = forecastData![index];
          final dateTime = DateTime.parse(forecast['dt_txt']);
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(DateFormat.E().format(dateTime)),
                  const SizedBox(height: 5),
                  Image.network(
                    'https://openweathermap.org/img/wn/${forecast['weather'][0]['icon']}@2x.png',
                    width: 50,
                  ),
                  const SizedBox(height: 5),
                  Text('${forecast['main']['temp']}°F'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _backgroundColor,
        builder: (context, child) {
          return Container(
            color: _backgroundColor.value,
            child: Padding(
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
                    decoration: const InputDecoration(
                      labelText: 'Enter city name',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildWeatherDetails()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
