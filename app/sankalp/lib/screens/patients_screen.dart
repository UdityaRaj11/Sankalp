import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sankalp/models/note.dart';
import 'package:sankalp/screens/note_screen.dart';
import 'package:sankalp/screens/read_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  @override
  Widget build(BuildContext context) {
    final noteModel = Provider.of<NoteModel>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 224, 224),
      body: noteModel.notes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wheelchair_pickup,
                    color: Color.fromARGB(255, 57, 132, 59),
                    size: 100,
                  ),
                  Text(
                    'Patients list can be viewed here',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: noteModel.notes.length,
              itemBuilder: (context, index) {
                final note = noteModel.notes[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReadScreen(notes: note.content),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Card(
                      child: ListTile(
                        title: Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text("${note.date.day}/${note.date.month}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            noteModel.deleteNote(note);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NoteScreen(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }
}
