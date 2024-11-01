import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CreateTaskScreen.dart';
import 'EditTaskScreen.dart'; // New screen for editing tasks
import 'SubmittedTasksPage.dart';

class TeacherDashboard extends StatefulWidget {
  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _removeTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  void _editTask(Map<String, dynamic> taskData, String taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditTaskScreen(taskData: taskData, taskId: taskId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Teacher Dashboard",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskScreen()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs;
          if (tasks.isEmpty) {
            return Center(child: Text("No tasks available."));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final taskData = tasks[index].data() as Map<String, dynamic>;
              final taskId = tasks[index].id; // Get task ID
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(
                      Icons.assignment,
                      size: 40,
                      color: Colors.blue,
                    ),
                    title: Text(
                      taskData['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(taskData['description']),
                        // SizedBox(height: 4),
                        Text(
                          '${((taskData['deadline'] as Timestamp).toDate()).toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editTask(taskData, taskId),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeTask(taskId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Task deleted successfully')),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Handle task tap (e.g., navigate to task details)
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubmittedTasksPage()),
                );
              },
            ),
            Text("Submitted Tasks"),
          ],
        ),
      ),
    );
  }
}
