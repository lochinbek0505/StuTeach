class TaskModel {
  String? id;
  String title;
  String description;

  String? fileUrl;

  TaskModel({this.id, required this.title, required this.description, this.fileUrl});
}
