import 'package:cloud_firestore/cloud_firestore.dart';
import 'TaskModel.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TaskModel>> getTasks() {
    return _firestore.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          fileUrl: doc['fileUrl'],
        );
      }).toList();
    });
  }
  Future<void> submitTask(String taskId, String fileUrl) async {
    await _firestore.collection('tasks').doc(taskId).collection('submissions').add({
      'fileUrl': fileUrl,
      'submittedAt': Timestamp.now(),
    });
  }

  Future<void> createTask(TaskModel task) async {
    await _firestore.collection('tasks').add({
      'title': task.title,
      'description': task.description,
      'fileUrl': task.fileUrl,
    });
  }
}
