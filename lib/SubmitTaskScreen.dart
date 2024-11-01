import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'TaskModel.dart';
import 'TaskService.dart';


class SubmitTaskScreen extends StatefulWidget {
  final TaskModel task;

  SubmitTaskScreen({required this.task});

  @override
  _SubmitTaskScreenState createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
  String? fileUrl;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.single;
      final ref = FirebaseStorage.instance.ref().child("submissions/${file.name}");
      await ref.putData(file.bytes!);
      fileUrl = await ref.getDownloadURL();
    }
  }

  void _submitTask() async {
    if (fileUrl != null) {
      await TaskService().submitTask(widget.task.id!, fileUrl!);
      Navigator.pop(context);
    } else {
      // You can add a message to inform the user to select a file
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select a file to submit."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Task Title: ${widget.task.title}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Description: ${widget.task.description}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text("Pick File to Submit"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTask,
              child: Text("Submit Task"),
            ),
          ],
        ),
      ),
    );
  }
}
