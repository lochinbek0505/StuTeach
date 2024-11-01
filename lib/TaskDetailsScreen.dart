import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> taskData;
  final String taskId;

  TaskDetailsScreen({required this.taskData, required this.taskId});

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _userNameController = TextEditingController();
  String? _filePath; // For the file selected by the user

  // File picker function
  void _pickFile() async {
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
        _filePath = pickedFilePath;
      });
    }
  }

  Future<void> _confirmTaskCompletion() async {
    final userName = _userNameController.text.trim();

    if (userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your username")),
      );
      return;
    }

    final completedTask = {
      'title': widget.taskData['title'],
      'description': widget.taskData['description'],
      'deadline': widget.taskData['deadline'],
      'completedBy': userName,
      'completedAt': Timestamp.now(),
      'filePath': _filePath,
      'isApproved': true,
    };

    await _firestore
        .collection('tasks')
        .doc(widget.taskId)
        .update({'isApproved': true});
    await _firestore.collection('completed_tasks').add(completedTask);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Task Details",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: size.width / 1.1,
              height: size.height / 1.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.taskData['title'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text("Description: ${widget.taskData['description']}"),
                  SizedBox(height: 10),
                  Text(
                    '${((widget.taskData['deadline'] as Timestamp).toDate()).toLocal().toString().split(' ')[0]}',
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      labelText: "Enter your username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text("Upload File"),
                  ),
                  if (_filePath != null) ...[
                    SizedBox(height: 10),
                    Text("Selected File: ${_filePath!.split('/').last}"),
                  ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _confirmTaskCompletion,
                    child: Text(
                      "Confirm Task Completion",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
