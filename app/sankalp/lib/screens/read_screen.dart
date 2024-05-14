import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:sankalp/models/note.dart';

class ReadScreen extends StatelessWidget {
  final String notes;
  const ReadScreen({required this.notes, Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Sankalp',
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          backgroundColor: const Color.fromARGB(255, 27, 46, 27),
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ))),
      backgroundColor: const Color.fromARGB(255, 224, 224, 224),
      body: Container(
        padding: EdgeInsets.only(
          left: width / 60,
          bottom: height / 8,
          top: height / 60,
          right: width / 60,
        ),
        child: Card(
          color: const Color.fromARGB(255, 255, 255, 133),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: ListView(
              children: _buildNotesList(notes),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () {},
        label: const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.white),
            SizedBox(width: 5),
            Text(
              'AI Suggestions',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildNotesList(String notes) {
  List<String> lines = notes.split('\n');
  List<Widget> widgets = [];

  for (String line in lines) {
    if (line.trim().isEmpty) {
      widgets.add(
        const SizedBox(height: 5),
      );
    } else {
      widgets.add(
        Container(
          padding: const EdgeInsets.all(5),
          child: MarkdownBody(
            data: line,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: Color.fromARGB(255, 36, 87, 38)),
              textScaler: const TextScaler.linear(1.2),
            ),
          ),
        ),
      );
    }
  }

  return widgets;
}
