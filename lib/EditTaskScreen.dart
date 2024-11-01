import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart'; // Import for file picker
import 'dart:io'; // Import for file handling

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> taskData;
  final String taskId;

  EditTaskScreen({required this.taskData, required this.taskId});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _finishDateTime;
  String? _filePath; // Variable to store the selected file path

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.taskData['title'];
    _descriptionController.text = widget.taskData['description'];
    _finishDateTime = (widget.taskData['deadline'] as Timestamp).toDate();
  }

  Future<void> _updateTask() async {
    await _firestore.collection('tasks').doc(widget.taskId).update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'deadline': Timestamp.fromDate(_finishDateTime!),
      'file_url': _filePath ?? widget.taskData['file_url'],
      // Update file URL if a new file is picked
    });

    Navigator.pop(context); // Return to previous screen after update
  }

  Future<void> _selectFinishDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _finishDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_finishDateTime ?? DateTime.now()),
      );
      if (timePicked != null) {
        setState(() {
          _finishDateTime = DateTime(picked.year, picked.month, picked.day,
              timePicked.hour, timePicked.minute);
        });
      }
    }
  }

  void _uploadFile() async {
    String? pickedFilePath = await FilePicker.platform.pickFiles(
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'doc',
        'docx',
        'mp3',
        'mp4',
        'txt'
      ],
      type: FileType.custom,
    ).then((result) => result?.files.single.path);

    if (pickedFilePath != null) {
      setState(() {
        _filePath = pickedFilePath; // Store the selected file path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Edit Task",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Task Title',
                            prefixIcon: Icon(Icons.title),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.title),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: () => _selectFinishDateTime(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Finish Date & Time',
                              hintText: _finishDateTime != null
                                  ? '${_finishDateTime!.toLocal().toString().split(' ')[0]} ${_finishDateTime!.hour}:${_finishDateTime!.minute}'
                                  : 'Select a date & time',
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _finishDateTime != null
                                  ? '${_finishDateTime!.toLocal().toString().split(' ')[0]} ${_finishDateTime!.hour}:${_finishDateTime!.minute}'
                                  : 'Select a date & time',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _uploadFile,
                        child: Text("Pick File"),
                      ),
                      if (_filePath != null) ...[
                        SizedBox(height: 10),
                        Text("Selected File: ${_filePath!.split('/').last}"),
                      ],
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateTask,
                        child: Text("Update Task"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
