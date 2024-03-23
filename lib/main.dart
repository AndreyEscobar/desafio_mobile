import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Desafio CAIXA'),
      ),


      body: const MyCustomForm(),

    );
  }
}



// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();


  bool validarAlfanumerico(String value) {
    RegExp regex = RegExp(r"^[\p{L}\p{N}]+$", unicode: true);
    return (!regex.hasMatch(value)) ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            maxLength: 20,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Apelido',
            ),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor digite um apelido.';
              }
              else if (value.length < 3 ) {
                return 'Apelido deve possuir tamanho maior que 3 caracateres.';
              }
              else if  (!validarAlfanumerico(value)) {
                return 'Apelido deve ser alfa-numérico.' ;
              }
              else {
                return 'Apelido Válido.' ;
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ),

          Center(
            child: ElevatedButton(
              child: const Text('Abrir Nova Tela'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondRoute()),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}





///SEGUNDA TELA

class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key});


  @override
  State<SecondRoute> createState() => _MyAppState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}


class _MyAppState extends State<SecondRoute> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSONPlaceholder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('JSONPlaceholder'),
        ),



        body:
        ListView(


                        children: [

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Retornar Tela!'),

                                ),


                                FutureBuilder<Album>(
                                  future: futureAlbum,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(snapshot.data!.title);
                                    } else if (snapshot.hasError) {
                                      return Text('${snapshot.error}');
                                    }

                                    // By default, show a loading spinner.
                                    return const CircularProgressIndicator();
                                  },
                                ),


                        ]

        ),

      ),
    );
  }
}




Future<Album> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/98'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'userId': int userId,
      'id': int id,
      'title': String title,
      } =>
          Album(
            userId: userId,
            id: id,
            title: title,
          ),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}