import 'package:flutter/material.dart';
import 'dart:io';

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sankalp/models/note.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  File? _selectedFile;
  Future<String>? _notesFuture;
  bool _isLoading = false;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _uploadFile() async {
    if (_selectedFile == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:5000/generate_notes'),
    );
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      _selectedFile!.path,
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        _notesFuture = response.stream.bytesToString();
        _isLoading = false;
      });
      print('Uploaded successfully');
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to upload');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final noteModel = Provider.of<NoteModel>(context, listen: false);
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (_notesFuture == null && !_isLoading)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width / 3.5,
                    vertical: height / 3.7,
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.medical_information,
                          color: Color.fromARGB(255, 57, 132, 59), size: 100),
                    ],
                  ),
                ),
              ),
            if (_isLoading)
              Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width / 3.2,
                    vertical: height / 3.4,
                  ),
                  child: const CircularProgressIndicator())
            else if (_notesFuture != null)
              Expanded(
                child: Card(
                  color: const Color.fromARGB(255, 255, 255, 133),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: FutureBuilder<String>(
                      future: _notesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final Map<String, dynamic> data =
                              json.decode(snapshot.data!);
                          final String notes = data['notes'];
                          final String title = _extractTitle(notes);
                          noteModel.addNote(Note(
                            title: title,
                            content: notes,
                          ));
                          return ListView(
                            children: _buildNotesList(notes),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            Container(
              color: const Color.fromARGB(255, 27, 46, 27),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                children: [
                  if (_selectedFile != null)
                    Text(
                      'Selected file: ${_selectedFile!.path}',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 57, 132, 59),
                          fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filled(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.mic_rounded)),
                      OutlinedButton(
                        onPressed: _pickFile,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.audio_file,
                              color: Color.fromARGB(255, 112, 126, 112),
                            ),
                            SizedBox(width: width * 0.02),
                            const Text(
                              'Select Audio',
                              style: TextStyle(
                                color: Color.fromARGB(255, 112, 126, 112),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _uploadFile,
                        child: const Text('Upload',
                            style: TextStyle(
                              color: Color.fromARGB(255, 112, 126, 112),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractTitle(String notes) {
    List<String> lines = notes.split('\n');
    String title = '';

    String? patientLine = lines.firstWhere(
      (line) => line.trim().startsWith('**Patient:**'),
      orElse: () => '',
    );

    // If found, extract the title after "**Patient:**"
    if (patientLine != '') {
      title = patientLine.trim().substring('**Patient:**'.length).trim();
    }

    return title;
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
        widgets.add(Container(
          padding: const EdgeInsets.all(5),
          child: MarkdownBody(
            data: line,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: Color.fromARGB(255, 36, 87, 38)),
              textScaler: const TextScaler.linear(1.2),
            ),
          ),
        ));
      }
    }

    return widgets;
  }
}
