import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String? _weather;
  String? _address;
  bool _loading = false;
  String? _error;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _getLocationAndFetch();
  }

  Future<void> _getLocationAndFetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled.';
          _loading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permissions are denied.';
            _loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permissions are permanently denied.';
          _loading = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
      await _fetchWeatherAndAddress();
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _fetchWeatherAndAddress() async {
    try {
      // Fetch weather
      final weatherUrl = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true');
      final weatherResponse = await http.get(weatherUrl);
      if (weatherResponse.statusCode == 200) {
        final data = json.decode(weatherResponse.body);
        final temp = data['current_weather']['temperature'];
        final wind = data['current_weather']['windspeed'];
        _weather = 'Temperature: $temp°C\nWind Speed: $wind km/h';
      } else {
        setState(() {
          _error = 'Failed to fetch weather';
          _loading = false;
        });
        return;
      }
      // Fetch address
      final addressUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude');
      final addressResponse =
          await http.get(addressUrl, headers: {'User-Agent': 'FlutterApp'});
      if (addressResponse.statusCode == 200) {
        final addressData = json.decode(addressResponse.body);
        _address = addressData['display_name'] ?? 'Unknown location';
      } else {
        _address = 'Unknown location';
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2196F3);
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF6EC6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: _loading
              ? Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _error != null
                  ? Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          _error!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _weather != null || _address != null
                      ? Card(
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          color: Colors.white.withOpacity(0.95),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32.0, vertical: 36.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Weather Icon
                                Icon(
                                  _weather != null && _weather!.contains('°C')
                                      ? Icons.wb_sunny_rounded
                                      : Icons.cloud,
                                  color: primaryColor,
                                  size: 64,
                                ),
                                const SizedBox(height: 24),
                                if (_address != null)
                                  Text(
                                    _address!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                if (_weather != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    _weather!.split('\n')[0], // Temperature
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _weather!.split('\n').length > 1
                                        ? _weather!.split('\n')[1]
                                        : '', // Wind
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : const Text('No data',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.refresh),
        onPressed: _getLocationAndFetch,
        tooltip: 'Refresh',
      ),
    );
  }
}
