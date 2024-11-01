import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmittedTasksPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Submitted Tasks",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('completed_tasks').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            final completedTasks = snapshot.data!.docs;
            return ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final taskData =
                    completedTasks[index].data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    color: Colors.green.shade100,
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(
                        Icons.assignment_turned_in,
                        size: 30,
                        color: Colors.green,
                      ),
                      title: Text(
                        taskData['title'] ?? 'Untitled Task',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Completed by: ${taskData['completedBy']}"),
                          SizedBox(height: 4),
                          Text(
                              "Completion Date: ${taskData['completedAt'].toDate().toString().split(' ')[0]}"),
                        ],
                      ),
                      onTap: () {
                        // Implement any additional action when clicking on a completed task
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
