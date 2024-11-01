import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class CreateTaskScreen extends StatefulWidget {
  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _deadlineDate;
  String? _filePath;

  void _pickDeadlineDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _deadlineDate = pickedDate;
      });
    }
  }

  void _pickFinishDateTime(BuildContext context) async {
    final pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDateTime != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

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

  void _createTask() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _deadlineDate != null &&
        _filePath != null) {
      final task = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'createdAt': Timestamp.now(),
        // Set current date and time
        'deadline': Timestamp.fromDate(_deadlineDate!),
        // Convert DateTime to Firestore Timestamp
        // Store finish date and time
        'filePath': _filePath,
        // Store the file path
      };

      await FirebaseFirestore.instance.collection('tasks').add(task);

      // Optionally, navigate back or show a success message
      Navigator.pop(context);
    } else {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill in all fields and select a file."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text("Create Task",
      style: TextStyle(

        color: Colors.white

      ),),
      backgroundColor: Colors.blue,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Task Title',
                            hintText: 'Please enter task title',
                            prefixIcon: Icon(Icons.title),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Task Description',
                            hintText: 'Please enter task description',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Deadline Date',
                            hintText: _deadlineDate != null
                                ? _deadlineDate!
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]
                                : 'Select a date',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          onTap: () => _pickDeadlineDate(context),
                        ),
                        SizedBox(height: 16),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _uploadFile,
                          child: Text("Upload File"),
                        ),
                        SizedBox(height: 8),
                        if (_filePath != null) Text('Selected file: $_filePath'),
                        // Display the selected file path
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _createTask,
                          child: Text("Create Task"),
                        ),
                      ],
                    ),
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
