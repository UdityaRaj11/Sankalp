import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sankalp/models/note.dart';
import 'package:sankalp/screens/tabs_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NoteModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sankalp',
        theme: ThemeData(
          canvasColor: const Color.fromARGB(255, 173, 237, 175),
          fontFamily: 'Raleway',
          textTheme: ThemeData.light().textTheme.copyWith(
                bodyLarge: const TextStyle(
                  color: Color.fromRGBO(20, 51, 25, 1),
                ),
                bodyMedium: const TextStyle(
                  color: Color.fromRGBO(20, 51, 27, 1),
                ),
                titleLarge: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'RobotoCondensed',
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        routes: {
          '/': (ctx) => TabsScreen(),
        },
      ),
    );
  }
}
