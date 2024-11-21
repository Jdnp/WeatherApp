// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'b3ae5d23891e6d29f5f46b12a277be8e';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<dynamic> fetchCurrentWeather(String query) async {
    final url = '$baseUrl/weather?q=$query&appid=$apiKey&units=imperial';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
