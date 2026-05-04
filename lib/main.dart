import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta roja de "Debug"
      title: 'Clima App',
      home: const WeatherScreen(),
    );
  }
}

//Cambia en tiempo de ejecución
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Variable para almacenar la respuesta
  late Future<Map<String, dynamic>> weatherData;

  //datos ingreso
  //https://api.openweathermap.org
  //JmbA.00.OPE
  // Reemplazar API KEY de OpenWeatherMap
  //final String apiKey = "9028ff0875ae5dc99781e35d2355543f";
  //final String city = "Zapopan";
  // Controlador para la barra de búsqueda
  final TextEditingController _cityController = TextEditingController();

  // Ciudad por defecto al iniciar
  String currentCity = "Zapopan";

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final String apiKey = "9028ff0875ae5dc99781e35d2355543f";
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=es',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Si la API falla o la ciudad no existe, mostramos el error
      throw Exception('No se encontró la ciudad o error de API');
    }
  }

  @override
  void initState() {
    super.initState();
    weatherData = fetchWeather(currentCity);
  }

  // Función para disparar la búsqueda
  void _searchCity() {
    if (_cityController.text.isNotEmpty) {
      setState(() {
        currentCity = _cityController.text;
        weatherData = fetchWeather(currentCity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clima Global"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // UI de la Barra de Búsqueda
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: "Escribe una ciudad...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _searchCity, // Buscar al presionar el icono
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (_) => _searchCity(), // Buscar al presionar "Enter"
            ),

            const SizedBox(height: 20),

            // Contenedor del Clima
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: weatherData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Ciudad no encontrada",
                        style: TextStyle(color: Colors.red[400], fontSize: 18),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          elevation: 8,
                          shadowColor: Colors.blue.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                              children: [
                                Text(
                                  data['name'],
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.cloud,
                                  size: 100,
                                  color: Colors.blue,
                                ),
                                Text(
                                  "${data['main']['temp']}°C",
                                  style: const TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Text(
                                  data['weather'][0]['description']
                                      .toString()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ...
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
