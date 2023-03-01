import 'dart:convert';

import 'package:flutter/material.dart';

import 'models/Pais.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Pais>>? _listadoPaises;

  Future<List<Pais>> _getPaises() async {
    final response =
        await http.get(Uri.parse('https://restcountries.com/v2/all'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((paisData) => Pais(
              nombre: paisData['name'],
              capital: paisData['capital'] ?? '',
              URLbandera: paisData['flags']['png']))
          .toList();
    } else {
      throw Exception('Error de conexion');
    }
  }

  @override
  void initState() {
    super.initState();
    _listadoPaises = _getPaises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paises API'),
      ),
      body: FutureBuilder<List<Pais>>(
        future: _getPaises(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final paises = snapshot.data!;
            return ListView.builder(
              itemCount: paises.length,
              itemBuilder: (context, index) {
                final pais = paises[index];
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.network(pais.URLbandera)),
                    title: Text(pais.nombre),
                    subtitle: Text(pais.capital),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
