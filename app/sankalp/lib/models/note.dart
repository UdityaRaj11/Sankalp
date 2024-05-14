import 'package:flutter/material.dart';

class Note {
  final String title;
  final String content;
  final DateTime date = DateTime.now();

  Note({
    required this.title,
    required this.content,
  });
}

class NoteModel extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  void deleteNote(Note note) {
    _notes.remove(note);
    notifyListeners();
  }

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }
}
